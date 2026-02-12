import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:path_provider/path_provider.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:permission_handler/permission_handler.dart';
import 'package:fazakkir/core/services/native_scheduler_service.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;

  Future<void> init() async {
    if (_isInitialized) return;

    tz.initializeTimeZones();
    // We rely on UTC conversion for scheduling now, so explicit location setting is not strictly required
    // and can be dangerous if it doesn't match the device.

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    final DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        );

    final InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsDarwin,
        );

    await log('NotificationService: Initializing...');
    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (details) {},
    );

    // Create Channels Explicitly for Android 8+
    await _createNotificationChannels();

    _isInitialized = true;
    await log('NotificationService: Initialized successfully');
  }

  Future<void> _createNotificationChannels() async {
    const AndroidNotificationChannel adhanChannel = AndroidNotificationChannel(
      'fazakkir_adhan',
      'Adhan & Prayer Times',
      description: 'Notifications for prayer times and adhan',
      importance: Importance.max,
      playSound: true,
      // sound: RawResourceAndroidNotificationSound('adhan_notification'), // Commented out as resource is missing
    );

    const AndroidNotificationChannel dailyChannel = AndroidNotificationChannel(
      'fazakkir_daily',
      'Daily Reminders',
      description: 'Daily scheduled reminders',
      importance: Importance.max,
      playSound: true,
    );

    const AndroidNotificationChannel periodicChannel =
        AndroidNotificationChannel(
          'fazakkir_periodic',
          'Periodic Reminders',
          description: 'Recurring reminders throughout the day',
          importance: Importance.defaultImportance,
          playSound: true,
        );

    final androidPlugin = flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    if (androidPlugin != null) {
      await log('NotificationService: Creating channels...');
      await androidPlugin.createNotificationChannel(adhanChannel);
      await androidPlugin.createNotificationChannel(dailyChannel);
      await androidPlugin.createNotificationChannel(periodicChannel);
      await log('NotificationService: Channels created');
    }
  }

  Future<void> requestPermissions() async {
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >()
        ?.requestPermissions(alert: true, badge: true, sound: true);

    if (await Permission.notification.isDenied) {
      await Permission.notification.request();
    }
  }

  Future<void> showInstantNotification({
    required String title,
    required String body,
  }) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
          'fazakkir_reminders',
          'Fazakkir Reminders',
          channelDescription: 'General reminders from Fazakkir app',
          importance: Importance.max,
          priority: Priority.high,
          showWhen: true,
        );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );

    await flutterLocalNotificationsPlugin.show(
      0,
      title,
      body,
      platformChannelSpecifics,
    );
  }

  @deprecated
  Future<void> scheduleDailyNotification({
    required int id,
    required String title,
    required String body,
    required TimeOfDay time,
  }) async {
    await log(
      'WARNING: Legacy Daily Notification scheduled for $id. Prefer NativeScheduler.',
    );
    final scheduledDate = _nextInstanceOfTime(time);

    await flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      scheduledDate,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'fazakkir_daily',
          'Daily Reminders',
          channelDescription: 'Daily scheduled reminders',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> schedulePeriodicNotification({
    required int id,
    required String title,
    required String body,
    required RepeatInterval interval,
  }) async {
    await flutterLocalNotificationsPlugin.periodicallyShow(
      id,
      title,
      body,
      interval,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'fazakkir_periodic',
          'Periodic Reminders',
          channelDescription: 'Recurring reminders throughout the day',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  // Helper to get next instance of a time, converted to UTC to avoid Timezone DB issues
  tz.TZDateTime _nextInstanceOfTime(TimeOfDay time) {
    final DateTime now = DateTime.now();
    DateTime scheduledDate = DateTime(
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );

    // If the scheduled time is earlier than now, schedule for tomorrow
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    // Convert the Local DateTime to UTC
    // This allows us to use tz.UTC (which is always available) ensuring the instant is correct
    // regardless of whether the timezone DB matches the device settings.
    final DateTime scheduledUtc = scheduledDate.toUtc();

    return tz.TZDateTime.from(scheduledUtc, tz.UTC);
  }

  Future<void> cancelAll() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }

  Future<void> cancelNotification(int id) async {
    await flutterLocalNotificationsPlugin.cancel(id);
  }

  // Android 12+ Exact Alarm Permission
  Future<bool> checkExactAlarmPermission() async {
    if (await Permission.scheduleExactAlarm.isDenied) {
      // For Android 12+, we might need to ask user to go to settings
      return false;
    }
    return true;
  }

  Future<void> requestExactAlarmPermission() async {
    if (await Permission.scheduleExactAlarm.isDenied) {
      await Permission.scheduleExactAlarm.request();
    }
  }

  // Battery Optimization
  Future<bool> isBatteryOptimizationIgnored() async {
    return await Permission.ignoreBatteryOptimizations.isGranted;
  }

  Future<void> requestIgnoreBatteryOptimization() async {
    if (await Permission.ignoreBatteryOptimizations.isDenied) {
      await Permission.ignoreBatteryOptimizations.request();
    }
  }

  Future<void> showAdhanNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    // Native Implementation:
    // We don't "show" immediately here usually, this is called by the timer?
    // Wait, the current logic calls showAdhanNotification when the timer triggers?
    // OR does it schedule it?
    //
    // If this method is called to *show* an instant notification (e.g. from a timer running in Dart),
    // and we want to move to offline scheduling, we should change how this is CALLED.
    //
    // BUT the user asked to "Replace ONLY Adhan scheduling in existing NotificationService with native scheduleAdhan."
    //
    // Existing logic seems to be:
    // 1. Calculate times
    // 2. Schedule them?
    // Let's check where showAdhanNotification is called.
    // It seems showAdhanNotification is for *instant* showing.
    //
    // We need a method to SCHEDULE.
    // The current NotificationService doesn't seem to have a specific "scheduleAdhan" method
    // other than generic scheduleDaily/Periodic.
    //
    // If the app was using a background timer to call showAdhanNotification,
    // we need to find that timer and replace it with scheduleAdhan.
    //
    // However, I will add the scheduleAdhan method here to be used by the PrayerTimeService/Provider.
  }

  Future<void> scheduleNativeAdhan({
    required int id,
    required DateTime triggerAt,
    required String prayerName,
    required String hijriDate,
    String? audioAssetPath,
  }) async {
    final nativeScheduler = NativeSchedulerService();
    await nativeScheduler.scheduleAdhan(
      id: id,
      triggerAt: triggerAt,
      title: prayerName,
      body: hijriDate,
      prayerName: prayerName,
      hijriDate: hijriDate,
      audioAssetPath: audioAssetPath,
      deeplink: "/location_settings", // Test deep link
    );
  }

  Future<void> cancelNativeAdhan(int id) async {
    final nativeScheduler = NativeSchedulerService();
    await nativeScheduler.cancelAdhan(id);
  }

  Future<void> cancelAllNativeAdhans() async {
    final nativeScheduler = NativeSchedulerService();
    await nativeScheduler.cancelAllAdhan();
  }

  Future<void> scheduleNativeReminder({
    required int id,
    required DateTime triggerAt,
    required String title,
    required String body,
    String? route,
  }) async {
    final nativeScheduler = NativeSchedulerService();
    await nativeScheduler.scheduleAdhan(
      id: id,
      triggerAt: triggerAt,
      title: title,
      body: body,
      prayerName: title, // Fallback
      hijriDate: "",
      notificationType: "reminder",
      deeplink: route ?? "",
    );
  }

  // --- Alarm Manager Support for Reminders ---

  // --- Workmanager Background Handler ---
  // --- Logging Helper ---
  static Future<void> log(String message) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/app_logs.txt');
      final timestamp = DateTime.now().toIso8601String();
      await file.writeAsString('$timestamp: $message\n', mode: FileMode.append);
    } catch (e) {}
  }

  Future<String> getLogs() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/app_logs.txt');
      if (await file.exists()) {
        return await file.readAsString();
      }
      return 'No logs found.';
    } catch (e) {
      return 'Error reading logs: $e';
    }
  }

  Future<void> testSchedule10s({String? audioPath}) async {
    await log('--- NATIVE TEST START ---');

    final now = DateTime.now();
    final trigger = now.add(const Duration(seconds: 10));

    await log('Scheduling Native Test ID: 10420 at $trigger (10s delay)');

    // Schedule through Native Service
    final nativeScheduler = NativeSchedulerService();
    await nativeScheduler.scheduleAdhan(
      id: 10420, // Test ID
      triggerAt: trigger,
      title: "تجربة النظام الجديد",
      body: "إذا وصلك هذا الإشعار، فالنظام يعمل بنجاح",
      prayerName: "تجربة",
      hijriDate: "1445 هـ",
      audioAssetPath: audioPath, // Use provided path from repository
      deeplink: "/location_settings", // Test deep link
    );

    await log('Native schedule command sent.');
    await log('--- NATIVE TEST END ---');
  }
}
