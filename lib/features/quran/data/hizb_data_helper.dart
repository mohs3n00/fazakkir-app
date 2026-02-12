import 'dart:convert';
import 'package:flutter/services.dart';

class HizbDataHelper {
  static List<dynamic> _quartersData = [];

  static Future<void> loadQuarters() async {
    if (_quartersData.isNotEmpty) return;
    try {
      final String response = await rootBundle.loadString(
        'assets/quran/quarters.json',
      );
      final data = json.decode(response);
      // Ensure data is a list
      if (data is List) {
        _quartersData = data;
      } else if (data is Map && data.containsKey('data')) {
        _quartersData = data['data']; // Adjust based on actual structure
      } else {
        _quartersData = [];
      }
    } catch (e) {
      // Error loading quarters data
    }
  }

  static List<dynamic> get quarters => _quartersData;

  // Find if a page has a Hizb/Quarter mark
  // This logic is adapted from Skoon's QuranPageUtils
  static String getQuarterText(List<dynamic> pageData) {
    if (_quartersData.isEmpty) return "";

    for (var i = 0; i < _quartersData.length; i++) {
      int qSurah = _quartersData[i]['surah'];
      int qAyah = _quartersData[i]['ayah'];

      // Check if this quarter start is in the page data
      for (var pageSurahData in pageData) {
        int pSurah = pageSurahData['surah'];
        int pStart = pageSurahData['start'];
        int pEnd = pageSurahData['end'];

        if (qSurah == pSurah && qAyah >= pStart && qAyah <= pEnd) {
          // Found a quarter start on this page
          // Calculate Hizb and Quarter index
          // 240 quarters total.
          // Hizb = (i / 4) + 1 (integer division)
          // Quarter of Hizb = (i % 4) + 1
          int hizb = (i ~/ 4) + 1;
          int quarter = (i % 4) + 1;

          String qText = "";
          if (quarter == 1) {
            qText = "الحزب $hizb";
          } else if (quarter == 2)
            qText = "ربع الحزب $hizb";
          else if (quarter == 3)
            qText = "نصف الحزب $hizb";
          else if (quarter == 4)
            qText = "ثلاثة أرباع الحزب $hizb";

          return qText;
        }
      }
    }
    return "";
  }
}
