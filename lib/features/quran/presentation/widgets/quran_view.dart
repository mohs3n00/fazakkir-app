import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fazakkir/core/providers.dart';
import 'package:fazakkir/features/quran/presentation/screens/quran_download_screen.dart';
import 'quran_page_widget_skoon.dart';

class QuranView extends ConsumerStatefulWidget {
  final VoidCallback? onToggleNavBar;
  final PageController controller;

  const QuranView({super.key, this.onToggleNavBar, required this.controller});

  @override
  ConsumerState<QuranView> createState() => _QuranViewState();
}

class _QuranViewState extends ConsumerState<QuranView> {
  bool? _isDownloaded;

  @override
  void initState() {
    super.initState();
    _checkDownloadStatus();
  }

  Future<void> _checkDownloadStatus() async {
    final isDownloaded = await ref
        .read(quranFontServiceProvider)
        .isFontsDownloaded();
    if (mounted) {
      setState(() {
        _isDownloaded = isDownloaded;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isDownloaded == null) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xff805528)),
      );
    }

    if (!_isDownloaded!) {
      return QuranDownloadScreen(
        onSuccess: () {
          setState(() {
            _isDownloaded = true;
          });
        },
      );
    }

    return Directionality(
      textDirection: TextDirection.rtl,
      child: PageView.builder(
        controller: widget.controller,
        reverse: false, // Keep normal: swipe left to go to next page
        allowImplicitScrolling: true,
        physics: const BouncingScrollPhysics(),
        padEnds: false,
        itemCount: 604,
        itemBuilder: (context, index) {
          final pageNum = index + 1;
          return QuranPageWidgetSkoon(
            pageNumber: pageNum,
            onJumpToPage: (page) => widget.controller.jumpToPage(page - 1),
            onTap: widget.onToggleNavBar,
          );
        },
      ),
    );
  }
}
