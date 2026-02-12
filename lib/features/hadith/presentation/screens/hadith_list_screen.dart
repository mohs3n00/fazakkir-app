import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/models/hadith_model.dart';
import 'package:fazakkir/l10n/app_localizations.dart';
import '../../../../core/utils/number_converter.dart';

class HadithListScreen extends StatefulWidget {
  final HadithChapter chapter;
  final List<Hadith> allHadiths;
  final int? highlightHadithId;

  const HadithListScreen({
    super.key,
    required this.chapter,
    required this.allHadiths,
    this.highlightHadithId,
  });

  @override
  State<HadithListScreen> createState() => _HadithListScreenState();
}

class _HadithListScreenState extends State<HadithListScreen> {
  final ItemScrollController _itemScrollController = ItemScrollController();
  final ItemPositionsListener _itemPositionsListener =
      ItemPositionsListener.create();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.highlightHadithId != null) {
        _scrollToHighlighted();
      }
    });
  }

  void _scrollToHighlighted() {
    final index = widget.allHadiths
        .where((h) => h.chapterId == widget.chapter.id)
        .toList()
        .indexWhere((h) => h.id == widget.highlightHadithId);

    if (index != -1) {
      _itemScrollController.jumpTo(index: index);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    // Filter Hadiths for this chapter
    final chapterHadiths = widget.allHadiths
        .where((h) => h.chapterId == widget.chapter.id)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.chapter.arabic,
          style: TextStyle(
            fontFamily: "Bakra",
            fontSize: 18.sp,
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
      body: chapterHadiths.isEmpty
          ? const Center(child: Text("لا توجد أحاديث في هذا الباب"))
          : ScrollablePositionedList.separated(
              itemScrollController: _itemScrollController,
              itemPositionsListener: _itemPositionsListener,
              padding: EdgeInsets.all(16.w),
              itemCount: chapterHadiths.length,
              separatorBuilder: (context, index) => SizedBox(height: 16.h),
              itemBuilder: (context, index) {
                final hadith = chapterHadiths[index];
                final bool isHighlighted =
                    hadith.id == widget.highlightHadithId;

                return _buildHadithCard(context, hadith, isDark, isHighlighted);
              },
            ),
    );
  }

  Widget _buildHadithCard(
    BuildContext context,
    Hadith hadith,
    bool isDark,
    bool isHighlighted,
  ) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: isHighlighted
            ? Border.all(color: AppColors.islamicGold, width: 2)
            : Border.all(
                color: isDark
                    ? Colors.white.withOpacity(0.1)
                    : AppColors.islamicBrown.withOpacity(0.1),
              ),
        boxShadow: [
          if (!isDark && !isHighlighted)
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          if (isHighlighted)
            BoxShadow(
              color: AppColors.islamicGold.withOpacity(0.3),
              blurRadius: 12,
              spreadRadius: 2,
            ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header: Number + Actions
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: AppColors.islamicGold.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Text(
                  NumberConverter.convert(hadith.idInBook, forceArabic: true),
                  style: TextStyle(
                    color: AppColors.islamicGold,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                icon: Icon(Icons.copy, size: 20.sp, color: Colors.grey),
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: hadith.arabic));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(AppLocalizations.of(context)!.hadithCopied),
                    ),
                  );
                },
              ),
            ],
          ),
          SizedBox(height: 12.h),

          // Arabic Text
          Text(
            hadith.arabic,
            textAlign: TextAlign.justify,
            style: TextStyle(
              fontSize: 18.sp,
              fontFamily: "Amiri", // Use readable font
              height: 1.8,
              color: isDark ? Colors.white : AppColors.islamicBrown,
            ),
          ),

          if (hadith.english.text.isNotEmpty) ...[
            Divider(height: 30.h),
            Text(
              "Narrated: ${hadith.english.narrator}",
              style: TextStyle(
                fontStyle: FontStyle.italic,
                color: Colors.grey,
                fontSize: 14.sp,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              hadith.english.text,
              style: TextStyle(
                fontSize: 16.sp,
                fontFamily: "Roboto",
                height: 1.5,
                color: isDark ? Colors.white70 : Colors.black87,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
