import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/hadith_repository.dart';
import 'hadith_chapters_screen.dart';
import 'package:fazakkir/l10n/app_localizations.dart';
import 'hadith_search_delegate.dart';

class HadithBooksScreen extends StatelessWidget {
  const HadithBooksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final books = HadithRepository.availableBooks;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.hadithBooks,
          style: TextStyle(
            fontFamily: "Bakra",
            fontSize: 22.sp,
            color: isDark ? AppColors.islamicGold : AppColors.islamicBrown,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(
          color: isDark ? Colors.white : AppColors.islamicBrown,
        ),
        actions: [
          IconButton(
            onPressed: () {
              showSearch(context: context, delegate: HadithSearchDelegate());
            },
            icon: const Icon(Icons.search_rounded),
          ),
        ],
      ),
      body: GridView.builder(
        padding: EdgeInsets.all(16.w),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, // 2 columns
          crossAxisSpacing: 16.w,
          mainAxisSpacing: 16.h,
          childAspectRatio: 1.2,
        ),
        itemCount: books.length,
        itemBuilder: (context, index) {
          final fileName = books[index];
          final bookName = HadithRepository.bookNames[fileName] ?? fileName;

          return _buildBookCard(context, fileName, bookName, isDark);
        },
      ),
    );
  }

  Widget _buildBookCard(
    BuildContext context,
    String fileName,
    String bookName,
    bool isDark,
  ) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                HadithChaptersScreen(fileName: fileName, bookName: bookName),
          ),
        );
      },
      child: Container(
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
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.menu_book_rounded,
              color: AppColors.islamicGold,
              size: 40.sp,
            ),
            SizedBox(height: 12.h),
            Text(
              bookName,
              style: TextStyle(
                color: isDark ? Colors.white : AppColors.islamicBrown,
                fontSize: 16.sp,
                fontFamily: "Cairo",
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
