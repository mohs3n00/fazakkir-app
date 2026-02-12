import 'dart:convert';
import 'dart:io';
import 'package:fazakkir/features/quran/data/translation/muyassar.dart';
import 'package:fazakkir/features/quran/data/translation/sahih_english.dart';
import 'package:fazakkir/features/quran/data/translation/translation_info.dart';
import 'package:path_provider/path_provider.dart';

class TranslationHelper {
  static Future<String> getVerseTranslation(
    int surahNumber,
    int verseNumber,
    TranslationData translation,
  ) async {
    List<dynamic> translationDataList = [];

    // Check locally included files first (Hardcoded assets)
    if (translation.typeAsEnumValue == TranslationType.ar_muyassar) {
      translationDataList = muyassar;
    } else if (translation.typeAsEnumValue == TranslationType.en_sahih) {
      translationDataList = en_sahih;
    } else {
      // Check downloaded files in Application Documents Directory
      try {
        final docDir = await getApplicationDocumentsDirectory();
        // We assume files are stored in 'tafseer' subdir or root of docDir based on legacy.
        // New standard: docDir/tafseer/filename.json
        // Fallback: check docDir/filename.json (legacy)

        File file = File("${docDir.path}/tafseer/${translation.typeText}.json");
        if (!await file.exists()) {
          // Try legacy path or simple path
          file = File("${docDir.path}/${translation.typeText}.json");
        }

        if (await file.exists()) {
          String jsonData = await file.readAsString();
          translationDataList = json.decode(jsonData);
        } else {
          // Try temporary directory as last resort (legacy cache)
          final tempDir = await getTemporaryDirectory();
          file = File("${tempDir.path}/${translation.typeText}.json");
          if (await file.exists()) {
            String jsonData = await file.readAsString();
            translationDataList = json.decode(jsonData);
          } else {
            return "Download required";
          }
        }
      } catch (e) {
        // Error loading translation file
        return "Error loading translation";
      }
    }

    String verse = "";
    for (var item in translationDataList) {
      if (item['sura'].toString() == surahNumber.toString() &&
          item['aya'].toString() == verseNumber.toString()) {
        verse = item['text'];
        break;
      }
    }

    if (verse == "") {
      return "Translation not found for $surahNumber:$verseNumber";
    }

    return verse.replaceAll("<br>", "\n");
  }
}
