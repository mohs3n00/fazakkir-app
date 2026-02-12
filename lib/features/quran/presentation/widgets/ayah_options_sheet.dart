import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:fazakkir/features/quran/data/quran_library/quran.dart' as quran;
import 'package:fazakkir/features/quran/data/quran_preferences.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:fazakkir/features/quran/presentation/widgets/tafseer_sheet.dart';
import 'package:fazakkir/core/theme/app_colors.dart';
import 'package:fazakkir/core/theme/app_theme.dart';
import 'package:fazakkir/features/quran/presentation/widgets/reciter_selection_sheet.dart';
import 'package:fazakkir/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fazakkir/features/quran/presentation/controllers/audio_controller.dart';

class AyahOptionsSheet extends ConsumerStatefulWidget {
  final int surahNumber;
  final int verseNumber;
  final int pageIndex;

  const AyahOptionsSheet({
    super.key,
    required this.surahNumber,
    required this.verseNumber,
    required this.pageIndex,
  });

  static Future<void> show(
    BuildContext context,
    int surahNumber,
    int verseNumber,
    int pageIndex,
  ) async {
    await showMaterialModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Theme(
        data: AppTheme.lightTheme,
        child: AyahOptionsSheet(
          surahNumber: surahNumber,
          verseNumber: verseNumber,
          pageIndex: pageIndex,
        ),
      ),
    );
  }

  @override
  ConsumerState<AyahOptionsSheet> createState() => _AyahOptionsSheetState();
}

class _AyahOptionsSheetState extends ConsumerState<AyahOptionsSheet> {
  @override
  Widget build(BuildContext context) {
    final audioState = ref.watch(audioControllerProvider);
    final isCurrentAyahPlaying =
        audioState.isPlaying &&
        audioState.currentSurah == widget.surahNumber &&
        audioState.currentAyah == widget.verseNumber;

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark
        ? AppColors.darkSurface
        : AppColors.lightSurface;
    final textColor = isDark ? AppColors.darkText : AppColors.lightText;
    final accentColor = AppColors.islamicGold;

    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: backgroundColor.withOpacity(0.95),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24.r),
            topRight: Radius.circular(24.r),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag Handle
            Center(
              child: Container(
                width: 40.w,
                height: 5.h,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white24 : Colors.black12,
                  borderRadius: BorderRadius.circular(10.r),
                ),
              ),
            ),
            SizedBox(height: 20.h),

            // Header: Surah & Verse
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  AppLocalizations.of(context)!.surahName(
                    Localizations.localeOf(context).languageCode == 'ar'
                        ? quran.getSurahNameArabic(widget.surahNumber)
                        : quran.getSurahNameEnglish(widget.surahNumber),
                  ),
                  style: TextStyle(
                    fontFamily: "Bakra",
                    fontSize: 18.sp,
                    color: accentColor,
                  ),
                ),
                SizedBox(width: 8.w),
                Container(
                  width: 4.w,
                  height: 4.w,
                  decoration: BoxDecoration(
                    color: textColor.withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(width: 8.w),
                Text(
                  AppLocalizations.of(
                    context,
                  )!.ayahNumber(widget.verseNumber.toString()),
                  style: TextStyle(
                    fontFamily: "Bakra",
                    fontSize: 18.sp,
                    color: accentColor,
                  ),
                ),
              ],
            ),
            SizedBox(height: 24.h),

            // Primary Action: Tafseer
            _buildPrimaryAction(
              context,
              label: AppLocalizations.of(context)!.tafseerAndTranslation,
              icon: Icons.menu_book_rounded,
              color: accentColor,
              textColor: isDark ? Colors.white : Colors.white,
              onTap: () {
                Navigator.pop(context);
                TafseerSheet.show(
                  context,
                  widget.surahNumber,
                  widget.verseNumber,
                );
              },
            ),
            SizedBox(height: 16.h),

            // Secondary Actions Grid
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              childAspectRatio: 3,
              crossAxisSpacing: 12.w,
              mainAxisSpacing: 12.h,
              children: [
                _buildActionItem(
                  icon: isCurrentAyahPlaying
                      ? Icons.stop_rounded
                      : Icons.play_arrow_rounded,
                  label: isCurrentAyahPlaying
                      ? AppLocalizations.of(context)!.stop
                      : AppLocalizations.of(context)!.listen,
                  onTap: () {
                    if (isCurrentAyahPlaying) {
                      ref.read(audioControllerProvider.notifier).stop();
                    } else {
                      ref
                          .read(audioControllerProvider.notifier)
                          .playAyah(widget.surahNumber, widget.verseNumber);
                      // Close sheet so user can see the highlight/player
                      Navigator.pop(context);
                    }
                  },
                  isDark: isDark,
                  textColor: textColor,
                  isActive: isCurrentAyahPlaying,
                ),
                _buildActionItem(
                  icon: Icons.person_rounded,
                  label: AppLocalizations.of(context)!.changeReciter,
                  onTap: () async {
                    Navigator.pop(context);
                    await ReciterSelectionSheet.show(context);
                  },
                  isDark: isDark,
                  textColor: textColor,
                ),
                _buildActionItem(
                  icon: Icons.copy_rounded,
                  label: AppLocalizations.of(context)!.copyText,
                  onTap: () {
                    final text = quran.getVerse(
                      widget.surahNumber,
                      widget.verseNumber,
                    );
                    Clipboard.setData(ClipboardData(text: text));
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          AppLocalizations.of(context)!.copyAyahSuccess,
                        ),
                      ),
                    );
                  },
                  isDark: isDark,
                  textColor: textColor,
                ),
                _buildActionItem(
                  icon: Icons.share_rounded,
                  label: AppLocalizations.of(context)!.share,
                  onTap: () {
                    final text = quran.getVerse(
                      widget.surahNumber,
                      widget.verseNumber,
                    );
                    Share.share(
                      "$text\n\n[${quran.getSurahNameArabic(widget.surahNumber)}: ${widget.verseNumber}]",
                    );
                    Navigator.pop(context);
                  },
                  isDark: isDark,
                  textColor: textColor,
                ),
                _buildActionItem(
                  icon:
                      QuranPreferences.isBookmarked(
                        widget.surahNumber,
                        widget.verseNumber,
                      )
                      ? Icons.bookmark_rounded
                      : Icons.bookmark_border_rounded,
                  label:
                      QuranPreferences.isBookmarked(
                        widget.surahNumber,
                        widget.verseNumber,
                      )
                      ? AppLocalizations.of(context)!.removeBookmark
                      : AppLocalizations.of(context)!.saveBookmark,
                  onTap: () async {
                    if (QuranPreferences.isBookmarked(
                      widget.surahNumber,
                      widget.verseNumber,
                    )) {
                      await QuranPreferences.removeBookmark(
                        widget.surahNumber,
                        widget.verseNumber,
                      );
                    } else {
                      await QuranPreferences.addBookmark(
                        widget.surahNumber,
                        widget.verseNumber,
                      );
                    }
                    if (context.mounted) {
                      Navigator.pop(context);
                    }
                  },
                  isDark: isDark,
                  textColor: textColor,
                  isActive: QuranPreferences.isBookmarked(
                    widget.surahNumber,
                    widget.verseNumber,
                  ),
                ),
              ],
            ),
            SizedBox(height: 30.h),
          ],
        ),
      ),
    );
  }

  Widget _buildPrimaryAction(
    BuildContext context, {
    required String label,
    required IconData icon,
    required Color color,
    required Color textColor,
    required VoidCallback onTap,
  }) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(16.r),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16.r),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 14.h),
          width: double.infinity,
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: textColor, size: 22.sp),
              SizedBox(width: 12.w),
              Text(
                label,
                style: TextStyle(
                  fontFamily: "Cairo",
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required bool isDark,
    required Color textColor,
    bool isActive = false,
  }) {
    final bgColor = isDark
        ? (isActive
              ? AppColors.islamicGold.withOpacity(0.2)
              : Colors.white.withOpacity(0.05))
        : (isActive
              ? AppColors.islamicGold.withOpacity(0.1)
              : Colors.black.withOpacity(0.03));

    final iconColor = isActive
        ? AppColors.islamicGold
        : (isDark ? Colors.white70 : Colors.black54);

    return Material(
      color: bgColor,
      borderRadius: BorderRadius.circular(12.r),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.r),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w),
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: iconColor, size: 20.sp),
              SizedBox(width: 8.w),
              Text(
                label,
                style: TextStyle(
                  fontFamily: "Cairo",
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                  color: textColor.withOpacity(0.9),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
