import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../data/quran_library/quran.dart' as quran;
import '../../data/hizb_data_helper.dart';
import '../delegates/quran_search_delegate.dart';
import '../../../../core/utils/number_converter.dart';

class QuranIndexScreen extends StatefulWidget {
  const QuranIndexScreen({super.key});

  @override
  State<QuranIndexScreen> createState() => _QuranIndexScreenState();
}

class _QuranIndexScreenState extends State<QuranIndexScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final Color kPrimaryColor = const Color(0xff805528);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffFFFCE7),
      appBar: AppBar(
        title: Text(
          "الفهرس",
          style: TextStyle(
            color: kPrimaryColor,
            fontFamily: "UthmanicHafs1 Ver13",
            fontSize: 22.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: kPrimaryColor),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.search, color: kPrimaryColor),
            onPressed: () async {
              final page = await showSearch(
                context: context,
                delegate: QuranSearchDelegate(),
              );
              if (page != null && mounted) {
                Navigator.pop(context, page);
              }
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: kPrimaryColor,
          unselectedLabelColor: Colors.grey,
          indicatorColor: kPrimaryColor,
          labelStyle: TextStyle(
            fontSize: 16.sp,
            fontFamily: "Cairo",
            fontWeight: FontWeight.bold,
          ),
          tabs: const [
            Tab(text: "سورة"),
            Tab(text: "جزء"),
            Tab(text: "حزب"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildSurahList(), _buildJuzList(), _buildQuarterList()],
      ),
    );
  }

  Widget _buildSurahList() {
    return ListView.builder(
      itemCount: 114,
      padding: EdgeInsets.all(8.w),
      itemBuilder: (context, index) {
        int surahNum = index + 1;
        return Card(
          color: Colors.white.withOpacity(0.7),
          elevation: 0,
          margin: EdgeInsets.symmetric(vertical: 4.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
            side: BorderSide(color: kPrimaryColor.withOpacity(0.2)),
          ),
          child: ListTile(
            contentPadding: EdgeInsets.symmetric(
              horizontal: 16.w,
              vertical: 4.h,
            ),
            leading: Container(
              width: 40.w,
              height: 40.w,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: const AssetImage("assets/images/888-02.png"),
                  colorFilter: ColorFilter.mode(kPrimaryColor, BlendMode.srcIn),
                ),
              ),
              child: Center(
                child: Text(
                  NumberConverter.convert(surahNum, forceArabic: true),
                  style: TextStyle(
                    color: kPrimaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            title: Text(
              quran.getSurahNameArabic(surahNum),
              style: TextStyle(
                fontFamily: "UthmanicHafs1 Ver13",
                fontSize: 20.sp,
                color: Colors.black87,
              ),
            ),
            trailing: Text(
              "${NumberConverter.convert(quran.getVerseCount(surahNum), forceArabic: true)} آية",
              style: TextStyle(
                fontFamily: "Cairo",
                fontSize: 12.sp,
                color: Colors.grey,
              ),
            ),
            onTap: () {
              Navigator.pop(context, quran.getPageNumber(surahNum, 1));
            },
          ),
        );
      },
    );
  }

  Widget _buildJuzList() {
    return ListView.builder(
      itemCount: 30,
      padding: EdgeInsets.all(8.w),
      itemBuilder: (context, index) {
        int juz = index + 1;
        return Card(
          margin: EdgeInsets.symmetric(vertical: 4.h),
          child: ListTile(
            title: Text(
              "الجزء ${NumberConverter.convert(juz, forceArabic: true)}",
              style: TextStyle(fontFamily: "Cairo", fontSize: 18.sp),
            ),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              Navigator.pop(context, _getPageForJuz(juz));
            },
          ),
        );
      },
    );
  }

  Widget _buildQuarterList() {
    final quarters = HizbDataHelper.quarters;
    if (quarters.isEmpty) {
      return const Center(child: Text("جاري تحميل البيانات..."));
    }

    return ListView.builder(
      itemCount: quarters.length,
      itemBuilder: (context, index) {
        final q = quarters[index];
        return ListTile(
          title: Text(
            "حزب ${NumberConverter.convert((index ~/ 4) + 1, forceArabic: true)} - ربع ${NumberConverter.convert((index % 4) + 1, forceArabic: true)}",
          ),
          subtitle: Text(
            "سورة ${quran.getSurahNameArabic(q['surah'])} - آية ${NumberConverter.convert(q['ayah'], forceArabic: true)}",
          ),
          onTap: () {
            Navigator.pop(context, quran.getPageNumber(q['surah'], q['ayah']));
          },
        );
      },
    );
  }

  int _getPageForJuz(int juz) {
    // Get the first surah and verse of this Juz
    try {
      final surahAndVerses = quran.getSurahAndVersesFromJuz(juz);
      if (surahAndVerses.isNotEmpty) {
        final firstSurah = surahAndVerses.keys.first;
        final firstVerse = surahAndVerses[firstSurah]![0];
        return quran.getPageNumber(firstSurah, firstVerse);
      }
    } catch (e) {
      // Fallback if error
      return 1 + (juz - 1) * 20; // Rough estimate
    }
    return 1;
  }
}
