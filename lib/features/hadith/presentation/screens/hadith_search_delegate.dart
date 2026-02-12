import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fazakkir/core/widgets/search_highlight_text.dart';
import '../../data/hadith_repository.dart';
import '../../data/models/hadith_model.dart';
import 'hadith_list_screen.dart';

class HadithSearchDelegate extends SearchDelegate<String> {
  final HadithRepository repository = HadithRepository();

  @override
  String get searchFieldLabel => 'بحث في الأحاديث...';

  @override
  ThemeData appBarTheme(BuildContext context) {
    final theme = Theme.of(context);
    return theme.copyWith(
      appBarTheme: theme.appBarTheme.copyWith(
        elevation: 0,
        backgroundColor: theme.scaffoldBackgroundColor,
        iconTheme: IconThemeData(color: theme.primaryColor),
      ),
      inputDecorationTheme: InputDecorationTheme(
        hintStyle: TextStyle(color: Colors.grey, fontSize: 16.sp),
        border: InputBorder.none,
      ),
      textTheme: theme.textTheme.copyWith(
        titleLarge: TextStyle(
          color: theme.primaryColor,
          fontSize: 18.sp,
          fontFamily: "Cairo",
        ),
      ),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: theme.primaryColor,
        selectionColor: theme.primaryColor.withOpacity(0.3),
      ),
    );
  }

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () {
            query = '';
            showSuggestions(context);
          },
        ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, '');
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    if (query.trim().length < 3) {
      return Center(
        child: Text(
          "اكتب 3 أحرف على الأقل للبحث",
          style: TextStyle(
            fontFamily: "Cairo",
            fontSize: 16.sp,
            color: Colors.grey,
          ),
        ),
      );
    }

    return FutureBuilder<List<Map<String, dynamic>>>(
      future: repository.searchAll(query),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(
              color: Theme.of(context).primaryColor,
            ),
          );
        } else if (snapshot.hasError) {
          return Center(child: Text("حدث خطأ: ${snapshot.error}"));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.search_off, size: 64.sp, color: Colors.grey),
                SizedBox(height: 16.h),
                Text(
                  "لم يتم العثور على نتائج",
                  style: TextStyle(
                    fontFamily: "Cairo",
                    fontSize: 16.sp,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          );
        }

        final results = snapshot.data!;

        return ListView.builder(
          padding: EdgeInsets.all(16.w),
          itemCount: results.length,
          itemBuilder: (context, index) {
            final item = results[index];
            final bookName = item['book'] ?? "";
            final hadith = item['hadith'] as Hadith;
            final bookObject = item['bookObject'] as HadithBook;

            // SAFE NAVIGATION FIX:
            // Find the EXACT chapter. Do not fallback to first chapter.
            HadithChapter? chapter;
            try {
              // Try to find the matching chapter
              chapter = bookObject.chapters.firstWhere(
                (c) => c.id == hadith.chapterId,
              );
            } catch (e) {
              chapter = null;
            }

            return Card(
              margin: EdgeInsets.only(bottom: 12.h),
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(12.r),
                onTap: () {
                  if (chapter == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          "عذراً، لم يتم العثور على فصل هذا الحديث",
                          style: TextStyle(fontFamily: "Cairo"),
                        ),
                      ),
                    );
                    return;
                  }

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => HadithListScreen(
                        chapter: chapter!, // We checked for null above
                        allHadiths: bookObject.hadiths,
                        highlightHadithId: hadith.id,
                      ),
                    ),
                  );
                },
                child: Padding(
                  padding: EdgeInsets.all(16.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Header: Book & Chapter
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8.w,
                              vertical: 4.h,
                            ),
                            decoration: BoxDecoration(
                              color: Theme.of(
                                context,
                              ).primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            child: Text(
                              bookName,
                              style: TextStyle(
                                fontFamily: "Cairo",
                                fontSize: 10.sp,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                          ),
                          SizedBox(width: 8.w),
                          Expanded(
                            child: Text(
                              chapter?.arabic ?? "فصل غير معروف",
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontFamily: "Cairo",
                                fontSize: 10.sp,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                          Text(
                            "#${hadith.idInBook}",
                            style: TextStyle(
                              fontFamily: "Roboto",
                              fontSize: 12.sp,
                              color: Colors.grey.withOpacity(0.5),
                            ),
                          ),
                        ],
                      ),
                      Divider(
                        height: 24.h,
                        color: Colors.grey.withOpacity(0.1),
                      ),
                      // Hadith Text with Highlight
                      _buildHighlightedText(context, hadith.arabic, query),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildHighlightedText(
    BuildContext context,
    String text,
    String query,
  ) {
    return SearchHighlightText(
      text: text,
      query: query,
      maxLines: 3,
      overflow: TextOverflow.ellipsis,
      textAlign: TextAlign.justify,
      style: TextStyle(
        fontFamily: "Amiri",
        fontSize: 16.sp,
        height: 1.6,
        color: Theme.of(context).textTheme.bodyMedium?.color,
      ),
      highlightColor: const Color(0xFFFFD54F),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_rounded,
            size: 64.sp,
            color: Colors.grey.withOpacity(0.3),
          ),
          SizedBox(height: 16.h),
          Text(
            "ابحث في الكتب التسعة",
            style: TextStyle(
              fontFamily: "Cairo",
              fontSize: 16.sp,
              color: Colors.grey,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            "اضغط بحث لإظهار النتائج",
            style: TextStyle(
              fontFamily: "Cairo",
              fontSize: 12.sp,
              color: Colors.grey.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }
}
