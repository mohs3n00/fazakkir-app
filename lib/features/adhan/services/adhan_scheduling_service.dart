import 'package:adhan/adhan.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/native_scheduler_service.dart';
import '../../../core/providers.dart';
import '../data/repositories/adhan_repository.dart';
import '../../../services/prayer_config_service.dart';
import '../../../core/utils/prayer_time_utils.dart';

final adhanSchedulingServiceProvider = Provider(
  (ref) => AdhanSchedulingService(ref),
);

class AdhanSchedulingService {
  final Ref ref;

  AdhanSchedulingService(this.ref);

  Future<void> scheduleAdhans({bool force = true}) async {
    // Check if already scheduled recently (within 12 hours)
    final prefs = ref.read(sharedPreferencesProvider);
    final now = DateTime.now();
    final lastRunMillis = prefs.getInt('last_adhan_schedule_timestamp');

    if (!force && lastRunMillis != null) {
      final lastRun = DateTime.fromMillisecondsSinceEpoch(lastRunMillis);
      if (now.difference(lastRun).inHours < 12) {
        // Already scheduled recently, skip to save battery and avoid "early" updates
        return;
      }
    }

    // Get location and params via PrayerConfigService (cached)
    final configService = ref.read(prayerConfigServiceProvider);
    // passing forceRefresh: force ensures if we force schedule, we also maybe force refresh location?
    // Actually, user wants stability. Let's trust the 12h cache logic in config service unless explicitly told otherwise.
    // But since we are scheduling for 30 days, we should probably get the best available location NOW.
    // If 'force' is true (e.g. from settings), we might want to force refresh location too.
    // For now, let's stick to the consistent cache to solve the "jumping times" issue.
    final coordinates = await configService.getCoordinates(forceRefresh: force);

    final params = CalculationMethod.egyptian.getParameters();
    params.madhab = Madhab.shafi;

    // Get Audio Path
    final repo = ref.read(adhanRepositoryProvider);

    // Check if Adhan is enabled
    final isEnabled = await repo.isAdhanEnabled();
    if (!isEnabled) {
      // If disabled, cancel all existing adhans and return
      await cancelAllAdhans();
      return;
    }

    final muezzin = await repo.getSelectedMuezzin();
    final file = await repo.getMuezzinFile(muezzin);
    final audioPath = (file != null && await file.exists()) ? file.path : null;

    // Initialize NativeScheduler
    final scheduler = NativeSchedulerService();

    // Verify permission first
    if (!await scheduler.canScheduleExactAlarms()) {
      await scheduler.requestExactAlarmPermission();
    }

    // Check for battery optimization (optional but recommended for reliability)
    // We don't force it here to avoid nagging, but for "Deep" fix we should at least log or try once.
    // Ideally this should be in settings, but we can try to request if not ignored.
    // For now, let's rely on the settings screen for battery optimization to avoid bad UX on startup.

    // Schedule for 30 days
    // final now = DateTime.now(); // Already defined above
    for (int i = 0; i < 30; i++) {
      final date = now.add(Duration(days: i));
      final dateComponents = DateComponents(date.year, date.month, date.day);
      final prayerTimes = PrayerTimes(coordinates, dateComponents, params);

      await _scheduleForDate(prayerTimes, audioPath, scheduler);
    }

    // Save execution timestamp
    await prefs.setInt(
      'last_adhan_schedule_timestamp',
      now.millisecondsSinceEpoch,
    );
  }

  Future<void> _scheduleForDate(
    PrayerTimes times,
    String? audioPath,
    NativeSchedulerService scheduler,
  ) async {
    final now = DateTime.now();

    final prayers = {
      Prayer.fajr: times.fajr,
      Prayer.dhuhr: times.dhuhr,
      Prayer.asr: times.asr,
      Prayer.maghrib: times.maghrib,
      Prayer.isha: times.isha,
    };

    final formattedNames = {
      Prayer.fajr: "صلاة الفجر",
      Prayer.dhuhr: "صلاة الظهر",
      Prayer.asr: "صلاة العصر",
      Prayer.maghrib: "صلاة المغرب",
      Prayer.isha: "صلاة العشاء",
    };

    for (final entry in prayers.entries) {
      // Use PrayerTimeUtils to align time to the next minute start
      // This ensures 12:00:01 becomes 12:01:00, matching DateFormat.jm() display
      final alignedTime = PrayerTimeUtils.ceilToMinute(entry.value);

      // Only schedule if time is in future
      if (alignedTime.isAfter(now)) {
        // Unique ID: DayOfYear * 10 + PrayerIndex
        // Let's shift Prayers to 10000+.

        final dayVal =
            alignedTime.difference(DateTime(alignedTime.year, 1, 1)).inDays + 1;
        int alarmId = 10000 + (dayVal * 10) + entry.key.index;

        // Hijri Date (approximate or fetch if available)
        // For now, empty or from a service if we have one.
        // We can use HijriCalendar from adhan_dart?
        // or just leave it blank/approx.
        // String hijriDate = ...;

        await scheduler.scheduleAdhan(
          id: alarmId,
          triggerAt: alignedTime,
          title: "حان الآن موعد ${formattedNames[entry.key]}",
          body: "حي على الصلاة",
          prayerName: formattedNames[entry.key],
          hijriDate: "", // populate if we have Hijri converter
          audioAssetPath: audioPath,
          notificationType: 'adhan',
          deeplink: '/adhan',
        );

        // Schedule pre-prayer reminder if enabled
        final prefs = ref.read(reminderPreferencesProvider);
        if (prefs.isPrePrayerEnabled) {
          final offsetMinutes = prefs.prePrayerOffsetMinutes;
          // Calculate pre-prayer based on the ALIGNED time
          final prePrayerTime = alignedTime.subtract(
            Duration(minutes: offsetMinutes),
          );

          // Only schedule if pre-prayer time is still in future
          if (prePrayerTime.isAfter(now)) {
            // Use 20000+ range for pre-prayer reminders
            int prePrayerAlarmId = 20000 + (dayVal * 10) + entry.key.index;

            await scheduler.scheduleAdhan(
              id: prePrayerAlarmId,
              triggerAt: prePrayerTime,
              title: "تذكير ما قبل ${formattedNames[entry.key]}",
              body:
                  "باقي $offsetMinutes دقائق على ${formattedNames[entry.key]}",
              prayerName: formattedNames[entry.key],
              hijriDate: "",
              audioAssetPath: 'assets/audio/pre_prayer_reminder.mp3',
              notificationType: 'pre_prayer_reminder',
              deeplink: '/adhan',
            );
          }
        } else {
          // Explicitly cancel if disabled to clean up any old alarms
          // Use 20000+ range for pre-prayer reminders
          int prePrayerAlarmId = 20000 + (dayVal * 10) + entry.key.index;
          await scheduler.cancelAdhan(prePrayerAlarmId);
        }
      }
    }
  }

  Future<void> cancelPrePrayerReminders() async {
    final scheduler = NativeSchedulerService();
    final now = DateTime.now();

    // Loop through potential IDs for the next 30 days
    // Logic matches scheduling: 20000 + (dayVal * 10) + index
    // We can just iterate a reasonable range or use the same logic as scheduling.
    // Iterating 30 days is safe.
    for (int i = 0; i < 30; i++) {
      final date = now.add(Duration(days: i));
      final dayVal = date.difference(DateTime(date.year, 1, 1)).inDays + 1;

      for (int prayerIndex = 0; prayerIndex < 5; prayerIndex++) {
        int prePrayerAlarmId = 20000 + (dayVal * 10) + prayerIndex;
        await scheduler.cancelAdhan(prePrayerAlarmId);
      }
    }
  }

  Future<void> cancelAllAdhans() async {
    final scheduler = NativeSchedulerService();
    final now = DateTime.now();

    for (int i = 0; i < 30; i++) {
      final date = now.add(Duration(days: i));
      final dayVal = date.difference(DateTime(date.year, 1, 1)).inDays + 1;

      for (int prayerIndex = 0; prayerIndex < 5; prayerIndex++) {
        // Cancel Adhan
        int alarmId = 10000 + (dayVal * 10) + prayerIndex;
        await scheduler.cancelAdhan(alarmId);

        // Cancel Pre-Prayer
        int prePrayerAlarmId = 20000 + (dayVal * 10) + prayerIndex;
        await scheduler.cancelAdhan(prePrayerAlarmId);
      }
    }
  }
}
