import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/repositories/ihsan_repository.dart';
import '../../data/models/ihsan_model.dart';
import 'package:fazakkir/l10n/app_localizations.dart';

class IhsanScreen extends StatefulWidget {
  const IhsanScreen({super.key});

  @override
  State<IhsanScreen> createState() => _IhsanScreenState();
}

class _IhsanScreenState extends State<IhsanScreen> {
  final IhsanRepository _repository = IhsanRepository();
  DailyProgress? _todayProgress;
  List<DailyProgress> _weeklyProgress = [];
  bool _isLoading = true;
  final DateTime _currentDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final today = await _repository.getDayProgress(_currentDate);
    final week = await _repository.getWeeklyProgress();

    if (mounted) {
      setState(() {
        _todayProgress = today;
        _weeklyProgress = week;
        _isLoading = false;
      });
    }
  }

  void _toggleHabit(String key, bool currentValue) async {
    await _repository.updateProgress(_currentDate, key, !currentValue);
    _loadData(); // Reload to refresh chart and state
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
          AppLocalizations.of(context)!.ihsanTitle,
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
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildWeeklyChart(isDark),
                  SizedBox(height: 20.h),
                  _buildHabitsList(isDark),
                ],
              ),
            ),
    );
  }

  Widget _buildWeeklyChart(bool isDark) {
    return Container(
      height: 200.h,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          if (!isDark)
            BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 10),
        ],
      ),
      child: Column(
        children: [
          Text(
            AppLocalizations.of(context)!.weeklyProgress,
            style: TextStyle(
              fontFamily: "Cairo",
              fontWeight: FontWeight.bold,
              fontSize: 14.sp,
              color: isDark ? Colors.white : AppColors.islamicBrown,
            ),
          ),
          Expanded(
            child: BarChart(
              BarChartData(
                barGroups: _weeklyProgress.asMap().entries.map((entry) {
                  final index = entry.key;
                  final progress = entry.value;
                  final score = _calculateScore(progress);
                  return BarChartGroupData(
                    x: index,
                    barRods: [
                      BarChartRodData(
                        toY: score,
                        color: AppColors.islamicGold,
                        width: 12,
                        borderRadius: BorderRadius.circular(4),
                        backDrawRodData: BackgroundBarChartRodData(
                          show: true,
                          toY: 100,
                          color: Colors.grey.withOpacity(0.1),
                        ),
                      ),
                    ],
                  );
                }).toList(),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        if (value.toInt() >= 0 &&
                            value.toInt() < _weeklyProgress.length) {
                          final dateStr = _weeklyProgress[value.toInt()].date;
                          final date = DateTime.parse(dateStr);
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              DateFormat('E', 'ar').format(date),
                              style: TextStyle(
                                fontSize: 10.sp,
                                fontFamily: "Cairo",
                                color: Colors.grey,
                              ),
                            ),
                          );
                        }
                        return const Text("");
                      },
                    ),
                  ),
                ),
                gridData: FlGridData(show: false),
                borderData: FlBorderData(show: false),
                maxY: 100,
              ),
            ),
          ),
        ],
      ),
    );
  }

  double _calculateScore(DailyProgress progress) {
    if (progress.habits.isEmpty) return 0.0;
    final completed = progress.habits.values.where((v) => v).length;
    return (completed / progress.habits.length) * 100;
  }

  Widget _buildHabitsList(bool isDark) {
    if (_todayProgress == null) return const SizedBox.shrink();

    final prayers = ['fajr', 'dhuhr', 'asr', 'maghrib', 'isha'];
    final others = [
      'sunnah_duha',
      'sunnah_qiyam',
      'witr',
      'quran',
      'athkar_morning',
      'athkar_evening',
    ];

    return Column(
      children: [
        _buildSectionTitle(AppLocalizations.of(context)!.fivePrayers, isDark),
        ...prayers.map((key) => _buildHabitTile(key, isDark)),
        SizedBox(height: 20.h),
        _buildSectionTitle(AppLocalizations.of(context)!.sunnahPrayers, isDark),
        ...others.map((key) => _buildHabitTile(key, isDark)),
      ],
    );
  }

  Widget _buildSectionTitle(String title, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Container(width: 4, height: 20, color: AppColors.islamicGold),
          SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              fontFamily: "Bakra",
              fontSize: 16.sp,
              color: isDark ? Colors.white : AppColors.islamicBrown,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHabitTile(String key, bool isDark) {
    final l10n = AppLocalizations.of(context)!;
    final labels = {
      'fajr': l10n.fajr,
      'dhuhr': l10n.dhuhr,
      'asr': l10n.asr,
      'maghrib': l10n.maghrib,
      'isha': l10n.isha,
      'sunnah_duha': l10n.sunnahDuha,
      'sunnah_qiyam': l10n.sunnahQiyam,
      'witr': l10n.witr,
      'quran': l10n.quranReading,
      'athkar_morning': l10n.athkarMorning,
      'athkar_evening': l10n.athkarEvening,
    };

    final isCompleted = _todayProgress!.habits[key] ?? false;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: isCompleted
            ? Border.all(color: AppColors.islamicGold.withOpacity(0.5))
            : null,
        boxShadow: [
          if (!isDark)
            BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 5),
        ],
      ),
      child: ListTile(
        onTap: () => _toggleHabit(key, isCompleted),
        leading: Container(
          width: 24.w,
          height: 24.w,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isCompleted ? AppColors.islamicGold : Colors.transparent,
            border: Border.all(
              color: isCompleted ? AppColors.islamicGold : Colors.grey,
            ),
          ),
          child: isCompleted
              ? Icon(Icons.check, color: Colors.white, size: 16.sp)
              : null,
        ),
        title: Text(
          labels[key] ?? key,
          style: TextStyle(
            fontFamily: "Cairo",
            fontSize: 14.sp,
            color: isDark ? Colors.white : Colors.black,
            decoration: isCompleted ? TextDecoration.lineThrough : null,
            decorationColor: AppColors.islamicGold,
          ),
        ),
        trailing: isCompleted
            ? Icon(Icons.star, color: AppColors.islamicGold, size: 20.sp)
            : null,
      ),
    );
  }
}
