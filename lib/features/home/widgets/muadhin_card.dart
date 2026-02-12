import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_colors.dart';

class MuadhinCard extends StatelessWidget {
  const MuadhinCard({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: isDark ? Colors.white10 : Colors.black.withOpacity(0.03),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.volume_up_rounded,
                color: AppColors.islamicGold,
                size: 24.sp,
              ),
              SizedBox(width: 10.w),
              Text(
                "المؤذن",
                style: TextStyle(
                  fontFamily: "Bakra",
                  fontSize: 18.sp,
                  color: isDark
                      ? AppColors.islamicGold
                      : AppColors.islamicBrown,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withOpacity(0.05)
                  : AppColors.islamicGold.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: AppColors.islamicGold.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20.r,
                  backgroundColor: AppColors.islamicGold.withOpacity(0.2),
                  child: Icon(
                    Icons.person,
                    color: AppColors.islamicGold,
                    size: 24.sp,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "مشاري راشد العفاسي", // Placeholder default
                        style: TextStyle(
                          fontFamily: "Cairo",
                          fontWeight: FontWeight.bold,
                          fontSize: 14.sp,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                      ),
                      Text(
                        "صلاة الفجر", // Placeholder
                        style: TextStyle(
                          fontFamily: "Cairo",
                          fontSize: 12.sp,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () {
                    // TODO: Implement playback logic
                  },
                  icon: Icon(
                    Icons.play_circle_fill,
                    color: AppColors.islamicGold,
                    size: 32.sp,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
