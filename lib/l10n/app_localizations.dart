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
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

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
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
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
  String homeInteractionsDescription(Object first, Object score, Object second, Object tone);

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

  /// No description provided for @dreamSave.
  ///
  /// In en, this message translates to:
  /// **'Save interpretation'**
  String get dreamSave;

  /// No description provided for @dreamSaved.
  ///
  /// In en, this message translates to:
  /// **'Dream saved to history.'**
  String get dreamSaved;

  /// No description provided for @dreamAlreadySaved.
  ///
  /// In en, this message translates to:
  /// **'This interpretation is already saved.'**
  String get dreamAlreadySaved;

  /// No description provided for @dreamHistoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Saved interpretations'**
  String get dreamHistoryTitle;

  /// No description provided for @dreamHistoryEmpty.
  ///
  /// In en, this message translates to:
  /// **'You haven\'t saved any interpretations yet.'**
  String get dreamHistoryEmpty;

  /// No description provided for @dreamDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get dreamDelete;

  /// No description provided for @dreamDeleteConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Remove this saved interpretation?'**
  String get dreamDeleteConfirmation;

  /// No description provided for @dreamDeleteSuccess.
  ///
  /// In en, this message translates to:
  /// **'Entry removed.'**
  String get dreamDeleteSuccess;

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
  String compatibilityAdviceTemplate(Object advice, Object first, Object second);

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
  /// **'Let\'s explore the emotional message behind your dream'**
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

  /// No description provided for @menuZodiacSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Zodiac encyclopedia'**
  String get menuZodiacSubtitle;

  /// No description provided for @menuTarotSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Secrets of the cards'**
  String get menuTarotSubtitle;

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

  /// No description provided for @actionRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get actionRetry;

  /// No description provided for @homeTitle.
  ///
  /// In en, this message translates to:
  /// **'Cosmic Dashboard'**
  String get homeTitle;

  /// No description provided for @homeDailyZodiac.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Chart'**
  String get homeDailyZodiac;

  /// No description provided for @homeSunRising.
  ///
  /// In en, this message translates to:
  /// **'Sun {sun} • Rising {rising}'**
  String homeSunRising(Object rising, Object sun);

  /// No description provided for @homeInsightError.
  ///
  /// In en, this message translates to:
  /// **'Insights could not load.'**
  String get homeInsightError;

  /// No description provided for @homeEnergyFocusTitle.
  ///
  /// In en, this message translates to:
  /// **'Main energy focus'**
  String get homeEnergyFocusTitle;

  /// No description provided for @homeEnergyLove.
  ///
  /// In en, this message translates to:
  /// **'Love'**
  String get homeEnergyLove;

  /// No description provided for @homeEnergyCareer.
  ///
  /// In en, this message translates to:
  /// **'Career'**
  String get homeEnergyCareer;

  /// No description provided for @homeEnergySpiritual.
  ///
  /// In en, this message translates to:
  /// **'Spiritual'**
  String get homeEnergySpiritual;

  /// No description provided for @homeEnergySocial.
  ///
  /// In en, this message translates to:
  /// **'Social'**
  String get homeEnergySocial;

  /// No description provided for @homeInsightEmpty.
  ///
  /// In en, this message translates to:
  /// **'Insights will appear soon.'**
  String get homeInsightEmpty;

  /// No description provided for @homeCosmicGuideTitle.
  ///
  /// In en, this message translates to:
  /// **'Today\'s cosmic guide'**
  String get homeCosmicGuideTitle;

  /// No description provided for @homeWeatherErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Weather unavailable'**
  String get homeWeatherErrorTitle;

  /// No description provided for @compatibilityErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Connection unavailable right now'**
  String get compatibilityErrorTitle;

  /// No description provided for @compatibilityEmpty.
  ///
  /// In en, this message translates to:
  /// **'No insight yet — try again soon.'**
  String get compatibilityEmpty;

  /// No description provided for @onboardingGreeting.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Kismetly'**
  String get onboardingGreeting;

  /// No description provided for @onboardingIntro.
  ///
  /// In en, this message translates to:
  /// **'Your cosmic companion is ready to write daily guidance just for you.'**
  String get onboardingIntro;

  /// No description provided for @onboardingSignGoogle.
  ///
  /// In en, this message translates to:
  /// **'Sign in with Google'**
  String get onboardingSignGoogle;

  /// No description provided for @onboardingContinueGuest.
  ///
  /// In en, this message translates to:
  /// **'Continue as guest'**
  String get onboardingContinueGuest;

  /// No description provided for @onboardingDetailsTitle.
  ///
  /// In en, this message translates to:
  /// **'Tell us about you'**
  String get onboardingDetailsTitle;

  /// No description provided for @onboardingWelcome.
  ///
  /// In en, this message translates to:
  /// **'Hoş geldin 🌟 Let\'s attune to your energy.'**
  String get onboardingWelcome;

  /// No description provided for @onboardingName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get onboardingName;

  /// No description provided for @onboardingNameError.
  ///
  /// In en, this message translates to:
  /// **'Please share your name.'**
  String get onboardingNameError;

  /// No description provided for @onboardingBirthDate.
  ///
  /// In en, this message translates to:
  /// **'Birth date'**
  String get onboardingBirthDate;

  /// No description provided for @onboardingBirthTime.
  ///
  /// In en, this message translates to:
  /// **'Birth time'**
  String get onboardingBirthTime;

  /// No description provided for @onboardingBirthCity.
  ///
  /// In en, this message translates to:
  /// **'Birth city'**
  String get onboardingBirthCity;

  /// No description provided for @onboardingGenderOptional.
  ///
  /// In en, this message translates to:
  /// **'Gender (optional)'**
  String get onboardingGenderOptional;

  /// No description provided for @onboardingMissingDate.
  ///
  /// In en, this message translates to:
  /// **'Select your birth date and time.'**
  String get onboardingMissingDate;

  /// No description provided for @onboardingCityError.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t find that city. Try again.'**
  String get onboardingCityError;

  /// No description provided for @onboardingFinish.
  ///
  /// In en, this message translates to:
  /// **'Begin my journey'**
  String get onboardingFinish;

  /// No description provided for @premiumTitle.
  ///
  /// In en, this message translates to:
  /// **'Kismetly Pro'**
  String get premiumTitle;

  /// No description provided for @premiumSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Unlimited cosmic guidance'**
  String get premiumSubtitle;

  /// No description provided for @premiumMonthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get premiumMonthly;

  /// No description provided for @premiumAnnual.
  ///
  /// In en, this message translates to:
  /// **'Annual'**
  String get premiumAnnual;

  /// No description provided for @premiumPriceMonthly.
  ///
  /// In en, this message translates to:
  /// **'\$\$7.99/month'**
  String get premiumPriceMonthly;

  /// No description provided for @premiumPriceAnnual.
  ///
  /// In en, this message translates to:
  /// **'\$\$49.99/year'**
  String get premiumPriceAnnual;

  /// No description provided for @premiumFeatureUnlimited.
  ///
  /// In en, this message translates to:
  /// **'Unlimited AI Astrologer Questions'**
  String get premiumFeatureUnlimited;

  /// No description provided for @premiumFeatureReports.
  ///
  /// In en, this message translates to:
  /// **'Monthly & Annual Personalized Reports'**
  String get premiumFeatureReports;

  /// No description provided for @premiumFeatureCompatibility.
  ///
  /// In en, this message translates to:
  /// **'Premium Compatibility Deep Dive'**
  String get premiumFeatureCompatibility;

  /// No description provided for @premiumFeatureAdFree.
  ///
  /// In en, this message translates to:
  /// **'Ad-free Experience'**
  String get premiumFeatureAdFree;

  /// No description provided for @premiumUpgrade.
  ///
  /// In en, this message translates to:
  /// **'Upgrade to Pro'**
  String get premiumUpgrade;

  /// No description provided for @premiumRestore.
  ///
  /// In en, this message translates to:
  /// **'Restore Purchases'**
  String get premiumRestore;

  /// No description provided for @premiumCurrent.
  ///
  /// In en, this message translates to:
  /// **'Pro Member'**
  String get premiumCurrent;

  /// No description provided for @premiumExpires.
  ///
  /// In en, this message translates to:
  /// **'Your Pro membership expires on {date}'**
  String premiumExpires(Object date);

  /// No description provided for @creditsTitle.
  ///
  /// In en, this message translates to:
  /// **'Credit Store'**
  String get creditsTitle;

  /// No description provided for @creditsBalance.
  ///
  /// In en, this message translates to:
  /// **'Balance: {credits} credits'**
  String creditsBalance(Object credits);

  /// No description provided for @creditsPack20.
  ///
  /// In en, this message translates to:
  /// **'20 Credits'**
  String get creditsPack20;

  /// No description provided for @creditsPack50.
  ///
  /// In en, this message translates to:
  /// **'50 Credits'**
  String get creditsPack50;

  /// No description provided for @creditsPack100.
  ///
  /// In en, this message translates to:
  /// **'100 Credits'**
  String get creditsPack100;

  /// No description provided for @creditsPrice20.
  ///
  /// In en, this message translates to:
  /// **'\$\$4.99'**
  String get creditsPrice20;

  /// No description provided for @creditsPrice50.
  ///
  /// In en, this message translates to:
  /// **'\$\$9.99'**
  String get creditsPrice50;

  /// No description provided for @creditsPrice100.
  ///
  /// In en, this message translates to:
  /// **'\$\$17.99'**
  String get creditsPrice100;

  /// No description provided for @creditsInsufficient.
  ///
  /// In en, this message translates to:
  /// **'Insufficient Credits'**
  String get creditsInsufficient;

  /// No description provided for @creditsNeeded.
  ///
  /// In en, this message translates to:
  /// **'This feature requires {amount} credits.'**
  String creditsNeeded(Object amount);

  /// No description provided for @creditsBuy.
  ///
  /// In en, this message translates to:
  /// **'Buy Credits'**
  String get creditsBuy;

  /// No description provided for @creditsUpgrade.
  ///
  /// In en, this message translates to:
  /// **'Upgrade to Pro'**
  String get creditsUpgrade;

  /// No description provided for @lockPremium.
  ///
  /// In en, this message translates to:
  /// **'This feature is for Pro members'**
  String get lockPremium;

  /// No description provided for @lockCredits.
  ///
  /// In en, this message translates to:
  /// **'This feature requires {amount} credits'**
  String lockCredits(Object amount);

  /// No description provided for @lockUnlock.
  ///
  /// In en, this message translates to:
  /// **'Unlock'**
  String get lockUnlock;

  /// No description provided for @lockUpgrade.
  ///
  /// In en, this message translates to:
  /// **'Upgrade'**
  String get lockUpgrade;

  /// No description provided for @paywallTitle.
  ///
  /// In en, this message translates to:
  /// **'Premium Features'**
  String get paywallTitle;

  /// No description provided for @paywallSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Deepen your cosmic journey'**
  String get paywallSubtitle;

  /// No description provided for @paywallFeature1.
  ///
  /// In en, this message translates to:
  /// **'Unlimited personal guidance access'**
  String get paywallFeature1;

  /// No description provided for @paywallFeature2.
  ///
  /// In en, this message translates to:
  /// **'Detailed compatibility reports'**
  String get paywallFeature2;

  /// No description provided for @paywallFeature3.
  ///
  /// In en, this message translates to:
  /// **'Monthly and annual personal charts'**
  String get paywallFeature3;

  /// No description provided for @paywallFeature4.
  ///
  /// In en, this message translates to:
  /// **'Ad-free experience'**
  String get paywallFeature4;

  /// No description provided for @paywallTrial.
  ///
  /// In en, this message translates to:
  /// **'7-day free trial'**
  String get paywallTrial;

  /// No description provided for @paywallTerms.
  ///
  /// In en, this message translates to:
  /// **'By continuing, you agree to Terms of Use and Privacy Policy.'**
  String get paywallTerms;

  /// No description provided for @creditCostDream.
  ///
  /// In en, this message translates to:
  /// **'Dream interpretation: 3 credits'**
  String get creditCostDream;

  /// No description provided for @creditCostCoffee.
  ///
  /// In en, this message translates to:
  /// **'Coffee reading: 5 credits'**
  String get creditCostCoffee;

  /// No description provided for @creditCostChat.
  ///
  /// In en, this message translates to:
  /// **'Personal guidance question: 5 credits'**
  String get creditCostChat;

  /// No description provided for @creditCostChart.
  ///
  /// In en, this message translates to:
  /// **'Guest chart: 10 credits'**
  String get creditCostChart;

  /// No description provided for @purchaseSuccess.
  ///
  /// In en, this message translates to:
  /// **'Purchase successful!'**
  String get purchaseSuccess;

  /// No description provided for @purchaseError.
  ///
  /// In en, this message translates to:
  /// **'Purchase failed. Please try again.'**
  String get purchaseError;

  /// No description provided for @purchaseRestoreSuccess.
  ///
  /// In en, this message translates to:
  /// **'Purchases restored.'**
  String get purchaseRestoreSuccess;

  /// No description provided for @purchaseRestoreError.
  ///
  /// In en, this message translates to:
  /// **'No purchases found to restore.'**
  String get purchaseRestoreError;

  /// No description provided for @menuProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get menuProfile;

  /// No description provided for @menuProfileSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your personal information'**
  String get menuProfileSubtitle;

  /// No description provided for @settingsTheme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get settingsTheme;

  /// No description provided for @settingsThemeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get settingsThemeLight;

  /// No description provided for @settingsThemeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get settingsThemeDark;

  /// No description provided for @settingsThemeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get settingsThemeSystem;

  /// No description provided for @settingsThemeSaved.
  ///
  /// In en, this message translates to:
  /// **'Theme saved'**
  String get settingsThemeSaved;

  /// No description provided for @settingsNotifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get settingsNotifications;

  /// No description provided for @settingsNotificationsDailyHoroscope.
  ///
  /// In en, this message translates to:
  /// **'Daily Horoscope'**
  String get settingsNotificationsDailyHoroscope;

  /// No description provided for @settingsNotificationsDailyHoroscopeDesc.
  ///
  /// In en, this message translates to:
  /// **'Receive daily horoscope notifications'**
  String get settingsNotificationsDailyHoroscopeDesc;

  /// No description provided for @settingsNotificationsNightly.
  ///
  /// In en, this message translates to:
  /// **'Nightly Motivation'**
  String get settingsNotificationsNightly;

  /// No description provided for @settingsNotificationsNightlyDesc.
  ///
  /// In en, this message translates to:
  /// **'Receive nightly motivation messages'**
  String get settingsNotificationsNightlyDesc;

  /// No description provided for @settingsData.
  ///
  /// In en, this message translates to:
  /// **'Data'**
  String get settingsData;

  /// No description provided for @settingsClearCache.
  ///
  /// In en, this message translates to:
  /// **'Clear Cache'**
  String get settingsClearCache;

  /// No description provided for @settingsClearCacheDesc.
  ///
  /// In en, this message translates to:
  /// **'Clear saved readings cache'**
  String get settingsClearCacheDesc;

  /// No description provided for @settingsCacheCleared.
  ///
  /// In en, this message translates to:
  /// **'Cache cleared'**
  String get settingsCacheCleared;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'tr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
    case 'tr': return AppLocalizationsTr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
