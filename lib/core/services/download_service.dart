import 'dart:io';
import 'package:archive/archive_io.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

final downloadServiceProvider = Provider((ref) => DownloadService());

class DownloadService {
  final Dio _dio = Dio();

  Future<void> downloadAndExtract({
    required String url,
    required String destinationDir, // The folder where contents should go
    required Function(double) onProgress,
    required Function(String) onError,
    required Function() onSuccess,
    required Function(String) onStatusChange,
  }) async {
    final docDir = await getApplicationDocumentsDirectory();
    // Create a temporary zip path
    final zipFileName = url.split('/').last;
    final zipPath = '${docDir.path}/$zipFileName';

    // Ensure destination exists
    final targetDirectory = Directory(destinationDir);

    try {
      // 1. Download
      onStatusChange("جاري التنزيل...");

      await _dio.download(
        url,
        zipPath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            final progress = received / total * 0.7;
            onProgress(progress); // 70% for download
          }
        },
      );

      // 2. Extract
      onStatusChange("جاري فك الضغط...");
      onProgress(0.7);

      if (!await targetDirectory.exists()) {
        await targetDirectory.create(recursive: true);
      }

      await _extractZip(zipPath, destinationDir, (extractProgress) {
        // Map 0.0-1.0 extract progress to 0.7-0.95 overall
        onProgress(0.7 + (extractProgress * 0.25));
      });

      // 3. Cleanup
      onStatusChange("جاري التنظيف...");
      final zipFile = File(zipPath);
      if (await zipFile.exists()) {
        await zipFile.delete();
      }

      onProgress(1.0);
      onSuccess();
    } catch (e) {
      // Attempt cleanup
      try {
        if (await File(zipPath).exists()) {
          await File(zipPath).delete();
        }
      } catch (_) {}

      onError("فشل العملية: $e");
    }
  }

  Future<void> _extractZip(
    String zipPath,
    String destinationPath,
    Function(double) onExtractProgress,
  ) async {
    final bytes = await File(zipPath).readAsBytes();
    final archive = ZipDecoder().decodeBytes(bytes);
    final totalFiles = archive.where((f) => f.isFile).length;
    int processed = 0;

    for (final file in archive) {
      final filename = file.name;
      if (file.isFile) {
        final data = file.content as List<int>;
        File('$destinationPath/$filename')
          ..createSync(recursive: true)
          ..writeAsBytesSync(data);

        processed++;
        onExtractProgress(processed / totalFiles);
      } else {
        Directory('$destinationPath/$filename').create(recursive: true);
      }
    }
  }
}
