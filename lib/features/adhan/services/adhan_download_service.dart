import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:archive/archive_io.dart';
import 'package:fazakkir/features/adhan/data/repositories/adhan_repository.dart';

final adhanDownloadServiceProvider = Provider(
  (ref) => AdhanDownloadService(ref),
);

class AdhanDownloadService {
  final Ref ref;
  final Dio _dio = Dio();

  AdhanDownloadService(this.ref);

  Future<void> downloadAndExtractAdhan({
    required Function(double) onProgress,
    required Function(String) onError,
    required Function() onSuccess,
    required Function(String) onStatusChange,
  }) async {
    final docDir = await getApplicationDocumentsDirectory();
    final zipPath = '${docDir.path}/Athan.zip';
    final targetDir = '${docDir.path}/athan_sounds';

    try {
      // 1. Download
      onStatusChange("جاري التنزيل...");

      await _dio.download(
        'https://github.com/mohs3n00/fazakkir-assets/releases/download/athan_v1/Athan_Fixed.zip',
        zipPath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            final progress = received / total * 0.7;
            onProgress(progress); // 70% for download
          }
        },
      );

      final zipFile = File(zipPath);
      final zipExists = await zipFile.exists();
      final zipSize = zipExists ? await zipFile.length() : 0;

      if (!zipExists || zipSize == 0) {
        throw 'ZIP file not found or empty after download';
      }

      // 2. Extract
      onStatusChange("جاري فك الضغط...");
      onProgress(0.7); // Start extraction at 70%

      final dir = Directory(targetDir);
      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }

      try {
        // Extract ZIP using archive package
        final bytes = await File(zipPath).readAsBytes();

        final archive = ZipDecoder().decodeBytes(bytes);

        int processedFiles = 0;
        final totalFiles = archive.where((f) => f.isFile).length;

        for (final file in archive) {
          if (file.isFile) {
            final data = file.content as List<int>;

            // Extract filename from path (handle subdirectories)
            final fileName = file.name.split('/').last.split('\\').last;

            // Skip if not an audio file
            if (!fileName.toLowerCase().endsWith('.mp3')) {
              continue;
            }

            final outputPath = '$targetDir/$fileName';

            File(outputPath)
              ..createSync(recursive: true)
              ..writeAsBytesSync(data);
          }

          processedFiles++;
          // Progress from 70% to 95%
          onProgress(0.7 + (processedFiles / totalFiles * 0.25));
        }

        // Verify extracted files
        final extractedDir = Directory(targetDir);
        await extractedDir.list().toList();
      } catch (e) {
        // Cleanup on extraction failure
        if (await Directory(targetDir).exists()) {
          await Directory(targetDir).delete(recursive: true);
        }
        if (await File(zipPath).exists()) {
          await File(zipPath).delete();
        }
        onError("فشل فك الضغط: $e");
        return;
      }

      // 3. Cleanup
      onStatusChange("جاري الإنهاء...");
      onProgress(0.95);

      final zipFileToDelete = File(zipPath);
      if (await zipFileToDelete.exists()) {
        await zipFileToDelete.delete();
      }

      // Mark as downloaded
      await ref.read(adhanRepositoryProvider).setAdhanDownloaded(true);

      onProgress(1.0);
      onSuccess();
    } catch (e) {
      // Cleanup on any failure
      try {
        if (await Directory(targetDir).exists()) {
          await Directory(targetDir).delete(recursive: true);
        }
        if (await File(zipPath).exists()) {
          await File(zipPath).delete();
        }
      } catch (_) {}

      onError("فشل التنزيل: $e");
    }
  }
}
