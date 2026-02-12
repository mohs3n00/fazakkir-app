import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/repositories/khatma_repository.dart';
import '../../data/models/khatma_model.dart';
import '../widgets/create_khatma_dialog.dart';
import 'package:percent_indicator/percent_indicator.dart';
import '../../../../l10n/app_localizations.dart';

class KhatmaScreen extends StatefulWidget {
  const KhatmaScreen({super.key});

  @override
  State<KhatmaScreen> createState() => _KhatmaScreenState();
}

class _KhatmaScreenState extends State<KhatmaScreen> {
  final KhatmaRepository _repository = KhatmaRepository();
  Khatma? _activeKhatma;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadKhatma();
  }

  Future<void> _loadKhatma() async {
    final k = await _repository.getActiveKhatma();
    if (mounted) {
      setState(() {
        _activeKhatma = k;
        _isLoading = false;
      });
    }
  }

  void _startNew() async {
    final result = await showDialog(
      context: context,
      builder: (_) => const CreateKhatmaDialog(),
    );
    if (result == true) {
      _loadKhatma();
    }
  }

  void _deleteKhatma() async {
    if (_activeKhatma != null) {
      await _repository.deleteKhatma(_activeKhatma!.id);
      _loadKhatma();
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
          l10n.khatmaTitle,
          style: TextStyle(fontFamily: "Bakra", fontSize: 22.sp),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(
          color: isDark ? Colors.white : AppColors.islamicBrown,
        ),
        actions: [
          if (_activeKhatma != null) ...[
            IconButton(
              icon: Icon(
                Icons.notifications_active_outlined,
                color: isDark ? Colors.white : AppColors.islamicBrown,
              ),
              onPressed: _showReminderSettings,
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              onPressed: _deleteKhatma,
            ),
          ],
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _activeKhatma == null
          ? _buildEmptyState(isDark, l10n)
          : _buildActiveState(isDark, l10n),
    );
  }

  Widget _buildEmptyState(bool isDark, AppLocalizations l10n) {
    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.menu_book,
              size: 80.sp,
              color: Colors.grey.withOpacity(0.5),
            ),
            SizedBox(height: 20.h),
            Text(
              l10n.noActiveKhatma,
              style: TextStyle(
                fontFamily: "Cairo",
                fontSize: 18.sp,
                color: isDark ? Colors.white : AppColors.islamicBrown,
              ),
            ),
            SizedBox(height: 30.h),
            ElevatedButton(
              onPressed: _startNew,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.islamicGold,
                padding: EdgeInsets.symmetric(horizontal: 40.w, vertical: 12.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  l10n.startNewKhatma,
                  style: TextStyle(
                    fontFamily: "Bakra",
                    fontSize: 16.sp,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveState(bool isDark, AppLocalizations l10n) {
    final k = _activeKhatma!;
    final progress = k.progress;
    final pagesLeft = k.pagesRemaining;

    return SingleChildScrollView(
      padding: EdgeInsets.all(20.w),
      child: Column(
        children: [
          // Main Progress Card
          Container(
            padding: EdgeInsets.all(24.w),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark
                    ? [AppColors.darkCard, Colors.black]
                    : [AppColors.islamicGold, AppColors.islamicBrown],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24.r),
              boxShadow: [
                BoxShadow(
                  color: AppColors.islamicGold.withOpacity(0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              children: [
                Text(
                  k.name,
                  style: TextStyle(
                    fontFamily: "Bakra",
                    fontSize: 24.sp,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 20.h),
                CircularPercentIndicator(
                  radius: 80.w,
                  lineWidth: 12.w,
                  percent: progress,
                  center: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "${(progress * 100).toInt()}%",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 32.sp,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        l10n.khatmaProgress,
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                  progressColor: Colors.white,
                  backgroundColor: Colors.white24,
                  circularStrokeCap: CircularStrokeCap.round,
                ),
                SizedBox(height: 20.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildInfoCol(
                      l10n.currentPage,
                      "${k.currentPage}",
                      Icons.bookmark,
                    ),
                    Container(width: 1, height: 40, color: Colors.white24),
                    _buildInfoCol(
                      l10n.remainingPages,
                      "$pagesLeft ${l10n.page}",
                      Icons.pages,
                    ),
                  ],
                ),
              ],
            ),
          ),

          SizedBox(height: 24.h),

          // Daily Goal Card
          if (k.dailyPageGoal != null)
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkCard : Colors.white,
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(
                  color: AppColors.islamicGold.withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      color: AppColors.islamicGold.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.calendar_today,
                      color: AppColors.islamicGold,
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.dailyGoalLabel,
                        style: TextStyle(
                          fontFamily: "Cairo",
                          color: Colors.grey,
                        ),
                      ),
                      Text(
                        "${k.dailyPageGoal} ${l10n.page}",
                        style: TextStyle(
                          fontFamily: "Bakra",
                          fontSize: 18.sp,
                          color: isDark ? Colors.white : AppColors.islamicBrown,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

          SizedBox(height: 16.h),
          // Instructions
          Text(
            l10n.khatmaInstructions,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: "Cairo",
              fontSize: 13.sp,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCol(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white70, size: 20.sp),
        SizedBox(height: 4.h),
        Text(
          value,
          style: TextStyle(
            fontFamily: "Bakra",
            fontSize: 18.sp,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontFamily: "Cairo",
            fontSize: 12.sp,
            color: Colors.white70,
          ),
        ),
      ],
    );
  }

  void _showReminderSettings() {
    if (_activeKhatma == null) return;

    final k = _activeKhatma!;
    // Default to enabled=false if null (backward compat)
    bool isEnabled = k.reminderEnabled;
    // Default to 9 PM if null
    TimeOfDay time = k.reminderTime != null
        ? TimeOfDay.fromDateTime(k.reminderTime!)
        : const TimeOfDay(hour: 21, minute: 0);

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final l10n = AppLocalizations.of(context)!;
            final isDark = Theme.of(context).brightness == Brightness.dark;

            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              backgroundColor: isDark ? AppColors.darkCard : Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      l10n.khatmaReminderTitle,
                      style: TextStyle(
                        fontFamily: "Bakra",
                        fontSize: 18.sp,
                        color: isDark ? Colors.white : AppColors.islamicBrown,
                      ),
                    ),
                    SizedBox(height: 20.h),
                    SwitchListTile(
                      title: Text(
                        l10n.dailyReminder,
                        style: TextStyle(
                          fontFamily: "Cairo",
                          fontSize: 14.sp,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                      ),
                      value: isEnabled,
                      activeThumbColor: AppColors.islamicGold,
                      onChanged: (v) {
                        setDialogState(() {
                          isEnabled = v;
                        });
                      },
                    ),
                    if (isEnabled)
                      ListTile(
                        title: Text(
                          l10n.reminderTime,
                          style: TextStyle(
                            fontFamily: "Cairo",
                            fontSize: 14.sp,
                            color: isDark ? Colors.white70 : Colors.black54,
                          ),
                        ),
                        trailing: Text(
                          time.format(context),
                          style: TextStyle(
                            color: AppColors.islamicGold,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        onTap: () async {
                          final t = await showTimePicker(
                            context: context,
                            initialTime: time,
                          );
                          if (t != null) {
                            setDialogState(() {
                              time = t;
                            });
                          }
                        },
                      ),
                    SizedBox(height: 24.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text(
                            l10n.cancel,
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                        SizedBox(width: 8.w),
                        ElevatedButton(
                          onPressed: () async {
                            await _repository.updateKhatmaReminder(
                              id: k.id,
                              enabled: isEnabled,
                              time: time,
                              title: l10n.khatmaReminderTitle,
                              body: l10n.khatmaReminderBody(k.name),
                            );
                            if (mounted) {
                              _loadKhatma(); // Refresh UI
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(l10n.saved),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.islamicGold,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            l10n.save,
                            style: TextStyle(
                              fontFamily: "Bakra",
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
