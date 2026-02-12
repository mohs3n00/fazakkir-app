import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/hadith_repository.dart';
import 'hadith_list_screen.dart';
import '../../../../core/utils/number_converter.dart';

class HadithChaptersScreen extends StatefulWidget {
  final String fileName;
  final String bookName;

  const HadithChaptersScreen({
    super.key,
    required this.fileName,
    required this.bookName,
  });

  @override
  State<HadithChaptersScreen> createState() => _HadithChaptersScreenState();
}

class _HadithChaptersScreenState extends State<HadithChaptersScreen> {
  final HadithRepository _repository = HadithRepository();
  late Future<dynamic>
  _bookFuture; // HadithBook is dynamic for now to avoid verbose typing if import is tricky

  @override
  void initState() {
    super.initState();
    _bookFuture = _repository.loadBook(widget.fileName);
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.bookName,
          style: TextStyle(
            fontFamily: "Bakra",
            fontSize: 20.sp,
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
      body: FutureBuilder(
        future: _bookFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }
          if (!snapshot.hasData) {
            return const Center(child: Text("No Data"));
          }

          final book = snapshot.data; // HadithBook
          final chapters = book.chapters;

          return ListView.separated(
            padding: EdgeInsets.all(16.w),
            itemCount: chapters.length,
            separatorBuilder: (context, index) => SizedBox(height: 12.h),
            itemBuilder: (context, index) {
              final chapter = chapters[index];
              return _buildChapterTile(context, chapter, book, isDark);
            },
          );
        },
      ),
    );
  }

  Widget _buildChapterTile(
    BuildContext context,
    dynamic chapter, // HadithChapter
    dynamic book, // HadithBook
    bool isDark,
  ) {
    return ListTile(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => HadithListScreen(
              chapter: chapter,
              allHadiths: book
                  .hadiths, // Pass all hadiths to filter inside next screen or filter here
            ),
          ),
        );
      },
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
        side: BorderSide(color: isDark ? Colors.white12 : Colors.black12),
      ),
      tileColor: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
      leading: Container(
        padding: EdgeInsets.all(8.w),
        decoration: BoxDecoration(
          color: AppColors.islamicGold.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Text(
          NumberConverter.convert(chapter.id, forceArabic: true),
          style: TextStyle(
            color: AppColors.islamicGold,
            fontWeight: FontWeight.bold,
            fontSize: 14.sp,
          ),
        ),
      ),
      title: Text(
        chapter.arabic,
        style: TextStyle(
          fontFamily: "Cairo",
          fontSize: 16.sp,
          fontWeight: FontWeight.w600,
          color: isDark ? Colors.white : AppColors.islamicBrown,
        ),
      ),
      // subtitle: Text(chapter.english), // Optional
      trailing: Icon(
        Icons.arrow_forward_ios,
        size: 16.sp,
        color: isDark ? Colors.white54 : Colors.grey,
      ),
    );
  }
}
