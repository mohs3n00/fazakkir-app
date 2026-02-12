import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../l10n/app_localizations.dart';
import 'package:fazakkir/core/providers.dart';

class QuranDownloadScreen extends ConsumerStatefulWidget {
  final VoidCallback onSuccess;

  const QuranDownloadScreen({super.key, required this.onSuccess});

  @override
  ConsumerState<QuranDownloadScreen> createState() =>
      _QuranDownloadScreenState();
}

class _QuranDownloadScreenState extends ConsumerState<QuranDownloadScreen> {
  double _progress = 0.0;
  String _status = "";
  String? _error;
  bool _isDownloading = false;

  void _startDownload() {
    setState(() {
      _isDownloading = true;
      _error = null;
      _status = "Preparing...";
    });

    ref
        .read(quranFontServiceProvider)
        .downloadFonts(
          onProgress: (p) => setState(() => _progress = p),
          onStatusChange: (s) => setState(() => _status = s),
          onSuccess: widget.onSuccess,
          onError: (e) => setState(() {
            _error = e;
            _isDownloading = false;
          }),
        );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF1A1A1A) : Colors.white,
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.menu_book_rounded,
                size: 80.sp,
                color: const Color(0xff805528),
              ),
              SizedBox(height: 24.h),
              Text(
                l10n.downloadQuranTitle,
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                  fontFamily: "Cairo",
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 12.h),
              Text(
                l10n.downloadQuranBody,
                style: TextStyle(
                  fontSize: 16.sp,
                  color: Colors.grey,
                  fontFamily: "Cairo",
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 32.h),
              if (_isDownloading) ...[
                LinearProgressIndicator(
                  value: _progress,
                  backgroundColor: Colors.grey[300],
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    Color(0xff805528),
                  ),
                ),
                SizedBox(height: 12.h),
                Text(
                  "$_status ${(_progress * 100).toInt()}%",
                  style: TextStyle(fontSize: 14.sp),
                ),
              ] else ...[
                if (_error != null) ...[
                  Text(
                    "${l10n.error}: $_error",
                    style: TextStyle(color: Colors.red, fontSize: 14.sp),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 16.h),
                ],
                ElevatedButton(
                  onPressed: _startDownload,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff805528),
                    padding: EdgeInsets.symmetric(
                      horizontal: 32.w,
                      vertical: 12.h,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    _error != null ? l10n.retry : l10n.download,
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: Colors.white,
                      fontFamily: "Cairo",
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
