import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'Fazakkir'**
  String get appName;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @sebha.
  ///
  /// In en, this message translates to:
  /// **'Tasbih'**
  String get sebha;

  /// No description provided for @athkar.
  ///
  /// In en, this message translates to:
  /// **'Athkar'**
  String get athkar;

  /// No description provided for @quran.
  ///
  /// In en, this message translates to:
  /// **'Quran'**
  String get quran;

  /// No description provided for @me.
  ///
  /// In en, this message translates to:
  /// **'Me'**
  String get me;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @light.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get light;

  /// No description provided for @dark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get dark;

  /// No description provided for @system.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get system;

  /// No description provided for @downloadQuran.
  ///
  /// In en, this message translates to:
  /// **'Download Quran'**
  String get downloadQuran;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @prayerTimes.
  ///
  /// In en, this message translates to:
  /// **'Prayer Times'**
  String get prayerTimes;

  /// No description provided for @nextPrayer.
  ///
  /// In en, this message translates to:
  /// **'Next Prayer'**
  String get nextPrayer;

  /// No description provided for @fajr.
  ///
  /// In en, this message translates to:
  /// **'Fajr'**
  String get fajr;

  /// No description provided for @dhuhr.
  ///
  /// In en, this message translates to:
  /// **'Dhuhr'**
  String get dhuhr;

  /// No description provided for @asr.
  ///
  /// In en, this message translates to:
  /// **'Asr'**
  String get asr;

  /// No description provided for @maghrib.
  ///
  /// In en, this message translates to:
  /// **'Maghrib'**
  String get maghrib;

  /// No description provided for @isha.
  ///
  /// In en, this message translates to:
  /// **'Isha'**
  String get isha;

  /// No description provided for @sunrise.
  ///
  /// In en, this message translates to:
  /// **'Sunrise'**
  String get sunrise;

  /// No description provided for @counter.
  ///
  /// In en, this message translates to:
  /// **'Counter'**
  String get counter;

  /// No description provided for @reset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get reset;

  /// No description provided for @goal.
  ///
  /// In en, this message translates to:
  /// **'Goal'**
  String get goal;

  /// No description provided for @count.
  ///
  /// In en, this message translates to:
  /// **'Count'**
  String get count;

  /// No description provided for @morning.
  ///
  /// In en, this message translates to:
  /// **'Morning Athkar'**
  String get morning;

  /// No description provided for @evening.
  ///
  /// In en, this message translates to:
  /// **'Evening Athkar'**
  String get evening;

  /// No description provided for @afterPrayer.
  ///
  /// In en, this message translates to:
  /// **'After Prayer'**
  String get afterPrayer;

  /// No description provided for @sleep.
  ///
  /// In en, this message translates to:
  /// **'Before Sleep'**
  String get sleep;

  /// No description provided for @wakeUp.
  ///
  /// In en, this message translates to:
  /// **'Upon Waking'**
  String get wakeUp;

  /// No description provided for @general.
  ///
  /// In en, this message translates to:
  /// **'General Athkar'**
  String get general;

  /// No description provided for @juz.
  ///
  /// In en, this message translates to:
  /// **'Juz'**
  String get juz;

  /// No description provided for @surah.
  ///
  /// In en, this message translates to:
  /// **'Surah'**
  String get surah;

  /// No description provided for @page.
  ///
  /// In en, this message translates to:
  /// **'Page'**
  String get page;

  /// No description provided for @bookmark.
  ///
  /// In en, this message translates to:
  /// **'Bookmark'**
  String get bookmark;

  /// No description provided for @lastRead.
  ///
  /// In en, this message translates to:
  /// **'Last Read'**
  String get lastRead;

  /// No description provided for @index.
  ///
  /// In en, this message translates to:
  /// **'Index'**
  String get index;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @version.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get version;

  /// No description provided for @rateApp.
  ///
  /// In en, this message translates to:
  /// **'Rate App'**
  String get rateApp;

  /// No description provided for @shareApp.
  ///
  /// In en, this message translates to:
  /// **'Share App'**
  String get shareApp;

  /// No description provided for @contactUs.
  ///
  /// In en, this message translates to:
  /// **'Contact Us'**
  String get contactUs;

  /// No description provided for @storage.
  ///
  /// In en, this message translates to:
  /// **'Storage'**
  String get storage;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @saved.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get saved;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @noData.
  ///
  /// In en, this message translates to:
  /// **'No data available'**
  String get noData;

  /// No description provided for @errorOccurred.
  ///
  /// In en, this message translates to:
  /// **'An error occurred'**
  String get errorOccurred;

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get tryAgain;

  /// No description provided for @noInternet.
  ///
  /// In en, this message translates to:
  /// **'No internet connection'**
  String get noInternet;

  /// No description provided for @success.
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get success;

  /// No description provided for @failed.
  ///
  /// In en, this message translates to:
  /// **'Failed'**
  String get failed;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @yesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get yesterday;

  /// No description provided for @tomorrow.
  ///
  /// In en, this message translates to:
  /// **'Tomorrow'**
  String get tomorrow;

  /// No description provided for @now.
  ///
  /// In en, this message translates to:
  /// **'Now'**
  String get now;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @filter.
  ///
  /// In en, this message translates to:
  /// **'Filter'**
  String get filter;

  /// No description provided for @sort.
  ///
  /// In en, this message translates to:
  /// **'Sort'**
  String get sort;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @none.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get none;

  /// No description provided for @electronicRosary.
  ///
  /// In en, this message translates to:
  /// **'Electronic Rosary'**
  String get electronicRosary;

  /// No description provided for @selectThikr.
  ///
  /// In en, this message translates to:
  /// **'Select Thikr'**
  String get selectThikr;

  /// No description provided for @thikr1.
  ///
  /// In en, this message translates to:
  /// **'Subhan Allah'**
  String get thikr1;

  /// No description provided for @thikr2.
  ///
  /// In en, this message translates to:
  /// **'Alhamdulillah'**
  String get thikr2;

  /// No description provided for @thikr3.
  ///
  /// In en, this message translates to:
  /// **'Allahu Akbar'**
  String get thikr3;

  /// No description provided for @thikr4.
  ///
  /// In en, this message translates to:
  /// **'La ilaha illa Allah'**
  String get thikr4;

  /// No description provided for @thikr5.
  ///
  /// In en, this message translates to:
  /// **'Subhan Allah wa Bihamdihi'**
  String get thikr5;

  /// No description provided for @thikr6.
  ///
  /// In en, this message translates to:
  /// **'Subhan Allah Al-Adheem'**
  String get thikr6;

  /// No description provided for @thikr7.
  ///
  /// In en, this message translates to:
  /// **'Astaghfirullah'**
  String get thikr7;

  /// No description provided for @thikr8.
  ///
  /// In en, this message translates to:
  /// **'La Hawla wa La Quwwata illa Billah'**
  String get thikr8;

  /// No description provided for @thikr9.
  ///
  /// In en, this message translates to:
  /// **'Allahumma Salli \'ala Muhammad'**
  String get thikr9;

  /// No description provided for @holyQuran.
  ///
  /// In en, this message translates to:
  /// **'Holy Quran'**
  String get holyQuran;

  /// No description provided for @tafseer.
  ///
  /// In en, this message translates to:
  /// **'Tafseer'**
  String get tafseer;

  /// No description provided for @services.
  ///
  /// In en, this message translates to:
  /// **'Services'**
  String get services;

  /// No description provided for @qibla.
  ///
  /// In en, this message translates to:
  /// **'Qibla'**
  String get qibla;

  /// No description provided for @calendar.
  ///
  /// In en, this message translates to:
  /// **'Calendar'**
  String get calendar;

  /// No description provided for @ihsan.
  ///
  /// In en, this message translates to:
  /// **'Ihsan'**
  String get ihsan;

  /// No description provided for @reminders.
  ///
  /// In en, this message translates to:
  /// **'Reminders'**
  String get reminders;

  /// No description provided for @khatma.
  ///
  /// In en, this message translates to:
  /// **'Khatma'**
  String get khatma;

  /// No description provided for @adhan.
  ///
  /// In en, this message translates to:
  /// **'Adhan'**
  String get adhan;

  /// No description provided for @hadith.
  ///
  /// In en, this message translates to:
  /// **'Hadith'**
  String get hadith;

  /// No description provided for @analytics.
  ///
  /// In en, this message translates to:
  /// **'Analytics'**
  String get analytics;

  /// No description provided for @duas.
  ///
  /// In en, this message translates to:
  /// **'Duas'**
  String get duas;

  /// No description provided for @tasbihThisMonth.
  ///
  /// In en, this message translates to:
  /// **'Tasbih (Month)'**
  String get tasbihThisMonth;

  /// No description provided for @pagesThisMonth.
  ///
  /// In en, this message translates to:
  /// **'Pages (Month)'**
  String get pagesThisMonth;

  /// No description provided for @khatmasThisMonth.
  ///
  /// In en, this message translates to:
  /// **'Khatmas (Month)'**
  String get khatmasThisMonth;

  /// No description provided for @keepItUp.
  ///
  /// In en, this message translates to:
  /// **'Keep it up'**
  String get keepItUp;

  /// No description provided for @hadithKeepUp.
  ///
  /// In en, this message translates to:
  /// **'The Prophet ﷺ said: The most beloved of deeds to Allah are those that are most consistent, even if they are few.'**
  String get hadithKeepUp;

  /// No description provided for @startNewKhatma.
  ///
  /// In en, this message translates to:
  /// **'Start New Khatma'**
  String get startNewKhatma;

  /// No description provided for @noActiveKhatma.
  ///
  /// In en, this message translates to:
  /// **'No active Khatma'**
  String get noActiveKhatma;

  /// No description provided for @current.
  ///
  /// In en, this message translates to:
  /// **'Current'**
  String get current;

  /// No description provided for @remaining.
  ///
  /// In en, this message translates to:
  /// **'Remaining'**
  String get remaining;

  /// No description provided for @dailyGoal.
  ///
  /// In en, this message translates to:
  /// **'Daily Goal'**
  String get dailyGoal;

  /// No description provided for @completed.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get completed;

  /// No description provided for @tafseerAndTranslation.
  ///
  /// In en, this message translates to:
  /// **'Tafseer & Translation'**
  String get tafseerAndTranslation;

  /// No description provided for @tafseerNotDownloaded.
  ///
  /// In en, this message translates to:
  /// **'Tafseer not downloaded'**
  String get tafseerNotDownloaded;

  /// No description provided for @downloadTafseerNow.
  ///
  /// In en, this message translates to:
  /// **'Download Tafseer Now'**
  String get downloadTafseerNow;

  /// No description provided for @changeReciter.
  ///
  /// In en, this message translates to:
  /// **'Change Reciter'**
  String get changeReciter;

  /// No description provided for @copyText.
  ///
  /// In en, this message translates to:
  /// **'Copy Text'**
  String get copyText;

  /// No description provided for @share.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// No description provided for @saveBookmark.
  ///
  /// In en, this message translates to:
  /// **'Save Bookmark'**
  String get saveBookmark;

  /// No description provided for @removeBookmark.
  ///
  /// In en, this message translates to:
  /// **'Remove Bookmark'**
  String get removeBookmark;

  /// No description provided for @qiblaTitle.
  ///
  /// In en, this message translates to:
  /// **'Qibla'**
  String get qiblaTitle;

  /// No description provided for @compass.
  ///
  /// In en, this message translates to:
  /// **'Compass'**
  String get compass;

  /// No description provided for @map.
  ///
  /// In en, this message translates to:
  /// **'Map'**
  String get map;

  /// No description provided for @calibrateCompass.
  ///
  /// In en, this message translates to:
  /// **'Move your phone in a figure 8 to calibrate the compass.'**
  String get calibrateCompass;

  /// No description provided for @faceQibla.
  ///
  /// In en, this message translates to:
  /// **'You are facing the Qibla'**
  String get faceQibla;

  /// No description provided for @qiblaInstruction.
  ///
  /// In en, this message translates to:
  /// **'Rotate your phone until the arrow aligns with the Kaaba'**
  String get qiblaInstruction;

  /// No description provided for @compassError.
  ///
  /// In en, this message translates to:
  /// **'Compass Error: {error}'**
  String compassError(Object error);

  /// No description provided for @deviceNoCompass.
  ///
  /// In en, this message translates to:
  /// **'This device does not support compass'**
  String get deviceNoCompass;

  /// No description provided for @hijriCalendar.
  ///
  /// In en, this message translates to:
  /// **'Hijri Calendar'**
  String get hijriCalendar;

  /// No description provided for @ramadanEvent.
  ///
  /// In en, this message translates to:
  /// **'Ramadan'**
  String get ramadanEvent;

  /// No description provided for @eidFitrEvent.
  ///
  /// In en, this message translates to:
  /// **'Eid Al-Fitr'**
  String get eidFitrEvent;

  /// No description provided for @eidAdhaEvent.
  ///
  /// In en, this message translates to:
  /// **'Eid Al-Adha'**
  String get eidAdhaEvent;

  /// No description provided for @ihsanTitle.
  ///
  /// In en, this message translates to:
  /// **'Ihsan'**
  String get ihsanTitle;

  /// No description provided for @weeklyProgress.
  ///
  /// In en, this message translates to:
  /// **'Weekly Progress'**
  String get weeklyProgress;

  /// No description provided for @fivePrayers.
  ///
  /// In en, this message translates to:
  /// **'Five Prayers'**
  String get fivePrayers;

  /// No description provided for @sunnahPrayers.
  ///
  /// In en, this message translates to:
  /// **'Sunnah Prayers'**
  String get sunnahPrayers;

  /// No description provided for @sunnahDuha.
  ///
  /// In en, this message translates to:
  /// **'Duha Prayer'**
  String get sunnahDuha;

  /// No description provided for @sunnahQiyam.
  ///
  /// In en, this message translates to:
  /// **'Qiyam (Night Prayer)'**
  String get sunnahQiyam;

  /// No description provided for @witr.
  ///
  /// In en, this message translates to:
  /// **'Witr'**
  String get witr;

  /// No description provided for @quranReading.
  ///
  /// In en, this message translates to:
  /// **'Quran Reading'**
  String get quranReading;

  /// No description provided for @athkarMorning.
  ///
  /// In en, this message translates to:
  /// **'Morning Athkar'**
  String get athkarMorning;

  /// No description provided for @athkarEvening.
  ///
  /// In en, this message translates to:
  /// **'Evening Athkar'**
  String get athkarEvening;

  /// No description provided for @hadithBooks.
  ///
  /// In en, this message translates to:
  /// **'The Nine Books'**
  String get hadithBooks;

  /// No description provided for @noHadithFound.
  ///
  /// In en, this message translates to:
  /// **'No Hadiths found in this chapter'**
  String get noHadithFound;

  /// No description provided for @hadithCopied.
  ///
  /// In en, this message translates to:
  /// **'Hadith copied to clipboard'**
  String get hadithCopied;

  /// No description provided for @narrated.
  ///
  /// In en, this message translates to:
  /// **'Narrated'**
  String get narrated;

  /// No description provided for @listen.
  ///
  /// In en, this message translates to:
  /// **'Listen'**
  String get listen;

  /// No description provided for @stop.
  ///
  /// In en, this message translates to:
  /// **'Stop'**
  String get stop;

  /// No description provided for @downloading.
  ///
  /// In en, this message translates to:
  /// **'Downloading...'**
  String get downloading;

  /// No description provided for @surahName.
  ///
  /// In en, this message translates to:
  /// **'Surah {name}'**
  String surahName(Object name);

  /// No description provided for @ayahNumber.
  ///
  /// In en, this message translates to:
  /// **'Ayah {number}'**
  String ayahNumber(Object number);

  /// No description provided for @errorPlayingAudio.
  ///
  /// In en, this message translates to:
  /// **'Error playing audio: {error}'**
  String errorPlayingAudio(Object error);

  /// No description provided for @copyAyahSuccess.
  ///
  /// In en, this message translates to:
  /// **'Ayah copied to clipboard'**
  String get copyAyahSuccess;

  /// No description provided for @newKhatma.
  ///
  /// In en, this message translates to:
  /// **'New Khatma'**
  String get newKhatma;

  /// No description provided for @khatmaNameHint.
  ///
  /// In en, this message translates to:
  /// **'Khatma Name (e.g. Ramadan Khatma)'**
  String get khatmaNameHint;

  /// No description provided for @byDate.
  ///
  /// In en, this message translates to:
  /// **'By Date'**
  String get byDate;

  /// No description provided for @byAmount.
  ///
  /// In en, this message translates to:
  /// **'By Daily Amount'**
  String get byAmount;

  /// No description provided for @selectEndDate.
  ///
  /// In en, this message translates to:
  /// **'Select End Date'**
  String get selectEndDate;

  /// No description provided for @dailyPagesGoal.
  ///
  /// In en, this message translates to:
  /// **'Daily Goal: {count} pages'**
  String dailyPagesGoal(Object count);

  /// No description provided for @dailyPages.
  ///
  /// In en, this message translates to:
  /// **'Daily Pages:'**
  String get dailyPages;

  /// No description provided for @dailyReminder.
  ///
  /// In en, this message translates to:
  /// **'Daily Reminder'**
  String get dailyReminder;

  /// No description provided for @reminderTime.
  ///
  /// In en, this message translates to:
  /// **'Reminder Time'**
  String get reminderTime;

  /// No description provided for @startKhatma.
  ///
  /// In en, this message translates to:
  /// **'Start Khatma'**
  String get startKhatma;

  /// No description provided for @pleaseSelectDate.
  ///
  /// In en, this message translates to:
  /// **'Please select a date'**
  String get pleaseSelectDate;

  /// No description provided for @required.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get required;

  /// No description provided for @khatmaReminderTitle.
  ///
  /// In en, this message translates to:
  /// **'Reading Time 📖'**
  String get khatmaReminderTitle;

  /// No description provided for @khatmaReminderBody.
  ///
  /// In en, this message translates to:
  /// **'Don\'t forget your daily wirth from {name}'**
  String khatmaReminderBody(Object name);

  /// No description provided for @enableReminders.
  ///
  /// In en, this message translates to:
  /// **'Enable Reminders'**
  String get enableReminders;

  /// No description provided for @morningAthkarTime.
  ///
  /// In en, this message translates to:
  /// **'Morning Athkar Time'**
  String get morningAthkarTime;

  /// No description provided for @eveningAthkarTime.
  ///
  /// In en, this message translates to:
  /// **'Evening Athkar Time'**
  String get eveningAthkarTime;

  /// No description provided for @sleepAthkarTime.
  ///
  /// In en, this message translates to:
  /// **'Sleep Athkar Time'**
  String get sleepAthkarTime;

  /// No description provided for @wakeUpAthkarTime.
  ///
  /// In en, this message translates to:
  /// **'Wake Up Athkar Time'**
  String get wakeUpAthkarTime;

  /// No description provided for @audioReminder.
  ///
  /// In en, this message translates to:
  /// **'Audio Reminder'**
  String get audioReminder;

  /// No description provided for @notificationSound.
  ///
  /// In en, this message translates to:
  /// **'Notification Sound'**
  String get notificationSound;

  /// No description provided for @prophetReminder.
  ///
  /// In en, this message translates to:
  /// **'Prophet Reminder'**
  String get prophetReminder;

  /// No description provided for @prePrayerReminder.
  ///
  /// In en, this message translates to:
  /// **'Pre-Prayer Reminder'**
  String get prePrayerReminder;

  /// No description provided for @reminderInterval.
  ///
  /// In en, this message translates to:
  /// **'Reminder Interval (Minutes)'**
  String get reminderInterval;

  /// No description provided for @minutesBeforePrayer.
  ///
  /// In en, this message translates to:
  /// **'Minutes Before Prayer'**
  String get minutesBeforePrayer;

  /// No description provided for @pickTime.
  ///
  /// In en, this message translates to:
  /// **'Pick Time'**
  String get pickTime;

  /// No description provided for @remindersSettings.
  ///
  /// In en, this message translates to:
  /// **'Reminders Settings'**
  String get remindersSettings;

  /// No description provided for @everyXMinutes.
  ///
  /// In en, this message translates to:
  /// **'Every {minutes} minutes'**
  String everyXMinutes(Object minutes);

  /// No description provided for @everyHour.
  ///
  /// In en, this message translates to:
  /// **'Every hour'**
  String get everyHour;

  /// No description provided for @everyTwoHours.
  ///
  /// In en, this message translates to:
  /// **'Every 2 hours'**
  String get everyTwoHours;

  /// No description provided for @beforeXMinutes.
  ///
  /// In en, this message translates to:
  /// **'Before {minutes} minutes'**
  String beforeXMinutes(Object minutes);

  /// No description provided for @prePrayerSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Alert before Adhan by a specific time'**
  String get prePrayerSubtitle;

  /// No description provided for @selectReciter.
  ///
  /// In en, this message translates to:
  /// **'Select Reciter'**
  String get selectReciter;

  /// No description provided for @shortTone.
  ///
  /// In en, this message translates to:
  /// **'Short Tone'**
  String get shortTone;

  /// No description provided for @adhanSettingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Adhan & Muezzins'**
  String get adhanSettingsTitle;

  /// No description provided for @downloadAdhanTitle.
  ///
  /// In en, this message translates to:
  /// **'Download Adhan Sounds'**
  String get downloadAdhanTitle;

  /// No description provided for @downloadAdhanBody.
  ///
  /// In en, this message translates to:
  /// **'A distinctive collection of Muezzin sounds (20 MB)\nPlease ensure internet connection'**
  String get downloadAdhanBody;

  /// No description provided for @preparingDownload.
  ///
  /// In en, this message translates to:
  /// **'Preparing...'**
  String get preparingDownload;

  /// No description provided for @startDownload.
  ///
  /// In en, this message translates to:
  /// **'Start Download'**
  String get startDownload;

  /// No description provided for @fileNotFound.
  ///
  /// In en, this message translates to:
  /// **'File not found: {name}'**
  String fileNotFound(Object name);

  /// No description provided for @audioError.
  ///
  /// In en, this message translates to:
  /// **'Error playing audio: {error}'**
  String audioError(Object error);

  /// No description provided for @khatmaTitle.
  ///
  /// In en, this message translates to:
  /// **'Khatma'**
  String get khatmaTitle;

  /// No description provided for @khatmaProgress.
  ///
  /// In en, this message translates to:
  /// **'Progress'**
  String get khatmaProgress;

  /// No description provided for @currentPage.
  ///
  /// In en, this message translates to:
  /// **'Current Page'**
  String get currentPage;

  /// No description provided for @remainingPages.
  ///
  /// In en, this message translates to:
  /// **'Remaining'**
  String get remainingPages;

  /// No description provided for @dailyGoalLabel.
  ///
  /// In en, this message translates to:
  /// **'Daily Goal'**
  String get dailyGoalLabel;

  /// No description provided for @khatmaInstructions.
  ///
  /// In en, this message translates to:
  /// **'Read from the Quran and your progress will update automatically.'**
  String get khatmaInstructions;

  /// No description provided for @remindersTitle.
  ///
  /// In en, this message translates to:
  /// **'Reminders'**
  String get remindersTitle;

  /// No description provided for @morningAthkarTitle.
  ///
  /// In en, this message translates to:
  /// **'Morning Athkar'**
  String get morningAthkarTitle;

  /// No description provided for @morningAthkarBody.
  ///
  /// In en, this message translates to:
  /// **'Time for Morning Athkar'**
  String get morningAthkarBody;

  /// No description provided for @morningAthkarSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Daily reminder for Morning Athkar'**
  String get morningAthkarSubtitle;

  /// No description provided for @eveningAthkarTitle.
  ///
  /// In en, this message translates to:
  /// **'Evening Athkar'**
  String get eveningAthkarTitle;

  /// No description provided for @eveningAthkarBody.
  ///
  /// In en, this message translates to:
  /// **'Time for Evening Athkar'**
  String get eveningAthkarBody;

  /// No description provided for @eveningAthkarSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Daily reminder for Evening Athkar'**
  String get eveningAthkarSubtitle;

  /// No description provided for @periodicRemindersTitle.
  ///
  /// In en, this message translates to:
  /// **'Periodic Reminders'**
  String get periodicRemindersTitle;

  /// No description provided for @thikrAllahTitle.
  ///
  /// In en, this message translates to:
  /// **'Thikr Allah'**
  String get thikrAllahTitle;

  /// No description provided for @thikrAllahBody.
  ///
  /// In en, this message translates to:
  /// **'Subhan Allah, Walhamdulillah, Wala ilaha illallah, Wallahu Akbar'**
  String get thikrAllahBody;

  /// No description provided for @thikrAllahSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Short reminder every specific interval'**
  String get thikrAllahSubtitle;

  /// No description provided for @sunnahPrayersTitle.
  ///
  /// In en, this message translates to:
  /// **'Sunnah Prayers'**
  String get sunnahPrayersTitle;

  /// No description provided for @duhaPrayerTitle.
  ///
  /// In en, this message translates to:
  /// **'Duha Prayer'**
  String get duhaPrayerTitle;

  /// No description provided for @duhaPrayerBody.
  ///
  /// In en, this message translates to:
  /// **'Reminder: Time for Duha Prayer'**
  String get duhaPrayerBody;

  /// No description provided for @duhaPrayerSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Reminder before Dhuhr by an hour (10:00 AM)'**
  String get duhaPrayerSubtitle;

  /// No description provided for @qiyamPrayerTitle.
  ///
  /// In en, this message translates to:
  /// **'Qiyam Al-Layl'**
  String get qiyamPrayerTitle;

  /// No description provided for @qiyamPrayerBody.
  ///
  /// In en, this message translates to:
  /// **'Reminder: The last third of the night, time for answering prayers'**
  String get qiyamPrayerBody;

  /// No description provided for @qiyamPrayerSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Reminder in the last third of the night (3:00 AM)'**
  String get qiyamPrayerSubtitle;

  /// No description provided for @witrPrayerTitle.
  ///
  /// In en, this message translates to:
  /// **'Witr Prayer'**
  String get witrPrayerTitle;

  /// No description provided for @witrPrayerBody.
  ///
  /// In en, this message translates to:
  /// **'Reminder: Do not forget Witr prayer before sleeping'**
  String get witrPrayerBody;

  /// No description provided for @witrPrayerSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Reminder after Isha prayer (10:00 PM)'**
  String get witrPrayerSubtitle;

  /// No description provided for @batteryWarning.
  ///
  /// In en, this message translates to:
  /// **'Warning: Notifications may stop due to battery optimization'**
  String get batteryWarning;

  /// No description provided for @fixBatteryIssue.
  ///
  /// In en, this message translates to:
  /// **'Fix Issue'**
  String get fixBatteryIssue;

  /// No description provided for @prayerAlertsTitle.
  ///
  /// In en, this message translates to:
  /// **'Prayer Alerts'**
  String get prayerAlertsTitle;

  /// No description provided for @prophetReminderTitle.
  ///
  /// In en, this message translates to:
  /// **'Prophet Reminder'**
  String get prophetReminderTitle;

  /// No description provided for @prophetReminderSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Periodic reminder to pray upon the Prophet ﷺ'**
  String get prophetReminderSubtitle;

  /// No description provided for @every5Minutes.
  ///
  /// In en, this message translates to:
  /// **'Every 5 minutes'**
  String get every5Minutes;

  /// No description provided for @every10Minutes.
  ///
  /// In en, this message translates to:
  /// **'Every 10 minutes'**
  String get every10Minutes;

  /// No description provided for @every15Minutes.
  ///
  /// In en, this message translates to:
  /// **'Every 15 minutes'**
  String get every15Minutes;

  /// No description provided for @every30Minutes.
  ///
  /// In en, this message translates to:
  /// **'Every 30 minutes'**
  String get every30Minutes;

  /// No description provided for @morningAthkarScheduled.
  ///
  /// In en, this message translates to:
  /// **'Morning Athkar scheduled'**
  String get morningAthkarScheduled;

  /// No description provided for @eveningAthkarScheduled.
  ///
  /// In en, this message translates to:
  /// **'Evening Athkar scheduled'**
  String get eveningAthkarScheduled;

  /// No description provided for @periodicReminderScheduled.
  ///
  /// In en, this message translates to:
  /// **'Reminder enabled every {minutes} minutes'**
  String periodicReminderScheduled(Object minutes);

  /// No description provided for @reminderError.
  ///
  /// In en, this message translates to:
  /// **'Error enabling reminder: {error}'**
  String reminderError(Object error);

  /// No description provided for @repetition.
  ///
  /// In en, this message translates to:
  /// **'Repetition'**
  String get repetition;

  /// No description provided for @downloadQuranTitle.
  ///
  /// In en, this message translates to:
  /// **'Download Quran Fonts'**
  String get downloadQuranTitle;

  /// No description provided for @downloadQuranBody.
  ///
  /// In en, this message translates to:
  /// **'To display the Quran pages correctly, we need to download the font files (80 MB).'**
  String get downloadQuranBody;

  /// No description provided for @download.
  ///
  /// In en, this message translates to:
  /// **'Download'**
  String get download;

  /// No description provided for @quranFonts.
  ///
  /// In en, this message translates to:
  /// **'Quran Fonts'**
  String get quranFonts;

  /// No description provided for @deleteQuranFonts.
  ///
  /// In en, this message translates to:
  /// **'Delete Quran Fonts?'**
  String get deleteQuranFonts;

  /// No description provided for @deleteQuranFontsConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete the Quran fonts? You will need to download them again to read the Quran.'**
  String get deleteQuranFontsConfirmation;

  /// No description provided for @filesNotDownloaded.
  ///
  /// In en, this message translates to:
  /// **'Files are not downloaded'**
  String get filesNotDownloaded;

  /// No description provided for @fontsDeleted.
  ///
  /// In en, this message translates to:
  /// **'Fonts deleted successfully'**
  String get fontsDeleted;

  /// No description provided for @troubleshootNotifications.
  ///
  /// In en, this message translates to:
  /// **'Troubleshoot Notifications'**
  String get troubleshootNotifications;

  /// No description provided for @troubleshootNotificationsDesc.
  ///
  /// In en, this message translates to:
  /// **'Tap here if notifications are delayed or missing'**
  String get troubleshootNotificationsDesc;

  /// No description provided for @checkPermissions.
  ///
  /// In en, this message translates to:
  /// **'Check Permissions'**
  String get checkPermissions;

  /// No description provided for @exactAlarmPermission.
  ///
  /// In en, this message translates to:
  /// **'Exact Alarm Permission'**
  String get exactAlarmPermission;

  /// No description provided for @batteryOptimizationPermission.
  ///
  /// In en, this message translates to:
  /// **'Battery Optimization (Should be OFF)'**
  String get batteryOptimizationPermission;

  /// No description provided for @permissionGranted.
  ///
  /// In en, this message translates to:
  /// **'✅ Granted'**
  String get permissionGranted;

  /// No description provided for @permissionDenied.
  ///
  /// In en, this message translates to:
  /// **'❌ Denied'**
  String get permissionDenied;

  /// No description provided for @allow.
  ///
  /// In en, this message translates to:
  /// **'Grant'**
  String get allow;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
