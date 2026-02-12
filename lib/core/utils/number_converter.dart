import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class NumberConverter {
  static String convert(
    Object number, {
    BuildContext? context,
    bool forceArabic = false,
  }) {
    String str = number.toString();
    if (forceArabic) {
      return _toArabic(str);
    }

    // If context is provided, check locale
    if (context != null) {
      final locale = Localizations.localeOf(context);
      if (locale.languageCode == 'ar') {
        return _toArabic(str);
      }
    } else {
      // Fallback to Intl.defaultLocale
      if (Intl.defaultLocale?.startsWith('ar') ?? false) {
        return _toArabic(str);
      }
    }

    return str;
  }

  static String _toArabic(String input) {
    const english = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    const arabic = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];

    for (int i = 0; i < english.length; i++) {
      input = input.replaceAll(english[i], arabic[i]);
    }
    return input;
  }
}
