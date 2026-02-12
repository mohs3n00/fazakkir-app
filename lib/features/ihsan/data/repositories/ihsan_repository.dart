import 'package:hive/hive.dart';
import '../models/ihsan_model.dart';

class IhsanRepository {
  static const String boxName = 'ihsan_box';

  Future<Box<DailyProgress>> _openBox() async {
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(DailyProgressAdapter());
    }
    return await Hive.openBox<DailyProgress>(boxName);
  }

  Future<DailyProgress> getDayProgress(DateTime date) async {
    final box = await _openBox();
    final key = _dateKey(date);
    return box.get(key) ?? DailyProgress.empty(key);
  }

  Future<void> updateProgress(
    DateTime date,
    String habitKey,
    bool value,
  ) async {
    final box = await _openBox();
    final key = _dateKey(date);
    DailyProgress current = box.get(key) ?? DailyProgress.empty(key);

    // Create new map to ensure Hive detects change
    final newHabits = Map<String, bool>.from(current.habits);
    newHabits[habitKey] = value;

    final updated = DailyProgress(date: key, habits: newHabits);
    await box.put(key, updated);
  }

  // Get last 7 days including today
  Future<List<DailyProgress>> getWeeklyProgress() async {
    final box = await _openBox();
    final now = DateTime.now();
    List<DailyProgress> list = [];

    for (int i = 6; i >= 0; i--) {
      final d = now.subtract(Duration(days: i));
      final key = _dateKey(d);
      list.add(box.get(key) ?? DailyProgress.empty(key));
    }
    return list;
  }

  String _dateKey(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }
}
