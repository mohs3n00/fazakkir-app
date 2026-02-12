import 'package:flutter/material.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../athkar/athkar_screen.dart';
import '../../../../data/models/athkar_model.dart';
import '../../data/duas_data.dart';

class DuasScreen extends StatelessWidget {
  const DuasScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final categories = DuasData.duas;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          "الأدعية",
          style: TextStyle(
            fontFamily: "Bakra",
            fontSize: 24.sp,
            color: isDark ? AppColors.islamicGold : AppColors.islamicBrown,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(
          color: isDark ? Colors.white : AppColors.islamicBrown,
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkBackground : AppColors.lightBackground,
          // Reuse pattern logic if desired, or keep clean
        ),
        child: Stack(
          children: [
            // Background Pattern
            Positioned.fill(
              child: Opacity(
                opacity: 0.05,
                child: SvgPicture.asset(
                  "assets/images/prayer_header_pattern.svg",
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(
                    isDark ? Colors.white : AppColors.islamicBrown,
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ),

            ListView.builder(
              padding: EdgeInsets.fromLTRB(16.w, 100.h, 16.w, 20.h),
              itemCount: categories.length,
              physics: const ClampingScrollPhysics(),
              itemBuilder: (context, index) {
                return _buildCategoryCard(context, categories[index], isDark);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryCard(
    BuildContext context,
    DhikrCategory category,
    bool isDark,
  ) {
    return GestureDetector(
      onTap: () {
        // Reuse AthkarDetailScreen since the model is compatible!
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => AthkarDetailScreen(category: category),
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: isDark
                ? Colors.white.withOpacity(0.1)
                : AppColors.islamicBrown.withOpacity(0.1),
          ),
          boxShadow: [
            if (!isDark)
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: AppColors.islamicGold.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.volunteer_activism,
                color: AppColors.islamicGold,
                size: 24.sp,
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Text(
                category.category,
                style: TextStyle(
                  color: isDark ? Colors.white : AppColors.islamicBrown,
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  fontFamily: "Bakra",
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: isDark ? Colors.white24 : Colors.grey,
              size: 16.sp,
            ),
          ],
        ),
      ),
    );
  }
}
