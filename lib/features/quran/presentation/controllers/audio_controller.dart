import 'package:fazakkir/features/quran/data/quran_preferences.dart';
import 'package:fazakkir/features/quran/data/reciters_data.dart';
import 'package:fazakkir/core/services/package_registry_service.dart';
import 'package:fazakkir/features/quran/data/quran_library/quran.dart';
import 'package:fazakkir/features/quran/presentation/controllers/highlight_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
// import 'package:fazakkir/core/providers.dart';
import 'dart:io';
import 'package:flutter/material.dart'; // For Colors/SnackBar
import 'package:fazakkir/core/utils/keys.dart';

class AudioState {
  final bool isPlaying;
  final bool isLoading;
  final int? currentSurah;
  final int? currentAyah;
  final String currentReaderId; // Use folder name as ID
  final Duration position;
  final Duration duration;

  const AudioState({
    this.isPlaying = false,
    this.isLoading = false,
    this.currentSurah,
    this.currentAyah,
    this.currentReaderId = "mishari_rashid_al_afasy", // Default
    this.position = Duration.zero,
    this.duration = Duration.zero,
  });

  AudioState copyWith({
    bool? isPlaying,
    bool? isLoading,
    int? currentSurah,
    int? currentAyah,
    String? currentReaderId,
    Duration? position,
    Duration? duration,
  }) {
    return AudioState(
      isPlaying: isPlaying ?? this.isPlaying,
      isLoading: isLoading ?? this.isLoading,
      currentSurah: currentSurah ?? this.currentSurah,
      currentAyah: currentAyah ?? this.currentAyah,
      currentReaderId: currentReaderId ?? this.currentReaderId,
      position: position ?? this.position,
      duration: duration ?? this.duration,
    );
  }
}

final audioControllerProvider =
    StateNotifierProvider<AudioController, AudioState>((ref) {
      return AudioController(ref);
    });

class AudioController extends StateNotifier<AudioState> {
  final Ref ref;
  final AudioPlayer _player = AudioPlayer();

  AudioController(this.ref) : super(const AudioState()) {
    _initListeners();
    _loadSavedReciter();
  }

  void _loadSavedReciter() {
    final saved = QuranPreferences.getReciter();
    if (saved != state.currentReaderId) {
      state = state.copyWith(currentReaderId: saved);
    }
  }

  void _initListeners() {
    _player.playerStateStream.listen((playerState) {
      final isPlaying = playerState.playing;
      final processingState = playerState.processingState;

      if (processingState == ProcessingState.completed) {
        _onAyahFinished();
      }

      state = state.copyWith(
        isPlaying: isPlaying,
        isLoading:
            processingState == ProcessingState.loading ||
            processingState == ProcessingState.buffering,
      );
    });

    _player.positionStream.listen((pos) {
      state = state.copyWith(position: pos);
    });

    _player.durationStream.listen((dur) {
      state = state.copyWith(duration: dur ?? Duration.zero);
    });
  }

  Future<void> playAyah(int surah, int ayah) async {
    // 0. Ensure Reciter is Ready (Removes unused asset logic)
    // await _ensureReciterReady(state.currentReaderId);

    // 1. Check if reader is installed (Voice or DB)
    final registry = ref.read(packageRegistryProvider);
    final voiceInstalled = registry.isPackageInstalled(
      state.currentReaderId,
      PackageType.voice,
    );
    /*
    final dbInstalled = registry.isPackageInstalled(
      state.currentReaderId,
      PackageType.recitationDb,
    );
*/

    state = state.copyWith(
      currentSurah: surah,
      currentAyah: ayah,
      isLoading: true,
    );

    // Trigger highlight
    ref
        .read(highlightControllerProvider.notifier)
        .highlight(surah, ayah, HighlightReason.audioActive);

    try {
      String? playUrl;

      if (voiceInstalled) {
        // ... existing local file logic ...
        final pkg = registry.getInstalledPackages().firstWhere(
          (p) => p.id == state.currentReaderId && p.type == PackageType.voice,
        );
        final surahStr = surah.toString().padLeft(3, '0');
        final ayahStr = ayah.toString().padLeft(3, '0');
        final possiblePath = "${pkg.localPath}/$surahStr$ayahStr.mp3";
        if (File(possiblePath).existsSync()) {
          await _player.setFilePath(possiblePath);
          await _player.play();
          return;
        }
      }

      /*
      // DB Lookup Disabled due to data mismatch issues
      if (dbInstalled) {
        // ... (Logic removed to fix critical bug)
      }
      */

      // Check internet connection before streaming
      try {
        final result = await InternetAddress.lookup('google.com');
        if (result.isEmpty || result[0].rawAddress.isEmpty) {
          throw SocketException("No internet");
        }
      } on SocketException catch (_) {
        state = state.copyWith(isLoading: false, isPlaying: false);
        rootScaffoldMessengerKey.currentState?.showSnackBar(
          const SnackBar(
            content: Text("لا يوجد اتصال بالانترنت للاستماع"),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final reciter = reciters.firstWhere(
        (r) => r.identifier == state.currentReaderId,
        orElse: () => reciters.first,
      );

      final surahStr = surah.toString().padLeft(3, '0');
      final ayahStr = ayah.toString().padLeft(3, '0');

      playUrl =
          "https://everyayah.com/data/${reciter.remotePath}/$surahStr$ayahStr.mp3";
    
      await _player.setUrl(playUrl);
      await _player.play();
    } catch (e) {
      // Audio Error

      state = state.copyWith(isLoading: false, isPlaying: false);
    }
  }

  Future<void> pause() async {
    await _player.pause();
  }

  Future<void> resume() async {
    await _player.play();
  }

  Future<void> nextAyah() async {
    if (state.currentSurah == null || state.currentAyah == null) return;

    int nextAyah = state.currentAyah! + 1;
    int nextSurah = state.currentSurah!;

    if (nextAyah > getVerseCount(nextSurah)) {
      nextSurah++;
      nextAyah = 1;
      if (nextSurah > 114) {
        // End of Quran
        stop();
        return;
      }
    }

    await playAyah(nextSurah, nextAyah);
  }

  Future<void> prevAyah() async {
    if (state.currentSurah == null || state.currentAyah == null) return;

    int prevAyah = state.currentAyah! - 1;
    int prevSurah = state.currentSurah!;

    if (prevAyah < 1) {
      prevSurah--;
      if (prevSurah < 1) return;
      prevAyah = getVerseCount(prevSurah);
    }

    await playAyah(prevSurah, prevAyah);
  }

  void _onAyahFinished() {
    // Auto advance
    nextAyah();
  }

  void changeReader(String readerId) {
    if (state.currentReaderId == readerId) return;
    state = state.copyWith(currentReaderId: readerId);
    QuranPreferences.saveReciter(readerId);

    // Restart the current ayah with the new reader immediately
    if (state.currentSurah != null && state.currentAyah != null) {
      playAyah(state.currentSurah!, state.currentAyah!);
    }
  }

  Future<void> stop() async {
    await _player.stop();
    // Re-create state to ensure nulls are applied (copyWith ignores nulls)
    state = AudioState(
      currentReaderId: state.currentReaderId,
      isPlaying: false,
      isLoading: false,
    );
    ref.read(highlightControllerProvider.notifier).clearAudioHighlight();
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }
}
