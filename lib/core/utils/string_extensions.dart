extension StringExtensions on String {
  String removeDiacritics() {
    final diacritics = RegExp(
      r'[\u064B-\u065F\u06D6-\u06DC\u06DF-\u06E8\u06EA-\u06ED]',
    );
    return replaceAll(diacritics, '');
  }

  // Normalize Alef (optional, but good for smart search)
  String normalizeArabic() {
    String text = removeDiacritics();
    text = text.replaceAll(RegExp(r'[أإآ]'), 'ا');
    text = text.replaceAll(RegExp(r'ة'), 'ه');
    text = text.replaceAll(RegExp(r'ى'), 'ي');
    return text;
  }
}
