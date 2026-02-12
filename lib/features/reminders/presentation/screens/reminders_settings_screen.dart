import 'package:fazakkir/core/providers.dart';
import 'package:fazakkir/core/services/native_scheduler_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import '../../../../l10n/app_localizations.dart';

import 'package:fazakkir/features/adhan/services/adhan_scheduling_service.dart';

class RemindersSettingsScreen extends ConsumerStatefulWidget {
  const RemindersSettingsScreen({super.key});

  @override
  ConsumerState<RemindersSettingsScreen> createState() =>
      _RemindersSettingsScreenState();
}

class _RemindersSettingsScreenState
    extends ConsumerState<RemindersSettingsScreen> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  String? _currentlyPlayingPath;
  bool _isPlaying = false;

  List<(String, String)> _getReciters(BuildContext context) {
    return [
      (
        'الشيخ عبد الباسط عبد الصمد',
        'assets/audio/prophet_prayers/abdul_basit.mp3',
      ),
      ('الشيخ محمد صديق المنشاوي', 'assets/audio/prophet_prayers/minshawi.mp3'),
      ('الشيخ محمد عمران', 'assets/audio/prophet_prayers/omran.mp3'),
      ('الشيخ مشاري راشد', 'assets/audio/prophet_prayers/mishary.mp3'),
      (
        AppLocalizations.of(context)!.shortTone,
        'assets/audio/prophet_prayers/asem_as.mp3',
      ),
    ];
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _playPreview(String path) async {
    try {
      if (_currentlyPlayingPath == path && _isPlaying) {
        await _audioPlayer.stop();
        setState(() {
          _isPlaying = false;
          _currentlyPlayingPath = null;
        });
      } else {
        await _audioPlayer.setAsset(path);
        await _audioPlayer.play();
        setState(() {
          _currentlyPlayingPath = path;
          _isPlaying = true;
        });
        _audioPlayer.playerStateStream.listen((state) {
          if (state.processingState == ProcessingState.completed) {
            setState(() {
              _isPlaying = false;
              _currentlyPlayingPath = null;
            });
          }
        });
      }
    } catch (e) {
      debugPrint("Error playing audio: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final prefs = ref.watch(reminderPreferencesProvider);
    final scheduler = NativeSchedulerService();
    final l10n = AppLocalizations.of(context)!;
    final reciters = _getReciters(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.remindersSettings)),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Section 1: Pray for Prophet
          _buildSectionHeader(l10n.prophetReminder),
          SwitchListTile(
            title: Text(l10n.enableReminders),
            value: prefs.isProphetEnabled,
            onChanged: (val) async {
              await prefs.setProphetEnabled(val);
              if (val) {
                // Schedule
                await scheduler.scheduleProphetReminder(
                  intervalMinutes: prefs.prophetIntervalMinutes,
                  audioPath: prefs.prophetAudio,
                );
              } else {
                // Cancel
                await scheduler.cancelProphetReminder();
              }
              // Rebuild will happen automatically
              if (mounted) setState(() {});
            },
          ),
          if (prefs.isProphetEnabled) ...[
            ListTile(
              title: Text(l10n.reminderInterval),
              trailing: DropdownButton<int>(
                value: prefs.prophetIntervalMinutes,
                items: [
                  DropdownMenuItem(
                    value: 5,
                    child: Text(l10n.everyXMinutes(5)),
                  ),
                  DropdownMenuItem(
                    value: 15,
                    child: Text(l10n.everyXMinutes(15)),
                  ),
                  DropdownMenuItem(
                    value: 30,
                    child: Text(l10n.everyXMinutes(30)),
                  ),
                  DropdownMenuItem(value: 60, child: Text(l10n.everyHour)),
                  DropdownMenuItem(value: 120, child: Text(l10n.everyTwoHours)),
                ],
                onChanged: (val) async {
                  if (val != null) {
                    await prefs.setProphetInterval(val);
                    // Reschedule
                    await scheduler.scheduleProphetReminder(
                      intervalMinutes: val,
                      audioPath: prefs.prophetAudio,
                    );
                    if (mounted) setState(() {});
                  }
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              child: Text(
                l10n.selectReciter,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            ...reciters.map((reciter) {
              return RadioListTile<String>(
                title: Text(reciter.$1),
                value: reciter.$2,
                groupValue: prefs.prophetAudio,
                onChanged: (val) async {
                  if (val != null) {
                    await prefs.setProphetAudio(val);
                    // Reschedule with new audio
                    await scheduler.scheduleProphetReminder(
                      intervalMinutes: prefs.prophetIntervalMinutes,
                      audioPath: val,
                    );
                    if (mounted) setState(() {});
                  }
                },
                secondary: IconButton(
                  icon: Icon(
                    _currentlyPlayingPath == reciter.$2 && _isPlaying
                        ? Icons.stop_circle_outlined
                        : Icons.play_circle_outline,
                    color: _currentlyPlayingPath == reciter.$2 && _isPlaying
                        ? Colors.red
                        : null,
                  ),
                  onPressed: () => _playPreview(reciter.$2),
                ),
              );
            }),
            const SizedBox(height: 16),
          ],

          const Divider(height: 48),

          // Section 2: Pre-Prayer
          _buildSectionHeader(l10n.prePrayerReminder),
          SwitchListTile(
            title: Text(l10n.enableReminders),
            subtitle: Text(l10n.prePrayerSubtitle),
            value: prefs.isPrePrayerEnabled,
            onChanged: (val) async {
              await prefs.setPrePrayerEnabled(val);
              if (val) {
                await ref.read(adhanSchedulingServiceProvider).scheduleAdhans();
              } else {
                await ref
                    .read(adhanSchedulingServiceProvider)
                    .cancelPrePrayerReminders();
              }
              if (mounted) setState(() {});
            },
          ),
          if (prefs.isPrePrayerEnabled) ...[
            ListTile(
              title: Text(l10n.minutesBeforePrayer),
              trailing: DropdownButton<int>(
                value: prefs.prePrayerOffsetMinutes,
                items: [
                  DropdownMenuItem(
                    value: 5,
                    child: Text(l10n.beforeXMinutes(5)),
                  ),
                  DropdownMenuItem(
                    value: 10,
                    child: Text(l10n.beforeXMinutes(10)),
                  ),
                  DropdownMenuItem(
                    value: 15,
                    child: Text(l10n.beforeXMinutes(15)),
                  ),
                ],
                onChanged: (val) async {
                  if (val != null) {
                    await prefs.setPrePrayerOffset(val);
                    // Reschedule handled automatically
                    if (mounted) setState(() {});
                  }
                },
              ),
            ),
            const SizedBox(height: 16),
          ],
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).primaryColor,
        ),
      ),
    );
  }
}
