import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:flutter_svg/flutter_svg.dart'; // Unused
import 'package:fazakkir/core/theme/app_colors.dart';
import 'package:fazakkir/features/qibla/presentation/screens/qibla_screen.dart';
import 'package:fazakkir/features/calendar/presentation/screens/calendar_screen.dart';
import 'package:fazakkir/features/ihsan/presentation/screens/ihsan_screen.dart';
import 'package:fazakkir/features/reminders/presentation/screens/reminders_screen.dart';
import 'package:fazakkir/features/khatma/presentation/screens/khatma_screen.dart';
import 'package:fazakkir/features/duas/presentation/screens/duas_screen.dart';
import 'package:fazakkir/features/hadith/presentation/screens/hadith_screen.dart';
import 'package:fazakkir/features/analytics/presentation/screens/analytics_screen.dart';
import 'package:fazakkir/features/settings/presentation/screens/settings_screen.dart';
import 'package:fazakkir/features/adhan/presentation/screens/adhan_settings_screen.dart';
import '../../../../core/widgets/ramadan_background.dart';
import 'package:fazakkir/l10n/app_localizations.dart';
// import 'package:fazakkir/features/reminders/presentation/screens/reminders_settings_screen.dart';

class ServicesScreen extends StatelessWidget {
  const ServicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    final l10n = AppLocalizations.of(context)!;
    final services = [
      (icon: Icons.explore, label: l10n.qibla, route: "/qibla"),
      (icon: Icons.calendar_month, label: l10n.calendar, route: "/calendar"),
      (icon: Icons.favorite, label: l10n.ihsan, route: "/ihsan"),
      (
        icon: Icons.notifications_active,
        label: l10n.reminders,
        route: "/reminders",
      ),
      // (icon: Icons.alarm_add, label: "إعدادات التذكيرات", route: "/reminder_settings"), // Removed
      (icon: Icons.import_contacts, label: l10n.khatma, route: "/khatma"),
      (icon: Icons.mosque, label: l10n.adhan, route: "/adhan"),
      // (icon: Icons.menu_book, label: "الأدعية", route: "/duas"), // Removed by user request
      (icon: Icons.format_quote, label: l10n.hadith, route: "/hadith"),
      (icon: Icons.bar_chart, label: l10n.analytics, route: "/analytics"),
      (icon: Icons.settings, label: l10n.settings, route: "/settings"),
    ];

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.darkBackground
          : AppColors.lightBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          AppLocalizations.of(context)!.services,
          style: TextStyle(
            color: isDark ? AppColors.islamicGold : AppColors.islamicBrown,
            fontSize: 24.sp,
            fontFamily: "Bakra",
          ),
        ),
      ),
      body: RamadanBackground(
        child: GridView.builder(
          padding: EdgeInsets.all(16.w),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 16.w,
            mainAxisSpacing: 16.h,
            childAspectRatio: 0.9,
          ),
          itemCount: services.length,
          itemBuilder: (context, index) {
            final service = services[index];
            return _buildServiceCard(
              context,
              service.icon,
              service.label,
              service.route,
              isDark,
            );
          },
        ),
      ),
    );
  }

  Widget _buildServiceCard(
    BuildContext context,
    IconData icon,
    String label,
    String route,
    bool isDark,
  ) {
    return GestureDetector(
      onTap: () {
        Widget? page;
        switch (route) {
          case "/qibla":
            page = const QiblaScreen();
            break;
          case "/calendar":
            page = const CalendarScreen();
            break;
          case "/ihsan":
            page = const IhsanScreen();
            break;
          case "/reminders":
            page = const RemindersScreen();
            break;
          case "/khatma":
            page = const KhatmaScreen();
            break;
          case "/duas":
            page = const DuasScreen();
            break;
          case "/hadith":
            page = const HadithScreen();
            break;
          case "/analytics":
            page = const AnalyticsScreen();
            break;
          case "/settings":
            page = const SettingsScreen();
            break;
          case "/adhan":
            page = const AdhanSettingsScreen();
            break;
          // case "/reminder_settings":
          //   page = const RemindersSettingsScreen();
          //   break;
          case "/sebha_service":
            // Switch main tab to Sebha (Index 1)
            // This needs access to Riverpod provider.
            // For now, let's just show a snackbar or navigate to sebha screen directly if possible.
            // Better: Use a simple callback or provider if converted to ConsumerWidget to switch tab.
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  "السبحة متاحة في القائمة السفلية",
                  style: TextStyle(fontFamily: "Cairo"),
                ),
              ),
            );
            return;
        }

        if (page != null) {
          Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (context) => page!));
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: isDark
                ? Colors.white.withOpacity(0.1)
                : Colors.black.withOpacity(0.05),
          ),
          boxShadow: [
            if (!isDark)
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: AppColors.islamicGold.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppColors.islamicGold, size: 28.sp),
            ),
            SizedBox(height: 12.h),
            Text(
              label,
              style: TextStyle(
                color: isDark ? Colors.white : AppColors.islamicBrown,
                fontSize: 14.sp,
                fontFamily: "Cairo",
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
