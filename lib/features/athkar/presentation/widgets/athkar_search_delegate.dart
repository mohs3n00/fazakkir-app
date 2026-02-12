import 'package:fazakkir/core/utils/string_extensions.dart';
import 'package:fazakkir/core/widgets/search_highlight_text.dart';
import 'package:fazakkir/features/athkar/athkar_screen.dart';
import 'package:fazakkir/data/models/athkar_model.dart';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AthkarSearchDelegate extends SearchDelegate {
  final List<DhikrCategory> allAthkar;

  AthkarSearchDelegate({required this.allAthkar});

  @override
  String get searchFieldLabel => "بحث في الأذكار";

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
          onPressed: () {
            query = '';
            showSuggestions(context);
          },
          icon: const Icon(Icons.clear),
        ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      onPressed: () => close(context, null),
      icon: const Icon(Icons.arrow_back),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildSearchResults(context);
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
              "ابحث عن أي ذكر أو دعاء",
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
    return _buildSearchResults(context);
  }

  Widget _buildSearchResults(BuildContext context) {
    final normalizedQuery = query.normalizeArabic();

    // 1. Filter Categories
    final matchedCategories = allAthkar.where((cat) {
      return cat.category.normalizeArabic().contains(normalizedQuery);
    }).toList();

    // 2. Filter Individual Items (Flat list)
    final List<(DhikrItem, String)> matchedItems = []; // (Item, CategoryName)

    for (var cat in allAthkar) {
      for (var item in cat.items) {
        if (item.text.normalizeArabic().contains(normalizedQuery)) {
          matchedItems.add((item, cat.category));
        }
      }
    }

    if (matchedCategories.isEmpty && matchedItems.isEmpty) {
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
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      physics: const ClampingScrollPhysics(),
      children: [
        // CATEGORIES SECTION
        if (matchedCategories.isNotEmpty) ...[
          Text(
            "التصنيفات",
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
              fontFamily: "Cairo",
            ),
          ),
          SizedBox(height: 8.h),
          ...matchedCategories.map(
            (cat) => Card(
              margin: EdgeInsets.symmetric(vertical: 4.h),
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: ListTile(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => AthkarDetailScreen(category: cat),
                    ),
                  );
                },
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16.w,
                  vertical: 4.h,
                ),
                leading: CircleAvatar(
                  backgroundColor: Theme.of(
                    context,
                  ).primaryColor.withOpacity(0.1),
                  child: Icon(
                    Icons.folder_open,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                title: SearchHighlightText(
                  text: cat.category,
                  query: normalizedQuery,
                  style: TextStyle(
                    fontFamily: "Cairo",
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                  highlightColor: const Color(0xFFFFD54F),
                ),
                trailing: Icon(
                  Icons.arrow_forward_ios,
                  size: 14.sp,
                  color: Colors.grey,
                ),
              ),
            ),
          ),
          SizedBox(height: 24.h),
        ],

        // ITEMS SECTION
        if (matchedItems.isNotEmpty) ...[
          Text(
            "الأذكار",
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
              fontFamily: "Cairo",
            ),
          ),
          SizedBox(height: 8.h),
          ...matchedItems.map(
            (match) =>
                _buildItemTile(context, match.$1, match.$2, normalizedQuery),
          ),
        ],
      ],
    );
  }

  Widget _buildItemTile(
    BuildContext context,
    DhikrItem item,
    String categoryName,
    String normalizedQuery,
  ) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 6.h),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12.r),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => AthkarDetailScreen(
                category: allAthkar.firstWhere(
                  (c) => c.category == categoryName,
                ),
              ),
            ),
          );
        },
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SearchHighlightText(
                text: item.text,
                query: normalizedQuery,
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: "UthmanicHafs1 Ver13",
                  fontSize: 18.sp,
                  height: 1.6,
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                ),
                highlightColor: const Color(0xFFFFD54F),
              ),
              SizedBox(height: 12.h),
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.w,
                      vertical: 4.h,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Text(
                      categoryName,
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontFamily: "Cairo",
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
