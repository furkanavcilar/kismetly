import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_tr.dart';

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
    Locale('en'),
    Locale('tr')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Kismetly'**
  String get appTitle;

  /// No description provided for @menuHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get menuHome;

  /// No description provided for @menuDreams.
  ///
  /// In en, this message translates to:
  /// **'Dream Interpreter'**
  String get menuDreams;

  /// No description provided for @menuHoroscopes.
  ///
  /// In en, this message translates to:
  /// **'Horoscopes'**
  String get menuHoroscopes;

  /// No description provided for @menuPalmistry.
  ///
  /// In en, this message translates to:
  /// **'Palm Reading'**
  String get menuPalmistry;

  /// No description provided for @menuCompatibility.
  ///
  /// In en, this message translates to:
  /// **'Zodiac Compatibility'**
  String get menuCompatibility;

  /// No description provided for @menuCoffee.
  ///
  /// In en, this message translates to:
  /// **'Coffee Reading'**
  String get menuCoffee;

  /// No description provided for @menuSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get menuSettings;

  /// No description provided for @menuLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get menuLanguage;

  /// No description provided for @languageTurkish.
  ///
  /// In en, this message translates to:
  /// **'Turkish'**
  String get languageTurkish;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @homeDailyTitle.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Astrological Insights'**
  String get homeDailyTitle;

  /// No description provided for @homeSetSun.
  ///
  /// In en, this message translates to:
  /// **'Select your sun sign'**
  String get homeSetSun;

  /// No description provided for @homeSetRising.
  ///
  /// In en, this message translates to:
  /// **'Select your rising sign'**
  String get homeSetRising;

  /// No description provided for @homeSunInsight.
  ///
  /// In en, this message translates to:
  /// **'Today\'s energy for {sign}: {message}'**
  String homeSunInsight(Object message, Object sign);

  /// No description provided for @homeRisingInsight.
  ///
  /// In en, this message translates to:
  /// **'Your rising sign {sign}: {message}'**
  String homeRisingInsight(Object message, Object sign);

  /// No description provided for @homePickSign.
  ///
  /// In en, this message translates to:
  /// **'Choose a sign'**
  String get homePickSign;

  /// No description provided for @homeOpenCompatibility.
  ///
  /// In en, this message translates to:
  /// **'See compatibility'**
  String get homeOpenCompatibility;

  /// No description provided for @homeTrending.
  ///
  /// In en, this message translates to:
  /// **'Trending Features'**
  String get homeTrending;

  /// No description provided for @homeDailyEnergy.
  ///
  /// In en, this message translates to:
  /// **'Daily Energy'**
  String get homeDailyEnergy;

  /// No description provided for @homeDailyQuote.
  ///
  /// In en, this message translates to:
  /// **'Quote of the Day'**
  String get homeDailyQuote;

  /// No description provided for @homeDailyCardTitle.
  ///
  /// In en, this message translates to:
  /// **'Sun & Rising'**
  String get homeDailyCardTitle;

  /// No description provided for @homeNoSelection.
  ///
  /// In en, this message translates to:
  /// **'Select your signs to unlock personalized insights.'**
  String get homeNoSelection;

  /// No description provided for @homeShortcutDream.
  ///
  /// In en, this message translates to:
  /// **'Interpret Dream'**
  String get homeShortcutDream;

  /// No description provided for @homeShortcutCoffee.
  ///
  /// In en, this message translates to:
  /// **'Coffee Reading'**
  String get homeShortcutCoffee;

  /// No description provided for @homeShortcutCompatibility.
  ///
  /// In en, this message translates to:
  /// **'Compatibility'**
  String get homeShortcutCompatibility;

  /// No description provided for @homeLoveMatch.
  ///
  /// In en, this message translates to:
  /// **'Love Match'**
  String get homeLoveMatch;

  /// No description provided for @homeFriendMatch.
  ///
  /// In en, this message translates to:
  /// **'Friendship Match'**
  String get homeFriendMatch;

  /// No description provided for @homeWorkMatch.
  ///
  /// In en, this message translates to:
  /// **'Work Match'**
  String get homeWorkMatch;

  /// No description provided for @homeSelectPrompt.
  ///
  /// In en, this message translates to:
  /// **'Choose a sign'**
  String get homeSelectPrompt;

  /// No description provided for @homeQuoteError.
  ///
  /// In en, this message translates to:
  /// **'Quote unavailable.'**
  String get homeQuoteError;

  /// No description provided for @homeQuoteEmpty.
  ///
  /// In en, this message translates to:
  /// **'No quote found for today.'**
  String get homeQuoteEmpty;

  /// No description provided for @homeEnergyFocusLove.
  ///
  /// In en, this message translates to:
  /// **'Love'**
  String get homeEnergyFocusLove;

  /// No description provided for @homeEnergyFocusCareer.
  ///
  /// In en, this message translates to:
  /// **'Career'**
  String get homeEnergyFocusCareer;

  /// No description provided for @homeEnergyFocusSpirit.
  ///
  /// In en, this message translates to:
  /// **'Spirit'**
  String get homeEnergyFocusSpirit;

  /// No description provided for @homeEnergyFocusSocial.
  ///
  /// In en, this message translates to:
  /// **'Social'**
  String get homeEnergyFocusSocial;

  /// No description provided for @homeInteractionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Interactions'**
  String get homeInteractionsTitle;

  /// No description provided for @homeInteractionsDescription.
  ///
  /// In en, this message translates to:
  /// **'Energy between {first} and {second} feels {tone} ({score}%).'**
  String homeInteractionsDescription(
      Object first, Object score, Object second, Object tone);

  /// No description provided for @homeInteractionsHint.
  ///
  /// In en, this message translates to:
  /// **'Tap to open the full compatibility view.'**
  String get homeInteractionsHint;

  /// No description provided for @homeHoroscopeTitle.
  ///
  /// In en, this message translates to:
  /// **'Guide for {sign}'**
  String homeHoroscopeTitle(Object sign);

  /// No description provided for @homeHoroscopeTabsDaily.
  ///
  /// In en, this message translates to:
  /// **'Daily'**
  String get homeHoroscopeTabsDaily;

  /// No description provided for @homeHoroscopeTabsMonthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get homeHoroscopeTabsMonthly;

  /// No description provided for @homeHoroscopeTabsYearly.
  ///
  /// In en, this message translates to:
  /// **'Yearly'**
  String get homeHoroscopeTabsYearly;

  /// No description provided for @homeHoroscopeEmpty.
  ///
  /// In en, this message translates to:
  /// **'Horoscope guidance is not ready yet.'**
  String get homeHoroscopeEmpty;

  /// No description provided for @homeHoroscopeError.
  ///
  /// In en, this message translates to:
  /// **'Horoscope could not be loaded.'**
  String get homeHoroscopeError;

  /// No description provided for @dreamTitle.
  ///
  /// In en, this message translates to:
  /// **'Dream Interpreter'**
  String get dreamTitle;

  /// No description provided for @dreamHint.
  ///
  /// In en, this message translates to:
  /// **'Describe your dream...'**
  String get dreamHint;

  /// No description provided for @dreamSubmit.
  ///
  /// In en, this message translates to:
  /// **'Interpret my dream'**
  String get dreamSubmit;

  /// No description provided for @dreamLoading.
  ///
  /// In en, this message translates to:
  /// **'We are reading your dream...'**
  String get dreamLoading;

  /// No description provided for @dreamError.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get dreamError;

  /// No description provided for @dreamEmpty.
  ///
  /// In en, this message translates to:
  /// **'Write a dream to interpret.'**
  String get dreamEmpty;

  /// No description provided for @coffeeTitle.
  ///
  /// In en, this message translates to:
  /// **'Coffee Reading'**
  String get coffeeTitle;

  /// No description provided for @coffeeHint.
  ///
  /// In en, this message translates to:
  /// **'Upload photos of your cup and saucer'**
  String get coffeeHint;

  /// No description provided for @coffeeAddPhotos.
  ///
  /// In en, this message translates to:
  /// **'Add photo'**
  String get coffeeAddPhotos;

  /// No description provided for @coffeeSubmit.
  ///
  /// In en, this message translates to:
  /// **'Read my fortune'**
  String get coffeeSubmit;

  /// No description provided for @coffeeLoading.
  ///
  /// In en, this message translates to:
  /// **'Preparing your reading...'**
  String get coffeeLoading;

  /// No description provided for @coffeeResultGeneral.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get coffeeResultGeneral;

  /// No description provided for @coffeeResultLove.
  ///
  /// In en, this message translates to:
  /// **'Love'**
  String get coffeeResultLove;

  /// No description provided for @coffeeResultCareer.
  ///
  /// In en, this message translates to:
  /// **'Career'**
  String get coffeeResultCareer;

  /// No description provided for @coffeeResultWarnings.
  ///
  /// In en, this message translates to:
  /// **'Warnings'**
  String get coffeeResultWarnings;

  /// No description provided for @coffeeEmpty.
  ///
  /// In en, this message translates to:
  /// **'Add at least one photo.'**
  String get coffeeEmpty;

  /// No description provided for @coffeeLimit.
  ///
  /// In en, this message translates to:
  /// **'You can upload up to three photos.'**
  String get coffeeLimit;

  /// No description provided for @coffeeHistory.
  ///
  /// In en, this message translates to:
  /// **'Recent readings'**
  String get coffeeHistory;

  /// No description provided for @coffeePrivacy.
  ///
  /// In en, this message translates to:
  /// **'Images are used only for interpretation and stay on your device.'**
  String get coffeePrivacy;

  /// No description provided for @compatibilityTitle.
  ///
  /// In en, this message translates to:
  /// **'Zodiac Compatibility'**
  String get compatibilityTitle;

  /// No description provided for @compatibilityLove.
  ///
  /// In en, this message translates to:
  /// **'Love'**
  String get compatibilityLove;

  /// No description provided for @compatibilityFamily.
  ///
  /// In en, this message translates to:
  /// **'Family'**
  String get compatibilityFamily;

  /// No description provided for @compatibilityCareer.
  ///
  /// In en, this message translates to:
  /// **'Career'**
  String get compatibilityCareer;

  /// No description provided for @compatibilityScore.
  ///
  /// In en, this message translates to:
  /// **'Score'**
  String get compatibilityScore;

  /// No description provided for @compatibilityAdvice.
  ///
  /// In en, this message translates to:
  /// **'Advice'**
  String get compatibilityAdvice;

  /// No description provided for @compatibilitySummary.
  ///
  /// In en, this message translates to:
  /// **'Summary'**
  String get compatibilitySummary;

  /// No description provided for @compatibilityLoveTemplate.
  ///
  /// In en, this message translates to:
  /// **'Love energy between {first} and {second} feels {tone}.'**
  String compatibilityLoveTemplate(Object first, Object second, Object tone);

  /// No description provided for @compatibilityFamilyTemplate.
  ///
  /// In en, this message translates to:
  /// **'Family dynamics offer a {tone} connection.'**
  String compatibilityFamilyTemplate(Object tone);

  /// No description provided for @compatibilityCareerTemplate.
  ///
  /// In en, this message translates to:
  /// **'Work partnerships flow in a {tone} rhythm.'**
  String compatibilityCareerTemplate(Object tone);

  /// No description provided for @compatibilityAdviceTemplate.
  ///
  /// In en, this message translates to:
  /// **'Tip for {first} and {second} today: {advice}.'**
  String compatibilityAdviceTemplate(
      Object advice, Object first, Object second);

  /// No description provided for @toneHigh.
  ///
  /// In en, this message translates to:
  /// **'vibrant'**
  String get toneHigh;

  /// No description provided for @toneBalanced.
  ///
  /// In en, this message translates to:
  /// **'balanced'**
  String get toneBalanced;

  /// No description provided for @toneFlux.
  ///
  /// In en, this message translates to:
  /// **'in flux'**
  String get toneFlux;

  /// No description provided for @toneTransform.
  ///
  /// In en, this message translates to:
  /// **'transforming'**
  String get toneTransform;

  /// No description provided for @adviceHigh.
  ///
  /// In en, this message translates to:
  /// **'Celebrate the harmony and plan a shared ritual.'**
  String get adviceHigh;

  /// No description provided for @adviceBalanced.
  ///
  /// In en, this message translates to:
  /// **'Stay curious about each other to keep balance.'**
  String get adviceBalanced;

  /// No description provided for @adviceFlux.
  ///
  /// In en, this message translates to:
  /// **'Give space for differences and listen deeply.'**
  String get adviceFlux;

  /// No description provided for @adviceTransform.
  ///
  /// In en, this message translates to:
  /// **'Transform tension with honest yet gentle conversations.'**
  String get adviceTransform;

  /// No description provided for @commentsTitle.
  ///
  /// In en, this message translates to:
  /// **'Comments'**
  String get commentsTitle;

  /// No description provided for @commentsEmpty.
  ///
  /// In en, this message translates to:
  /// **'Be the first to comment!'**
  String get commentsEmpty;

  /// No description provided for @commentsLogin.
  ///
  /// In en, this message translates to:
  /// **'Sign in to comment.'**
  String get commentsLogin;

  /// No description provided for @commentsHint.
  ///
  /// In en, this message translates to:
  /// **'Share your thoughts'**
  String get commentsHint;

  /// No description provided for @commentsSubmit.
  ///
  /// In en, this message translates to:
  /// **'Post'**
  String get commentsSubmit;

  /// No description provided for @commentsProfanity.
  ///
  /// In en, this message translates to:
  /// **'Please keep it respectful.'**
  String get commentsProfanity;

  /// No description provided for @commentsTooLong.
  ///
  /// In en, this message translates to:
  /// **'Your comment is too long.'**
  String get commentsTooLong;

  /// No description provided for @commentsFailure.
  ///
  /// In en, this message translates to:
  /// **'Could not save your comment. Try again.'**
  String get commentsFailure;

  /// No description provided for @commentsSuccess.
  ///
  /// In en, this message translates to:
  /// **'Comment posted!'**
  String get commentsSuccess;

  /// No description provided for @commentsLocalUser.
  ///
  /// In en, this message translates to:
  /// **'You'**
  String get commentsLocalUser;

  /// No description provided for @horoscopeDetailTitle.
  ///
  /// In en, this message translates to:
  /// **'{sign} Sign'**
  String horoscopeDetailTitle(Object sign);

  /// No description provided for @horoscopeDetailToday.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Themes'**
  String get horoscopeDetailToday;

  /// No description provided for @horoscopeDetailOpenComments.
  ///
  /// In en, this message translates to:
  /// **'View comments'**
  String get horoscopeDetailOpenComments;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'An error occurred.'**
  String get error;

  /// No description provided for @menuLanguagePrompt.
  ///
  /// In en, this message translates to:
  /// **'Choose language'**
  String get menuLanguagePrompt;

  /// No description provided for @menuDreamsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'AI-powered insights'**
  String get menuDreamsSubtitle;

  /// No description provided for @menuHomeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Personal astro feed'**
  String get menuHomeSubtitle;

  /// No description provided for @menuHoroscopesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Daily guidance'**
  String get menuHoroscopesSubtitle;

  /// No description provided for @menuPalmistrySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Secrets in your palm'**
  String get menuPalmistrySubtitle;

  /// No description provided for @menuCompatibilitySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Love, family, work'**
  String get menuCompatibilitySubtitle;

  /// No description provided for @menuCoffeeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Fortune from photos'**
  String get menuCoffeeSubtitle;

  /// No description provided for @menuSettingsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'App preferences'**
  String get menuSettingsSubtitle;

  /// No description provided for @coffeeSaved.
  ///
  /// In en, this message translates to:
  /// **'Reading saved'**
  String get coffeeSaved;

  /// No description provided for @coffeeHistoryEmpty.
  ///
  /// In en, this message translates to:
  /// **'No saved readings yet.'**
  String get coffeeHistoryEmpty;

  /// No description provided for @insightSunDefault.
  ///
  /// In en, this message translates to:
  /// **'Trust your intuition to balance today\'s energy.'**
  String get insightSunDefault;

  /// No description provided for @insightRisingDefault.
  ///
  /// In en, this message translates to:
  /// **'Strengthen connections around you.'**
  String get insightRisingDefault;

  /// No description provided for @pickerSun.
  ///
  /// In en, this message translates to:
  /// **'Sun Sign'**
  String get pickerSun;

  /// No description provided for @pickerRising.
  ///
  /// In en, this message translates to:
  /// **'Rising Sign'**
  String get pickerRising;

  /// No description provided for @dateToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get dateToday;

  /// No description provided for @horoscopeCommentsTitle.
  ///
  /// In en, this message translates to:
  /// **'{sign} comments - {date}'**
  String horoscopeCommentsTitle(Object date, Object sign);

  /// No description provided for @languageSwitchSaved.
  ///
  /// In en, this message translates to:
  /// **'Language preference saved.'**
  String get languageSwitchSaved;
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
      <String>['en', 'tr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'tr':
      return AppLocalizationsTr();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
