import 'dart:io';
import 'dart:ui';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fazakkir/features/adhan/data/models/muezzin_model.dart';
import 'package:fazakkir/features/adhan/data/repositories/adhan_repository.dart';

import 'package:fazakkir/core/services/notification_service.dart';

final adhanPlayerServiceProvider = Provider((ref) => AdhanPlayerService(ref));

class AdhanPlayerService {
  final Ref ref;
  final AudioPlayer _player = AudioPlayer();

  AdhanPlayerService(this.ref);

  Future<void> playAdhan() async {
    // Foreground play (preview or testing)
    await _playCurrentAdhan(_player);
  }

  Future<void> stopAdhan() async {
    await _player.stop();
  }

  // Helper to play current selected Adhan
  Future<void> _playCurrentAdhan(AudioPlayer player) async {
    final repo = ref.read(adhanRepositoryProvider);
    final muezzin = await repo.getSelectedMuezzin();
    final file = await repo.getMuezzinFile(muezzin);

    if (file != null && await file.exists()) {
      await player.setFilePath(file.path);
      await player.play();
    }
  }
}

// Background Callback
@pragma('vm:entry-point')
void playAdhanCallback(int id) async {
  try {
    // 1. Initialize dependencies for background isolate
    DartPluginRegistrant.ensureInitialized();

    // Initialize Notification Service for background usage
    final notificationService = NotificationService();
    await notificationService.init();

    // 2. Get Selected Muezzin from SharedPrefs
    final prefs = await SharedPreferences.getInstance();
    final muezzinId = prefs.getString(
      'selected_muezzin_id',
    ); // Hardcoded key from Repository

    final muezzin = Muezzin.allMuezzins.firstWhere(
      (m) => m.id == muezzinId,
      orElse: () => Muezzin.allMuezzins.first,
    );

    // 3. Show Notification
    // Determine which prayer this is based on ID or time?
    // ID convention: 1000 + index
    // 0: Fajr, 1: Dhuhr, 2: Asr, 3: Maghrib, 4: Isha
    String prayerName = 'Prayer Time';
    int prayerIndex = id - 1000;

    // Arabic mapping for better UX
    final arabicNames = ['الفجر', 'الظهر', 'العصر', 'المغرب', 'العشاء'];
    String bodyText = 'حي على الصلاة';
    String titleText = 'حان الآن موعد الصلاة';

    if (prayerIndex >= 0 && prayerIndex < 5) {
      titleText = 'حان الآن موعد صلاة ${arabicNames[prayerIndex]}';
    }

    try {
      await notificationService.showAdhanNotification(
        title: titleText,
        body: bodyText,
      );
    } catch (e) {
      // Ignore notification errors
    }

    // 4. Play Audio
    final docDir = await getApplicationDocumentsDirectory();
    final filePath = '${docDir.path}/athan_sounds/${muezzin.fileName}';
    final file = File(filePath);

    if (await file.exists()) {
      final player = AudioPlayer();
      try {
        await player.setFilePath(filePath);
        await player.play();

        // Wait for completion or timeout
        await player.playerStateStream
            .firstWhere(
              (state) => state.processingState == ProcessingState.completed,
            )
            .timeout(
              const Duration(minutes: 5),
              onTimeout: () {
                return PlayerState(false, ProcessingState.completed);
              },
            );
      } catch (e) {
        // Error playing audio
      } finally {
        await player.dispose();
      }
    }
  } catch (e) {
    // Fatal error in Adhan Callback
  }
}
