import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class NativeSchedulerService {
  static const MethodChannel _channel = MethodChannel(
    'com.fazakkir.app/adhan_scheduler',
  );

  Future<void> scheduleAdhan({
    required int id,
    required DateTime triggerAt,
    required String title,
    required String body,
    String? prayerName,
    String? hijriDate,
    String? audioAssetPath,
    String notificationType = "adhan", // "adhan" or "reminder"
    String deeplink = "",
    int repeatInterval = 0,
  }) async {
    try {
      final payload = jsonEncode({
        "title": title,
        "body": body,
        "prayerName": prayerName ?? title,
        "hijriDate": hijriDate ?? "",
        "audioAssetPath": audioAssetPath,
        "notificationType": notificationType,
        "deeplink": deeplink,
      });

      await _channel.invokeMethod('scheduleExact', {
        'id': id,
        'triggerAtMillis': triggerAt.millisecondsSinceEpoch,
        'payload': payload,
        'repeatInterval': repeatInterval,
      });
    } on PlatformException catch (_) {
      // Failed to schedule
    }
  }

  Future<String?> getLaunchPayload() async {
    try {
      final String? route = await _channel.invokeMethod('getLaunchPayload');
      return route;
    } on PlatformException catch (_) {
      return null;
    }
  }

  Future<void> cancelAdhan(int id) async {
    try {
      await _channel.invokeMethod('cancel', {'id': id});
    } on PlatformException catch (_) {
      // Failed to cancel Adhan
    }
  }

  Future<void> cancelAllAdhan() async {
    try {
      await _channel.invokeMethod('cancelAll');
    } on PlatformException catch (_) {
      // Failed to cancel all Adhans
    }
  }

  Future<bool> canScheduleExactAlarms() async {
    try {
      final bool result = await _channel.invokeMethod('canScheduleExactAlarms');
      return result;
    } on PlatformException catch (_) {
      return false;
    }
  }

  Future<void> requestExactAlarmPermission() async {
    try {
      await _channel.invokeMethod('requestExactAlarmPermission');
    } on PlatformException catch (_) {
      // Failed to request permission
    }
  }

  Future<Map<String, dynamic>> getScheduledAlarms() async {
    try {
      final Map<dynamic, dynamic> result = await _channel.invokeMethod(
        'getScheduledAlarms',
      );
      return result.cast<String, dynamic>();
    } on PlatformException catch (_) {
      return {};
    }
  }

  Future<void> startKeepAliveService() async {
    try {
      await _channel.invokeMethod('startKeepAlive');
    } on PlatformException catch (_) {
      // Failed to start keep alive
    }
  }

  Future<void> stopKeepAliveService() async {
    try {
      await _channel.invokeMethod('stopKeepAlive');
    } on PlatformException catch (_) {
      // Failed to stop keep alive
    }
  }

  Future<void> rescheduleFromStorage() async {
    try {
      await _channel.invokeMethod('rescheduleFromStorage');
    } on PlatformException catch (_) {
      // Failed to reschedule
    }
  }

  Future<void> updateKeepAliveContent(
    String prayerName,
    DateTime nextPrayerTime,
    String? hijriDate,
    String? currentLocation,
    String? prayerTimeFormatted,
  ) async {
    try {
      await _channel.invokeMethod('updateKeepAliveContent', {
        'prayerName': prayerName,
        'nextPrayerTimeMillis': nextPrayerTime.millisecondsSinceEpoch,
        'hijriDate': hijriDate,
        'currentLocation': currentLocation,
        'prayerTimeFormatted': prayerTimeFormatted,
      });
    } on PlatformException catch (e) {
      print("Failed to update keep alive content: '${e.message}'.");
    }
  }

  Future<void> scheduleProphetReminder({
    required int intervalMinutes,
    required String audioPath,
    bool isTest = false,
  }) async {
    try {
      await _channel.invokeMethod('scheduleProphetReminder', {
        'intervalMinutes': intervalMinutes,
        'audioPath': audioPath,
        'isTest': isTest,
      });
    } on PlatformException catch (e) {
      print("Failed to schedule prophet reminder: '${e.message}'.");
    }
  }

  Future<void> cancelProphetReminder() async {
    try {
      await _channel.invokeMethod('cancelProphetReminder');
    } on PlatformException catch (e) {
      print("Failed to cancel prophet reminder: '${e.message}'.");
    }
  }

  Future<void> schedulePrePrayerReminder({
    required int offsetMinutes,
    required String audioPath,
    bool isTest = false,
  }) async {
    try {
      await _channel.invokeMethod('schedulePrePrayerReminder', {
        'offsetMinutes': offsetMinutes,
        'audioPath': audioPath,
        'isTest': isTest,
      });
    } on PlatformException catch (e) {
      print("Failed to schedule pre-prayer reminder: '${e.message}'.");
    }
  }

  Future<void> cancelPrePrayerReminder() async {
    try {
      await _channel.invokeMethod('cancelPrePrayerReminder');
    } on PlatformException catch (e) {
      print("Failed to cancel pre-prayer reminder: '${e.message}'.");
    }
  }

  Future<void> scheduleDailyKhatma({
    required int id,
    required String title,
    required String body,
    required TimeOfDay time,
  }) async {
    final now = DateTime.now();
    var trigger = DateTime(
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );

    if (trigger.isBefore(now)) {
      trigger = trigger.add(const Duration(days: 1));
    }

    // Ensure ID is a safe positive 32-bit integer for Android PendingIntent
    // Khatma IDs: 30000 range to avoid collision with Adhan (10000+) and PrePrayer (20000+)
    // We use abs() to ensure positive, then modulo 10000 to keep within range, then add 30000.
    final safeId = 30000 + (id.hashCode.abs() % 10000);

    print(
      "Scheduling Khatma ID: $safeId at $trigger (millis: ${trigger.millisecondsSinceEpoch})",
    );

    try {
      await scheduleAdhan(
        id: safeId,
        triggerAt: trigger,
        title: title,
        body: body,
        prayerName: title,
        notificationType: "reminder", // Standard notification sound
        deeplink: "/khatma", // Route to open when tapped
        repeatInterval: 86400000, // 24 hours in milliseconds
      );
    } on PlatformException catch (e) {
      print("Failed to schedule daily khatma: '${e.message}'.");
    }
  }

  Future<void> cancelKhatmaReminder(int id) async {
    final safeId = 30000 + (id.hashCode.abs() % 10000);
    await cancelAdhan(safeId);
  }
}
