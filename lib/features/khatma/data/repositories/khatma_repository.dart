import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter/material.dart'; // For TimeOfDay
import '../models/khatma_model.dart';
import 'package:fazakkir/features/analytics/data/repositories/analytics_repository.dart';
import 'package:fazakkir/core/services/native_scheduler_service.dart';

class KhatmaRepository {
  static const String boxName = 'khatma_box';

  Future<Box<Khatma>> _openBox() async {
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(KhatmaAdapter());
    }
    return await Hive.openBox<Khatma>(boxName);
  }

  Future<Khatma?> getActiveKhatma() async {
    final box = await _openBox();
    try {
      return box.values.firstWhere((k) => !k.isCompleted);
    } catch (e) {
      return null;
    }
  }

  Future<List<Khatma>> getAllKhatmas() async {
    final box = await _openBox();
    return box.values.toList();
  }

  Future<String> createKhatma({
    required String name,
    DateTime? targetDate,
    int? dailyPageGoal,
    bool reminderEnabled = false,
    TimeOfDay? reminderTime,
    String? reminderTitle,
    String? reminderBody,
  }) async {
    final box = await _openBox();
    final id = const Uuid().v4();

    DateTime? reminderDateTime;
    if (reminderTime != null) {
      final now = DateTime.now();
      reminderDateTime = DateTime(
        now.year,
        now.month,
        now.day,
        reminderTime.hour,
        reminderTime.minute,
      );
    }

    final khatma = Khatma(
      id: id,
      name: name,
      startDate: DateTime.now(),
      targetDate: targetDate,
      dailyPageGoal: dailyPageGoal,
      reminderEnabled: reminderEnabled,
      reminderTime: reminderDateTime,
    );
    await box.put(id, khatma);

    // Schedule if enabled
    if (reminderEnabled &&
        reminderTime != null &&
        reminderTitle != null &&
        reminderBody != null) {
      await NativeSchedulerService().scheduleDailyKhatma(
        id: id.hashCode,
        title: reminderTitle,
        body: reminderBody,
        time: reminderTime,
      );
    }

    return id;
  }

  Future<void> updateKhatmaProgress(String id, int newPage) async {
    final box = await _openBox();
    final khatma = box.get(id);
    if (khatma != null) {
      final isCompleted = newPage >= khatma.endPage;
      final updated = khatma.copyWith(
        currentPage: newPage,
        isCompleted: isCompleted,
      );
      await box.put(id, updated);

      if (isCompleted && !khatma.isCompleted) {
        AnalyticsRepository().incrementKhatmaCompleted();
        // Cancel reminder on completion if desired?
        // User might want to keep it or start new one.
        // For now, let's leave it or maybe cancel it?
        // Usually, if completed, they should start a new one.
        // Let's NOT cancel automatically unless deleted, to avoid confusion.
      }
    }
  }

  Future<void> updateKhatmaReminder({
    required String id,
    required bool enabled,
    required TimeOfDay time,
    required String title,
    required String body,
  }) async {
    final box = await _openBox();
    final khatma = box.get(id);
    if (khatma != null) {
      final now = DateTime.now();
      final reminderDateTime = DateTime(
        now.year,
        now.month,
        now.day,
        time.hour,
        time.minute,
      );

      final updated = khatma.copyWith(
        reminderEnabled: enabled,
        reminderTime: reminderDateTime,
      );
      await box.put(id, updated);

      if (enabled) {
        await NativeSchedulerService().scheduleDailyKhatma(
          id: id.hashCode,
          title: title,
          body: body,
          time: time,
        );
      } else {
        await NativeSchedulerService().cancelKhatmaReminder(id.hashCode);
      }
    }
  }

  Future<void> deleteKhatma(String id) async {
    final box = await _openBox();
    await box.delete(id);
    await NativeSchedulerService().cancelKhatmaReminder(id.hashCode);
  }
}
