package com.fazakkir.app.fazakkir

import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.content.Context
import android.content.Intent
import android.media.AudioAttributes
import android.media.AudioFocusRequest
import android.media.AudioManager
import android.media.MediaPlayer
import android.net.Uri
import android.os.Build
import android.os.IBinder
import android.provider.Settings
import android.util.Log
import androidx.core.app.NotificationCompat
import org.json.JSONObject
import java.io.File

class AdhanService : Service() {

    private var mediaPlayer: MediaPlayer? = null
    private var audioManager: AudioManager? = null
    private var focusRequest: AudioFocusRequest? = null
    private val CHANNEL_ID = "fazakkir_adhan_service"
    private val NOTIFICATION_ID = 1001

    // Receiver to handle volume button presses (Silence Adhan)
    private val volumeReceiver = object : android.content.BroadcastReceiver() {
        override fun onReceive(context: Context, intent: Intent) {
            if (intent.action == "android.media.VOLUME_CHANGED_ACTION") {
                try {
                    // Check if player exists and is playing before acting
                    if (mediaPlayer != null && mediaPlayer!!.isPlaying) {
                        Log.d("AdhanService", "Volume changed, stopping Adhan (Silence requested)")
                        // Stop playback immediately
                        mediaPlayer?.stop()
                        // Release resources
                        mediaPlayer?.release()
                        mediaPlayer = null
                        // Stop the service
                        stopSelf()
                    }
                } catch (e: Exception) {
                    Log.e("AdhanService", "Error in volume receiver: ${e.message}")
                }
            }
        }
    }

    companion object {
        const val ACTION_STOP = "com.fazakkir.app.fazakkir.ACTION_STOP"
        const val ACTION_OPEN_MUSHAF = "com.fazakkir.app.fazakkir.ACTION_OPEN_MUSHAF"
        const val ACTION_UPDATE_LOCATION = "com.fazakkir.app.fazakkir.ACTION_UPDATE_LOCATION"
    }

    override fun onBind(intent: Intent?): IBinder? {
        return null
    }

    override fun onCreate() {
        super.onCreate()
        createNotificationChannel()
        audioManager = getSystemService(Context.AUDIO_SERVICE) as AudioManager
        
        // Register Volume Receiver
        val filter = android.content.IntentFilter("android.media.VOLUME_CHANGED_ACTION")
        registerReceiver(volumeReceiver, filter)
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        Log.d("AdhanService", "onStartCommand action: ${intent?.action}")

        if (intent?.action == ACTION_STOP) {
            stopSelf()
            return START_NOT_STICKY
        }

        // CRITICAL: Must start foreground immediately to avoid ANR/Crash
        createNotificationChannel() // Ensure channel exists
        
        // Default values for immediate notification
        var title = "Fazakkir"
        var body = "Adhan Service"
        var prayerName = "Adhan"
        var hijriDate = ""
        var deeplink = "/adhan"
        var audioPath: String? = null
        var notificationType = "adhan"

        // Extract payload if available
        val payloadJson = intent?.getStringExtra("payload")
        if (payloadJson != null) {
            try {
                val json = JSONObject(payloadJson)
                title = json.optString("title", title)
                body = json.optString("body", body)
                // optString returns "" for missing/empty values, convert to null
                val audioPathRaw = json.optString("audioAssetPath", "")
                audioPath = if (audioPathRaw.isEmpty()) null else audioPathRaw
                prayerName = json.optString("prayerName", prayerName)
                hijriDate = json.optString("hijriDate", hijriDate)
                deeplink = json.optString("deeplink", deeplink)
                notificationType = json.optString("notificationType", "adhan")
                
                Log.d("AdhanService", "=== PAYLOAD PARSED ===")
                Log.d("AdhanService", "Type: $notificationType")
                Log.d("AdhanService", "Audio Path: '$audioPath'")
                Log.d("AdhanService", "Audio Path Length: ${audioPath?.length ?: 0}")
                Log.d("AdhanService", "Audio Path isEmpty: ${audioPath?.isEmpty() ?: true}")
                Log.d("AdhanService", "======================")
            } catch (e: Exception) {
                Log.e("AdhanService", "Error parsing payload: ${e.message}")
            }
        }

        // Build Notification
        val notification = buildNotification(title, body, prayerName, hijriDate, deeplink, notificationType)

        // Start Foreground immediately
        try {
             if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                startForeground(NOTIFICATION_ID, notification, android.content.pm.ServiceInfo.FOREGROUND_SERVICE_TYPE_MEDIA_PLAYBACK)
            } else {
                startForeground(NOTIFICATION_ID, notification)
            }
        } catch (e: Exception) {
             Log.e("AdhanService", "Error starting foreground: ${e.message}")
             // If we can't start foreground, we must stop to allow system to clean up
             stopSelf()
             return START_NOT_STICKY
        }

        // Request Audio Focus
        if (!requestAudioFocus()) {
            Log.w("AdhanService", "Audio focus denied")
        }

        // Play Audio
        playAudio(audioPath)

        return START_NOT_STICKY
    }

    private fun buildNotification(title: String, body: String, prayerName: String, hijriDate: String, deeplink: String, notificationType: String): android.app.Notification {
        // Stop Action
        val stopIntent = Intent(this, AdhanService::class.java).apply {
            action = ACTION_STOP
        }
        val stopPendingIntent = PendingIntent.getService(this, 0, stopIntent, PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE)

        // Open App Action (Deep Link)
        val openAppIntent = packageManager.getLaunchIntentForPackage(packageName)?.apply {
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TASK
            putExtra("route", deeplink)
        }
        val openAppPendingIntent = PendingIntent.getActivity(this, 1, openAppIntent, PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE)

        // Update Location Action
        val locationIntent = packageManager.getLaunchIntentForPackage(packageName)?.apply {
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TASK
            putExtra("route", "/location_settings")
        }
        val locationPendingIntent = PendingIntent.getActivity(this, 2, locationIntent, PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE)

        val contentText = if (hijriDate.isNotEmpty()) "$hijriDate\n$body" else body
        
        // Adjust notification title based on type
        val notificationTitle = when (notificationType) {
            "prophet_reminder", "pre_prayer_reminder" -> title
            else -> "Fazakkir • $prayerName"
        }

        return NotificationCompat.Builder(this, CHANNEL_ID)
            .setContentTitle(notificationTitle)
            .setContentText(contentText)
            .setSmallIcon(R.drawable.ic_stat_notify)
            .setPriority(NotificationCompat.PRIORITY_MAX)
            .setCategory(NotificationCompat.CATEGORY_ALARM)
            .setVisibility(NotificationCompat.VISIBILITY_PUBLIC)
            .setOngoing(false) // Allow swipe to dismiss
            .setDeleteIntent(stopPendingIntent) // Stop service on swipe
            .setContentIntent(openAppPendingIntent)
            .setStyle(androidx.media.app.NotificationCompat.MediaStyle())
            .build()
    }

    private fun requestAudioFocus(): Boolean {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            focusRequest = AudioFocusRequest.Builder(AudioManager.AUDIOFOCUS_GAIN_TRANSIENT_MAY_DUCK)
                .setAudioAttributes(
                    AudioAttributes.Builder()
                        .setUsage(AudioAttributes.USAGE_ALARM)
                        .setContentType(AudioAttributes.CONTENT_TYPE_SONIFICATION)
                        .build()
                )
                .setAcceptsDelayedFocusGain(true)
                .setOnAudioFocusChangeListener { focusChange ->
                    when (focusChange) {
                        AudioManager.AUDIOFOCUS_LOSS -> stopSelf()
                        AudioManager.AUDIOFOCUS_LOSS_TRANSIENT -> mediaPlayer?.pause()
                        AudioManager.AUDIOFOCUS_LOSS_TRANSIENT_CAN_DUCK -> mediaPlayer?.setVolume(0.1f, 0.1f)
                        AudioManager.AUDIOFOCUS_GAIN -> {
                            mediaPlayer?.setVolume(1.0f, 1.0f)
                            if (mediaPlayer?.isPlaying == false) mediaPlayer?.start()
                        }
                    }
                }
                .build()
            return audioManager?.requestAudioFocus(focusRequest!!) == AudioManager.AUDIOFOCUS_REQUEST_GRANTED
        } else {
            @Suppress("DEPRECATION")
            return audioManager?.requestAudioFocus(
                null,
                AudioManager.STREAM_ALARM,
                AudioManager.AUDIOFOCUS_GAIN_TRANSIENT_MAY_DUCK
            ) == AudioManager.AUDIOFOCUS_REQUEST_GRANTED
        }
    }

    private fun abandonAudioFocus() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            focusRequest?.let { audioManager?.abandonAudioFocusRequest(it) }
        } else {
            @Suppress("DEPRECATION")
            audioManager?.abandonAudioFocus(null)
        }
    }

    private fun playAudio(path: String?) {
        Log.d("AdhanService", "=== playAudio called with path: $path ===")
        try {
            mediaPlayer?.release()
            
            mediaPlayer = MediaPlayer().apply {
                setAudioAttributes(
                    AudioAttributes.Builder()
                        .setUsage(AudioAttributes.USAGE_ALARM)
                        .setContentType(AudioAttributes.CONTENT_TYPE_SONIFICATION)
                        .build()
                )
                
                var dataSourceSet = false
                
                if (path != null && path.isNotEmpty()) {
                    Log.d("AdhanService", "Path is not null/empty: $path")
                    val file = File(path)
                    if (file.exists() && file.canRead()) {
                        Log.d("AdhanService", "Playing from file: $path")
                        setDataSource(this@AdhanService, Uri.fromFile(file))
                        dataSourceSet = true
                    } else if (path.startsWith("flutter_assets/") || path.startsWith("assets/")) {
                         try {
                            // Try raw path first, then with flutter_assets/ prefix
                            var assetPath = path
                            if (!path.startsWith("flutter_assets/")) {
                                assetPath = "flutter_assets/$path"
                            }
                            
                            Log.d("AdhanService", "Attempting to play asset: $assetPath")
                            val assetDescriptor = assets.openFd(assetPath)
                            setDataSource(assetDescriptor.fileDescriptor, assetDescriptor.startOffset, assetDescriptor.length)
                            dataSourceSet = true
                            Log.d("AdhanService", "Successfully loaded asset: $assetPath")
                        } catch (e: Exception) {
                            Log.e("AdhanService", "Asset not found: $path. Error: ${e.message}", e)
                            // Fallback: try listing assets to find a match? (Too expensive). 
                            // Just log error for now, default alarm will play.
                        }
                    } else {
                        Log.w("AdhanService", "Path doesn't match file or asset pattern: $path")
                    }
                } else {
                    Log.d("AdhanService", "Path is null or empty")
                }
                
                if (!dataSourceSet) {
                    Log.d("AdhanService", "Playing default alarm sound")
                    setDataSource(this@AdhanService, Settings.System.DEFAULT_ALARM_ALERT_URI)
                }
                
                prepare()
                start()
                setOnCompletionListener {
                    stopSelf()
                }
                setOnErrorListener { _, what, extra ->
                    Log.e("AdhanService", "MediaPlayer Error: $what, $extra")
                    stopSelf()
                    true
                }
            }
        } catch (e: Exception) {
            Log.e("AdhanService", "Error playing audio: ${e.message}", e)
            stopSelf()
        }
    }

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val serviceChannel = NotificationChannel(
                CHANNEL_ID,
                "Adhan Service Channel",
                NotificationManager.IMPORTANCE_HIGH
            ).apply {
                description = "Channel for Adhan playback and controls"
                setSound(null, null) // Silent channel, we play media manually
            }
            val manager = getSystemService(NotificationManager::class.java)
            manager.createNotificationChannel(serviceChannel)
        }
    }

    override fun onDestroy() {
        try {
            unregisterReceiver(volumeReceiver)
        } catch (e: Exception) {
            // Receiver might not be registered or already unregistered
        }
        abandonAudioFocus()
        try {
            mediaPlayer?.release()
            mediaPlayer = null
        } catch (e: Exception) {
             Log.e("AdhanService", "Error releasing media player: ${e.message}")
        }
        super.onDestroy()
    }
}
