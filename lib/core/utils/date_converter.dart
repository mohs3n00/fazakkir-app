import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DateConverter {
  static String format(
    DateTime date, {
    BuildContext? context,
    String pattern = 'yyyy-MM-dd',
    bool forceArabic = false,
  }) {
    String localeCode = 'en';

    if (forceArabic) {
      localeCode = 'ar';
    } else if (context != null) {
      localeCode = Localizations.localeOf(context).languageCode;
    } else {
      localeCode = Intl.defaultLocale ?? 'en';
    }

    // Ensure 'ar' locale is used if we want Arabic
    return DateFormat(pattern, localeCode).format(date);
  }
}
