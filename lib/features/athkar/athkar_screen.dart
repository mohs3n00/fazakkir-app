import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../core/theme/app_colors.dart';
import '../../data/athkar_repository.dart';
import '../../data/models/athkar_model.dart';
import '../../features/analytics/data/repositories/analytics_repository.dart';
import 'presentation/widgets/athkar_search_delegate.dart';

import '../../core/utils/number_converter.dart';
import '../../core/widgets/ramadan_background.dart';

class AthkarScreen extends ConsumerWidget {
  const AthkarScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final athkarAsync = ref.watch(athkarListProvider);
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'الأذكار',
          style: TextStyle(
            color: isDark ? AppColors.islamicGold : AppColors.islamicBrown,
            fontFamily: "Bakra",
            fontSize: 24.sp,
          ),
        ),
        iconTheme: IconThemeData(
          color: isDark ? Colors.white : AppColors.islamicBrown,
        ),
        actions: [
          IconButton(
            onPressed: () {
              athkarAsync.whenData((data) {
                showSearch(
                  context: context,
                  delegate: AthkarSearchDelegate(allAthkar: data),
                );
              });
            },
            icon: const Icon(Icons.search),
            tooltip: "بحث",
          ),
          SizedBox(width: 8.w),
        ],
      ),
      body: RamadanBackground(
        child: Container(
          // Removed opacity pattern & gradient cause they are in RamadanBackground now, or we keep them?
          // User asked for "transparency and design rules".
          // The original code had a gradient and SVG pattern.
          // RamadanBackground has image + gradient.
          // Let's keep the content clean.
          child: athkarAsync.when(
            data: (categories) => ListView.builder(
              padding: EdgeInsets.fromLTRB(16.w, 100.h, 16.w, 20.h),
              itemCount: categories.length,
              physics: const ClampingScrollPhysics(),
              itemBuilder: (context, index) {
                final category = categories[index];
                return _buildCategoryCard(context, category, isDark);
              },
            ),
            loading: () => const Center(
              child: CircularProgressIndicator(color: AppColors.islamicGold),
            ),
            error: (err, stack) => Center(
              child: Text(
                'Error: $err',
                style: TextStyle(
                  color: isDark ? Colors.white : AppColors.islamicBrown,
                ),
              ),
            ),
          ),
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
            BoxShadow(
              color: isDark
                  ? Colors.black.withOpacity(0.2)
                  : Colors.grey.withOpacity(0.1),
              blurRadius: 10,
              spreadRadius: 2,
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
                Icons.mosque,
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
                textAlign: TextAlign.start,
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: isDark
                  ? Colors.white24
                  : AppColors.islamicBrown.withOpacity(0.3),
              size: 16.sp,
            ),
          ],
        ),
      ),
    );
  }
}

class AthkarDetailScreen extends StatefulWidget {
  final DhikrCategory category;
  const AthkarDetailScreen({super.key, required this.category});

  @override
  State<AthkarDetailScreen> createState() => _AthkarDetailScreenState();
}

class _AthkarDetailScreenState extends State<AthkarDetailScreen> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  void _nextPage() {
    if (_currentIndex < widget.category.items.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousPage() {
    if (_currentIndex > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: isDark
          ? AppColors.darkBackground
          : AppColors.lightBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          widget.category.category,
          style: TextStyle(
            color: isDark ? AppColors.islamicGold : AppColors.islamicBrown,
            fontFamily: "Bakra",
            fontSize: 20.sp,
          ),
        ),
        iconTheme: IconThemeData(
          color: isDark ? Colors.white : AppColors.islamicBrown,
        ),
      ),
      body: Stack(
        children: [
          // Background
          Positioned.fill(
            child: Opacity(
              opacity: 0.1,
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

          Padding(
            padding: EdgeInsets.only(top: 100.h),
            child: Column(
              children: [
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: widget.category.items.length,
                    physics: const ClampingScrollPhysics(),
                    reverse: true, // RTL: swipe right to go next
                    onPageChanged: (index) {
                      setState(() => _currentIndex = index);
                    },
                    itemBuilder: (context, index) {
                      return _DhikrCounterPage(
                        item: widget.category.items[index],
                        totalItems: widget.category.items.length,
                        currentIndex: index,
                        isDark: isDark,
                      );
                    },
                  ),
                ),

                // Navigation & Pagination
                SafeArea(
                  top: false,
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 24.w,
                      vertical: 4.h,
                    ), // Minimal vertical padding to prevent overflow
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Next Button (Right in RTL - "التالي")
                        _buildNavButton(
                          context,
                          label: "التالي",
                          icon: Icons.arrow_back_ios,
                          onTap: _nextPage,
                          visible:
                              _currentIndex < widget.category.items.length - 1,
                          isDark: isDark,
                        ),

                        // Pagination Text
                        Text(
                          "${NumberConverter.convert(_currentIndex + 1, forceArabic: true)} / ${NumberConverter.convert(widget.category.items.length, forceArabic: true)}",
                          style: TextStyle(
                            color: isDark
                                ? Colors.white54
                                : AppColors.islamicBrown.withOpacity(0.6),
                            fontFamily: "Bakra",
                            fontSize: 16.sp,
                          ),
                        ),

                        // Previous Button (Left in RTL - "السابق")
                        _buildNavButton(
                          context,
                          label: "السابق",
                          icon: Icons.arrow_forward_ios,
                          onTap: _previousPage,
                          visible: _currentIndex > 0,
                          isDark: isDark,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavButton(
    BuildContext context, {
    required String label,
    required IconData icon,
    required VoidCallback onTap,
    required bool visible,
    required bool isDark,
  }) {
    return Visibility(
      visible: visible,
      maintainSize: true,
      maintainAnimation: true,
      maintainState: true,
      child: TextButton.icon(
        onPressed: onTap,
        style: TextButton.styleFrom(
          foregroundColor: isDark
              ? AppColors.islamicGold
              : AppColors.islamicBrown,
        ),
        icon: Icon(icon, size: 16.sp),
        label: Text(
          label,
          style: TextStyle(fontFamily: "Bakra", fontSize: 14.sp),
        ),
      ),
    );
  }
}

class _DhikrCounterPage extends StatefulWidget {
  final DhikrItem item;
  final int totalItems;
  final int currentIndex;
  final bool isDark;

  const _DhikrCounterPage({
    required this.item,
    required this.totalItems,
    required this.currentIndex,
    required this.isDark,
  });

  @override
  State<_DhikrCounterPage> createState() => _DhikrCounterPageState();
}

class _DhikrCounterPageState extends State<_DhikrCounterPage> {
  int _currentCount = 0;
  bool _isCompleted = false;

  @override
  void initState() {
    super.initState();
    _currentCount = 0;
    _isCompleted = widget.item.count == 0;
  }

  @override
  void didUpdateWidget(_DhikrCounterPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.item.id != widget.item.id ||
        oldWidget.item.text != widget.item.text) {
      _currentCount = 0;
      _isCompleted = widget.item.count == 0;
    }
  }

  void _increment() {
    if (_isCompleted) return;

    setState(() {
      _currentCount++;
      if (_currentCount >= widget.item.count) {
        _isCompleted = true;
      }
      // Track Analytics
      AnalyticsRepository().incrementTasbih();
    });
  }

  void _reset() {
    setState(() {
      _currentCount = 0;
      _isCompleted = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final double progress = widget.item.count > 0
        ? _currentCount / widget.item.count
        : 1.0;

    // Check if item has multiple counts (Needs counter)
    final bool hasCounter = widget.item.count > 1;

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 1.sw),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Dhikr Text Card - Maximized
              Expanded(
                flex: hasCounter ? 5 : 8, // Give even more space if no counter
                child: Center(
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(horizontal: 4.w),
                    child: SingleChildScrollView(
                      physics: const ClampingScrollPhysics(),
                      child: Container(
                        padding: EdgeInsets.all(24.w),
                        decoration: BoxDecoration(
                          color: widget.isDark
                              ? Colors.white.withOpacity(0.08)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(24.r),
                          border: Border.all(
                            color: _isCompleted
                                ? AppColors.islamicGold.withOpacity(0.8)
                                : (widget.isDark
                                      ? Colors.white.withOpacity(0.1)
                                      : AppColors.islamicBrown.withOpacity(
                                          0.1,
                                        )),
                            width: _isCompleted ? 2 : 1,
                          ),
                          boxShadow: [
                            if (!widget.isDark)
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.1),
                                blurRadius: 15,
                                offset: Offset(0, 5),
                              ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              widget.item.text,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: widget.isDark
                                    ? Colors.white
                                    : AppColors.islamicBrown,
                                fontSize: 22.sp, // Uthmanic font readable size
                                fontFamily:
                                    "UthmanicHafs1 Ver13", // Authentic Quran Font
                                height:
                                    1.8, // Adjusted line height for Tashkeel
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                            if (hasCounter) ...[
                              SizedBox(height: 16.h),
                              Divider(
                                color: widget.isDark
                                    ? Colors.white10
                                    : Colors.black12,
                              ),
                              SizedBox(height: 8.h),
                              Text(
                                "عدد المرات: ${NumberConverter.convert(widget.item.count, forceArabic: true)}",
                                style: TextStyle(
                                  color: AppColors.islamicGold,
                                  fontSize: 14.sp,
                                  fontFamily: "Bakra",
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              if (hasCounter) SizedBox(height: 16.h),

              // Counter Area (Only if count > 1)
              if (hasCounter)
                Expanded(
                  flex: 2,
                  child: Row(
                    // Row to place Reset next to Counter
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Reset Button (Side)
                      IconButton(
                        onPressed: _reset,
                        icon: Icon(
                          Icons.refresh,
                          color: widget.isDark
                              ? Colors.white54
                              : AppColors.islamicBrown.withOpacity(0.6),
                          size: 28.sp,
                        ),
                        tooltip: "إعادة",
                      ),

                      SizedBox(width: 20.w),

                      // Circular Counter (Center)
                      GestureDetector(
                        onTap: _increment,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Circular Progress
                            SizedBox(
                              width: 90.w,
                              height: 90.w,
                              child: CircularProgressIndicator(
                                value: progress,
                                strokeWidth: 8.w,
                                backgroundColor: widget.isDark
                                    ? Colors.white10
                                    : AppColors.islamicBrown.withOpacity(0.1),
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  _isCompleted
                                      ? const Color(0xFF4CAF50)
                                      : AppColors.islamicGold,
                                ),
                              ),
                            ),
                            // Text Count
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  NumberConverter.convert(
                                    widget.item.count - _currentCount,
                                    forceArabic: true,
                                  ),
                                  style: TextStyle(
                                    color: widget.isDark
                                        ? Colors.white
                                        : AppColors.islamicBrown,
                                    fontSize: 24.sp,
                                    fontWeight: FontWeight.bold,
                                    fontFamily:
                                        "Bakra", // Keep numbers in Bakra
                                  ),
                                ),
                                Text(
                                  "متبقي",
                                  style: TextStyle(
                                    color: widget.isDark
                                        ? Colors.white54
                                        : AppColors.islamicBrown.withOpacity(
                                            0.6,
                                          ),
                                    fontSize: 11.sp,
                                    fontFamily: "Cairo",
                                  ),
                                ),
                              ],
                            ),
                            // Touch Target
                            Container(
                              width: 90.w,
                              height: 90.w,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.transparent,
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(width: 20.w),

                      // Placeholder for symmetry or Checkmark if done
                      SizedBox(
                        width: 40.w,
                        child: _isCompleted
                            ? Container(
                                padding: EdgeInsets.all(8.w),
                                decoration: const BoxDecoration(
                                  color: Color(0xFF4CAF50),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.check,
                                  color: Colors.white,
                                  size: 20.sp,
                                ),
                              )
                            : null,
                      ),
                    ],
                  ),
                )
              else
                SizedBox(height: 20.h), // Minimal spacing if no counter
            ],
          ),
        ),
      ),
    );
  }
}
