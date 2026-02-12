import '../../../../core/utils/string_extensions.dart';

class HadithBook {
  final int id;
  final HadithBookMetadata metadata;
  final List<HadithChapter> chapters;
  final List<Hadith> hadiths;

  HadithBook({
    required this.id,
    required this.metadata,
    required this.chapters,
    required this.hadiths,
  });

  factory HadithBook.fromJson(Map<String, dynamic> json) {
    return HadithBook(
      id: json['id'] as int? ?? 0,
      metadata: HadithBookMetadata.fromJson(json['metadata'] ?? {}),
      chapters:
          (json['chapters'] as List<dynamic>?)
              ?.map((e) => HadithChapter.fromJson(e))
              .toList() ??
          [],
      hadiths:
          (json['hadiths'] as List<dynamic>?)
              ?.map((e) => Hadith.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class HadithBookMetadata {
  final int id;
  final int length;
  final LocalizedMetadata arabic;
  final LocalizedMetadata english;

  HadithBookMetadata({
    required this.id,
    required this.length,
    required this.arabic,
    required this.english,
  });

  factory HadithBookMetadata.fromJson(Map<String, dynamic> json) {
    return HadithBookMetadata(
      id: json['id'] as int? ?? 0,
      length: json['length'] as int? ?? 0,
      arabic: LocalizedMetadata.fromJson(json['arabic'] ?? {}),
      english: LocalizedMetadata.fromJson(json['english'] ?? {}),
    );
  }
}

class LocalizedMetadata {
  final String title;
  final String author;
  final String introduction;

  LocalizedMetadata({
    required this.title,
    required this.author,
    required this.introduction,
  });

  factory LocalizedMetadata.fromJson(Map<String, dynamic> json) {
    return LocalizedMetadata(
      title: json['title'] as String? ?? '',
      author: json['author'] as String? ?? '',
      introduction: json['introduction'] as String? ?? '',
    );
  }
}

class HadithChapter {
  final int id;
  final int bookId;
  final String arabic;
  final String english;

  HadithChapter({
    required this.id,
    required this.bookId,
    required this.arabic,
    required this.english,
  });

  factory HadithChapter.fromJson(Map<String, dynamic> json) {
    return HadithChapter(
      id: json['id'] as int? ?? 0,
      bookId: json['bookId'] as int? ?? 0,
      arabic: json['arabic'] as String? ?? '',
      english: json['english'] as String? ?? '',
    );
  }
}

class Hadith {
  final int id;
  final int idInBook;
  final int chapterId;
  final int bookId;
  final String arabic;
  final String normalizedArabic;
  final HadithTranslation english;

  Hadith({
    required this.id,
    required this.idInBook,
    required this.chapterId,
    required this.bookId,
    required this.arabic,
    required this.normalizedArabic,
    required this.english,
  });

  factory Hadith.fromJson(Map<String, dynamic> json) {
    final arabicText = json['arabic'] as String? ?? '';
    return Hadith(
      id: json['id'] as int? ?? 0,
      idInBook: json['idInBook'] as int? ?? 0,
      chapterId: json['chapterId'] as int? ?? 0,
      bookId: json['bookId'] as int? ?? 0,
      arabic: arabicText,
      normalizedArabic: arabicText.normalizeArabic(),
      english: HadithTranslation.fromJson(json['english'] ?? {}),
    );
  }
}

class HadithTranslation {
  final String narrator;
  final String text;

  HadithTranslation({required this.narrator, required this.text});

  factory HadithTranslation.fromJson(Map<String, dynamic> json) {
    return HadithTranslation(
      narrator: json['narrator'] as String? ?? '',
      text: json['text'] as String? ?? '',
    );
  }
}
