// import 'package:fazakkir/core/providers.dart';
import 'package:fazakkir/core/theme/app_colors.dart';
import 'package:fazakkir/features/quran/data/quran_library/quran.dart';

import 'package:fazakkir/features/quran/presentation/controllers/audio_controller.dart';
import 'package:fazakkir/features/quran/presentation/widgets/reciter_selection_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MiniAudioPlayer extends ConsumerWidget {
  const MiniAudioPlayer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final audioState = ref.watch(audioControllerProvider);

    // Only show if playing or active
    if (audioState.currentSurah == null || audioState.currentAyah == null) {
      return const SizedBox.shrink();
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark
        ? AppColors.darkSurface
        : AppColors.lightSurface;
    final textColor = isDark ? AppColors.darkText : AppColors.lightText;

    return Container(
      margin: EdgeInsets.all(12.w),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4)),
        ],
      ),
      child: Row(
        children: [
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  getSurahNameArabic(audioState.currentSurah!),
                  style: TextStyle(
                    fontFamily: "Bakra",
                    fontSize: 14.sp,
                    color: textColor,
                  ),
                ),
                Text(
                  "الآية ${audioState.currentAyah}",
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: textColor.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),

          // Controls
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(Icons.skip_next, color: AppColors.islamicGold),
                onPressed: () =>
                    ref.read(audioControllerProvider.notifier).prevAyah(),
              ),
              if (audioState.isLoading)
                SizedBox(
                  width: 24.w,
                  height: 24.w,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.islamicGold,
                  ),
                )
              else
                IconButton(
                  icon: Icon(
                    audioState.isPlaying
                        ? Icons.pause_circle_filled
                        : Icons.play_circle_filled,
                    color: AppColors.islamicGold,
                    size: 32.sp,
                  ),
                  onPressed: () {
                    if (audioState.isPlaying) {
                      ref.read(audioControllerProvider.notifier).pause();
                    } else {
                      ref.read(audioControllerProvider.notifier).resume();
                    }
                  },
                ),
              IconButton(
                icon: Icon(Icons.skip_previous, color: AppColors.islamicGold),
                onPressed: () =>
                    ref.read(audioControllerProvider.notifier).nextAyah(),
              ),
              SizedBox(width: 4.w),
              IconButton(
                icon: Icon(
                  Icons.settings,
                  color: textColor.withOpacity(0.5),
                  size: 20.sp,
                ),
                onPressed: () => ReciterSelectionSheet.show(context),
              ),
              // Close Button
              Container(
                margin: EdgeInsets.symmetric(horizontal: 4.w),
                width: 1.w,
                height: 20.h,
                color: textColor.withOpacity(0.1),
              ),
              IconButton(
                icon: Icon(Icons.close, color: Colors.redAccent, size: 20.sp),
                onPressed: () =>
                    ref.read(audioControllerProvider.notifier).stop(),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
