package com.fazakkir.app.fazakkir

import android.app.AlarmManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.os.Build
import android.provider.Settings
import android.util.Log
import org.json.JSONObject

class AdhanScheduler(private val context: Context) {

    private val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
    private val prefs = context.getSharedPreferences("adhank_prefs", Context.MODE_PRIVATE)

    fun scheduleExact(id: Int, triggerAtMillis: Long, payloadJson: String, repeatInterval: Long = 0) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            if (!alarmManager.canScheduleExactAlarms()) {
                Log.w("AdhanScheduler", "Cannot schedule exact alarms. Permission denied.")
                return
            }
        }

        val intent = Intent(context, AdhanReceiver::class.java).apply {
            putExtra("id", id)
            putExtra("payload", payloadJson)
            putExtra("repeatInterval", repeatInterval) // Pass repeat interval to receiver
        }

        val pendingIntent = PendingIntent.getBroadcast(
            context,
            id,
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        try {
            alarmManager.setExactAndAllowWhileIdle(
                AlarmManager.RTC_WAKEUP,
                triggerAtMillis,
                pendingIntent
            )
            persistAlarm(id, triggerAtMillis, payloadJson, repeatInterval)
            Log.d("AdhanScheduler", "Scheduled alarm $id at $triggerAtMillis (repeat: $repeatInterval)")
        } catch (e: Exception) {
            Log.e("AdhanScheduler", "Error scheduling alarm: ${e.message}", e)
        }
    }

    fun cancel(id: Int) {
        val intent = Intent(context, AdhanReceiver::class.java)
        val pendingIntent = PendingIntent.getBroadcast(
            context,
            id,
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
        alarmManager.cancel(pendingIntent)
        removePersistedAlarm(id)
        Log.d("AdhanScheduler", "Cancelled alarm $id")
    }

    fun cancelAll() {
        // We need to iterate known keys to cancel them in AlarmManager?
        // Actually, to cancel in AlarmManager we need the PendingIntent with the same ID.
        // So we MUST iterate.
        val alarms = getPersistedAlarms()
        alarms.keys.forEach { id ->
            cancel(id.toInt())
        }
        prefs.edit().clear().apply()
    }

    fun canScheduleExactAlarms(): Boolean {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            alarmManager.canScheduleExactAlarms()
        } else {
            true
        }
    }

    fun requestExactAlarmPermission() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            val intent = Intent(Settings.ACTION_REQUEST_SCHEDULE_EXACT_ALARM)
            intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            context.startActivity(intent)
        }
    }

    // Persistence using JSONObject
    private fun persistAlarm(id: Int, triggerAtMillis: Long, payloadJson: String, repeatInterval: Long) {
        val alarmsJson = getPersistedAlarmsJson()
        val alarmData = JSONObject()
        alarmData.put("triggerAtMillis", triggerAtMillis)
        alarmData.put("payload", payloadJson)
        alarmData.put("repeatInterval", repeatInterval)
        
        alarmsJson.put(id.toString(), alarmData)
        saveAlarmsJson(alarmsJson)
    }

    private fun removePersistedAlarm(id: Int) {
        val alarmsJson = getPersistedAlarmsJson()
        alarmsJson.remove(id.toString())
        saveAlarmsJson(alarmsJson)
    }

    private fun getPersistedAlarms(): Map<String, AlarmData> {
        val alarmsJson = getPersistedAlarmsJson()
        val map = mutableMapOf<String, AlarmData>()
        val keys = alarmsJson.keys()
        while (keys.hasNext()) {
            val key = keys.next()
            val data = alarmsJson.optJSONObject(key)
            if (data != null) {
                map[key] = AlarmData(
                    data.getLong("triggerAtMillis"),
                    data.getString("payload"),
                    data.optLong("repeatInterval", 0)
                )
            }
        }
        return map
    }

    private fun getPersistedAlarmsJson(): JSONObject {
        val jsonStr = prefs.getString("scheduled_alarms", "{}")
        return try {
            JSONObject(jsonStr)
        } catch (e: Exception) {
            JSONObject()
        }
    }

    private fun saveAlarmsJson(json: JSONObject) {
        prefs.edit().putString("scheduled_alarms", json.toString()).apply()
    }

    fun rescheduleAll() {
        val alarms = getPersistedAlarms()
        val now = System.currentTimeMillis()
        alarms.forEach { (idStr, data) ->
            if (data.triggerAtMillis > now) {
                // Future alarm, schedule as is
                scheduleExact(idStr.toInt(), data.triggerAtMillis, data.payload, data.repeatInterval)
            } else if (data.repeatInterval > 0) {
                // Past alarm but repeating, calculate next trigger
                var nextTrigger = data.triggerAtMillis
                while (nextTrigger <= now) {
                    nextTrigger += data.repeatInterval
                }
                scheduleExact(idStr.toInt(), nextTrigger, data.payload, data.repeatInterval)
            }
            // else: Past one-time alarm, ignored/dropped
        }
    }

    fun getScheduledAlarmsMap(): Map<String, Any> {
        val alarms = getPersistedAlarms()
        val result = mutableMapOf<String, Any>()
        alarms.forEach { (id, data) ->
            result[id] = mapOf(
                "triggerAtMillis" to data.triggerAtMillis,
                "payload" to data.payload,
                "repeatInterval" to data.repeatInterval
            )
        }
        return result
    }

    data class AlarmData(val triggerAtMillis: Long, val payload: String, val repeatInterval: Long)

    fun scheduleProphetReminder(intervalMinutes: Int, audioPath: String, isTest: Boolean) {
        val prophetId = 9999 // Dedicated ID for prophet reminder
        
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            if (!alarmManager.canScheduleExactAlarms()) {
                Log.w("AdhanScheduler", "Cannot schedule exact alarms for prophet reminder")
                return
            }
        }

        Log.d("AdhanScheduler", "=== CREATING PROPHET PAYLOAD ===")
        Log.d("AdhanScheduler", "Audio Path: '$audioPath'")
        Log.d("AdhanScheduler", "Audio Path Length: ${audioPath.length}")
        
        val payload = JSONObject().apply {
            put("title", "صلِّ على النبي ﷺ")
            put("body", "اللهم صل وسلم على نبينا محمد")
            put("audioAssetPath", audioPath)
            put("notificationType", "prophet_reminder")
            put("deeplink", "/athkar")
        }.toString()
        
        Log.d("AdhanScheduler", "Payload JSON: $payload")
        Log.d("AdhanScheduler", "================================")

        val triggerAtMillis = if (isTest) {
            System.currentTimeMillis() + 3000 // 3 seconds for test
        } else {
            System.currentTimeMillis() + (intervalMinutes * 60 * 1000L)
        }

        val repeatInterval = if (isTest) 0L else (intervalMinutes * 60 * 1000L)

        scheduleExact(prophetId, triggerAtMillis, payload, repeatInterval)
        Log.d("AdhanScheduler", "Scheduled prophet reminder: interval=$intervalMinutes min, test=$isTest")
    }

    fun cancelProphetReminder() {
        val prophetId = 9999
        cancel(prophetId)
        Log.d("AdhanScheduler", "Cancelled prophet reminder")
    }

    fun schedulePrePrayerReminder(offsetMinutes: Int, audioPath: String, isTest: Boolean) {
        val prePrayerId = 9998 // Dedicated ID for pre-prayer reminder
        
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            if (!alarmManager.canScheduleExactAlarms()) {
                Log.w("AdhanScheduler", "Cannot schedule exact alarms for pre-prayer reminder")
                return
            }
        }

        val payload = JSONObject().apply {
            put("title", "تنبيه ما قبل الصلاة")
            put("body", "حان موعد الاستعداد للصلاة")
            put("audioAssetPath", audioPath)
            put("notificationType", "pre_prayer_reminder")
            put("deeplink", "/adhan")
        }.toString()

        val triggerAtMillis = if (isTest) {
            System.currentTimeMillis() + 3000 // 3 seconds for test
        } else {
            System.currentTimeMillis() + (offsetMinutes * 60 * 1000L)
        }

        val repeatInterval = 0L // Pre-prayer reminders are scheduled per prayer, not repeating

        scheduleExact(prePrayerId, triggerAtMillis, payload, repeatInterval)
        Log.d("AdhanScheduler", "Scheduled pre-prayer reminder: offset=$offsetMinutes min, test=$isTest")
    }

    fun cancelPrePrayerReminder() {
        val prePrayerId = 9998
        cancel(prePrayerId)
        Log.d("AdhanScheduler", "Cancelled pre-prayer reminder")
    }
}
