import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/repositories/analytics_repository.dart';
import 'package:fazakkir/l10n/app_localizations.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  final AnalyticsRepository _repository = AnalyticsRepository();
  Map<String, int> _stats = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    final stats = await _repository.getStats();
    if (mounted) {
      setState(() {
        _stats = stats;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.darkBackground
          : AppColors.lightBackground,
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.analytics,
          style: TextStyle(fontFamily: "Bakra", fontSize: 22.sp),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(
          color: isDark ? Colors.white : AppColors.islamicBrown,
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildStatCard(
                    AppLocalizations.of(context)!.tasbihThisMonth,
                    _stats['tasbih']?.toString() ?? "0",
                    Icons.fingerprint,
                    isDark,
                  ),
                  SizedBox(height: 16.h),
                  _buildStatCard(
                    AppLocalizations.of(context)!.pagesThisMonth,
                    _stats['quran_pages']?.toString() ?? "0",
                    Icons.menu_book,
                    isDark,
                  ),
                  SizedBox(height: 16.h),
                  _buildStatCard(
                    AppLocalizations.of(context)!.khatmasThisMonth,
                    _stats['khatma']?.toString() ?? "0",
                    Icons.check_circle_outline,
                    isDark,
                  ),

                  SizedBox(height: 32.h),
                  Container(
                    padding: EdgeInsets.all(16.w),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkCard : Colors.white,
                      borderRadius: BorderRadius.circular(16.r),
                      border: Border.all(
                        color: AppColors.islamicGold.withOpacity(0.3),
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          AppLocalizations.of(context)!.keepItUp,
                          style: TextStyle(
                            fontFamily: "Cairo",
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                            color: isDark
                                ? Colors.white
                                : AppColors.islamicBrown,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          AppLocalizations.of(context)!.hadithKeepUp,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: "Cairo",
                            fontSize: 14.sp,
                            color: isDark ? Colors.white70 : Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    bool isDark,
  ) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontFamily: "Cairo",
                  fontSize: 16.sp,
                  color: isDark ? Colors.white70 : Colors.black54,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                value,
                style: TextStyle(
                  fontFamily: "Bakra",
                  fontSize: 32.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.islamicGold,
                ),
              ),
            ],
          ),
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: AppColors.islamicGold.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.islamicGold, size: 32.sp),
          ),
        ],
      ),
    );
  }
}
