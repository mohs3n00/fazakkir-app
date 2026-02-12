import 'package:hive/hive.dart';

class Khatma {
  final String id;
  final String name;
  final DateTime startDate;
  final DateTime? targetDate;
  final int startPage;
  final int endPage;
  final int currentPage;
  final int? dailyPageGoal;
  final bool isCompleted;
  final bool reminderEnabled;
  final DateTime? reminderTime;

  Khatma({
    required this.id,
    required this.name,
    required this.startDate,
    this.targetDate,
    this.startPage = 1,
    this.endPage = 604,
    this.currentPage = 0,
    this.dailyPageGoal,
    this.isCompleted = false,
    this.reminderEnabled = false,
    this.reminderTime,
  });

  Khatma copyWith({
    String? name,
    DateTime? targetDate,
    int? currentPage,
    bool? isCompleted,
    bool? reminderEnabled,
    DateTime? reminderTime,
  }) {
    return Khatma(
      id: id,
      name: name ?? this.name,
      startDate: startDate,
      targetDate: targetDate ?? this.targetDate,
      startPage: startPage,
      endPage: endPage,
      currentPage: currentPage ?? this.currentPage,
      dailyPageGoal: dailyPageGoal,
      isCompleted: isCompleted ?? this.isCompleted,
      reminderEnabled: reminderEnabled ?? this.reminderEnabled,
      reminderTime: reminderTime ?? this.reminderTime,
    );
  }

  int get pagesRemaining => endPage - currentPage;

  double get progress => (currentPage / endPage).clamp(0.0, 1.0);
}

class KhatmaAdapter extends TypeAdapter<Khatma> {
  @override
  final int typeId = 2;

  @override
  Khatma read(BinaryReader reader) {
    final id = reader.readString();
    final name = reader.readString();
    final startDate = DateTime.fromMillisecondsSinceEpoch(reader.readInt());
    final targetDate = reader.readBool()
        ? DateTime.fromMillisecondsSinceEpoch(reader.readInt())
        : null;
    final startPage = reader.readInt();
    final endPage = reader.readInt();
    final currentPage = reader.readInt();
    final dailyPageGoal = reader.readBool() ? reader.readInt() : null;
    final isCompleted = reader.readBool();

    // New fields with backward compatibility
    bool reminderEnabled = false;
    DateTime? reminderTime;

    try {
      // Try to read reminderEnabled
      // We check if we can read a bool.
      // Note: This relies on Hive throwing an error if EOF is reached.
      // However, Hive's BinaryReader might not expose EOF easily.
      // But typically manual adapters are tricky.
      // Since we can't easily check for EOF, we'll assume new data has it.
      // If this throws, it means it's old data.
      reminderEnabled = reader.readBool();

      if (reader.readBool()) {
        reminderTime = DateTime.fromMillisecondsSinceEpoch(reader.readInt());
      }
    } catch (e) {
      // End of valid data for old objects, use defaults
    }

    return Khatma(
      id: id,
      name: name,
      startDate: startDate,
      targetDate: targetDate,
      startPage: startPage,
      endPage: endPage,
      currentPage: currentPage,
      dailyPageGoal: dailyPageGoal,
      isCompleted: isCompleted,
      reminderEnabled: reminderEnabled,
      reminderTime: reminderTime,
    );
  }

  @override
  void write(BinaryWriter writer, Khatma obj) {
    writer.writeString(obj.id);
    writer.writeString(obj.name);
    writer.writeInt(obj.startDate.millisecondsSinceEpoch);

    writer.writeBool(obj.targetDate != null);
    if (obj.targetDate != null) {
      writer.writeInt(obj.targetDate!.millisecondsSinceEpoch);
    }

    writer.writeInt(obj.startPage);
    writer.writeInt(obj.endPage);
    writer.writeInt(obj.currentPage);

    writer.writeBool(obj.dailyPageGoal != null);
    if (obj.dailyPageGoal != null) writer.writeInt(obj.dailyPageGoal!);

    writer.writeBool(obj.isCompleted);

    // New fields
    writer.writeBool(obj.reminderEnabled);
    writer.writeBool(obj.reminderTime != null);
    if (obj.reminderTime != null) {
      writer.writeInt(obj.reminderTime!.millisecondsSinceEpoch);
    }
  }
}
