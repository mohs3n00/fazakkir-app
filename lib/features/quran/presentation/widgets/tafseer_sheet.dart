import 'dart:io';
import 'package:fazakkir/core/providers.dart';

import 'package:fazakkir/core/services/download_service.dart';
import 'package:fazakkir/core/services/package_registry_service.dart';
import 'package:fazakkir/core/theme/app_colors.dart';
// import 'package:fazakkir/core/theme/app_theme.dart';
import 'package:fazakkir/features/quran/data/quran_library/quran.dart' as quran;
import 'package:fazakkir/features/quran/data/translation/translation_data.dart';
import 'package:fazakkir/features/quran/data/translation/translation_helper.dart';
import 'package:fazakkir/features/quran/data/translation/translation_info.dart';
import 'package:fazakkir/features/quran/presentation/controllers/highlight_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:path_provider/path_provider.dart';
import 'package:fazakkir/l10n/app_localizations.dart';

class TafseerSheet extends ConsumerStatefulWidget {
  final int surahNumber;
  final int verseNumber;

  const TafseerSheet({
    super.key,
    required this.surahNumber,
    required this.verseNumber,
  });

  static void show(BuildContext context, int surahNumber, int verseNumber) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) =>
          TafseerSheet(surahNumber: surahNumber, verseNumber: verseNumber),
    );
  }

  @override
  ConsumerState<TafseerSheet> createState() => _TafseerSheetState();
}

class _TafseerSheetState extends ConsumerState<TafseerSheet> {
  late int _currentVerse;
  int _selectedTranslationIndex = 9; // Default to Muyassar (index 9)
  String _content = "";
  bool _isLoading = true;
  bool _isDownloading = false;
  double _downloadProgress = 0.0;
  String _errorMessage = "";

  @override
  void initState() {
    super.initState();
    _currentVerse = widget.verseNumber;

    // Set Highlight
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(highlightControllerProvider.notifier)
          .highlight(
            widget.surahNumber,
            widget.verseNumber,
            HighlightReason.tafsirFocus,
          );
    });

    _loadContent();
  }

  @override
  void dispose() {
    // Clear highlight on close (if reason is tafsirFocus)
    // We can't easily do it here because dispose might run after new highlight?
    // Actually highlight controller handles check.
    Future.microtask(() {
      ref
          .read(highlightControllerProvider.notifier)
          .clearHighlight(HighlightReason.tafsirFocus);
    });
    super.dispose();
  }

  Future<void> _loadContent() async {
    setState(() {
      _isLoading = true;
      _errorMessage = "";
    });

    TranslationData selected = translationDataList[_selectedTranslationIndex];

    // Check if installed
    bool isLocallyAvailable = selected.url.startsWith("local");
    String? dbContent;

    // Check Package Registry for DB type
    final registry = ref.read(packageRegistryProvider);
    // We need to map TranslationData to PackageID.
    // Ideally TranslationData should have an ID.
    // For now, let's use typeText as ID like in _downloadCurrentTafsir.
    final packageId = selected.typeText;

    // Check if installed as DB
    if (registry.isPackageInstalled(packageId, PackageType.tafsirDb)) {
      final pkg = registry.getInstalledPackages().firstWhere(
        (p) => p.id == packageId && p.type == PackageType.tafsirDb,
      );
      final dir = Directory(pkg.localPath);
      if (await dir.exists()) {
        final files = dir.listSync();
        final dbFile = files.firstWhere(
          (f) => f.path.endsWith('.db'),
          orElse: () => files.first,
        );

        final dbService = ref.read(tafsirDatabaseServiceProvider);
        dbContent = await dbService.getTafsirText(
          dbFile.path,
          widget.surahNumber,
          _currentVerse,
        );
      }
    }

    if (dbContent != null) {
      if (mounted) {
        setState(() {
          _content = dbContent!;
          _isLoading = false;
        });
      }
      return;
    }

    if (!isLocallyAvailable) {
      // Check registry or file existence via helper (helper checks file)
      // But helper returns "Download required" string.
      // Let's rely on Helper for now.
    }

    String text = await TranslationHelper.getVerseTranslation(
      widget.surahNumber,
      _currentVerse,
      selected,
    );

    if (text == "Download required") {
      if (mounted) {
        setState(() {
          _content = "";
          _isLoading = false;
        });
      }
    } else {
      if (mounted) {
        setState(() {
          _content = text;
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _downloadCurrentTafsir() async {
    final selected = translationDataList[_selectedTranslationIndex];
    setState(() {
      _isDownloading = true;
      _downloadProgress = 0.0;
      _errorMessage = "";
    });

    final docDir = await getApplicationDocumentsDirectory();
    final targetDir = "${docDir.path}/tafseer/${selected.typeText}";

    ref
        .read(downloadServiceProvider)
        .downloadAndExtract(
          url: selected.url,
          destinationDir: targetDir,
          onProgress: (p) => setState(() => _downloadProgress = p),
          onError: (e) => setState(() {
            _isDownloading = false;
            _errorMessage = e;
          }),
          onSuccess: () async {
            // Register
            final registry = ref.read(packageRegistryProvider);
            // Determine type based on URL or Metadata?
            // For now, if URL ends in .db.zip, it's a DB.
            final isDb = selected.url.endsWith(".db.zip");

            await registry.registerPackage(
              PackageEntry(
                id: selected.typeText,
                type: isDb ? PackageType.tafsirDb : PackageType.tafsir,
                localPath: targetDir,
                isInstalled: true,
                version: "1.0",
              ),
            );

            setState(() {
              _isDownloading = false;
            });
            _loadContent();
          },
          onStatusChange: (_) {},
        );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark
        ? AppColors.darkSurface
        : const Color(0xffFFFCE7);
    final textColor = isDark ? AppColors.darkText : AppColors.lightText;
    final dividerColor = isDark ? Colors.white24 : Colors.black12;

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
            boxShadow: [
              BoxShadow(color: Colors.black12, blurRadius: 10, spreadRadius: 5),
            ],
          ),
          child: Column(
            children: [
              // Handle
              Center(
                child: Container(
                  margin: EdgeInsets.only(top: 10.h, bottom: 10.h),
                  width: 40.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: dividerColor,
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
              ),

              // Header
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Navigation
                    Expanded(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(
                              Icons.arrow_back_ios,
                              size: 18.sp,
                              color: AppColors.islamicGold,
                            ),
                            onPressed: _currentVerse > 1
                                ? () {
                                    setState(() => _currentVerse--);
                                    // Update Highlight
                                    ref
                                        .read(
                                          highlightControllerProvider.notifier,
                                        )
                                        .highlight(
                                          widget.surahNumber,
                                          _currentVerse,
                                          HighlightReason.tafsirFocus,
                                        );
                                    _loadContent();
                                  }
                                : null,
                          ),
                          Flexible(
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                "${quran.getSurahNameArabic(widget.surahNumber)} : $_currentVerse",
                                style: TextStyle(
                                  fontFamily: 'Bakra',
                                  fontSize: 16.sp,
                                  color: AppColors.islamicGold,
                                ),
                              ),
                            ),
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.arrow_forward_ios,
                              size: 18.sp,
                              color: AppColors.islamicGold,
                            ),
                            onPressed:
                                _currentVerse <
                                    quran.getVerseCount(widget.surahNumber)
                                ? () {
                                    setState(() => _currentVerse++);
                                    ref
                                        .read(
                                          highlightControllerProvider.notifier,
                                        )
                                        .highlight(
                                          widget.surahNumber,
                                          _currentVerse,
                                          HighlightReason.tafsirFocus,
                                        );
                                    _loadContent();
                                  }
                                : null,
                          ),
                        ],
                      ),
                    ),

                    // Selector
                    DropdownButton<int>(
                      value: _selectedTranslationIndex,
                      underline: SizedBox(),
                      dropdownColor: backgroundColor,
                      icon: Icon(
                        Icons.keyboard_arrow_down,
                        color: AppColors.islamicGold,
                      ),
                      style: TextStyle(
                        color: textColor,
                        fontFamily: "Cairo",
                        fontSize: 14.sp,
                      ),
                      items: List.generate(translationDataList.length, (index) {
                        return DropdownMenuItem(
                          value: index,
                          child: ConstrainedBox(
                            constraints: BoxConstraints(maxWidth: 140.w),
                            child: Text(
                              translationDataList[index]
                                  .typeTextInRelatedLanguage,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        );
                      }),
                      onChanged: (val) {
                        if (val != null) {
                          setState(() => _selectedTranslationIndex = val);
                          _loadContent();
                        }
                      },
                    ),
                  ],
                ),
              ),
              Divider(color: dividerColor),

              // Content
              Expanded(
                child: _isDownloading
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircularProgressIndicator(
                              value: _downloadProgress,
                              color: AppColors.islamicGold,
                            ),
                            SizedBox(height: 10.h),
                            Text(
                              "${AppLocalizations.of(context)!.downloading} ${(_downloadProgress * 100).toInt()}%",
                              style: TextStyle(color: textColor),
                            ),
                          ],
                        ),
                      )
                    : _isLoading
                    ? Center(
                        child: CircularProgressIndicator(
                          color: AppColors.islamicGold,
                        ),
                      )
                    : ListView(
                        controller: scrollController,
                        padding: EdgeInsets.all(20.w),
                        children: [
                          // Ayah Text
                          Text(
                            quran.getVerse(widget.surahNumber, _currentVerse),
                            style: TextStyle(
                              fontSize: 22.sp,
                              fontFamily: 'UthmanicHafs1 Ver13',
                              color: AppColors.islamicGold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 20.h),
                          Container(
                            padding: EdgeInsets.all(12.r),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? Colors.white.withOpacity(0.05)
                                  : Colors.grey.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(10.r),
                            ),
                            child: _content.isEmpty
                                ? Column(
                                    children: [
                                      Icon(
                                        Icons.cloud_download_outlined,
                                        size: 40.sp,
                                        color: textColor,
                                      ),
                                      SizedBox(height: 10.h),
                                      Text(
                                        AppLocalizations.of(
                                          context,
                                        )!.tafseerNotDownloaded,
                                        style: TextStyle(color: textColor),
                                      ),
                                      TextButton(
                                        onPressed: _downloadCurrentTafsir,
                                        child: Text(
                                          AppLocalizations.of(
                                            context,
                                          )!.downloadTafseerNow,
                                          style: TextStyle(
                                            color: AppColors.islamicGold,
                                          ),
                                        ),
                                      ),
                                      if (_errorMessage.isNotEmpty)
                                        Text(
                                          _errorMessage,
                                          style: TextStyle(
                                            color: Colors.red,
                                            fontSize: 12.sp,
                                          ),
                                        ),
                                    ],
                                  )
                                : Html(
                                    data: _content,
                                    style: {
                                      "body": Style(
                                        fontSize: FontSize(18.sp),
                                        fontFamily: "Cairo",
                                        textAlign: TextAlign.right,
                                        color: textColor,
                                        lineHeight: LineHeight(1.6),
                                      ),
                                    },
                                  ),
                          ),
                        ],
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}
