import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../l10n/app_localizations.dart';
import 'package:fazakkir/core/providers.dart';
import '../../../../core/theme/theme_provider.dart';
import '../../../../core/localization/language_provider.dart';
import '../../../../core/services/notification_service.dart';
import '../../../../core/services/native_scheduler_service.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final themeMode = ref.watch(themeProvider);
    final currentLocale = ref.watch(languageProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settings)), // Changed title to 'Settings'
      body: ListView(
        children: [
          _buildSectionHeader(context, l10n.settings),
          ListTile(
            leading: const Icon(Icons.language),
            title: Text(l10n.language),
            subtitle: Text(
              currentLocale?.languageCode == 'ar' ? 'العربية' : 'English',
            ),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => _showLanguageDialog(context, ref),
          ),
          ListTile(
            leading: const Icon(Icons.brightness_6),
            title: Text(l10n.theme),
            subtitle: Text(_getThemeName(l10n, themeMode)),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => _showThemeDialog(context, ref, l10n),
          ),
          const Divider(),
          _buildSectionHeader(context, l10n.storage),
          ListTile(
            leading: const Icon(Icons.font_download),
            title: Text(l10n.quranFonts),
            subtitle: FutureBuilder<bool>(
              future: ref.watch(quranFontServiceProvider).isFontsDownloaded(),
              builder: (context, snapshot) {
                if (snapshot.hasData && snapshot.data == true) {
                  return const Text("80 MB");
                }
                return Text(l10n.filesNotDownloaded);
              },
            ),
            trailing: IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              onPressed: () => _confirmDeleteFonts(context, ref, l10n),
            ),
          ),
          const Divider(),
          _buildSectionHeader(context, l10n.troubleshootNotifications),
          ListTile(
            leading: const Icon(
              Icons.notifications_active,
              color: Colors.orange,
            ),
            title: Text(l10n.troubleshootNotifications),
            subtitle: Text(l10n.troubleshootNotificationsDesc),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => _showTroubleshootDialog(context, l10n),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: Text(l10n.about),
            subtitle: const Text("1.0.0"),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDeleteFonts(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
  ) async {
    final downloaded = await ref
        .read(quranFontServiceProvider)
        .isFontsDownloaded();
    if (!downloaded) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.filesNotDownloaded)));
      }
      return;
    }

    if (context.mounted) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(l10n.deleteQuranFonts),
          content: Text(l10n.deleteQuranFontsConfirmation),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.cancel),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                await ref.read(quranFontServiceProvider).deleteFonts();
                if (context.mounted) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text(l10n.fontsDeleted)));
                }
              },
              child: Text(
                l10n.delete,
                style: const TextStyle(color: Colors.red),
              ),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  String _getThemeName(AppLocalizations l10n, ThemeMode mode) {
    switch (mode) {
      case ThemeMode.system:
        return l10n.system;
      case ThemeMode.light:
        return l10n.light;
      case ThemeMode.dark:
        return l10n.dark;
    }
  }

  void _showLanguageDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Select Language'),
        children: [
          SimpleDialogOption(
            onPressed: () {
              ref.read(languageProvider.notifier).setLocale(const Locale('en'));
              Navigator.pop(context);
            },
            child: const Text('English'),
          ),
          SimpleDialogOption(
            onPressed: () {
              ref.read(languageProvider.notifier).setLocale(const Locale('ar'));
              Navigator.pop(context);
            },
            child: const Text('العربية'),
          ),
        ],
      ),
    );
  }

  void _showThemeDialog(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
  ) {
    showDialog(
      context: context,
      builder: (context) => SimpleDialog(
        title: Text(l10n.theme),
        children: [
          SimpleDialogOption(
            onPressed: () {
              ref.read(themeProvider.notifier).setThemeMode(ThemeMode.light);
              Navigator.pop(context);
            },
            child: Text(l10n.light),
          ),
          SimpleDialogOption(
            onPressed: () {
              ref.read(themeProvider.notifier).setThemeMode(ThemeMode.dark);
              Navigator.pop(context);
            },
            child: Text(l10n.dark),
          ),
          SimpleDialogOption(
            onPressed: () {
              ref.read(themeProvider.notifier).setThemeMode(ThemeMode.system);
              Navigator.pop(context);
            },
            child: Text(l10n.system),
          ),
        ],
      ),
    );
  }

  void _showTroubleshootDialog(BuildContext context, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(l10n.troubleshootNotifications),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Exact Alarm Permission
                  FutureBuilder<bool>(
                    future: NativeSchedulerService().canScheduleExactAlarms(),
                    builder: (context, snapshot) {
                      final granted = snapshot.data ?? false;
                      return ListTile(
                        leading: Icon(
                          granted ? Icons.check_circle : Icons.error,
                          color: granted ? Colors.green : Colors.red,
                        ),
                        title: Text(l10n.exactAlarmPermission),
                        subtitle: Text(
                          granted
                              ? l10n.permissionGranted
                              : l10n.permissionDenied,
                        ),
                        trailing: granted
                            ? null
                            : ElevatedButton(
                                onPressed: () async {
                                  await NativeSchedulerService()
                                      .requestExactAlarmPermission();
                                  // Wait a bit for user to potentially act (though they go to settings usually)
                                  await Future.delayed(
                                    const Duration(seconds: 1),
                                  );
                                  setState(() {});
                                },
                                child: Text(l10n.allow),
                              ),
                      );
                    },
                  ),
                  const Divider(),
                  // Battery Optimization
                  FutureBuilder<bool>(
                    future: NotificationService()
                        .isBatteryOptimizationIgnored(),
                    builder: (context, snapshot) {
                      final ignored = snapshot.data ?? false;
                      // "Ignored" means optimization is OFF (Good)
                      // "Not Ignored" means optimization is ON (Bad)
                      return ListTile(
                        leading: Icon(
                          ignored ? Icons.check_circle : Icons.warning,
                          color: ignored ? Colors.green : Colors.orange,
                        ),
                        title: Text(l10n.batteryOptimizationPermission),
                        subtitle: Text(
                          ignored
                              ? l10n.permissionGranted
                              : l10n.permissionDenied,
                        ),
                        trailing: ignored
                            ? null
                            : ElevatedButton(
                                onPressed: () async {
                                  await NotificationService()
                                      .requestIgnoreBatteryOptimization();
                                  await Future.delayed(
                                    const Duration(seconds: 1),
                                  );
                                  setState(() {});
                                },
                                child: Text(l10n.allow),
                              ),
                      );
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(l10n.close),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
