import 'dart:convert';
import 'package:flutter/services.dart';
import 'models/hadith_model.dart';

class HadithRepository {
  // Cache loaded books to avoid reloading
  static final Map<String, HadithBook> _cache = {};

  // List of available book files
  static final List<String> availableBooks = [
    "bukhari.json",
    "muslim.json",
    "ahmed.json",
    "abudawud.json",
    "darimi.json",
    "ibnmajah.json",
    "malik.json",
    "nasai.json",
    "tirmidhi.json",
  ];

  static final Map<String, String> bookNames = {
    "bukhari.json": "صحيح البخاري",
    "muslim.json": "صحيح مسلم",
    "ahmed.json": "مسند أحمد",
    "abudawud.json": "سنن أبي داود",
    "darimi.json": "سنن الدارمي",
    "ibnmajah.json": "سنن ابن ماجه",
    "malik.json": "موطأ مالك",
    "nasai.json": "سنن النسائي",
    "tirmidhi.json": "جامع الترمذي",
  };

  /// Loads a specific book by filename
  Future<HadithBook> loadBook(String filename) async {
    if (_cache.containsKey(filename)) {
      return _cache[filename]!;
    }

    try {
      final String jsonString = await rootBundle.loadString(
        'assets/json/hadith/$filename',
      );
      final Map<String, dynamic> jsonData = json.decode(jsonString);
      final book = HadithBook.fromJson(jsonData);
      _cache[filename] = book;
      return book;
    } catch (e) {
      throw Exception("Failed to load book $filename: $e");
    }
  }

  /// Searches for a query in a specific book
  Future<List<Hadith>> searchInBook(String filename, String query) async {
    final book = await loadBook(filename);
    if (query.isEmpty) return [];

    final normalizedQuery = _normalize(query);
    final queryWords = normalizedQuery
        .split(' ')
        .where((w) => w.isNotEmpty)
        .toList();

    return book.hadiths.where((hadith) {
      // Check if ALL query words are present in the hadith
      return queryWords.every(
            (word) => hadith.normalizedArabic.contains(word),
          ) ||
          hadith.english.text.toLowerCase().contains(query.toLowerCase());
    }).toList();
  }

  /// Searches across all books (computationally expensive, use with caution)
  Future<List<Map<String, dynamic>>> searchAll(String query) async {
    List<Map<String, dynamic>> results = [];
    final normalizedQuery = _normalize(query);
    final queryWords = normalizedQuery
        .split(' ')
        .where((w) => w.isNotEmpty)
        .toList();

    for (String file in availableBooks) {
      // Don't await strictly sequential if possible, but load one by one to save memory
      // Or load all if memory allows. Mobile devices might struggle with huge JSONs at once.
      // Let's load sequentially.
      final book = await loadBook(file);
      final matches = book.hadiths.where((hadith) {
        // Use pre-computed normalized text
        return queryWords.every(
          (word) => hadith.normalizedArabic.contains(word),
        );
        // || hadith.english.text.toLowerCase().contains(query.toLowerCase()); // Focus on Arabic for now
      }).toList();

      for (var match in matches) {
        results.add({
          "book": book.metadata.arabic.title,
          "hadith": match,
          "bookObject": book, // Pass full book object for navigation
        });
      }
    }
    return results;
  }

  String _normalize(String text) {
    // Basic normalization: remove diacritics, unification of alefs, etc.
    // Ensure you have this logic or import it.
    // For now, simple implementation inline if not importing string_extensions globally here.
    // Assuming you have string_extensions.dart, but standardizing here for this method.
    var normalized = text;
    // Remove diacritics
    normalized = normalized.replaceAll(
      RegExp(r'[\u064B-\u065F\u06D6-\u06DC\u06DF-\u06E8\u06EA-\u06ED]'),
      '',
    );
    // Normalize Alefs
    normalized = normalized.replaceAll(RegExp(r'[أإآ]'), 'ا');
    normalized = normalized.replaceAll(RegExp(r'ة'), 'ه');
    normalized = normalized.replaceAll(RegExp(r'ى'), 'ي');
    return normalized;
  }
}
