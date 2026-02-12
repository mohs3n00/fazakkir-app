import 'package:flutter/material.dart';
import '../utils/arabic_utils.dart'; // Utilizing relative import or package import based on structure

class SearchHighlightText extends StatelessWidget {
  final String text;
  final String query;
  final TextStyle style;
  final Color highlightColor;
  final TextStyle? highlightStyle;
  final int? maxLines;
  final TextOverflow? overflow;
  final TextAlign? textAlign;

  const SearchHighlightText({
    super.key,
    required this.text,
    required this.query,
    required this.style,
    this.highlightColor = const Color(0xFFFFF176), // Default yellow highlight
    this.highlightStyle,
    this.maxLines,
    this.overflow,
    this.textAlign,
  });

  @override
  Widget build(BuildContext context) {
    if (query.isEmpty) {
      return Text(
        text,
        style: style,
        maxLines: maxLines,
        overflow: overflow,
        textAlign: textAlign,
      );
    }

    RegExp regex;
    try {
      // Ideally we use a shared instance if performance matters, but for UI text this is fine.
      regex = ArabicUtils.buildFuzzyRegex(query);
    } catch (e) {
      return Text(
        text,
        style: style,
        maxLines: maxLines,
        overflow: overflow,
        textAlign: textAlign,
      );
    }

    final matches = regex.allMatches(text);

    if (matches.isEmpty) {
      return Text(
        text,
        style: style,
        maxLines: maxLines,
        overflow: overflow,
        textAlign: textAlign,
      );
    }

    final List<TextSpan> spans = [];
    int start = 0;

    for (final match in matches) {
      if (match.start > start) {
        spans.add(
          TextSpan(text: text.substring(start, match.start), style: style),
        );
      }

      spans.add(
        TextSpan(
          text: text.substring(match.start, match.end),
          style:
              highlightStyle ??
              style.copyWith(
                backgroundColor: highlightColor.withOpacity(0.3),
                fontWeight: FontWeight.bold,
                color: Colors.black, // Ensure contrast
              ),
        ),
      );

      start = match.end;
    }

    if (start < text.length) {
      spans.add(TextSpan(text: text.substring(start), style: style));
    }

    return RichText(
      textAlign: textAlign ?? TextAlign.start,
      maxLines: maxLines,
      overflow: overflow ?? TextOverflow.clip,
      text: TextSpan(children: spans),
    );
  }
}
