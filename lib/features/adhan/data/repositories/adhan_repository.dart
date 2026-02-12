import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fazakkir/features/adhan/data/models/muezzin_model.dart';

class AdhanRepository {
  static const String _storageKey = 'selected_muezzin_id';
  static const String _downloadedKey = 'adhan_downloaded';

  Future<String> getAdhanDirectory() async {
    final docDir = await getApplicationDocumentsDirectory();
    return '${docDir.path}/athan_sounds';
  }

  Future<bool> isAdhanDownloaded() async {
    final prefs = await SharedPreferences.getInstance();
    final markedAsDownloaded = prefs.getBool(_downloadedKey) ?? false;

    // Always verify actual files exist
    final dir = await getAdhanDirectory();
    final directory = Directory(dir);

    if (!await directory.exists()) {
      // Reset flag if directory doesn't exist
      if (markedAsDownloaded) {
        await setAdhanDownloaded(false);
      }
      return false;
    }

    // Check if at least 3 files exist (to ensure download wasn't partial)
    int existingFiles = 0;
    for (final muezzin in Muezzin.allMuezzins.take(3)) {
      final file = File('$dir/${muezzin.fileName}');
      if (await file.exists()) {
        existingFiles++;
      }
    }

    final hasFiles = existingFiles >= 3;

    // Sync the flag with actual state
    if (hasFiles != markedAsDownloaded) {
      await setAdhanDownloaded(hasFiles);
    }

    return hasFiles;
  }

  Future<void> setAdhanDownloaded(bool downloaded) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_downloadedKey, downloaded);
  }

  Future<Muezzin> getSelectedMuezzin() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getString(_storageKey);
    return Muezzin.allMuezzins.firstWhere(
      (m) => m.id == id,
      orElse: () => Muezzin.allMuezzins.first,
    );
  }

  Future<void> saveSelectedMuezzin(String id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKey, id);
  }

  Future<File?> getMuezzinFile(Muezzin muezzin) async {
    final dir = await getAdhanDirectory();
    final file = File('$dir/${muezzin.fileName}');
    final exists = await file.exists();

    // Checking file
    // Checking file path and existence

    if (exists) {
      return file;
    }
    return null;
  }
}

final adhanRepositoryProvider = Provider((ref) => AdhanRepository());
