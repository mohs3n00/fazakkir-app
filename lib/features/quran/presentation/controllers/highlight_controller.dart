import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum HighlightReason {
  audioActive, // Highest priority
  tafsirFocus, // When viewing tafsir
  searchJump, // Temporary after search
  manualSelect, // Short press
}

class HighlightState {
  final int? surah;
  final int? ayah;
  final HighlightReason? reason;
  final DateTime? expiresAt;

  const HighlightState({this.surah, this.ayah, this.reason, this.expiresAt});

  bool get isActive {
    if (expiresAt != null && DateTime.now().isAfter(expiresAt!)) {
      return false;
    }
    return surah != null && ayah != null;
  }
}

final highlightControllerProvider =
    StateNotifierProvider<HighlightController, HighlightState>((ref) {
      return HighlightController();
    });

class HighlightController extends StateNotifier<HighlightState> {
  Timer? _expiryTimer;

  HighlightController() : super(const HighlightState());

  void highlight(
    int surah,
    int ayah,
    HighlightReason reason, {
    Duration? duration,
  }) {
    // Priority check
    /*
    if (state.isActive) {
      // If current is audioActive, don't override with lower priority
      if (state.reason == HighlightReason.audioActive &&
          reason != HighlightReason.audioActive) {
        return;
      }

      // If current is tafsirFocus, only override with audioActive
      if (state.reason == HighlightReason.tafsirFocus &&
          reason != HighlightReason.audioActive &&
          reason != HighlightReason.tafsirFocus) {
        return;
      }
    }
    */
    // SIMPLIFIED LOGIC:
    // manualSelect always wins (user intent).
    // audioActive wins over tafsir/search (system intent).
    // But if manualSelect happens, we expect the audio to stop first or be paused.
    // So we just allow the update. The only thing we might want to block is
    // if we are in "Tafsir Mode" and audio tries to play? No, audio should also win there.
    //
    // Let's just allow updates. If proper state management is done in controllers,
    // this class should just hold the state.

    _expiryTimer?.cancel();

    DateTime? expiry;
    if (duration != null) {
      expiry = DateTime.now().add(duration);
      _expiryTimer = Timer(duration, () {
        if (state.reason == reason) {
          clearHighlight(reason);
        }
      });
    }

    state = HighlightState(
      surah: surah,
      ayah: ayah,
      reason: reason,
      expiresAt: expiry,
    );
  }

  void clearHighlight(HighlightReason reason) {
    if (state.reason == reason) {
      _expiryTimer?.cancel();
      state = const HighlightState();
    }
  }

  // Useful for when audio stops
  void clearAudioHighlight() {
    clearHighlight(HighlightReason.audioActive);
  }
}
