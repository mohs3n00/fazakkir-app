import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers.dart';

final themeProvider = NotifierProvider<ThemeNotifier, ThemeMode>(
  ThemeNotifier.new,
);

class ThemeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() {
    return ref.watch(appPreferencesProvider).getThemeMode();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = mode;
    await ref.read(appPreferencesProvider).setThemeMode(mode);
  }
}
