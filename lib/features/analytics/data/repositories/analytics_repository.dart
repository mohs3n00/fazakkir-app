import 'package:hive/hive.dart';

class AnalyticsRepository {
  static final AnalyticsRepository _instance = AnalyticsRepository._internal();
  factory AnalyticsRepository() => _instance;
  AnalyticsRepository._internal();

  Future<Box> _getBox() async {
    if (!Hive.isBoxOpen('analytics_box')) {
      return await Hive.openBox('analytics_box');
    }
    return Hive.box('analytics_box');
  }

  Future<void> incrementTasbihMonthly() async {
    final box = await _getBox();
    final dateKey = _getCurrentMonthKey();

    // Increment Total
    final total = box.get('total_tasbih', defaultValue: 0) as int;
    await box.put('total_tasbih', total + 1);

    // Increment Monthly
    final monthlyKey = 'tasbih_$dateKey';
    final monthly = box.get(monthlyKey, defaultValue: 0) as int;
    await box.put(monthlyKey, monthly + 1);
  }

  Future<void> incrementQuranPagesMonthly(int count) async {
    final box = await _getBox();
    final dateKey = _getCurrentMonthKey();

    // Increment Total
    final total = box.get('total_quran_pages', defaultValue: 0) as int;
    await box.put('total_quran_pages', total + count);

    // Increment Monthly
    final monthlyKey = 'quran_pages_$dateKey';
    final monthly = box.get(monthlyKey, defaultValue: 0) as int;
    await box.put(monthlyKey, monthly + count);
  }

  Future<void> incrementKhatmaMonthly() async {
    final box = await _getBox();
    final dateKey = _getCurrentMonthKey();

    // Increment Total
    final total = box.get('total_khatmas', defaultValue: 0) as int;
    await box.put('total_khatmas', total + 1);

    // Increment Monthly
    final monthlyKey = 'khatma_$dateKey';
    final monthly = box.get(monthlyKey, defaultValue: 0) as int;
    await box.put(monthlyKey, monthly + 1);
  }

  String _getCurrentMonthKey() {
    final now = DateTime.now();
    return "${now.year}_${now.month}";
  }

  // Keeping old methods for backward compatibility if needed, but redirecting logic
  // actually, let's keep them as "Total Only" helpers if needed, but better to use new ones.
  // The interface used by existing code is:
  // incrementTasbih() -> void
  // incrementQuranPages(int) -> void
  // incrementKhatmaCompleted() -> void

  // Refactoring existing methods to call new monthly ones to ensure data consistency
  Future<void> incrementTasbih() async => incrementTasbihMonthly();

  Future<void> incrementQuranPages(int count) async =>
      incrementQuranPagesMonthly(count);

  Future<void> incrementKhatmaCompleted() async => incrementKhatmaMonthly();

  Future<int> getTotalTasbih() async {
    final box = await _getBox();
    return box.get('total_tasbih', defaultValue: 0) as int;
  }

  Future<int> getTotalQuranPages() async {
    final box = await _getBox();
    return box.get('total_quran_pages', defaultValue: 0) as int;
  }

  Future<int> getTotalKhatmas() async {
    final box = await _getBox();
    return box.get('total_khatmas', defaultValue: 0) as int;
  }

  Future<int> getMonthlyTasbih() async {
    final box = await _getBox();
    final key = 'tasbih_${_getCurrentMonthKey()}';
    return box.get(key, defaultValue: 0) as int;
  }

  Future<int> getMonthlyQuranPages() async {
    final box = await _getBox();
    final key = 'quran_pages_${_getCurrentMonthKey()}';
    return box.get(key, defaultValue: 0) as int;
  }

  Future<int> getMonthlyKhatmas() async {
    final box = await _getBox();
    final key = 'khatma_${_getCurrentMonthKey()}';
    return box.get(key, defaultValue: 0) as int;
  }

  Future<Map<String, int>> getStats() async {
    return {
      'tasbih': await getMonthlyTasbih(),
      'quran_pages': await getMonthlyQuranPages(),
      'khatma': await getMonthlyKhatmas(),
      // We can also return totals if we want to show them somewhere else
      'total_tasbih': await getTotalTasbih(),
      'total_quran_pages': await getTotalQuranPages(),
      'total_khatmas': await getTotalKhatmas(),
    };
  }
}
