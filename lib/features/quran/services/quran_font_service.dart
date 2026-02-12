import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:archive/archive_io.dart';

final quranFontServiceProvider = Provider<QuranFontService>((ref) {
  return QuranFontService();
});

class QuranFontService {
  final Dio _dio = Dio();
  // Using the URL provided by the user
  static const String _fontZipUrl =
      'https://github.com/mohs3n00/fazakkir-assets/releases/download/fonts/quran_fonts.zip';
  static const String _zipFileName = 'quran_fonts.zip';
  static const String _targetDirName =
      'fonts_v2woff'; // Matching the folder name in zip if possible, or custom

  // Track download state
  bool _isDownloading = false;
  bool get isDownloading => _isDownloading;

  /// Checks if the fonts are already downloaded and extracted.
  Future<bool> isFontsDownloaded() async {
    final docDir = await getApplicationDocumentsDirectory();
    final fontDir = Directory('${docDir.path}/$_targetDirName');

    if (!await fontDir.exists()) return false;

    // Check for a few critical files to ensure completion
    // We check p1.woff, p604.woff and maybe a random one like p300.woff
    if (!await File('${fontDir.path}/p1.woff').exists()) return false;
    if (!await File('${fontDir.path}/p300.woff').exists()) return false;
    if (!await File('${fontDir.path}/p604.woff').exists()) return false;

    return true;
  }

  /// Downloads and extracts the fonts.
  Future<void> downloadFonts({
    required Function(double) onProgress,
    required Function(String status) onStatusChange,
    required Function() onSuccess,
    required Function(String error) onError,
  }) async {
    if (_isDownloading) return;
    _isDownloading = true;

    final docDir = await getApplicationDocumentsDirectory();
    final zipPath = '${docDir.path}/$_zipFileName';
    final targetDir = Directory('${docDir.path}/$_targetDirName');

    try {
      // 1. Download
      onStatusChange("downloading");

      await _dio.download(
        _fontZipUrl,
        zipPath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            final progress = received / total * 0.7; // 70% for download
            onProgress(progress);
          }
        },
      );

      // Verify Zip
      final zipFile = File(zipPath);
      if (!await zipFile.exists() || await zipFile.length() == 0) {
        throw Exception('Download failed or file empty');
      }

      // 2. Extract
      onStatusChange("extracting");
      onProgress(0.75);

      if (!await targetDir.exists()) {
        await targetDir.create(recursive: true);
      }

      final bytes = await zipFile.readAsBytes();
      final archive = ZipDecoder().decodeBytes(bytes);

      int totalFiles = archive.length;
      int processed = 0;

      for (final file in archive) {
        final filename = file.name;
        if (file.isFile) {
          // Flatten the directory structure: extract only filenames if they are inside subfolders in zip
          // The user said the fonts are in "assets/fonts/v2woff" in their source,
          // so the zip might contain "v2woff/p1.woff" or just "p1.woff".
          // We should extract to target dir directly.

          final shortName = filename.split('/').last.split('\\').last;
          if (shortName.isEmpty || !shortName.endsWith('.woff')) continue;

          final data = file.content as List<int>;
          File('${targetDir.path}/$shortName')
            ..createSync(recursive: true)
            ..writeAsBytesSync(data);
        }

        processed++;
        // Throttle progress updates to avoid UI lag
        if (processed % 50 == 0) {
          onProgress(0.75 + (processed / totalFiles * 0.25));
          await Future.delayed(Duration.zero);
        }
      }

      // 3. Cleanup
      if (await zipFile.exists()) {
        await zipFile.delete();
      }

      _isDownloading = false;
      onProgress(1.0);
      onSuccess();
    } catch (e) {
      _isDownloading = false;
      // Cleanup partially downloaded/extracted files
      if (await File(zipPath).exists()) await File(zipPath).delete();
      if (await targetDir.exists()) await targetDir.delete(recursive: true);

      onError(e.toString());
    }
  }

  /// Loads a specific page's font into the Flutter Engine.
  /// This must be called before the page is rendered or in initState.
  Future<bool> loadPageFont(int pageNumber) async {
    try {
      final docDir = await getApplicationDocumentsDirectory();
      final fontDir = Directory('${docDir.path}/$_targetDirName');
      final fileName = 'p$pageNumber.woff'; // e.g. p1.woff
      final file = File('${fontDir.path}/$fileName');

      if (!await file.exists()) {
        print("Font file not found: ${file.path}");
        return false;
      }

      // The family name MUST match what is used in QuranPageWidgetSkoon
      // fontFamily: 'QCF_P${widget.pageNumber.toString().padLeft(3, '0')}'
      final fontName = 'QCF_P${pageNumber.toString().padLeft(3, '0')}';

      final fontLoader = FontLoader(fontName);
      fontLoader.addFont(
        Future.value(ByteData.view((await file.readAsBytes()).buffer)),
      );
      await fontLoader.load();

      return true;
    } catch (e) {
      // FontLoader throws if font is already loaded, which is fine.
      // We can check the message if we want to be strict, but for now ignore 'already loaded' errors.
      if (e.toString().contains('already')) return true;
      print("Error loading font for page $pageNumber: $e");
      return false;
    }
  }

  /// Deletes the downloaded fonts (for Settings/Cleanup)
  Future<void> deleteFonts() async {
    try {
      final docDir = await getApplicationDocumentsDirectory();
      final fontDir = Directory('${docDir.path}/$_targetDirName');
      if (await fontDir.exists()) {
        await fontDir.delete(recursive: true);
      }
    } catch (e) {
      throw Exception("Failed to delete fonts: $e");
    }
  }
}
