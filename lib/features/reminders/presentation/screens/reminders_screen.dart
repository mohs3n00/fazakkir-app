import 'package:flutter/material.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/providers.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/services/notification_service.dart';
import 'package:just_audio/just_audio.dart';
import '../../../../core/services/native_scheduler_service.dart';
import '../../../../l10n/app_localizations.dart';
// import '../../../debug/presentation/screens/scheduler_test_screen.dart';

class RemindersScreen extends ConsumerStatefulWidget {
  const RemindersScreen({super.key});

  @override
  ConsumerState<RemindersScreen> createState() => _RemindersScreenState();
}

class _RemindersScreenState extends ConsumerState<RemindersScreen> {
  final NotificationService _notificationService = NotificationService();
  final NativeSchedulerService _nativeScheduler = NativeSchedulerService();
  bool _notificationsEnabled = false;
  bool _batteryOptimizationIgnored = true;

  Future<void> _scheduleMorning() async {
    // Save time
    final sp = await SharedPreferences.getInstance();
    await sp.setInt('morning_hour', _morningTime.hour);
    await sp.setInt('morning_minute', _morningTime.minute);

    final now = DateTime.now();
    var scheduledDate = DateTime(
      now.year,
      now.month,
      now.day,
      _morningTime.hour,
      _morningTime.minute,
    );
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    try {
      await _nativeScheduler.scheduleAdhan(
        id: 2001,
        triggerAt: scheduledDate,
        title: AppLocalizations.of(context)!.morningAthkarTitle,
        body: AppLocalizations.of(context)!.morningAthkarBody,
        repeatInterval: const Duration(days: 1).inMilliseconds,
        notificationType: "reminder",
        deeplink: "/athkar",
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.morningAthkarScheduled),
          ),
        );
      }
    } catch (e) {
      debugPrint('Error scheduling morning: $e');
    }
  }

  Future<void> _scheduleEvening() async {
    final sp = await SharedPreferences.getInstance();
    await sp.setInt('evening_hour', _eveningTime.hour);
    await sp.setInt('evening_minute', _eveningTime.minute);

    final now = DateTime.now();
    var scheduledDate = DateTime(
      now.year,
      now.month,
      now.day,
      _eveningTime.hour,
      _eveningTime.minute,
    );
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    try {
      await _nativeScheduler.scheduleAdhan(
        id: 2002,
        triggerAt: scheduledDate,
        title: AppLocalizations.of(context)!.eveningAthkarTitle,
        body: AppLocalizations.of(context)!.eveningAthkarBody,
        repeatInterval: const Duration(days: 1).inMilliseconds,
        notificationType: "reminder",
        deeplink: "/athkar",
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.eveningAthkarScheduled),
          ),
        );
      }
    } catch (e) {
      debugPrint('Error scheduling evening: $e');
    }
  }

  Future<void> _schedulePeriodic() async {
    // Save interval
    final sp = await SharedPreferences.getInstance();
    await sp.setString('periodic_interval', _periodicInterval);

    int minutes = 60;
    if (_periodicInterval == '15m') minutes = 15;
    if (_periodicInterval == '30m') minutes = 30;

    final triggerAt = DateTime.now().add(Duration(minutes: minutes));

    try {
      await _nativeScheduler.scheduleAdhan(
        id: 3000,
        triggerAt: triggerAt,
        title: AppLocalizations.of(context)!.thikrAllahTitle,
        body: AppLocalizations.of(context)!.thikrAllahBody,
        repeatInterval: Duration(minutes: minutes).inMilliseconds,
        notificationType: "reminder",
        deeplink: "/athkar",
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context)!.periodicReminderScheduled(minutes),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context)!.reminderError(e.toString()),
            ),
          ),
        );
      }
    }
  }

  Future<void> _scheduleDuha() async {
    final now = DateTime.now();
    var scheduledDate = DateTime(
      now.year,
      now.month,
      now.day,
      10,
      0, // 10:00 AM
    );
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    try {
      await _nativeScheduler.scheduleAdhan(
        id: 2003,
        triggerAt: scheduledDate,
        title: AppLocalizations.of(context)!.duhaPrayerTitle,
        body: AppLocalizations.of(context)!.duhaPrayerBody,
        repeatInterval: const Duration(days: 1).inMilliseconds,
        notificationType: "reminder",
        deeplink: "/athkar",
      );
    } catch (e) {
      debugPrint('Error Duha: $e');
    }
  }

  Future<void> _scheduleQiyam() async {
    final now = DateTime.now();
    var scheduledDate = DateTime(
      now.year,
      now.month,
      now.day,
      3,
      0, // 3:00 AM
    );
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    try {
      await _nativeScheduler.scheduleAdhan(
        id: 2004,
        triggerAt: scheduledDate,
        title: AppLocalizations.of(context)!.qiyamPrayerTitle,
        body: AppLocalizations.of(context)!.qiyamPrayerBody,
        repeatInterval: const Duration(days: 1).inMilliseconds,
        notificationType: "reminder",
        deeplink: "/athkar",
      );
    } catch (e) {
      debugPrint('Error Qiyam: $e');
    }
  }

  Future<void> _scheduleWitr() async {
    final now = DateTime.now();
    var scheduledDate = DateTime(
      now.year,
      now.month,
      now.day,
      22,
      0, // 10:00 PM
    );
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    try {
      await _nativeScheduler.scheduleAdhan(
        id: 2005,
        triggerAt: scheduledDate,
        title: AppLocalizations.of(context)!.witrPrayerTitle,
        body: AppLocalizations.of(context)!.witrPrayerBody,
        repeatInterval: const Duration(days: 1).inMilliseconds,
        notificationType: "reminder",
        deeplink: "/athkar",
      );
    } catch (e) {
      debugPrint('Error Witr: $e');
    }
  }

  TimeOfDay _morningTime = const TimeOfDay(hour: 6, minute: 0);
  bool _morningAzkarEnabled = false;

  bool _eveningAzkarEnabled = false;
  TimeOfDay _eveningTime = const TimeOfDay(hour: 18, minute: 0);

  // Periodic
  bool _periodicEnabled = false;
  String _periodicInterval = '30m'; // 15m, 30m, 1h

  // Audio Preview State
  final AudioPlayer _audioPlayer = AudioPlayer();
  String? _currentlyPlayingPath;
  bool _isPlaying = false;

  final List<(String, String)> _reciters = [
    (
      'الشيخ عبد الباسط عبد الصمد',
      'assets/audio/prophet_prayers/abdul_basit.mp3',
    ),
    ('الشيخ محمد صديق المنشاوي', 'assets/audio/prophet_prayers/minshawi.mp3'),
    ('الشيخ محمد عمران', 'assets/audio/prophet_prayers/omran.mp3'),
    ('الشيخ مشاري راشد', 'assets/audio/prophet_prayers/mishary.mp3'),
    ('نغمة قصيرة', 'assets/audio/prophet_prayers/asem_as.mp3'),
  ];

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _playPreview(String path) async {
    try {
      if (_currentlyPlayingPath == path && _isPlaying) {
        await _audioPlayer.stop();
        if (mounted) {
          setState(() {
            _isPlaying = false;
            _currentlyPlayingPath = null;
          });
        }
      } else {
        await _audioPlayer.setAsset(path);
        await _audioPlayer.play();
        if (mounted) {
          setState(() {
            _currentlyPlayingPath = path;
            _isPlaying = true;
          });
        }
        _audioPlayer.playerStateStream.listen((state) {
          if (state.processingState == ProcessingState.completed) {
            if (mounted) {
              setState(() {
                _isPlaying = false;
                _currentlyPlayingPath = null;
              });
            }
          }
        });
      }
    } catch (e) {
      debugPrint("Error playing audio: $e");
    }
  }

  // Sunnah Prayers
  bool _duhaEnabled = false;
  bool _qiyamEnabled = false;
  bool _witrEnabled = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = ref.read(appPreferencesProvider);
    setState(() {
      _morningAzkarEnabled = prefs.getMorningAzkarEnabled();
      _morningTime = prefs.getMorningAzkarTime();
      _eveningAzkarEnabled = prefs.getEveningAzkarEnabled();
      _eveningTime = prefs.getEveningAzkarTime();
      _periodicEnabled = prefs.getPeriodicEnabled();
      _periodicInterval = prefs.getPeriodicInterval();
      _duhaEnabled = prefs.getDuhaEnabled();
      _qiyamEnabled = prefs.getQiyamEnabled();
      _witrEnabled = prefs.getWitrEnabled();
    });

    await _notificationService.init();
    await _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    await _notificationService.requestPermissions();
    await _notificationService.requestExactAlarmPermission(); // Android 12+
    if (mounted) {
      setState(() {
        _notificationsEnabled = true;
      });
    }

    // Check battery optimization
    final ignored = await _notificationService.isBatteryOptimizationIgnored();

    // Always enable KeepAlive Service (User Request: "Essential default behavior")
    // We don't need to check prefs, we enforce it.
    await _nativeScheduler.startKeepAliveService();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('keep_alive_enabled', true);

    if (mounted) {
      setState(() {
        _batteryOptimizationIgnored = ignored;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.darkBackground
          : AppColors.lightBackground,
      appBar: AppBar(
        title: Text(
          l10n.remindersTitle,
          style: TextStyle(fontFamily: "Bakra", fontSize: 22.sp),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(
          color: isDark ? Colors.white : AppColors.islamicBrown,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (!_batteryOptimizationIgnored) _buildBatteryWarning(isDark),
            if (!_batteryOptimizationIgnored) SizedBox(height: 10.h),

            // _buildSettingsCard call removed
            SizedBox(height: 10.h),

            // --- Prayer Alerts Section (New) ---
            _buildPrayerAlertsSection(isDark, l10n),

            SizedBox(height: 20.h),
            _buildSectionHeader(l10n.morningAthkarTitle, isDark),
            _buildSwitchTile(
              l10n.morningAthkarTitle,
              l10n.morningAthkarSubtitle,
              _morningAzkarEnabled,
              (val) {
                setState(() => _morningAzkarEnabled = val);
                ref
                    .read(appPreferencesProvider)
                    .setMorningAzkarEnabled(val); // Save
                if (val) {
                  _scheduleMorning();
                } else {
                  _nativeScheduler.cancelAdhan(2001); // Native cancel
                }
              },
              isDark,
              trailing: _buildTimePicker(_morningTime, (t) {
                setState(() => _morningTime = t);
                ref.read(appPreferencesProvider).setMorningAzkarTime(t); // Save
                if (_morningAzkarEnabled) _scheduleMorning();
              }, isDark),
            ),
            _buildSwitchTile(
              l10n.eveningAthkarTitle,
              l10n.eveningAthkarSubtitle,
              _eveningAzkarEnabled,
              (val) {
                setState(() => _eveningAzkarEnabled = val);
                ref
                    .read(appPreferencesProvider)
                    .setEveningAzkarEnabled(val); // Save
                if (val) {
                  _scheduleEvening();
                } else {
                  _nativeScheduler.cancelAdhan(2002); // Native cancel
                }
              },
              isDark,
              trailing: _buildTimePicker(_eveningTime, (t) {
                setState(() => _eveningTime = t);
                ref.read(appPreferencesProvider).setEveningAzkarTime(t); // Save
                if (_eveningAzkarEnabled) _scheduleEvening();
              }, isDark),
            ),

            SizedBox(height: 20.h),
            _buildSectionHeader(l10n.periodicRemindersTitle, isDark),
            _buildSwitchTile(
              l10n.thikrAllahTitle,
              l10n.thikrAllahSubtitle,
              _periodicEnabled,
              (val) {
                setState(() => _periodicEnabled = val);
                ref
                    .read(appPreferencesProvider)
                    .setPeriodicEnabled(val); // Save
                if (val) {
                  _schedulePeriodic();
                } else {
                  _nativeScheduler.cancelAdhan(3000); // Native cancel
                }
              },
              isDark,
              trailing: DropdownButton<String>(
                value: _periodicInterval,
                dropdownColor: isDark ? AppColors.darkCard : Colors.white,
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black,
                  fontFamily: "Cairo",
                ),
                underline: Container(),
                items: ['15m', '30m', '1h']
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (v) {
                  setState(() => _periodicInterval = v!);
                  ref.read(appPreferencesProvider).setPeriodicInterval(v!);
                  if (_periodicEnabled) _schedulePeriodic();
                },
              ),
            ),

            SizedBox(height: 20.h),
            _buildSectionHeader(l10n.sunnahPrayersTitle, isDark),
            _buildSwitchTile(
              l10n.duhaPrayerTitle,
              l10n.duhaPrayerSubtitle,
              _duhaEnabled,
              (val) {
                setState(() => _duhaEnabled = val);
                ref.read(appPreferencesProvider).setDuhaEnabled(val);
                if (val) {
                  _scheduleDuha();
                } else {
                  _nativeScheduler.cancelAdhan(2003); // Native cancel
                }
              },
              isDark,
            ),
            _buildSwitchTile(
              l10n.qiyamPrayerTitle,
              l10n.qiyamPrayerSubtitle,
              _qiyamEnabled,
              (val) {
                setState(() => _qiyamEnabled = val);
                ref.read(appPreferencesProvider).setQiyamEnabled(val);
                if (val) {
                  _scheduleQiyam();
                } else {
                  _nativeScheduler.cancelAdhan(2004); // Native cancel
                }
              },
              isDark,
            ),
            _buildSwitchTile(
              l10n.witrPrayerTitle,
              l10n.witrPrayerSubtitle,
              _witrEnabled,
              (val) {
                setState(() => _witrEnabled = val);
                ref.read(appPreferencesProvider).setWitrEnabled(val);
                if (val) {
                  _scheduleWitr();
                } else {
                  _nativeScheduler.cancelAdhan(2005); // Native cancel
                }
              },
              isDark,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, bool isDark) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      child: Text(
        title,
        style: TextStyle(
          fontFamily: "Bakra",
          fontSize: 18.sp,
          color: AppColors.islamicGold,
        ),
        textAlign: TextAlign.start,
      ),
    );
  }

  Widget _buildSwitchTile(
    String title,
    String subtitle,
    bool value,
    Function(bool) onChanged,
    bool isDark, {
    Widget? trailing,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          if (!isDark)
            BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 5),
        ],
      ),
      child: ListTile(
        title: Text(
          title,
          style: TextStyle(
            fontFamily: "Cairo",
            fontWeight: FontWeight.bold,
            fontSize: 14.sp,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            fontFamily: "Cairo",
            fontSize: 12.sp,
            color: Colors.grey,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (trailing != null) ...[trailing, SizedBox(width: 10)],
            Switch(
              value: value,
              onChanged: onChanged,
              activeThumbColor: AppColors.islamicGold,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimePicker(
    TimeOfDay time,
    Function(TimeOfDay) onTimeChanged,
    bool isDark,
  ) {
    return GestureDetector(
      onTap: () async {
        final picked = await showTimePicker(
          context: context,
          initialTime: time,
        );
        if (picked != null) onTimeChanged(picked);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          time.format(context),
          style: TextStyle(
            fontFamily: "Cairo",
            color: isDark ? Colors.white : Colors.black,
            fontSize: 12.sp,
          ),
        ),
      ),
    );
  }

  Widget _buildBatteryWarning(bool isDark) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.orange),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  AppLocalizations.of(context)!.batteryWarning,
                  style: TextStyle(
                    fontFamily: "Cairo",
                    fontSize: 14.sp,
                    color: isDark ? Colors.white : Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            onPressed: () async {
              await _notificationService.requestIgnoreBatteryOptimization();
              // Recheck
              if (mounted) _checkPermissions();
            },
            child: Text(
              AppLocalizations.of(context)!.fixBatteryIssue,
              style: TextStyle(color: Colors.white, fontFamily: "Cairo"),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrayerAlertsSection(bool isDark, AppLocalizations l10n) {
    final prefs = ref.watch(reminderPreferencesProvider);

    return Column(
      children: [
        _buildSectionHeader(l10n.prayerAlertsTitle, isDark),

        // --- 1. Prophet Reminder ---
        Container(
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkCard : Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              if (!isDark)
                BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 5),
            ],
          ),
          child: Column(
            children: [
              SwitchListTile(
                title: Text(
                  l10n.prophetReminderTitle,
                  style: TextStyle(
                    fontFamily: "Cairo",
                    fontWeight: FontWeight.bold,
                    fontSize: 14.sp,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
                subtitle: Text(
                  l10n.prophetReminderSubtitle,
                  style: TextStyle(
                    fontFamily: "Cairo",
                    fontSize: 12.sp,
                    color: Colors.grey,
                  ),
                ),
                value: prefs.isProphetEnabled,
                activeThumbColor: AppColors.islamicGold,
                onChanged: (val) async {
                  await prefs.setProphetEnabled(val);
                  if (val) {
                    await _nativeScheduler.scheduleProphetReminder(
                      intervalMinutes: prefs.prophetIntervalMinutes,
                      audioPath: prefs.prophetAudio,
                    );
                  } else {
                    await _nativeScheduler.cancelProphetReminder();
                  }
                  setState(() {});
                },
              ),
              if (prefs.isProphetEnabled) ...[
                Divider(height: 1),
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 8.h,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        l10n.repetition,
                        style: TextStyle(
                          fontFamily: "Cairo",
                          color: isDark ? Colors.white : Colors.black,
                        ),
                      ),
                      DropdownButton<int>(
                        value: prefs.prophetIntervalMinutes,
                        dropdownColor: isDark
                            ? AppColors.darkCard
                            : Colors.white,
                        style: TextStyle(
                          color: isDark ? Colors.white : Colors.black,
                          fontFamily: "Cairo",
                        ),
                        items: [
                          DropdownMenuItem(
                            value: 5,
                            child: Text(l10n.every5Minutes),
                          ),
                          DropdownMenuItem(
                            value: 10,
                            child: Text(l10n.every10Minutes),
                          ),
                          DropdownMenuItem(
                            value: 15,
                            child: Text(l10n.every15Minutes),
                          ),
                          DropdownMenuItem(
                            value: 30,
                            child: Text(l10n.every30Minutes),
                          ),
                          DropdownMenuItem(
                            value: 60,
                            child: Text(l10n.everyHour),
                          ),
                          DropdownMenuItem(
                            value: 120,
                            child: Text(l10n.everyTwoHours),
                          ),
                        ],
                        onChanged: (val) async {
                          if (val != null) {
                            await prefs.setProphetInterval(val);
                            await _nativeScheduler.scheduleProphetReminder(
                              intervalMinutes: val,
                              audioPath: prefs.prophetAudio,
                            );
                            setState(() {});
                          }
                        },
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 8.h,
                  ),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      l10n.selectReciter,
                      style: TextStyle(
                        fontFamily: "Cairo",
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                  ),
                ),
                ..._reciters.map((reciter) {
                  return RadioListTile<String>(
                    title: Text(
                      reciter.$1,
                      style: TextStyle(
                        fontFamily: "Cairo",
                        fontSize: 13.sp,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                    value: reciter.$2,
                    groupValue: prefs.prophetAudio,
                    activeColor: AppColors.islamicGold,
                    onChanged: (val) async {
                      if (val != null) {
                        await prefs.setProphetAudio(val);
                        await _nativeScheduler.scheduleProphetReminder(
                          intervalMinutes: prefs.prophetIntervalMinutes,
                          audioPath: val,
                        );
                        setState(() {});
                      }
                    },
                    secondary: IconButton(
                      icon: Icon(
                        _currentlyPlayingPath == reciter.$2 && _isPlaying
                            ? Icons.stop_circle_outlined
                            : Icons.play_circle_outline,
                        color: _currentlyPlayingPath == reciter.$2 && _isPlaying
                            ? Colors.red
                            : AppColors.islamicGold,
                      ),
                      onPressed: () => _playPreview(reciter.$2),
                    ),
                  );
                }),
                // Test Button for Prophet Reminder
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 8.h,
                  ),
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      await _testProphetReminder();
                    },
                    icon: Icon(Icons.notifications_active, size: 18.sp),
                    label: Text(
                      "اختبار التنبيه الآن",
                      style: TextStyle(fontFamily: "Cairo", fontSize: 13.sp),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.islamicGold,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(
                        horizontal: 20.w,
                        vertical: 12.h,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),

        // --- 2. Pre-Prayer Reminder ---
        Container(
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkCard : Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              if (!isDark)
                BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 5),
            ],
          ),
          child: Column(
            children: [
              SwitchListTile(
                title: Text(
                  "تذكير ما قبل الصلاة",
                  style: TextStyle(
                    fontFamily: "Cairo",
                    fontWeight: FontWeight.bold,
                    fontSize: 14.sp,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
                subtitle: Text(
                  "تنبيه قبل الأذان (الصلوات المفروضة)",
                  style: TextStyle(
                    fontFamily: "Cairo",
                    fontSize: 12.sp,
                    color: Colors.grey,
                  ),
                ),
                value: prefs.isPrePrayerEnabled,
                activeThumbColor: AppColors.islamicGold,
                onChanged: (val) async {
                  await prefs.setPrePrayerEnabled(val);
                  if (mounted) setState(() {});
                  // Note: Change will take effect on next Adhan scheduling cycle
                },
              ),
              if (prefs.isPrePrayerEnabled) ...[
                Divider(height: 1),
                ListTile(
                  title: Text(
                    "وقت التنبيه",
                    style: TextStyle(
                      fontFamily: "Cairo",
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                  trailing: DropdownButton<int>(
                    value: prefs.prePrayerOffsetMinutes,
                    dropdownColor: isDark ? AppColors.darkCard : Colors.white,
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black,
                      fontFamily: "Cairo",
                    ),
                    items: const [
                      DropdownMenuItem(value: 5, child: Text("قبل 5 دقائق")),
                      DropdownMenuItem(value: 10, child: Text("قبل 10 دقائق")),
                    ],
                    onChanged: (val) async {
                      if (val != null) {
                        await prefs.setPrePrayerOffset(val);
                        final scheduler = NativeSchedulerService();
                        scheduler.rescheduleFromStorage();
                        setState(() {});
                      }
                    },
                  ),
                ),
                ListTile(
                  title: Text(
                    "معاينة الصوت",
                    style: TextStyle(
                      fontFamily: "Cairo",
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                  trailing: IconButton(
                    icon: Icon(
                      _currentlyPlayingPath ==
                                  'assets/audio/pre_prayer_reminder.mp3' &&
                              _isPlaying
                          ? Icons.stop_circle_outlined
                          : Icons.play_circle_outline,
                      color:
                          _currentlyPlayingPath ==
                                  'assets/audio/pre_prayer_reminder.mp3' &&
                              _isPlaying
                          ? Colors.red
                          : AppColors.islamicGold,
                    ),
                    onPressed: () =>
                        _playPreview('assets/audio/pre_prayer_reminder.mp3'),
                  ),
                ),
                // Test Button for Pre-Prayer Reminder
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 8.h,
                  ),
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      await _testPrePrayerReminder();
                    },
                    icon: Icon(Icons.notifications_active, size: 18.sp),
                    label: Text(
                      "اختبار التنبيه الآن",
                      style: TextStyle(fontFamily: "Cairo", fontSize: 13.sp),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.islamicGold,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(
                        horizontal: 20.w,
                        vertical: 12.h,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  // Test method for Prophet Reminder
  Future<void> _testProphetReminder() async {
    final prefs = ref.read(reminderPreferencesProvider);
    try {
      // Use native scheduling method with test flag
      await _nativeScheduler.scheduleProphetReminder(
        intervalMinutes: 1, // Dummy value for test
        audioPath: prefs.prophetAudio,
        isTest: true, // This triggers 3-second delay in native code
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('سيظهر التنبيه بعد 3 ثوانٍ'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      debugPrint('Error testing prophet reminder: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('خطأ في اختبار التنبيه: $e')));
      }
    }
  }

  // Test method for Pre-Prayer Reminder
  Future<void> _testPrePrayerReminder() async {
    try {
      // Use native scheduling method with test flag
      await _nativeScheduler.schedulePrePrayerReminder(
        offsetMinutes: 5, // Dummy value for test
        audioPath: 'assets/audio/pre_prayer_reminder.mp3',
        isTest: true, // This triggers 3-second delay in native code
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('سيظهر التنبيه بعد 3 ثوانٍ'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      debugPrint('Error testing pre-prayer reminder: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('خطأ في اختبار التنبيه: $e')));
      }
    }
  }
}
