import 'package:shared_preferences/shared_preferences.dart';

class ReminderPreferences {
  static const String keyProphetEnabled = 'prophet_reminder_enabled';
  static const String keyProphetInterval = 'prophet_reminder_interval';
  static const String keyProphetAudio = 'prophet_reminder_audio';
  static const String keyPrePrayerEnabled = 'pre_prayer_reminder_enabled';
  static const String keyPrePrayerOffset = 'pre_prayer_reminder_offset';

  final SharedPreferences _prefs;

  ReminderPreferences(this._prefs);

  // Prophet Reminder
  bool get isProphetEnabled => _prefs.getBool(keyProphetEnabled) ?? false;
  Future<void> setProphetEnabled(bool value) =>
      _prefs.setBool(keyProphetEnabled, value);

  int get prophetIntervalMinutes =>
      _prefs.getInt(keyProphetInterval) ?? 60; // Default 1 hour
  Future<void> setProphetInterval(int minutes) =>
      _prefs.setInt(keyProphetInterval, minutes);

  String get prophetAudio =>
      _prefs.getString(keyProphetAudio) ??
      'assets/audio/prophet_prayers/mishary.mp3';
  Future<void> setProphetAudio(String path) =>
      _prefs.setString(keyProphetAudio, path);

  // Pre-Prayer Reminder
  bool get isPrePrayerEnabled => _prefs.getBool(keyPrePrayerEnabled) ?? false;
  Future<void> setPrePrayerEnabled(bool value) =>
      _prefs.setBool(keyPrePrayerEnabled, value);

  int get prePrayerOffsetMinutes =>
      _prefs.getInt(keyPrePrayerOffset) ?? 10; // Default 10 min
  Future<void> setPrePrayerOffset(int minutes) =>
      _prefs.setInt(keyPrePrayerOffset, minutes);
}
