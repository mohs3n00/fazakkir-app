package com.fazakkir.app.fazakkir

import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.Service
import android.content.Intent
import android.os.Build
import android.os.IBinder
import androidx.core.app.NotificationCompat

class KeepAliveService : Service() {

    private val CHANNEL_ID = "fazakkir_keep_alive"
    private val NOTIFICATION_ID = 999

    override fun onBind(intent: Intent?): IBinder? {
        return null
    }

    override fun onCreate() {
        super.onCreate()
        createNotificationChannel()
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        val action = intent?.action
        
        // Read from Intent
        var prayerName = intent?.getStringExtra("prayerName")
        var nextPrayerTimeMillis = intent?.getLongExtra("nextPrayerTimeMillis", 0L) ?: 0L
        var hijriDate = intent?.getStringExtra("hijriDate")
        var currentLocation = intent?.getStringExtra("currentLocation")
        var prayerTimeFormatted = intent?.getStringExtra("prayerTimeFormatted")

        // Store/Read from SharedPreferences
        val prefs = applicationContext.getSharedPreferences("fazakkir_service_prefs", android.content.Context.MODE_PRIVATE)
        
        if (action == "com.fazakkir.app.fazakkir.ACTION_UPDATE_CONTENT" && prayerName != null && nextPrayerTimeMillis > 0) {
            // Update Prefs
            with(prefs.edit()) {
                putString("prayerName", prayerName)
                putLong("nextPrayerTimeMillis", nextPrayerTimeMillis)
                putString("hijriDate", hijriDate ?: "")
                putString("currentLocation", currentLocation ?: "")
                putString("prayerTimeFormatted", prayerTimeFormatted ?: "")
                apply()
            }
        } else {
            // Restore from Prefs if intent data missing
            if (prayerName == null || nextPrayerTimeMillis == 0L) {
                prayerName = prefs.getString("prayerName", "جاري التحميل...") ?: "جاري التحميل..."
                nextPrayerTimeMillis = prefs.getLong("nextPrayerTimeMillis", 0L)
                hijriDate = prefs.getString("hijriDate", "")
                currentLocation = prefs.getString("currentLocation", "")
                prayerTimeFormatted = prefs.getString("prayerTimeFormatted", "")
            }
        }

        // Create Custom Views
        val collapsedView = android.widget.RemoteViews(packageName, R.layout.notification_keep_alive_collapsed)
        val expandedView = android.widget.RemoteViews(packageName, R.layout.notification_keep_alive_expanded)

        // Determine Content Text
        val headerText = "${hijriDate ?: ""} | ${currentLocation ?: ""}"
        val contentText = "$prayerName ${prayerTimeFormatted ?: ""}"

        // Update Collapsed
        collapsedView.setTextViewText(R.id.notification_header_text, headerText)
        collapsedView.setTextViewText(R.id.notification_content_text, contentText)
        
        // Update Expanded
        expandedView.setTextViewText(R.id.notification_header_text_expanded, headerText)
        expandedView.setTextViewText(R.id.notification_content_text_expanded, contentText)

        // Set Timer Logic (Critical Fix)
        // Chronometer base must be in ELAPSED_REALTIME timebase
        if (nextPrayerTimeMillis > System.currentTimeMillis()) {
            val timeRemaining = nextPrayerTimeMillis - System.currentTimeMillis()
            val triggerAtRealtime = android.os.SystemClock.elapsedRealtime() + timeRemaining
            
            // Collapsed
            collapsedView.setChronometer(R.id.notification_timer, triggerAtRealtime, null, true)
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
                collapsedView.setChronometerCountDown(R.id.notification_timer, true)
            }
            collapsedView.setViewVisibility(R.id.notification_timer, android.view.View.VISIBLE)
            
            // Expanded
            expandedView.setChronometer(R.id.notification_timer_expanded, triggerAtRealtime, null, true)
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
                expandedView.setChronometerCountDown(R.id.notification_timer_expanded, true)
            }
            expandedView.setViewVisibility(R.id.notification_timer_expanded, android.view.View.VISIBLE)
        } else {
            // Time passed
            collapsedView.setTextViewText(R.id.notification_timer, "الآن")
            expandedView.setTextViewText(R.id.notification_timer_expanded, "الآن")
        }

        // PendingIntent for Open App (General)
        val openIntent = packageManager.getLaunchIntentForPackage(packageName)
        openIntent?.flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP or Intent.FLAG_ACTIVITY_SINGLE_TOP
        val openPendingIntent = android.app.PendingIntent.getActivity(
            this, 0, openIntent, android.app.PendingIntent.FLAG_IMMUTABLE or android.app.PendingIntent.FLAG_UPDATE_CURRENT
        )
        
        // PendingIntent for Open Quran
        val quranIntent = packageManager.getLaunchIntentForPackage(packageName)
        quranIntent?.flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP or Intent.FLAG_ACTIVITY_SINGLE_TOP
        quranIntent?.putExtra("route", "quran")
        quranIntent?.action = "OPEN_QURAN"
        
        val quranPendingIntent = android.app.PendingIntent.getActivity(
            this, 1, quranIntent, android.app.PendingIntent.FLAG_IMMUTABLE or android.app.PendingIntent.FLAG_UPDATE_CURRENT
        )
        
        // Collapsed Clicks
        collapsedView.setOnClickPendingIntent(R.id.notification_content_text, openPendingIntent)
        
        // Expanded Clicks
        expandedView.setOnClickPendingIntent(R.id.notification_content_text_expanded, openPendingIntent)
        expandedView.setOnClickPendingIntent(R.id.notification_btn_refresh, openPendingIntent) // Just open app for now
        expandedView.setOnClickPendingIntent(R.id.notification_btn_open, quranPendingIntent)
        
        val notification = NotificationCompat.Builder(this, CHANNEL_ID)
            .setSmallIcon(R.mipmap.ic_launcher)
            .setCustomContentView(collapsedView)
            .setCustomBigContentView(expandedView)
            .setPriority(NotificationCompat.PRIORITY_LOW)
            .setCategory(NotificationCompat.CATEGORY_SERVICE)
            .setOngoing(true)
            .setStyle(NotificationCompat.DecoratedCustomViewStyle())
            .setContentIntent(openPendingIntent)
            .build()

        startForeground(NOTIFICATION_ID, notification)
        
        return START_STICKY
    }

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val serviceChannel = NotificationChannel(
                CHANNEL_ID,
                "Fazakkir Active Service",
                NotificationManager.IMPORTANCE_LOW 
            ).apply {
                description = "Keeps the app active for reliable notifications"
                setShowBadge(false)
            }
            val manager = getSystemService(NotificationManager::class.java)
            manager.createNotificationChannel(serviceChannel)
        }
    }
}
