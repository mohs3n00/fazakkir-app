import 'dart:ui';
import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers.dart';

final languageProvider = NotifierProvider<LanguageNotifier, Locale?>(
  LanguageNotifier.new,
);

class LanguageNotifier extends Notifier<Locale?> {
  @override
  Locale? build() {
    return ref.watch(appPreferencesProvider).getLocale();
  }

  Future<void> setLocale(Locale? locale) async {
    state = locale;
    if (locale != null) {
      // Update Intl default locale so formatted dates/numbers pick it up
      // We might need to handle country codes, but usually language code is enough for numbers/dates
      Intl.defaultLocale = locale.languageCode;
    }
    await ref.read(appPreferencesProvider).setLocale(locale);
  }
}
