import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class QuranPreferences {
  static const String keyBookmarks = 'quran_bookmarks';
  static const String keyLastRead = 'quran_last_read';
  static const String keyStarredVerses = 'quran_starred_verses';

  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Bookmarks: List<Map<String, dynamic>>
  // Format: {surah: int, verse: int, name: String, color: int}
  static List<Map<String, dynamic>> getBookmarks() {
    final String? jsonString = _prefs?.getString(keyBookmarks);
    if (jsonString == null) return [];
    try {
      return List<Map<String, dynamic>>.from(json.decode(jsonString));
    } catch (e) {
      return [];
    }
  }

  static Future<void> addBookmark(
    int surah,
    int verse, {
    String name = "Bookmark",
    int color = 0xFF2196F3,
  }) async {
    List<Map<String, dynamic>> bookmarks = getBookmarks();
    bookmarks.add({
      "surah": surah,
      "verse": verse,
      "name": name,
      "color": color,
    });
    await _prefs?.setString(keyBookmarks, json.encode(bookmarks));
  }

  static Future<void> removeBookmark(int surah, int verse) async {
    List<Map<String, dynamic>> bookmarks = getBookmarks();
    bookmarks.removeWhere(
      (element) => element['surah'] == surah && element['verse'] == verse,
    );
    await _prefs?.setString(keyBookmarks, json.encode(bookmarks));
  }

  static bool isBookmarked(int surah, int verse) {
    List<Map<String, dynamic>> bookmarks = getBookmarks();
    return bookmarks.any(
      (element) => element['surah'] == surah && element['verse'] == verse,
    );
  }

  // Starred Verses (Favorites): Set<String> "surah-verse"
  static Set<String> getStarredVerses() {
    final String? jsonString = _prefs?.getString(keyStarredVerses);
    if (jsonString == null) return {};
    try {
      List<dynamic> list = json.decode(jsonString);
      return list.cast<String>().toSet();
    } catch (e) {
      return {};
    }
  }

  static Future<void> toggleStar(int surah, int verse) async {
    Set<String> stars = getStarredVerses();
    String key = "$surah-$verse";
    if (stars.contains(key)) {
      stars.remove(key);
    } else {
      stars.add(key);
    }
    await _prefs?.setString(keyStarredVerses, json.encode(stars.toList()));
  }

  static bool isStarred(int surah, int verse) {
    Set<String> stars = getStarredVerses();
    return stars.contains("$surah-$verse");
  }

  // Last Read: int pageNumber
  static int getLastReadPage() {
    return _prefs?.getInt(keyLastRead) ?? 1;
  }

  static Future<void> setLastReadPage(int page) async {
    await _prefs?.setInt(keyLastRead, page);
  }

  // Preferred Reciter: String identifier
  static const String keyReciter = 'quran_reciter';
  static const String defaultReciter = 'mishari_rashid_al_afasy';

  static String getReciter() {
    return _prefs?.getString(keyReciter) ?? defaultReciter;
  }

  static Future<void> saveReciter(String identifier) async {
    await _prefs?.setString(keyReciter, identifier);
  }

  // Saved Pages: List<int>
  static const String keySavedPages = 'quran_saved_pages';

  static List<int> getSavedPages() {
    final String? jsonString = _prefs?.getString(keySavedPages);
    if (jsonString == null) return [];
    try {
      List<dynamic> list = json.decode(jsonString);
      return list.cast<int>();
    } catch (e) {
      return [];
    }
  }

  static Future<void> toggleSavedPage(int page) async {
    List<int> pages = getSavedPages();
    if (pages.contains(page)) {
      pages.remove(page);
    } else {
      pages.add(page);
      pages.sort(); // Keep sorted
    }
    await _prefs?.setString(keySavedPages, json.encode(pages));
  }

  static bool isPageSaved(int page) {
    List<int> pages = getSavedPages();
    return pages.contains(page);
  }
}
