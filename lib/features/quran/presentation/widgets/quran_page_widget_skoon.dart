import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fazakkir/features/quran/data/hizb_data_helper.dart';
import 'package:fazakkir/features/analytics/data/repositories/analytics_repository.dart';
import 'package:fazakkir/features/khatma/data/repositories/khatma_repository.dart';
import 'package:fazakkir/core/providers.dart';

import 'package:flutter/gestures.dart';
import '../../data/quran_library/quran.dart' as quran;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/highlight_controller.dart';
import '../controllers/audio_controller.dart';
import 'ayah_options_sheet.dart';

/// Complete Skoon-style Quran page renderer
class QuranPageWidgetSkoon extends ConsumerStatefulWidget {
  final int pageNumber;
  final Function(int)? onJumpToPage;
  final VoidCallback? onTap;

  const QuranPageWidgetSkoon({
    super.key,
    required this.pageNumber,
    this.onJumpToPage,
    this.onTap,
  });

  @override
  ConsumerState<QuranPageWidgetSkoon> createState() =>
      _QuranPageWidgetSkoonState();
}

class _QuranPageWidgetSkoonState extends ConsumerState<QuranPageWidgetSkoon> {
  // Primary Brown/Gold color
  static const Color kPrimaryColor = Color(0xff805528);
  final List<GestureRecognizer> _recognizers = [];

  bool _isFontLoaded = false;

  @override
  void initState() {
    super.initState();
    // Ensure Hizb data is loaded
    HizbDataHelper.loadQuarters();
    // Track Page View
    AnalyticsRepository().incrementQuranPages(1);

    // Update Khatma Progress
    _updateKhatma();

    // Load Font
    _loadFont();
  }

  Future<void> _loadFont() async {
    final success = await ref
        .read(quranFontServiceProvider)
        .loadPageFont(widget.pageNumber);
    if (mounted) {
      setState(() {
        _isFontLoaded = success;
      });
    }
  }

  @override
  void dispose() {
    _disposeRecognizers();
    super.dispose();
  }

  void _disposeRecognizers() {
    for (final r in _recognizers) {
      r.dispose();
    }
    _recognizers.clear();
  }

  void _updateKhatma() async {
    final repo = KhatmaRepository();
    final active = await repo.getActiveKhatma();
    if (active != null) {
      if (widget.pageNumber > active.currentPage) {
        repo.updateKhatmaProgress(active.id, widget.pageNumber);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    _disposeRecognizers(); // Clear old recognizers on rebuild

    if (!_isFontLoaded) {
      // Show invisible container or loader while font loads to avoid layout shift/tofu
      // Or show valid loader
      return const Center(child: SizedBox());
    }

    final pageData = quran.getPageData(widget.pageNumber);
    final firstSurah = pageData[0];
    final surahName = quran.getSurahNameArabic(firstSurah['surah']);
    final juzNum = quran.getJuzNumber(firstSurah['surah'], firstSurah['start']);
    final highlightState = ref.watch(highlightControllerProvider);

    // Theme-aware colors
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark
        ? const Color(0xFF2D2419)
        : const Color(0xffFFFCE7);
    final textColor = isDark ? const Color(0xFFF5E6D3) : Colors.black;
    final headerColor = isDark ? const Color(0xFFD4AF37) : kPrimaryColor;

    return GestureDetector(
      onTap: widget.onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        color: backgroundColor,
        child: Column(
          children: [
            // 1. Status Bar Spacer
            SizedBox(height: MediaQuery.of(context).padding.top),

            // 2. Header (Surah, Page Badge, Juz) - Small and integrated
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Right: Surah Name
                  Expanded(
                    child: Text(
                      "سورة $surahName",
                      style: TextStyle(
                        fontFamily: "Bakra",
                        fontSize: 13.sp,
                        color: headerColor,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.right,
                    ),
                  ),

                  // Center: Page Number Badge
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 8.w),
                    padding: EdgeInsets.symmetric(
                      horizontal: 10.w,
                      vertical: 4.h,
                    ),
                    decoration: BoxDecoration(
                      color: headerColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: headerColor.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "صفحة ${widget.pageNumber}",
                          style: TextStyle(
                            fontFamily: "Bakra",
                            fontSize: 11.sp,
                            color: headerColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (widget.pageNumber > 2) ...[
                          SizedBox(width: 6.w),
                          Container(
                            height: 12.h,
                            color: headerColor.withOpacity(0.3),
                            width: 1,
                          ),
                          SizedBox(width: 6.w),
                          Text(
                            HizbDataHelper.getQuarterText(pageData),
                            style: TextStyle(
                              fontFamily: "Bakra",
                              fontSize: 10.sp,
                              color: headerColor.withOpacity(0.8),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  // Left: Juz Number
                  Expanded(
                    child: Text(
                      "الجزء $juzNum",
                      style: TextStyle(
                        fontFamily: "Bakra",
                        fontSize: 13.sp,
                        color: headerColor,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.left,
                    ),
                  ),
                ],
              ),
            ),

            // 3. Quran Text Content
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  left: 12.w,
                  right: 12.w,
                  top: 4.h,
                  bottom: 12.h + MediaQuery.of(context).padding.bottom,
                ),
                child: Directionality(
                  textDirection: TextDirection.rtl,
                  child: Center(
                    child: RichText(
                      textDirection: TextDirection.rtl,
                      textAlign: TextAlign.center,
                      softWrap: true,
                      locale: const Locale("ar"),
                      text: TextSpan(
                        style: TextStyle(
                          color: textColor,
                          fontSize: 22.9.sp,
                          height: 2.2, // Consistent line spacing
                          fontFamily:
                              'QCF_P${widget.pageNumber.toString().padLeft(3, '0')}',
                        ),
                        children: _buildTextSpans(highlightState),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<InlineSpan> _buildTextSpans(HighlightState highlightState) {
    List<InlineSpan> spans = [];

    try {
      final pageData = quran.getPageData(widget.pageNumber);

      for (var e in pageData) {
        int surah = e['surah'];
        int start = e['start'];
        int end = e['end'];

        for (int i = start; i <= end; i++) {
          // Header & Basmallah Logic
          if (i == 1) {
            spans.add(WidgetSpan(child: _buildHeader(e)));
            if (widget.pageNumber != 187 && widget.pageNumber != 1) {
              spans.add(WidgetSpan(child: _buildBasmallah()));
            }
            if (widget.pageNumber == 187) {
              spans.add(WidgetSpan(child: Container(height: 10.h)));
            }
          }

          // Verse Text
          String qcfData = quran.getVerseQCF(surah, i);
          String finalText;
          if (i == start) {
            String cleanData = qcfData.replaceAll(' ', '');
            if (cleanData.isNotEmpty) {
              finalText =
                  "${cleanData.substring(0, 1)}\u200A${cleanData.substring(1)}";
            } else {
              finalText = cleanData;
            }
          } else {
            finalText = qcfData.replaceAll(' ', '');
          }

          // Check highlight logic
          final isHighlighted =
              highlightState.isActive &&
              highlightState.surah == surah &&
              highlightState.ayah == i;

          final TextStyle commonStyle = TextStyle(
            color: Theme.of(context).brightness == Brightness.dark
                ? const Color(0xFFF5E6D3)
                : Colors.black,
            height: (widget.pageNumber == 1 || widget.pageNumber == 2)
                ? 2.2
                : 2.2,
            letterSpacing: 0.w,
            wordSpacing: 0,
            fontFamily: 'QCF_P${widget.pageNumber.toString().padLeft(3, '0')}',
            fontSize: (widget.pageNumber == 1 || widget.pageNumber == 2)
                ? 28.sp
                : (widget.pageNumber == 145 || widget.pageNumber == 201)
                ? (widget.pageNumber == 532 || widget.pageNumber == 533)
                      ? 22.5.sp
                      : 22.4.sp
                : 22.9.sp,
            backgroundColor: isHighlighted
                ? kPrimaryColor.withOpacity(0.3)
                : Colors.transparent,
          );

          String verseContent = finalText;
          String verseSymbol = "";

          if (finalText.isNotEmpty) {
            verseContent = finalText.substring(0, finalText.length - 1);
            verseSymbol = finalText.substring(finalText.length - 1);
          }

          final longPressRecognizer = LongPressGestureRecognizer()
            ..onLongPress = () {
              // 1. Stop Audio if playing
              final audioState = ref.read(audioControllerProvider);
              if (audioState.isPlaying) {
                ref.read(audioControllerProvider.notifier).stop();
              }

              // 2. Highlight manually
              ref
                  .read(highlightControllerProvider.notifier)
                  .highlight(
                    surah,
                    i,
                    HighlightReason.manualSelect, // Persistent until dismissed
                  );
              AyahOptionsSheet.show(context, surah, i, widget.pageNumber);
            };

          _recognizers.add(longPressRecognizer);
          // _recognizers.add(tapRecognizer); // Optional: if we want single tap interaction on verse

          spans.add(
            TextSpan(
              text: verseContent,
              style: commonStyle,
              recognizer: longPressRecognizer,
            ),
          );

          if (verseSymbol.isNotEmpty) {
            spans.add(
              TextSpan(
                text: verseSymbol,
                style: commonStyle.copyWith(color: kPrimaryColor),
                recognizer: longPressRecognizer,
              ),
            );
          }
        }
      }
    } catch (e) {
      spans.add(
        TextSpan(
          text: "خطأ: $e",
          style: const TextStyle(color: Colors.red),
        ),
      );
    }

    return spans;
  }

  Widget _buildHeader(Map<String, dynamic> e) {
    return SizedBox(
      height: 50.h,
      child: Stack(
        children: [
          Center(
            child: Image.asset(
              "assets/images/888-02.png",
              width: 375.w,
              height: 50.h,
              color: kPrimaryColor,
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 19.7.w, vertical: 10.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text(
                  textAlign: TextAlign.center,
                  "اياتها\n${quran.getVerseCount(e["surah"])}",
                  style: TextStyle(
                    color: kPrimaryColor,
                    fontSize: 5.sp,
                    fontFamily: "UthmanicHafs1 Ver13",
                  ),
                ),
                Center(
                  child: RichText(
                    text: TextSpan(
                      text: "${e["surah"]}",
                      style: TextStyle(
                        fontFamily: "arsura",
                        fontSize: 25.sp,
                        color: kPrimaryColor,
                      ),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                Text(
                  "ترتيبها\n${e["surah"]}",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: kPrimaryColor,
                    fontSize: 5.sp,
                    fontFamily: "UthmanicHafs1 Ver13",
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBasmallah() {
    return SizedBox(
      width: 375.w,
      child: Padding(
        padding: EdgeInsets.only(
          left: (375 * .2).w,
          right: (375 * .2).w,
          top: 8.h,
          bottom: 2.h,
        ),
        child: Image.asset(
          "assets/images/Basmala.png",
          color: kPrimaryColor,
          width: 375.w * .4,
        ),
      ),
    );
  }
}
