class ArabicUtils {
  static String normalize(String text) {
    return text
        .replaceAll(
          RegExp(
            r'[\u064B-\u065F\u06D6-\u06ED\u0640\u0670\u0610-\u061A\u06E6-\u06EA]',
          ),
          '',
        )
        .replaceAll(RegExp(r'[أإآ]'), 'ا')
        .replaceAll(RegExp(r'ة'), 'ه')
        .replaceAll(RegExp(r'ى'), 'ي')
        .replaceAll(RegExp(r'ؤ'), 'و')
        .replaceAll(RegExp(r'ئ'), 'ي');
  }

  static RegExp buildFuzzyRegex(String query) {
    final normalizedQuery = normalize(query);
    final buffer = StringBuffer();

    // Characters relevant to Quranic text that should be ignored during matching
    // Includes Tashkeel, Tatweel, specific Quranic marks, etc.
    const ignorables =
        r'[\u064B-\u065F\u06D6-\u06ED\u0640\u0670\u0610-\u061A\u06E6-\u06EA]*';

    for (int i = 0; i < normalizedQuery.length; i++) {
      final char = normalizedQuery[i];

      // Map normalized char back to possible variations in text
      String patternChar;
      switch (char) {
        case 'ا':
          patternChar = r'[اأإآٱ]';
          break;
        case 'ه':
          patternChar = r'[هة]';
          break;
        case 'ي':
          patternChar = r'[يىئ]';
          break;
        case 'و':
          patternChar = r'[وؤ]';
          break;
        default:
          patternChar = RegExp.escape(char);
      }

      buffer.write(patternChar);
      buffer.write(ignorables);
    }

    return RegExp(buffer.toString());
  }
}
