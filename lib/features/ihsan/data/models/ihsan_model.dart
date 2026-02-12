import 'package:hive/hive.dart';

class DailyProgress {
  final String date; // yyyy-mm-dd
  final Map<String, bool> habits;
  // Habits keys: fajr, dhuhr, asr, maghrib, isha, sunnah_qiyam, sunnah_duha, athkar_morning, athkar_evening, quran, witr

  DailyProgress({required this.date, required this.habits});

  factory DailyProgress.empty(String date) {
    return DailyProgress(
      date: date,
      habits: {
        'fajr': false,
        'dhuhr': false,
        'asr': false,
        'maghrib': false,
        'isha': false,
        'sunnah_qiyam': false,
        'sunnah_duha': false,
        'athkar_morning': false,
        'athkar_evening': false,
        'quran': false,
        'witr': false,
      },
    );
  }
}

class DailyProgressAdapter extends TypeAdapter<DailyProgress> {
  @override
  final int typeId = 1;

  @override
  DailyProgress read(BinaryReader reader) {
    final date = reader.readString();
    final habits = Map<String, bool>.from(reader.read());
    return DailyProgress(date: date, habits: habits);
  }

  @override
  void write(BinaryWriter writer, DailyProgress obj) {
    writer.writeString(obj.date);
    writer.write(obj.habits);
  }
}
