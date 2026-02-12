import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fazakkir/features/analytics/data/repositories/analytics_repository.dart';

class SebhaState {
  final int counter;
  final int totalCount;
  final String currentThikr;
  final int target;
  final double animationOffset;
  final double visualPosition;
  final double targetPosition;

  SebhaState({
    this.counter = 0,
    this.totalCount = 0,
    this.target = 33,
    this.visualPosition = 0.0,
    this.targetPosition = 0.0,
    this.animationOffset = 0.0,
    this.currentThikr = "سبحان الله",
  });

  SebhaState copyWith({
    int? counter,
    int? totalCount,
    int? target,
    double? visualPosition,
    double? targetPosition,
    double? animationOffset,
    String? currentThikr,
  }) {
    return SebhaState(
      counter: counter ?? this.counter,
      totalCount: totalCount ?? this.totalCount,
      target: target ?? this.target,
      visualPosition: visualPosition ?? this.visualPosition,
      targetPosition: targetPosition ?? this.targetPosition,
      animationOffset: animationOffset ?? this.animationOffset,
      currentThikr: currentThikr ?? this.currentThikr,
    );
  }
}

class SebhaController extends StateNotifier<SebhaState> {
  SebhaController() : super(SebhaState());

  void increment() {
    int nextCounter = state.counter + 1;
    // If target is 0, it means "Open" / Infinity
    if (state.target > 0 && nextCounter > state.target) {
      nextCounter = 1;
    }

    state = state.copyWith(
      counter: nextCounter,
      totalCount: state.totalCount + 1,
      targetPosition: state.targetPosition + 1.0,
    );

    // Track Analytics
    AnalyticsRepository().incrementTasbih();
  }

  void reset() {
    state = state.copyWith(
      counter: 0,
      targetPosition: 0.0,
      visualPosition: 0.0,
    );
  }

  void setTarget(int newTarget) {
    state = state.copyWith(target: newTarget, counter: 0);
  }

  void toggleTarget() {
    // Cycle: 33 -> 100 -> 0 (Open) -> 33
    int newTarget = 33;
    if (state.target == 33) {
      newTarget = 100;
    } else if (state.target == 100)
      newTarget = 0;

    state = state.copyWith(target: newTarget, counter: 0);
  }

  void setThikr(String thikr) {
    state = state.copyWith(currentThikr: thikr, counter: 0);
  }
}

final sebhaProvider = StateNotifierProvider<SebhaController, SebhaState>((ref) {
  return SebhaController();
});
