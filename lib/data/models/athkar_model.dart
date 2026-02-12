class DhikrCategory {
  final int id;
  final String category;
  final String audio;
  final String filename;
  final List<DhikrItem> items;

  DhikrCategory({
    required this.id,
    required this.category,
    required this.audio,
    required this.filename,
    required this.items,
  });

  factory DhikrCategory.fromJson(Map<String, dynamic> json) {
    return DhikrCategory(
      id: json['id'] as int? ?? 0,
      category: json['category'] as String? ?? '',
      audio: json['audio'] as String? ?? '',
      filename: json['filename'] as String? ?? '',
      items:
          (json['array'] as List<dynamic>?)
              ?.map((e) => DhikrItem.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class DhikrItem {
  final int id;
  final String text;
  final int count;
  final String audio;
  final String filename;

  DhikrItem({
    required this.id,
    required this.text,
    required this.count,
    required this.audio,
    required this.filename,
  });

  factory DhikrItem.fromJson(Map<String, dynamic> json) {
    return DhikrItem(
      id: json['id'] as int? ?? 0,
      text: json['text'] as String? ?? '',
      count: json['count'] as int? ?? 1,
      audio: json['audio'] as String? ?? '',
      filename: json['filename'] as String? ?? '',
    );
  }
}
