import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppPreferences {
  static const String keyThemeMode = 'theme_mode';
  static const String keyLocale = 'locale';

  // Notification Keys
  static const String keyMorningAzkarEnabled = 'morning_azkar_enabled';
  static const String keyMorningAzkarTime = 'morning_azkar_time'; // "HH:mm"
  static const String keyEveningAzkarEnabled = 'evening_azkar_enabled';
  static const String keyEveningAzkarTime = 'evening_azkar_time'; // "HH:mm"
  static const String keyPeriodicEnabled = 'periodic_enabled';
  static const String keyPeriodicInterval = 'periodic_interval';
  static const String keyDuhaEnabled = 'duha_enabled';
  static const String keyQiyamEnabled = 'qiyam_enabled';
  static const String keyWitrEnabled = 'witr_enabled';

  final SharedPreferences _prefs;
  AppPreferences(this._prefs);

  ThemeMode getThemeMode() {
    final val = _prefs.getString(keyThemeMode);
    if (val == 'light') return ThemeMode.light;
    if (val == 'dark') return ThemeMode.dark;
    return ThemeMode.system;
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    String val = 'system';
    if (mode == ThemeMode.light) val = 'light';
    if (mode == ThemeMode.dark) val = 'dark';
    await _prefs.setString(keyThemeMode, val);
  }

  Locale? getLocale() {
    final val = _prefs.getString(keyLocale);
    if (val == null) return null; // System default
    return Locale(val);
  }

  Future<void> setLocale(Locale? locale) async {
    if (locale == null) {
      await _prefs.remove(keyLocale);
    } else {
      await _prefs.setString(keyLocale, locale.languageCode);
    }
  }

  // Morning Azkar
  bool getMorningAzkarEnabled() =>
      _prefs.getBool(keyMorningAzkarEnabled) ?? false;
  Future<void> setMorningAzkarEnabled(bool val) =>
      _prefs.setBool(keyMorningAzkarEnabled, val);

  TimeOfDay getMorningAzkarTime() {
    final s = _prefs.getString(keyMorningAzkarTime);
    if (s == null) return const TimeOfDay(hour: 6, minute: 0);
    return _parseTime(s);
  }

  Future<void> setMorningAzkarTime(TimeOfDay t) =>
      _prefs.setString(keyMorningAzkarTime, _formatTime(t));

  // Evening Azkar
  bool getEveningAzkarEnabled() =>
      _prefs.getBool(keyEveningAzkarEnabled) ?? false;
  Future<void> setEveningAzkarEnabled(bool val) =>
      _prefs.setBool(keyEveningAzkarEnabled, val);

  TimeOfDay getEveningAzkarTime() {
    final s = _prefs.getString(keyEveningAzkarTime);
    if (s == null) return const TimeOfDay(hour: 18, minute: 0); // 6 PM
    return _parseTime(s);
  }

  Future<void> setEveningAzkarTime(TimeOfDay t) =>
      _prefs.setString(keyEveningAzkarTime, _formatTime(t));

  // Periodic
  bool getPeriodicEnabled() => _prefs.getBool(keyPeriodicEnabled) ?? false;
  Future<void> setPeriodicEnabled(bool val) =>
      _prefs.setBool(keyPeriodicEnabled, val);

  String getPeriodicInterval() =>
      _prefs.getString(keyPeriodicInterval) ?? '30m';
  Future<void> setPeriodicInterval(String val) =>
      _prefs.setString(keyPeriodicInterval, val);

  // Sunan (Duha, Qiyam, Witr)
  bool getDuhaEnabled() => _prefs.getBool(keyDuhaEnabled) ?? false;
  Future<void> setDuhaEnabled(bool val) => _prefs.setBool(keyDuhaEnabled, val);

  bool getQiyamEnabled() => _prefs.getBool(keyQiyamEnabled) ?? false;
  Future<void> setQiyamEnabled(bool val) =>
      _prefs.setBool(keyQiyamEnabled, val);

  bool getWitrEnabled() => _prefs.getBool(keyWitrEnabled) ?? false;
  Future<void> setWitrEnabled(bool val) => _prefs.setBool(keyWitrEnabled, val);

  // Helpers
  String _formatTime(TimeOfDay t) => '${t.hour}:${t.minute}';

  TimeOfDay _parseTime(String s) {
    final parts = s.split(':');
    if (parts.length != 2) return const TimeOfDay(hour: 6, minute: 0);
    return TimeOfDay(
      hour: int.tryParse(parts[0]) ?? 6,
      minute: int.tryParse(parts[1]) ?? 0,
    );
  }
}
