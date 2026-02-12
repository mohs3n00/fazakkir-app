import 'package:fazakkir/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'logic/sebha_provider.dart';
import 'presentation/widgets/sebha_beads_widget.dart';
import '../../../core/widgets/ramadan_background.dart';
import 'package:fazakkir/l10n/app_localizations.dart';

class SebhaScreen extends ConsumerWidget {
  const SebhaScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sebhaState = ref.watch(sebhaProvider);
    final notifier = ref.read(sebhaProvider.notifier);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.electronicRosary,
          style: TextStyle(
            fontFamily: "Bakra",
            color: isDark ? AppColors.islamicGold : AppColors.islamicBrown,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(
          color: isDark ? AppColors.islamicGold : AppColors.islamicBrown,
        ),
        // actions: [
        //   IconButton(
        //     icon: const Icon(Icons.refresh),
        //     onPressed: notifier.reset,
        //   ),
        // ],
      ),
      body: RamadanBackground(
        child: Stack(
          children: [
            Column(
              children: [
                SizedBox(height: 100.h),

                // Thikr Display & Selector
                GestureDetector(
                  onTap: () {
                    _showThikrSelector(context, notifier);
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 24.w,
                      vertical: 12.h,
                    ),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF2C2C2C) : Colors.white,
                      borderRadius: BorderRadius.circular(30.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(
                          child: Text(
                            sebhaState.currentThikr,
                            style: TextStyle(
                              fontFamily: "Bakra",
                              fontSize: 18.sp, // Reduced from 22.sp
                              color: isDark
                                  ? AppColors.islamicGold
                                  : AppColors.islamicBrown,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: isDark ? Colors.white70 : Colors.black54,
                        ),
                      ],
                    ),
                  ),
                ),

                // Counter Display Row
                Expanded(
                  flex: 2,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // RESET Button (Small Left)
                      IconButton(
                        onPressed: notifier.reset,
                        icon: Icon(
                          Icons.refresh_rounded,
                          color: Colors.grey.withOpacity(0.8),
                          size: 28.sp,
                        ),
                        tooltip: "تصفير",
                      ),

                      SizedBox(width: 20.w),

                      // Main Counter
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "${sebhaState.counter}",
                            style: TextStyle(
                              fontFamily: "Bakra",
                              fontSize: 80.sp,
                              color: isDark
                                  ? Colors.white
                                  : AppColors.islamicBrown,
                              fontWeight: FontWeight.bold,
                              height: 1.0,
                            ),
                          ),
                          Text(
                            "Total: ${sebhaState.totalCount}",
                            style: TextStyle(
                              fontFamily: "Cairo",
                              fontSize: 14.sp,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),

                      SizedBox(width: 20.w),

                      // TARGET Button (Small Right)
                      GestureDetector(
                        onTap: notifier.toggleTarget,
                        child: Container(
                          width: 40.w,
                          height: 40.w,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.grey.withOpacity(0.5),
                              width: 1.5,
                            ),
                          ),
                          child: Text(
                            sebhaState.target == 0
                                ? "∞"
                                : "${sebhaState.target}",
                            style: TextStyle(
                              fontFamily: "Cairo",
                              fontWeight: FontWeight.bold,
                              fontSize: 14.sp,
                              color: isDark
                                  ? Colors.white
                                  : AppColors.islamicBrown,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Interactive Beads Area
                Expanded(
                  flex: 4,
                  child: GestureDetector(
                    onTap: notifier.increment,
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      width: double.infinity,
                      alignment: Alignment.center,
                      child: const SebhaBeadsWidget(),
                    ),
                  ),
                ),

                SizedBox(height: 50.h),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showThikrSelector(BuildContext context, SebhaController notifier) {
    final l10n = AppLocalizations.of(context)!;
    final thikrs = [
      l10n.thikr1,
      l10n.thikr2,
      l10n.thikr3,
      l10n.thikr4,
      l10n.thikr5,
      l10n.thikr6,
      l10n.thikr7,
      l10n.thikr8,
      l10n.thikr9,
    ];

    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(16.w),
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.6,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "اختر الذكر",
                style: TextStyle(
                  fontFamily: "Bakra",
                  fontSize: 18.sp,
                  color: isDark
                      ? AppColors.islamicGold
                      : AppColors.islamicBrown,
                ),
              ),
              SizedBox(height: 16.h),
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const ClampingScrollPhysics(),
                  itemCount: thikrs.length,
                  separatorBuilder: (c, i) =>
                      Divider(color: Colors.grey.withOpacity(0.2)),
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(
                        thikrs[index],
                        style: TextStyle(
                          fontFamily: "Cairo",
                          fontSize: 16.sp,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      onTap: () {
                        notifier.setThikr(thikrs[index]);
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
