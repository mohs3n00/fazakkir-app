import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../widgets/quran_view.dart';
import '../widgets/mini_audio_player.dart';
import 'package:fazakkir/features/main_layout/main_layout_screen.dart';
import 'package:fazakkir/core/theme/app_theme.dart';
import 'package:fazakkir/features/quran/data/quran_library/quran.dart' as quran;
import 'package:fazakkir/features/quran/presentation/controllers/highlight_controller.dart';
import 'quran_index_screen.dart';
import '../delegates/quran_search_delegate.dart';
import '../../data/quran_preferences.dart';
import 'package:fazakkir/l10n/app_localizations.dart';

class QuranScreen extends ConsumerStatefulWidget {
  const QuranScreen({super.key});

  @override
  ConsumerState<QuranScreen> createState() => _QuranScreenState();
}

class _QuranScreenState extends ConsumerState<QuranScreen> {
  final PageController _pageController = PageController();

  int _currentPage = 1;

  @override
  void initState() {
    super.initState();
    // Listen to page changes to update UI (bookmark icon)
    _pageController.addListener(() {
      if (_pageController.hasClients) {
        final newPage = (_pageController.page?.round() ?? 0) + 1;
        if (newPage != _currentPage) {
          setState(() {
            _currentPage = newPage;
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _toggleNavBar() {
    final isVisible = ref.read(navigationBarVisibilityProvider);
    ref.read(navigationBarVisibilityProvider.notifier).state = !isVisible;
  }

  void _navigateToPage(int page) {
    if (page >= 1 && page <= 604) {
      _pageController.jumpToPage(page - 1);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Listen to highlight changes for auto-scroll
    ref.listen<HighlightState>(highlightControllerProvider, (previous, next) {
      if (next.isActive && next.surah != null && next.ayah != null) {
        try {
          final page = quran.getPageNumber(next.surah!, next.ayah!);
          if (_pageController.hasClients) {
            final currentPage = _pageController.page?.round() ?? 0;
            if ((page - 1) != currentPage) {
              _pageController.animateToPage(
                page - 1,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            }
          }
        } catch (e) {
          debugPrint("Auto-scroll error: $e");
        }
      }
    });

    final isNavBarVisible = ref.watch(navigationBarVisibilityProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      extendBodyBehindAppBar:
          true, // Allow content to go behind app bar for smooth hide/show? No, might obscure text.
      // Actually, if we want full screen reading, we usually want content to expand.
      // If we use extendBodyBehindAppBar, we need safe area padding in QuranView.
      // QuranView already has SafeArea padding (SizedBox status bar).
      // Let's NOT extend for now to avoid layout shifts.
      appBar: isNavBarVisible
          ? AppBar(
              title: Text(
                AppLocalizations.of(context)!.holyQuran,
                style: TextStyle(
                  fontFamily: "Bakra",
                  color: isDark
                      ? const Color(0xFFD4AF37)
                      : const Color(0xff805528),
                  fontSize: 20.sp,
                ),
              ),
              centerTitle: true,
              backgroundColor: Theme.of(
                context,
              ).scaffoldBackgroundColor.withOpacity(0.9),
              elevation: 0,
              iconTheme: IconThemeData(
                color: isDark
                    ? const Color(0xFFD4AF37)
                    : const Color(0xff805528),
              ),
              leading: IconButton(
                icon: const Icon(Icons.search),
                onPressed: () async {
                  final result = await showSearch(
                    context: context,
                    delegate: QuranSearchDelegate(),
                  );
                  if (result != null) {
                    final page = result['page'] as int;
                    final surah = result['surah'] as int;
                    final ayah = result['ayah'] as int;

                    _navigateToPage(page);

                    // Trigger Highlight
                    // Wait a bit for page turn?
                    // Verify if we need delay. PageView usually instant if jump.
                    // But if animation, we might need delay.
                    // _navigateToPage uses jump if far, or animate?
                    // Implementation of _navigateToPage says jumpToPage.

                    ref
                        .read(highlightControllerProvider.notifier)
                        .highlight(
                          surah,
                          ayah,
                          HighlightReason.searchJump,
                          duration: const Duration(seconds: 4),
                        );
                  }
                },
              ),
              actions: [
                // Bookmarks List
                IconButton(
                  icon: const Icon(Icons.bookmarks_rounded),
                  tooltip: "العلامات المحفوظة",
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      backgroundColor: Colors.transparent,
                      builder: (context) => _BookmarksListSheet(
                        onPageSelected: (page) {
                          Navigator.pop(context);
                          _navigateToPage(page);
                        },
                      ),
                    ).then((_) {
                      if (mounted) setState(() {});
                    });
                  },
                ),
                // Toggle Bookmark for Current Page
                IconButton(
                  icon: Icon(
                    QuranPreferences.isPageSaved(_currentPage)
                        ? Icons.bookmark
                        : Icons.bookmark_border,
                  ),
                  tooltip: "حفظ / إلغاء حفظ الصفحة",
                  onPressed: () async {
                    if (_pageController.hasClients) {
                      await QuranPreferences.toggleSavedPage(_currentPage);
                      if (mounted) {
                        setState(() {});
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              QuranPreferences.isPageSaved(_currentPage)
                                  ? "تم حفظ الصفحة $_currentPage"
                                  : "تم إزالة الصفحة $_currentPage من المحفوظات",
                            ),
                            duration: const Duration(seconds: 1),
                          ),
                        );
                      }
                    }
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.list),
                  onPressed: () async {
                    final page = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const QuranIndexScreen(),
                      ),
                    );
                    if (page != null) {
                      _navigateToPage(page);
                    }
                  },
                ),
              ],
            )
          : null,
      body: Theme(
        data: AppTheme
            .lightTheme, // Force light/specific theme for reader? Or align with app?
        // QuranView handles its own colors based on brightness.
        child: Stack(
          children: [
            MediaQuery(
              data: MediaQuery.of(
                context,
              ).copyWith(textScaler: TextScaler.linear(1.0)),
              child: QuranView(
                controller: _pageController,
                onToggleNavBar: _toggleNavBar,
              ),
            ),
            const Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: MiniAudioPlayer(),
            ),
          ],
        ),
      ),
    );
  }
}

class _BookmarksListSheet extends StatefulWidget {
  final Function(int) onPageSelected;

  const _BookmarksListSheet({required this.onPageSelected});

  @override
  State<_BookmarksListSheet> createState() => _BookmarksListSheetState();
}

class _BookmarksListSheetState extends State<_BookmarksListSheet> {
  List<int> _savedPages = [];

  @override
  void initState() {
    super.initState();
    _loadBookmarks();
  }

  void _loadBookmarks() {
    setState(() {
      _savedPages = QuranPreferences.getSavedPages();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "العلامات المحفوظة",
                  style: TextStyle(
                    fontFamily: "Cairo",
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
                Text(
                  "${_savedPages.length} علامة",
                  style: TextStyle(
                    fontFamily: "Cairo",
                    fontSize: 14.sp,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          const Divider(),
          if (_savedPages.isEmpty)
            Padding(
              padding: const EdgeInsets.all(30.0),
              child: Text(
                "لا توجد علامات محفوظة",
                style: TextStyle(
                  fontFamily: "Cairo",
                  fontSize: 16.sp,
                  color: Colors.grey,
                ),
              ),
            )
          else
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _savedPages.length,
                itemBuilder: (context, index) {
                  final page = _savedPages[index];
                  // Get Surah Name from Page Data
                  String surahName = "صفحة $page";
                  try {
                    final pageData = quran.getPageData(page);
                    if (pageData.isNotEmpty) {
                      final surahNum = pageData[0]['surah'];
                      surahName = quran.getSurahNameArabic(surahNum);
                    }
                  } catch (e) {
                    debugPrint("Error getting surah name: $e");
                  }

                  return ListTile(
                    leading: Icon(
                      Icons.bookmark,
                      color: isDark
                          ? const Color(0xFFD4AF37)
                          : const Color(0xff805528),
                      size: 32.sp,
                    ),
                    title: Text(
                      "سورة $surahName",
                      style: TextStyle(
                        fontFamily: "Bakra",
                        fontSize: 16.sp,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                    subtitle: Text(
                      "صفحة $page",
                      style: TextStyle(
                        fontFamily: "Cairo",
                        fontSize: 12.sp,
                        color: Colors.grey,
                      ),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      onPressed: () async {
                        await QuranPreferences.toggleSavedPage(page);
                        _loadBookmarks();
                      },
                    ),
                    onTap: () => widget.onPageSelected(page),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
