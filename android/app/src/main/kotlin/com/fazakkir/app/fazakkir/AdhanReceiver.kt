package com.fazakkir.app.fazakkir

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.os.Build
import android.os.PowerManager
import android.util.Log
import androidx.core.content.ContextCompat

class AdhanReceiver : BroadcastReceiver() {

    private val shortAthkar = listOf(
        "سبحان الله",
        "الحمد لله",
        "لا إله إلا الله",
        "الله أكبر",
        "سبحان الله وبحمده",
        "سبحان الله العظيم",
        "استغفر الله",
        "لا حول ولا قوة إلا بالله",
        "اللهم صل وسلم على نبينا محمد",
        "سبحان الله وبحمده، سبحان الله العظيم",
        "لا إله إلا الله وحده لا شريك له",
        "رضيت بالله رباً وبالإسلام ديناً وبمحمد نبياً",
        "يا حي يا قيوم برحمتك أستغيث"
    )

    override fun onReceive(context: Context, intent: Intent) {
        Log.d("AdhanReceiver", "Alarm received for id: ${intent.getIntExtra("id", 0)}")

        val id = intent.getIntExtra("id", 0)
        val payloadStr = intent.getStringExtra("payload")
        var type = "adhan"
        var title = "Fazakkir"
        var body = "Reminder"
        var deeplink = ""
        var audioAssetPath = ""

        if (payloadStr != null) {
            try {
                val json = org.json.JSONObject(payloadStr)
                type = json.optString("notificationType", "adhan")
                title = json.optString("title", title)
                body = json.optString("body", body)
                deeplink = json.optString("deeplink", "")
                audioAssetPath = json.optString("audioAssetPath", "")
            } catch (e: Exception) {
                Log.e("AdhanReceiver", "Error parsing payload: ${e.message}")
            }
        }

        if (type == "prophet_reminder" || type == "pre_prayer_reminder") {
            // Handle Prophet and Pre-Prayer Reminders with Audio Service (like Adhan)
            startAdhanService(context, intent)
        } else if (type == "reminder") {
            // --- Dynamic Content Logic (User Request: Cycle Athkar) ---
            if (id == 3000 || title == "ذكرني بالله") {
                body = shortAthkar.random()
            }
            // Handle Standard Reminder (Default Sound)
            showStandardNotification(context, id, title, body, deeplink)
        } else {
            // Handle Adhan (Audio Service)
            startAdhanService(context, intent)
        }
        
        // --- Repeating Alarm Logic ---
        val repeatInterval = intent.getLongExtra("repeatInterval", 0L)
        if (repeatInterval > 0) {
            val nextTrigger = System.currentTimeMillis() + repeatInterval
            Log.d("AdhanReceiver", "Rescheduling repeating alarm $id for +$repeatInterval ms at $nextTrigger")
            
            // We need to use AdhanScheduler to schedule the next one
            // Ideally we should reuse the existing AdhanScheduler class but it takes context
            // We can just replicate the basic exact alarm logic here or instantiate AdhanScheduler
            try {
                val scheduler = AdhanScheduler(context)
                // We need to pass the same payload back
                scheduler.scheduleExact(id, nextTrigger, payloadStr ?: "{}", repeatInterval)
            } catch (e: Exception) {
                Log.e("AdhanReceiver", "Failed to reschedule alarm $id: ${e.message}")
            }
        }
    }

    private fun showProphetNotification(context: Context, id: Int, title: String, body: String, deeplink: String, audioAssetPath: String) {
        val soundFilename = if (audioAssetPath.isNotEmpty()) java.io.File(audioAssetPath).name else "default"
        // Sanitize filename for channel ID (replace spaces and non-alphanumeric chars)
        val sanitizedName = soundFilename.replace(Regex("[^a-zA-Z0-9]"), "_")
        val channelId = "fazakkir_prophet_$sanitizedName"

        val notificationManager = context.getSystemService(Context.NOTIFICATION_SERVICE) as android.app.NotificationManager

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            // Check if channel exists. If not, create it
            // Note: We cannot check checking specific sound, but assume ID maps to sound unique-ly.
            if (notificationManager.getNotificationChannel(channelId) == null) {
                Log.d("AdhanReceiver", "Creating new channel: $channelId for sound: $soundFilename")
                
                // Prepare Audio File from Assets
                val soundUri = prepareSoundUri(context, audioAssetPath, soundFilename)
                
                val channel = android.app.NotificationChannel(
                    channelId,
                    "Prophet Reminder - $soundFilename",
                    android.app.NotificationManager.IMPORTANCE_DEFAULT
                ).apply {
                    description = "Reminder to pray for the Prophet"
                    if (soundUri != null) {
                        val audioAttributes = android.media.AudioAttributes.Builder()
                            .setContentType(android.media.AudioAttributes.CONTENT_TYPE_SONIFICATION)
                            .setUsage(android.media.AudioAttributes.USAGE_NOTIFICATION)
                            .build()
                        setSound(soundUri, audioAttributes)
                    }
                    enableVibration(true)
                    enableLights(true)
                }
                notificationManager.createNotificationChannel(channel)
            }
        }

        // Build Notification
        val contentIntent = context.packageManager.getLaunchIntentForPackage(context.packageName)?.apply {
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TASK
            putExtra("route", deeplink)
        }
        val pendingIntent = android.app.PendingIntent.getActivity(
            context,
            id,
            contentIntent,
            android.app.PendingIntent.FLAG_UPDATE_CURRENT or android.app.PendingIntent.FLAG_IMMUTABLE
        )

        val builder = androidx.core.app.NotificationCompat.Builder(context, channelId)
            .setSmallIcon(R.drawable.ic_stat_notify)
            .setContentTitle(title)
            .setContentText(body)
            .setContentIntent(pendingIntent)
            .setPriority(androidx.core.app.NotificationCompat.PRIORITY_DEFAULT)
            .setAutoCancel(true)
            .setOnlyAlertOnce(true)
            
        // Do NOT setSound on builder if channel has it, but for pre-O devices we might need it.
        // However, user specifically asked to NOT use setSound for Channel conflict reasons.
        // For pre-O, channels don't exist, so setSound on builder IS required.
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) {
             val soundUri = prepareSoundUri(context, audioAssetPath, soundFilename)
             if (soundUri != null) {
                 builder.setSound(soundUri)
             }
        }

        notificationManager.notify(id, builder.build())
        Log.d("AdhanReceiver", "Shown prophet notification on channel: $channelId")
    }

    private fun prepareSoundUri(context: Context, assetPath: String, filename: String): android.net.Uri? {
        if (assetPath.isEmpty()) {
            Log.w("AdhanReceiver", "Asset path is empty, returning default sound URI")
            return android.provider.Settings.System.DEFAULT_NOTIFICATION_URI
        }

        try {
            // Target file in internal storage
            val soundsDir = java.io.File(context.filesDir, "sounds")
            if (!soundsDir.exists()) soundsDir.mkdirs()
            
            // Validate filename to prevent path traversal
            val safeFilename = java.io.File(filename).name
            val targetFile = java.io.File(soundsDir, safeFilename)

            Log.d("AdhanReceiver", "Preparing sound: $assetPath -> $targetFile")
            
            // If file doesn't exist, copy from assets
            if (!targetFile.exists()) {
                // Try to find the asset
                // Flutter assets are usually in "flutter_assets/"
                // normalize path separators
                val normalizedPath = assetPath.replace("\\", "/")
                val flutterAssetPath = "flutter_assets/$normalizedPath"
                
                Log.d("AdhanReceiver", "Attempting to open asset: $flutterAssetPath")
                
                try {
                    context.assets.open(flutterAssetPath).use { inputStream ->
                        java.io.FileOutputStream(targetFile).use { outputStream ->
                            inputStream.copyTo(outputStream)
                        }
                    }
                    Log.d("AdhanReceiver", "Copied asset $flutterAssetPath to ${targetFile.absolutePath}")
                } catch (e: java.io.FileNotFoundException) {
                     Log.e("AdhanReceiver", "Asset not found: $flutterAssetPath. Trying fallback without folder prefix...")
                     // Fallback: Try just filename if path fails (unlikely for Flutter but good for safety)
                     try {
                        context.assets.open("flutter_assets/$safeFilename").use { inputStream ->
                            java.io.FileOutputStream(targetFile).use { outputStream ->
                                inputStream.copyTo(outputStream)
                            }
                        }
                        Log.d("AdhanReceiver", "Copied asset fallback $safeFilename to ${targetFile.absolutePath}")
                     } catch (e2: Exception) {
                         Log.e("AdhanReceiver", "Asset fallback failed: ${e2.message}")
                         return android.provider.Settings.System.DEFAULT_NOTIFICATION_URI
                     }
                }
            } else {
                 Log.d("AdhanReceiver", "File already exists: ${targetFile.absolutePath}")
            }
            
            // Get Content URI using FileProvider
            val authority = "${context.packageName}.fileprovider"
            val uri = androidx.core.content.FileProvider.getUriForFile(context, authority, targetFile)
            
            Log.d("AdhanReceiver", "Generated URI: $uri")
            
            // Grant permission to Notification System (System UI)
            context.grantUriPermission("com.android.systemui", uri, Intent.FLAG_GRANT_READ_URI_PERMISSION)
            
            return uri
        } catch (e: Exception) {
            Log.e("AdhanReceiver", "Error preparing sound URI: ${e.message}", e)
            // Fallback to default
            return android.provider.Settings.System.DEFAULT_NOTIFICATION_URI
        }
    }

    private fun showPrePrayerNotification(context: Context, id: Int, title: String, body: String, deeplink: String, audioAssetPath: String) {
        val channelId = "fazakkir_pre_prayer"
        val notificationManager = context.getSystemService(Context.NOTIFICATION_SERVICE) as android.app.NotificationManager

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            // Check if channel exists. If not, create it
            if (notificationManager.getNotificationChannel(channelId) == null) {
                Log.d("AdhanReceiver", "Creating new channel: $channelId for Pre-Prayer Reminder")
                
                // Prepare Audio File from Assets
                val soundUri = prepareSoundUri(context, audioAssetPath, "pre_prayer_reminder.mp3")
                
                val channel = android.app.NotificationChannel(
                    channelId,
                    "Pre-Prayer Reminder",
                    android.app.NotificationManager.IMPORTANCE_HIGH
                ).apply {
                    description = "Reminder before prayer time"
                    if (soundUri != null) {
                        val audioAttributes = android.media.AudioAttributes.Builder()
                            .setContentType(android.media.AudioAttributes.CONTENT_TYPE_SONIFICATION)
                            .setUsage(android.media.AudioAttributes.USAGE_NOTIFICATION)
                            .build()
                        setSound(soundUri, audioAttributes)
                    }
                    enableVibration(true)
                    enableLights(true)
                }
                notificationManager.createNotificationChannel(channel)
            }
        }

        // Build Notification
        val contentIntent = context.packageManager.getLaunchIntentForPackage(context.packageName)?.apply {
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TASK
            putExtra("route", deeplink)
        }
        val pendingIntent = android.app.PendingIntent.getActivity(
            context,
            id,
            contentIntent,
            android.app.PendingIntent.FLAG_UPDATE_CURRENT or android.app.PendingIntent.FLAG_IMMUTABLE
        )

        val builder = androidx.core.app.NotificationCompat.Builder(context, channelId)
            .setSmallIcon(R.drawable.ic_stat_notify)
            .setContentTitle(title)
            .setContentText(body)
            .setContentIntent(pendingIntent)
            .setPriority(androidx.core.app.NotificationCompat.PRIORITY_HIGH)
            .setAutoCancel(true)
            .setOnlyAlertOnce(false)
            
        // For pre-O devices, set sound on builder
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) {
             val soundUri = prepareSoundUri(context, audioAssetPath, "pre_prayer_reminder.mp3")
             if (soundUri != null) {
                 builder.setSound(soundUri)
             }
        }

        notificationManager.notify(id, builder.build())
        Log.d("AdhanReceiver", "Shown pre-prayer notification on channel: $channelId")
    }


    private fun showStandardNotification(context: Context, id: Int, title: String, body: String, deeplink: String) {
        val channelId = "fazakkir_reminders_default_v3" // Changed ID to force update settings on devices
        val notificationManager = context.getSystemService(Context.NOTIFICATION_SERVICE) as android.app.NotificationManager

        // Create Channel if needed
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = android.app.NotificationChannel(
                channelId,
                "Reminders",
                android.app.NotificationManager.IMPORTANCE_DEFAULT // DEFAULT importance = Sound + Icon, no popup
            ).apply {
                description = "Standard notifications for Athkar and Sunnah"
                // Use Default Notification Sound
                val soundUri = android.provider.Settings.System.DEFAULT_NOTIFICATION_URI
                val audioAttributes = android.media.AudioAttributes.Builder()
                    .setContentType(android.media.AudioAttributes.CONTENT_TYPE_SONIFICATION)
                    .setUsage(android.media.AudioAttributes.USAGE_NOTIFICATION)
                    .build()
                setSound(soundUri, audioAttributes)
                enableVibration(true)
                enableLights(true)
            }
            notificationManager.createNotificationChannel(channel)
        }

        // Content Intent with Deep Link
        val contentIntent = context.packageManager.getLaunchIntentForPackage(context.packageName)?.apply {
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TASK
            putExtra("route", deeplink)
            putExtra("payload", deeplink) // redundancy
        }
        val pendingIntent = android.app.PendingIntent.getActivity(
            context,
            id,
            contentIntent,
            android.app.PendingIntent.FLAG_UPDATE_CURRENT or android.app.PendingIntent.FLAG_IMMUTABLE
        )

        // Use BigTextStyle to show full Athkar if long
        val bigTextStyle = androidx.core.app.NotificationCompat.BigTextStyle()
            .bigText(body)

        val notification = androidx.core.app.NotificationCompat.Builder(context, channelId)
            .setSmallIcon(R.drawable.ic_stat_notify)
            .setContentTitle(title)
            .setContentText(body)
            .setStyle(bigTextStyle)
            .setContentIntent(pendingIntent)
            .setPriority(androidx.core.app.NotificationCompat.PRIORITY_DEFAULT)
            .setCategory(androidx.core.app.NotificationCompat.CATEGORY_REMINDER)
            .setAutoCancel(true)
            .setOnlyAlertOnce(true)
            .build()

        notificationManager.notify(id, notification)
        Log.d("AdhanReceiver", "Shown standard notification for $id with body: $body")
    }

    private fun startAdhanService(context: Context, intent: Intent) {
        // Acquire WakeLock
        val powerManager = context.getSystemService(Context.POWER_SERVICE) as PowerManager
        val wakeLock = powerManager.newWakeLock(
            PowerManager.PARTIAL_WAKE_LOCK,
            "Fazakkir:AdhanWakeLock"
        )
        wakeLock.acquire(30 * 1000L)

        try {
            val id = intent.getIntExtra("id", 0)
            val payload = intent.getStringExtra("payload")

            val serviceIntent = Intent(context, AdhanService::class.java).apply {
                putExtra("id", id)
                putExtra("payload", payload)
                action = "com.fazakkir.app.fazakkir.ACTION_START_ADHAN"
            }

            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                ContextCompat.startForegroundService(context, serviceIntent)
            } else {
                context.startService(serviceIntent)
            }
            Log.d("AdhanReceiver", "Service start intent sent")

        } catch (e: Exception) {
            Log.e("AdhanReceiver", "Failed to start service: ${e.message}", e)
        }
        // WakeLock timeout handles release
    }
}
