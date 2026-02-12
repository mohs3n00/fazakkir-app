import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'l10n/app_localizations.dart';

import 'core/providers.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_provider.dart';
import 'core/localization/language_provider.dart';
import 'core/services/notification_service.dart';
import 'core/services/package_registry_service.dart';
import 'features/main_layout/main_layout_screen.dart';
import 'features/ihsan/data/models/ihsan_model.dart';
import 'features/khatma/data/models/khatma_model.dart';
import 'features/quran/data/quran_preferences.dart';

import 'core/utils/keys.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Notifications immediately to ensure channels exist
  await NotificationService().init();

  // Initialize Timezone
  tz.initializeTimeZones();
  try {
    tz.setLocalLocation(tz.getLocation('Africa/Cairo'));
  } catch (e) {
    debugPrint('Failed to set location: $e');
  }

  final prefs = await SharedPreferences.getInstance();

  await Hive.initFlutter();

  // Register Hive Adapters
  Hive.registerAdapter(DailyProgressAdapter());
  Hive.registerAdapter(KhatmaAdapter());

  await QuranPreferences.init();

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        packageRegistryProvider.overrideWithValue(
          PackageRegistryService(prefs),
        ),
      ],
      child: const FazakkirApp(),
    ),
  );
}

class FazakkirApp extends ConsumerWidget {
  const FazakkirApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);
    final locale = ref.watch(languageProvider);

    return ScreenUtilInit(
      designSize: const Size(392.72727272727275, 800.7272727272727),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp(
          scaffoldMessengerKey: rootScaffoldMessengerKey,
          debugShowCheckedModeBanner: false,
          onGenerateTitle: (context) => AppLocalizations.of(context)!.appName,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeMode,
          locale: locale,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: const MainLayoutScreen(),
        );
      },
    );
  }
}
