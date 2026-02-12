import 'package:flutter_svg/flutter_svg.dart';
import 'dart:async';
import 'package:adhan/adhan.dart';
import 'package:fazakkir/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:hijri/hijri_calendar.dart';
import '../../../../core/utils/date_converter.dart';
import '../../../services/prayer_times_service.dart';
import '../../../../core/services/native_scheduler_service.dart';
import 'package:fazakkir/l10n/app_localizations.dart';
import '../../../../core/utils/prayer_time_utils.dart';

class HomeHeader extends ConsumerStatefulWidget {
  const HomeHeader({super.key});

  @override
  ConsumerState<HomeHeader> createState() => _HomeHeaderState();
}

class _HomeHeaderState extends ConsumerState<HomeHeader> {
  Timer? _timer;
  DateTime _currentTime = DateTime.now();
  final NativeSchedulerService _nativeScheduler = NativeSchedulerService();
  Prayer? _lastNextPrayer;

  @override
  void initState() {
    super.initState();
    _startTimer();
    // Initial update after frame
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _checkAndNotifyNative(),
    );
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _currentTime = DateTime.now();
        });
        _checkAndNotifyNative();
      }
    });
  }

  Future<void> _checkAndNotifyNative() async {
    final prayerTimesAsync = ref.read(prayerTimesProvider);

    prayerTimesAsync.whenData((prayerTimes) {
      var next = prayerTimes.nextPrayer();
      DateTime? nextTime = _getNextPrayerTime(prayerTimes, next);
      String prayerName = _getPrayerName(next);

      // Handle "After Isha" case -> Next is Fajr Tomorrow
      if (next == Prayer.none) {
        next = Prayer.fajr;
        final tomorrow = DateTime.now().add(const Duration(days: 1));
        final coords = prayerTimes.coordinates;
        final params = prayerTimes.calculationParameters;

        // Calculate tomorrow's prayer times
        final tomorrowPrayerTimes = PrayerTimes(
          coords,
          DateComponents.from(tomorrow),
          params,
        );

        nextTime = tomorrowPrayerTimes.fajr;
        prayerName = "الفجر";
      }

      // Update if prayer changed OR if it's the first run (last is null)
      // We also check if nextTime changed to update countdown target
      if (nextTime != null) {
        // Round to next minute for display consistency with Alarm
        nextTime = PrayerTimeUtils.ceilToMinute(nextTime);

        // Always update if we have a valid time
        _lastNextPrayer = next; // Keep track, though less critical now

        final hijri = HijriCalendar.now();
        final hijriString =
            "${hijri.hDay} ${hijri.longMonthName} ${hijri.hYear}";
        // Location (Placeholder for now, or fetch from provider if available)
        final location = "الموقع الحالي";
        final formattedTime = DateFormat.jm().format(nextTime);

        _nativeScheduler.updateKeepAliveContent(
          prayerName,
          nextTime,
          hijriString,
          location,
          formattedTime,
        );
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final prayerTimesAsync = ref.watch(prayerTimesProvider);
    final hijri = HijriCalendar.now();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Stack(
      children: [
        // Layer 1: Background Color (Container)
        Container(
          width: double.infinity,
          // Layout hack: Use a temporary color transparent here but let it size the stack?
          // No, we use Positioned.fill for layers 1 & 2.
          // Layer 3 (Content) will dictate the size.
          decoration: BoxDecoration(
            color: isDark ? AppColors.islamicBrown : AppColors.islamicGold,
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(32.r),
              bottomRight: Radius.circular(32.r),
            ),
          ),
          // Child is empty, size determined by Stack's non-positioned children (Layer 3)
          // But wait, if Layer 3 is not "positioned", it fills the stack?
          // No, Stack sizes itself to fit non-positioned children.
          // We want the Container to MATCH the size of Layer 3.
          // So we should put the decoration ON Layer 3 but underneath?
          // Simplest way:
          // Stack -> [Positioned(BG Color), Positioned(SVG), Container(Content)]
          // But Positioned needs a size context.
          // Alternative: Container(BG Color) -> Stack -> [Positioned(SVG), Content]
          // The user specifically asked for "Layer of image ABOVE layer of Color".
          // So:
          // Decorating Container (Color)
          //   child: Stack
          //     children: [
          //        Positioned.fill(SVG) <- "Above Color"
          //        Column(Content)      <- "Above SVG"
          //     ]
          child: const SizedBox.shrink(),
        ),

        // Layer 1.5: Actually drawing the color requires a widget if we do the Stack size trick.
        // Let's rely on the Stack sizing to the largest non-positioned child.
        // If Layer 3 is the content, the stack height = content height.
        // Then Layer 1 & 2 can be Positioned.fill to match that height.
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              color: isDark ? AppColors.islamicBrown : AppColors.islamicGold,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(32.r),
                bottomRight: Radius.circular(32.r),
              ),
            ),
          ),
        ),

        // Layer 2: SVG Pattern (Above Color)
        Positioned.fill(
          child: ClipRRect(
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(32.r),
              bottomRight: Radius.circular(32.r),
            ),
            child: ShaderMask(
              shaderCallback: (rect) {
                return LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.black, Colors.transparent],
                  stops: const [0.3, 1.0],
                ).createShader(rect);
              },
              blendMode: BlendMode.dstIn,
              child: SvgPicture.asset(
                'assets/images/prayer_header_pattern.svg',
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
                colorFilter: ColorFilter.mode(
                  Colors.white.withOpacity(0.4), // Visible white pattern
                  BlendMode.srcIn,
                ),
              ),
            ),
          ),
        ),

        // Layer 3: Content (Above SVG)
        Container(
          width: double.infinity,
          padding: EdgeInsets.fromLTRB(
            20.w,
            MediaQuery.of(context).padding.top + 10.h,
            20.w,
            40.h,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Top Row: Date & Hijri
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${hijri.hDay} ${hijri.longMonthName} ${hijri.hYear}",
                        style: TextStyle(
                          color: isDark ? AppColors.islamicGold : Colors.white,
                          fontSize: 18.sp,
                          fontFamily: "Bakra",
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        DateConverter.format(
                          _currentTime,
                          pattern: 'EEEE, d MMMM',
                          context: context,
                        ),
                        style: TextStyle(
                          color: isDark
                              ? Colors.white70
                              : Colors.white.withOpacity(0.9),
                          fontSize: 14.sp,
                          fontFamily: "Cairo",
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 24.h),

              // Next Prayer Countdown
              prayerTimesAsync.when(
                data: (prayerTimes) {
                  var next = prayerTimes.nextPrayer();
                  var nextTime = _getNextPrayerTime(prayerTimes, next);

                  // Handle Post-Isha (Next Day Fajr)
                  if (next == Prayer.none) {
                    next = Prayer.fajr;
                    final tomorrow = DateTime.now().add(
                      const Duration(days: 1),
                    );
                    final tomorrowPrayerTimes = PrayerTimes(
                      prayerTimes.coordinates,
                      DateComponents.from(tomorrow),
                      prayerTimes.calculationParameters,
                    );
                    nextTime = tomorrowPrayerTimes.fajr;
                  }

                  // Round to next minute for display consistency
                  if (nextTime != null) {
                    nextTime = PrayerTimeUtils.ceilToMinute(nextTime);
                  }

                  final remaining = nextTime?.difference(_currentTime);

                  if (nextTime != null && remaining != null) {
                    final hours = remaining.inHours;
                    final minutes = remaining.inMinutes.remainder(60);
                    final seconds = remaining.inSeconds.remainder(60);

                    return Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 20.w,
                        vertical: 16.h,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(16.r),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                AppLocalizations.of(context)!.nextPrayer,
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12.sp,
                                  fontFamily: "Cairo",
                                ),
                              ),
                              SizedBox(height: 4.h),
                              Text(
                                _getPrayerName(next),
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18.sp,
                                  fontFamily: "Bakra",
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              _buildTimeUnit(
                                hours.toString().padLeft(2, '0'),
                                "ساعة",
                                isDark,
                              ),
                              Text(
                                " : ",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              _buildTimeUnit(
                                minutes.toString().padLeft(2, '0'),
                                "دقيقة",
                                isDark,
                              ),
                              Text(
                                " : ",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              _buildTimeUnit(
                                seconds.toString().padLeft(2, '0'),
                                "ثانية",
                                isDark,
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              ),

              SizedBox(height: 24.h),

              prayerTimesAsync.when(
                data: (prayerTimes) {
                  var next = prayerTimes.nextPrayer();
                  if (next == Prayer.none) {
                    next = Prayer.fajr; // Highlight Fajr after Isha
                  }

                  final l10n = AppLocalizations.of(context)!;
                  final prayers = [
                    (Prayer.fajr, prayerTimes.fajr, l10n.fajr),
                    (Prayer.sunrise, prayerTimes.sunrise, l10n.sunrise),
                    (Prayer.dhuhr, prayerTimes.dhuhr, l10n.dhuhr),
                    (Prayer.asr, prayerTimes.asr, l10n.asr),
                    (Prayer.maghrib, prayerTimes.maghrib, l10n.maghrib),
                    (Prayer.isha, prayerTimes.isha, l10n.isha),
                  ];

                  return Column(
                    children: prayers.map((p) {
                      return _buildVerticalPrayerCard(
                        context,
                        p.$3,
                        p.$2,
                        next == p.$1,
                        isDark,
                      );
                    }).toList(),
                  );
                },
                loading: () =>
                    const CircularProgressIndicator(color: Colors.white),
                error: (err, stack) => Text("Error loading prayers"),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildVerticalPrayerCard(
    BuildContext context,
    String name,
    DateTime time,
    bool isActive,
    bool isDark,
  ) {
    final activeColor = isDark ? AppColors.islamicGold : Colors.white;
    final activeTextColor = isDark ? Colors.black : AppColors.islamicBrown;

    final inactiveColor = Colors.white.withOpacity(0.15);
    final inactiveTextColor = Colors.white;

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      decoration: BoxDecoration(
        color: isActive ? activeColor : inactiveColor,
        borderRadius: BorderRadius.circular(16.r),
        border: isActive
            ? null
            : Border.all(color: Colors.white.withOpacity(0.2)),
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            DateFormat.jm().format(time),
            style: TextStyle(
              color: isActive ? activeTextColor : inactiveTextColor,
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              fontFamily: "Bakra",
            ),
          ),

          Row(
            children: [
              Text(
                name,
                style: TextStyle(
                  color: isActive
                      ? activeTextColor
                      : inactiveTextColor.withOpacity(0.9),
                  fontSize: 16.sp,
                  fontFamily: "Cairo",
                  fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              SizedBox(width: 12.w),
              Icon(
                _getPrayerIcon(name),
                color: isActive ? activeTextColor : inactiveTextColor,
                size: 20.sp,
              ),
            ],
          ),
        ],
      ),
    );
  }

  IconData _getPrayerIcon(String name) {
    if (name.contains("الفجر")) return Icons.wb_twilight;
    if (name.contains("الشروق")) return Icons.wb_sunny_outlined;
    if (name.contains("الظهر")) return Icons.wb_sunny;
    if (name.contains("العصر")) return Icons.wb_cloudy_outlined;
    if (name.contains("المغرب")) return Icons.nights_stay_outlined;
    if (name.contains("العشاء")) return Icons.nights_stay;
    return Icons.access_time;
  }

  DateTime? _getNextPrayerTime(PrayerTimes times, Prayer? next) {
    if (next == null) return null;
    switch (next) {
      case Prayer.fajr:
        return times.fajr;
      case Prayer.sunrise:
        return times.sunrise;
      case Prayer.dhuhr:
        return times.dhuhr;
      case Prayer.asr:
        return times.asr;
      case Prayer.maghrib:
        return times.maghrib;
      case Prayer.isha:
        return times.isha;
      default:
        return null;
    }
  }

  String _getPrayerName(Prayer? prayer) {
    if (prayer == null) return "";
    final l10n = AppLocalizations.of(context)!;
    switch (prayer) {
      case Prayer.fajr:
        return l10n.fajr;
      case Prayer.sunrise:
        return l10n.sunrise;
      case Prayer.dhuhr:
        return l10n.dhuhr;
      case Prayer.asr:
        return l10n.asr;
      case Prayer.maghrib:
        return l10n.maghrib;
      case Prayer.isha:
        return l10n.isha;
      default:
        return "";
    }
  }

  Widget _buildTimeUnit(String value, String label, bool isDark) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: Colors.white,
            fontSize: 24.sp,
            fontFamily: "Bakra",
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white60,
            fontSize: 10.sp,
            fontFamily: "Cairo",
          ),
        ),
      ],
    );
  }
}
