import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/widgets/search_highlight_text.dart';
import '../../data/quran_library/quran.dart' as quran;

class QuranSearchDelegate extends SearchDelegate<Map<String, dynamic>?> {
  @override
  String get searchFieldLabel => "بحث في القرآن الكريم";

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
        border: InputBorder.none,
        hintStyle: TextStyle(color: Colors.grey, fontSize: 16.sp),
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
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    // Immediate search on Enter
    return _buildSearchResults(context, query);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    if (query.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search,
              size: 64.sp,
              color: Colors.grey.withOpacity(0.5),
            ),
            SizedBox(height: 16.h),
            Text(
              "ابحث عن سورة أو آية",
              style: TextStyle(
                fontSize: 18.sp,
                color: Colors.grey,
                fontFamily: "Cairo",
              ),
            ),
          ],
        ),
      );
    }

    // Debounced search while typing
    return DebouncedSearchBuilder(
      query: query,
      builder: (context, debouncedQuery) {
        return _buildSearchResults(context, debouncedQuery);
      },
    );
  }

  Widget _buildSearchResults(BuildContext context, String searchQuery) {
    // Robust normalization
    String normalizedQuery = quran.normalise(searchQuery).trim();
    if (normalizedQuery.isEmpty) return const SizedBox.shrink();

    // 1. Search Surahs
    final surahMatches = <int>[];
    for (int i = 1; i <= 114; i++) {
      final nameArabic = quran.getSurahNameArabic(i);
      final normalizedName = quran.normalise(nameArabic);
      if (normalizedName.contains(normalizedQuery)) {
        surahMatches.add(i);
      }
    }

    // 2. Search Ayahs
    final ayahMatches = <Map<String, dynamic>>[];
    // Expand search trigger: length > 2 OR no surah matches
    if (normalizedQuery.length > 2 || surahMatches.isEmpty) {
      final searchResult = quran.searchWords(normalizedQuery);
      final results = searchResult['result'] as List<dynamic>;

      for (var item in results.take(50)) {
        ayahMatches.add({'surah': item['surah'], 'verse': item['verse']});
      }
    }

    if (surahMatches.isEmpty && ayahMatches.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64.sp, color: Colors.grey),
            SizedBox(height: 16.h),
            Text(
              "لا توجد نتائج",
              style: TextStyle(
                fontSize: 18.sp,
                fontFamily: "Cairo",
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    return ListView(
      padding: EdgeInsets.all(16.w),
      children: [
        if (surahMatches.isNotEmpty) ...[
          Text(
            "السور",
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
              fontFamily: "Cairo",
            ),
          ),
          SizedBox(height: 8.h),
          ...surahMatches.map(
            (surahNum) => Card(
              margin: EdgeInsets.symmetric(vertical: 4.h),
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Theme.of(
                    context,
                  ).primaryColor.withOpacity(0.1),
                  child: Text(
                    "$surahNum",
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                title: Text(
                  quran.getSurahNameArabic(surahNum),
                  style: TextStyle(
                    fontFamily: "UthmanicHafs1 Ver13",
                    fontSize: 20.sp,
                  ),
                ),
                onTap: () {
                  final page = quran.getPageNumber(surahNum, 1);
                  close(context, {'page': page, 'surah': surahNum, 'ayah': 1});
                },
              ),
            ),
          ),
          Divider(height: 32.h),
        ],

        if (ayahMatches.isNotEmpty) ...[
          Text(
            "الآيات",
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
              fontFamily: "Cairo",
            ),
          ),
          SizedBox(height: 8.h),
          ...ayahMatches.map((match) {
            final surah = match['surah'] as int;
            final verse = match['verse'] as int;
            final text = quran.getVerse(surah, verse, verseEndSymbol: false);
            final page = quran.getPageNumber(surah, verse);

            return Card(
              margin: EdgeInsets.symmetric(vertical: 6.h),
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(12.r),
                onTap: () {
                  close(context, {'page': page, 'surah': surah, 'ayah': verse});
                },
                child: Padding(
                  padding: EdgeInsets.all(16.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Header: Surah & Verse Number
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                              "${quran.getSurahNameArabic(surah)} - آية $verse",
                              style: TextStyle(
                                fontSize: 12.sp,
                                fontFamily: "Cairo",
                                color: Theme.of(context).primaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Text(
                            "ص $page",
                            style: TextStyle(
                              fontSize: 12.sp,
                              fontFamily: "Cairo",
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12.h),
                      // Ayah Text with Highlight
                      SearchHighlightText(
                        text: text,
                        query: normalizedQuery,
                        style: TextStyle(
                          fontFamily: "UthmanicHafs1 Ver13",
                          fontSize: 20.sp,
                          height: 1.6,
                          color: Theme.of(context).textTheme.bodyMedium?.color,
                        ),
                        highlightColor: const Color(0xFFFFD54F),
                        textAlign: TextAlign.justify,
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ],
    );
  }
}

class DebouncedSearchBuilder extends StatefulWidget {
  final String query;
  final Widget Function(BuildContext context, String debouncedQuery) builder;
  final Duration duration;

  const DebouncedSearchBuilder({
    super.key,
    required this.query,
    required this.builder,
    this.duration = const Duration(milliseconds: 500),
  });

  @override
  State<DebouncedSearchBuilder> createState() => _DebouncedSearchBuilderState();
}

class _DebouncedSearchBuilderState extends State<DebouncedSearchBuilder> {
  late String _debouncedQuery;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _debouncedQuery = widget.query;
  }

  @override
  void didUpdateWidget(DebouncedSearchBuilder oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.query != oldWidget.query) {
      _timer?.cancel();
      _timer = Timer(widget.duration, () {
        if (mounted) {
          setState(() {
            _debouncedQuery = widget.query;
          });
        }
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context, _debouncedQuery);
  }
}
