import 'package:fazakkir/core/services/sqlite_service.dart';

import 'package:fazakkir/features/reminders/data/reminder_preferences.dart';
import 'package:fazakkir/features/quran/services/tafsir_database_service.dart';
import 'package:fazakkir/features/quran/services/quran_font_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'preferences/app_preferences.dart';

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('SharedPreferences not initialized');
});

final appPreferencesProvider = Provider<AppPreferences>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return AppPreferences(prefs);
});

final sqliteServiceProvider = Provider<SQLiteService>((ref) {
  return SQLiteService();
});

final tafsirDatabaseServiceProvider = Provider<TafsirDatabaseService>((ref) {
  final sqliteService = ref.watch(sqliteServiceProvider);
  return TafsirDatabaseService(sqliteService);
});

final reminderPreferencesProvider = Provider<ReminderPreferences>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return ReminderPreferences(prefs);
});

final quranFontServiceProvider = Provider<QuranFontService>((ref) {
  return QuranFontService();
});
