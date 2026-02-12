import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:just_audio/just_audio.dart';
import '../../../../core/theme/app_colors.dart';
import 'package:fazakkir/features/adhan/data/models/muezzin_model.dart';
import 'package:fazakkir/features/adhan/data/repositories/adhan_repository.dart';
import 'package:fazakkir/features/adhan/services/adhan_download_service.dart';
import '../../../../l10n/app_localizations.dart';

class AdhanSettingsScreen extends ConsumerStatefulWidget {
  const AdhanSettingsScreen({super.key});

  @override
  ConsumerState<AdhanSettingsScreen> createState() =>
      _AdhanSettingsScreenState();
}

class _AdhanSettingsScreenState extends ConsumerState<AdhanSettingsScreen> {
  final AudioPlayer _player = AudioPlayer();
  bool _isDownloading = false;
  double _downloadProgress = 0.0;
  String? _error;
  String? _selectedMuezzinId;
  String? _playingMuezzinId;
  String _downloadStatus = "";
  bool? _isDownloaded; // Cache the download status

  @override
  void initState() {
    super.initState();
    _loadSelection();
    _checkDownloadStatus();
  }

  Future<void> _checkDownloadStatus() async {
    final downloaded = await ref
        .read(adhanRepositoryProvider)
        .isAdhanDownloaded();
    if (mounted) {
      setState(() {
        _isDownloaded = downloaded;
      });
    }
  }

  Future<void> _loadSelection() async {
    final muezzin = await ref
        .read(adhanRepositoryProvider)
        .getSelectedMuezzin();
    if (mounted) {
      setState(() {
        _selectedMuezzinId = muezzin.id;
      });
    }
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  Future<void> _downloadAdhan() async {
    setState(() {
      _isDownloading = true;
      _error = null;
      _downloadProgress = 0.0;
      _downloadStatus = AppLocalizations.of(context)!.preparingDownload;
    });

    final service = ref.read(adhanDownloadServiceProvider);
    await service.downloadAndExtractAdhan(
      onProgress: (p) {
        if (mounted) {
          setState(() => _downloadProgress = p);
        }
      },
      onStatusChange: (status) {
        if (mounted) {
          setState(() => _downloadStatus = status);
        }
      },
      onError: (e) {
        if (mounted) {
          setState(() {
            _error = e;
            _isDownloading = false;
            _downloadProgress = 0.0;
          });
        }
      },
      onSuccess: () {
        if (mounted) {
          setState(() {
            _isDownloading = false;
            _isDownloaded = true; // Update cached status
            _downloadProgress = 0.0;
          });
        }
      },
    );
  }

  Future<void> _playPreview(Muezzin muezzin) async {
    try {
      if (_playingMuezzinId == muezzin.id) {
        await _player.stop();
        setState(() => _playingMuezzinId = null);
        return;
      }

      final repo = ref.read(adhanRepositoryProvider);
      final file = await repo.getMuezzinFile(muezzin);

      if (file != null) {
        await _player.setFilePath(file.path);
        await _player.play();
        setState(() => _playingMuezzinId = muezzin.id);

        _player.playerStateStream.listen((state) {
          if (state.processingState == ProcessingState.completed) {
            setState(() => _playingMuezzinId = null);
          }
        });
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                AppLocalizations.of(context)!.fileNotFound(muezzin.name),
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context)!.audioError(e.toString()),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.adhanSettingsTitle), centerTitle: true),
      body: _isDownloaded == null
          ? const Center(child: CircularProgressIndicator())
          : _isDownloaded!
          ? _buildMuezzinList(isDark)
          : _buildDownloadView(isDark, l10n),
    );
  }

  Widget _buildDownloadView(bool isDark, AppLocalizations l10n) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(20.w),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white10
                    : AppColors.islamicGold.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.mosque_rounded,
                size: 64.sp,
                color: AppColors.islamicGold,
              ),
            ),
            SizedBox(height: 24.h),
            Text(
              l10n.downloadAdhanTitle,
              style: TextStyle(
                fontSize: 22.sp,
                fontWeight: FontWeight.bold,
                fontFamily: "Cairo",
              ),
            ),
            SizedBox(height: 12.h),
            Text(
              l10n.downloadAdhanBody,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey,
                fontSize: 14.sp,
                height: 1.5,
              ),
            ),
            SizedBox(height: 48.h),

            if (_isDownloading) ...[
              Column(
                children: [
                  LinearProgressIndicator(
                    value: _downloadProgress,
                    backgroundColor: Colors.grey[300],
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      AppColors.islamicGold,
                    ),
                    minHeight: 8.h,
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    _downloadStatus.isEmpty
                        ? "${(_downloadProgress * 100).toInt()}%"
                        : "$_downloadStatus ${(_downloadProgress * 100).toInt()}%",
                    style: TextStyle(
                      color: AppColors.islamicGold,
                      fontWeight: FontWeight.bold,
                      fontSize: 15.sp,
                    ),
                  ),
                ],
              ),
            ] else ...[
              SizedBox(
                width: double.infinity,
                height: 50.h,
                child: ElevatedButton.icon(
                  onPressed: _downloadAdhan,
                  icon: const Icon(Icons.download),
                  label: Text(
                    l10n.startDownload,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.islamicGold,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                ),
              ),
            ],

            if (_error != null) ...[
              SizedBox(height: 24.h),
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline, color: Colors.red),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Text(
                        _error!,
                        style: TextStyle(color: Colors.red, fontSize: 13.sp),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMuezzinList(bool isDark) {
    return ListView.builder(
      padding: EdgeInsets.all(16.w),
      itemCount: Muezzin.allMuezzins.length,
      itemBuilder: (context, index) {
        final muezzin = Muezzin.allMuezzins[index];
        final isSelected = _selectedMuezzinId == muezzin.id;
        final isPlaying = _playingMuezzinId == muezzin.id;

        return Card(
          color: isDark ? Colors.white10 : Colors.white,
          margin: EdgeInsets.only(bottom: 8.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
            side: isSelected
                ? BorderSide(color: AppColors.islamicGold, width: 2)
                : BorderSide.none,
          ),
          child: ListTile(
            leading: IconButton(
              icon: Icon(isPlaying ? Icons.pause_circle : Icons.play_circle),
              color: AppColors.islamicGold,
              onPressed: () => _playPreview(muezzin),
            ),
            title: Text(muezzin.name),
            trailing: isSelected
                ? Icon(Icons.check_circle, color: AppColors.islamicGold)
                : null,
            onTap: () {
              ref.read(adhanRepositoryProvider).saveSelectedMuezzin(muezzin.id);
              setState(() => _selectedMuezzinId = muezzin.id);
            },
          ),
        );
      },
    );
  }
}
