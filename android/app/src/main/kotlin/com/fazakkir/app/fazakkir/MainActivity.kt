package com.fazakkir.app.fazakkir

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.os.Build
import kotlinx.coroutines.launch

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.fazakkir.app/adhan_scheduler"

    override fun onNewIntent(intent: android.content.Intent) {
        super.onNewIntent(intent)
        this.intent = intent
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        val scheduler = AdhanScheduler(this)

        val mainScope = kotlinx.coroutines.CoroutineScope(kotlinx.coroutines.Dispatchers.Main)
        val ioScope = kotlinx.coroutines.CoroutineScope(kotlinx.coroutines.Dispatchers.IO)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            ioScope.launch {
                try {
                    when (call.method) {
                        "scheduleExact" -> {
                            val id = call.argument<Int>("id") ?: 0
                            val triggerAtMillis = call.argument<Number>("triggerAtMillis")?.toLong() ?: 0L
                            val payload = call.argument<String>("payload") ?: "{}"
                            val repeatInterval = call.argument<Number>("repeatInterval")?.toLong() ?: 0L
                            android.util.Log.d("MainActivity", "Scheduling exact alarm: $id at $triggerAtMillis")
                            scheduler.scheduleExact(id, triggerAtMillis, payload, repeatInterval)
                            mainScope.launch { result.success(true) }
                        }
                        "cancel" -> {
                            val id = call.argument<Int>("id") ?: 0
                            scheduler.cancel(id)
                            mainScope.launch { result.success(true) }
                        }
                        "cancelAll" -> {
                            scheduler.cancelAll()
                            mainScope.launch { result.success(true) }
                        }
                        "canScheduleExactAlarms" -> {
                            val canSchedule = scheduler.canScheduleExactAlarms()
                            mainScope.launch { result.success(canSchedule) }
                        }
                        "requestExactAlarmPermission" -> {
                            scheduler.requestExactAlarmPermission()
                            mainScope.launch { result.success(true) }
                        }
                        "getScheduledAlarms" -> {
                            val alarms = scheduler.getScheduledAlarmsMap()
                            mainScope.launch { result.success(alarms) }
                        }
                        "startKeepAlive" -> {
                            val intent = android.content.Intent(this@MainActivity, KeepAliveService::class.java)
                            if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.O) {
                                startForegroundService(intent)
                            } else {
                                startService(intent)
                            }
                            mainScope.launch { result.success(true) }
                        }
                        "stopKeepAlive" -> {
                            val intent = android.content.Intent(this@MainActivity, KeepAliveService::class.java)
                            stopService(intent)
                            mainScope.launch { result.success(true) }
                        }
                        "updateKeepAliveContent" -> {
                            val prayerName = call.argument<String>("prayerName") ?: ""
                            val nextPrayerTimeMillis = call.argument<Number>("nextPrayerTimeMillis")?.toLong() ?: 0L
                            val hijriDate = call.argument<String>("hijriDate") ?: ""
                            val currentLocation = call.argument<String>("currentLocation") ?: ""
                            val prayerTimeFormatted = call.argument<String>("prayerTimeFormatted") ?: ""
                            
                            val intent = android.content.Intent(this@MainActivity, KeepAliveService::class.java).apply {
                                action = "com.fazakkir.app.fazakkir.ACTION_UPDATE_CONTENT"
                                putExtra("prayerName", prayerName)
                                putExtra("nextPrayerTimeMillis", nextPrayerTimeMillis)
                                putExtra("hijriDate", hijriDate)
                                putExtra("currentLocation", currentLocation)
                                putExtra("prayerTimeFormatted", prayerTimeFormatted)
                            }
                            
                            if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.O) {
                                startForegroundService(intent)
                            } else {
                                startService(intent)
                            }
                            mainScope.launch { result.success(true) }
                        }
                        "rescheduleFromStorage" -> {
                            scheduler.rescheduleAll()
                            mainScope.launch { result.success(true) }
                        }
                        "getLaunchPayload" -> {
                            val route = intent.getStringExtra("route")
                            intent.removeExtra("route")
                            mainScope.launch { result.success(route) }
                        }
                        "scheduleProphetReminder" -> {
                            val intervalMinutes = call.argument<Int>("intervalMinutes") ?: 60
                            val audioPath = call.argument<String>("audioPath") ?: ""
                            val isTest = call.argument<Boolean>("isTest") ?: false
                            scheduler.scheduleProphetReminder(intervalMinutes, audioPath, isTest)
                            mainScope.launch { result.success(true) }
                        }
                        "cancelProphetReminder" -> {
                            scheduler.cancelProphetReminder()
                            mainScope.launch { result.success(true) }
                        }
                        "schedulePrePrayerReminder" -> {
                            val offsetMinutes = call.argument<Int>("offsetMinutes") ?: 5
                            val audioPath = call.argument<String>("audioPath") ?: ""
                            val isTest = call.argument<Boolean>("isTest") ?: false
                            scheduler.schedulePrePrayerReminder(offsetMinutes, audioPath, isTest)
                            mainScope.launch { result.success(true) }
                        }
                        "cancelPrePrayerReminder" -> {
                            scheduler.cancelPrePrayerReminder()
                            mainScope.launch { result.success(true) }
                        }
                        else -> mainScope.launch { result.notImplemented() }
                    }
                } catch (e: Exception) {
                    android.util.Log.e("MainActivity", "MethodChannel Error: ${e.message}", e)
                    mainScope.launch { result.error("NATIVE_ERROR", "Error in Native MethodChannel: ${e.message}", null) }
                }
            }
        }
    }
}
