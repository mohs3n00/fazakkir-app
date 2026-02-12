import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fazakkir/core/theme/app_colors.dart';
import 'package:fazakkir/core/theme/app_theme.dart';
import 'package:fazakkir/features/quran/data/reciters_data.dart';
import 'package:fazakkir/features/quran/presentation/controllers/audio_controller.dart';

class ReciterSelectionSheet extends ConsumerWidget {
  const ReciterSelectionSheet({super.key});

  static Future<void> show(BuildContext context) async {
    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Theme(
        data: AppTheme.lightTheme,
        child: const ReciterSelectionSheet(),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch current reader from provider
    final currentReader = ref.watch(audioControllerProvider).currentReaderId;

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark ? AppColors.darkSurface : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black;

    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      child: Column(
        children: [
          SizedBox(height: 16.h),
          // Handle
          Container(
            width: 40.w,
            height: 5.h,
            decoration: BoxDecoration(
              color: isDark ? Colors.white24 : Colors.grey[300],
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          SizedBox(height: 20.h),
          Text(
            "اختر القارئ",
            style: TextStyle(
              fontFamily: "Bakra",
              fontSize: 20.sp,
              color: AppColors.islamicGold,
            ),
          ),
          SizedBox(height: 20.h),
          Expanded(
            child: ListView.separated(
              itemCount: reciters.length,
              separatorBuilder: (context, index) => Divider(
                color: isDark ? Colors.white10 : Colors.grey[200],
                indent: 20,
                endIndent: 20,
              ),
              itemBuilder: (context, index) {
                final reciter = reciters[index];
                final isSelected = reciter.identifier == currentReader;

                return ListTile(
                  contentPadding: EdgeInsets.symmetric(horizontal: 24.w),
                  onTap: () {
                    // Update via controller (which also updates Prefs now)
                    ref
                        .read(audioControllerProvider.notifier)
                        .changeReader(reciter.identifier);
                    Navigator.pop(context);
                  },
                  leading: CircleAvatar(
                    backgroundColor: isSelected
                        ? AppColors.islamicGold
                        : (isDark ? Colors.white10 : Colors.grey[100]),
                    child: Icon(
                      Icons.person_rounded,
                      color: isSelected
                          ? Colors.white
                          : (isDark ? Colors.white54 : Colors.grey),
                    ),
                  ),
                  title: Text(
                    reciter.name,
                    style: TextStyle(
                      fontFamily: "Cairo",
                      fontSize: 16.sp,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                      color: isSelected ? AppColors.islamicGold : textColor,
                    ),
                  ),
                  subtitle: Text(
                    reciter.englishName,
                    style: TextStyle(
                      fontFamily: "Cairo",
                      fontSize: 12.sp,
                      color: isDark ? Colors.white38 : Colors.grey,
                    ),
                  ),
                  trailing: isSelected
                      ? Icon(
                          Icons.check_circle_rounded,
                          color: AppColors.islamicGold,
                        )
                      : null,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
