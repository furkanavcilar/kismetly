// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Kismetly';

  @override
  String get menuHome => 'Home';

  @override
  String get menuDreams => 'Dream Interpreter';

  @override
  String get menuHoroscopes => 'Horoscopes';

  @override
  String get menuPalmistry => 'Palm Reading';

  @override
  String get menuCompatibility => 'Zodiac Compatibility';

  @override
  String get menuCoffee => 'Coffee Reading';

  @override
  String get menuSettings => 'Settings';

  @override
  String get menuLanguage => 'Language';

  @override
  String get languageTurkish => 'Turkish';

  @override
  String get languageEnglish => 'English';

  @override
  String get homeDailyTitle => 'Today\'s Astrological Insights';

  @override
  String get homeSetSun => 'Select your sun sign';

  @override
  String get homeSetRising => 'Select your rising sign';

  @override
  String homeSunInsight(Object message, Object sign) {
    return 'Today\'s energy for $sign: $message';
  }

  @override
  String homeRisingInsight(Object message, Object sign) {
    return 'Your rising sign $sign: $message';
  }

  @override
  String get homePickSign => 'Choose a sign';

  @override
  String get homeOpenCompatibility => 'See compatibility';

  @override
  String get homeTrending => 'Trending Features';

  @override
  String get homeDailyEnergy => 'Daily Energy';

  @override
  String get homeDailyQuote => 'Quote of the Day';

  @override
  String get homeDailyCardTitle => 'Sun & Rising';

  @override
  String get homeNoSelection => 'Select your signs to unlock personalized insights.';

  @override
  String get homeShortcutDream => 'Interpret Dream';

  @override
  String get homeShortcutCoffee => 'Coffee Reading';

  @override
  String get homeShortcutCompatibility => 'Compatibility';

  @override
  String get homeLoveMatch => 'Love Match';

  @override
  String get homeFriendMatch => 'Friendship Match';

  @override
  String get homeWorkMatch => 'Work Match';

  @override
  String get homeSelectPrompt => 'Choose a sign';

  @override
  String get homeQuoteError => 'Quote unavailable.';

  @override
  String get homeQuoteEmpty => 'No quote found for today.';

  @override
  String get homeEnergyFocusLove => 'Love';

  @override
  String get homeEnergyFocusCareer => 'Career';

  @override
  String get homeEnergyFocusSpirit => 'Spirit';

  @override
  String get homeEnergyFocusSocial => 'Social';

  @override
  String get homeInteractionsTitle => 'Today\'s Interactions';

  @override
  String homeInteractionsDescription(Object first, Object score, Object second, Object tone) {
    return 'Energy between $first and $second feels $tone ($score%).';
  }

  @override
  String get homeInteractionsHint => 'Tap to open the full compatibility view.';

  @override
  String homeHoroscopeTitle(Object sign) {
    return 'Guide for $sign';
  }

  @override
  String get homeHoroscopeTabsDaily => 'Daily';

  @override
  String get homeHoroscopeTabsMonthly => 'Monthly';

  @override
  String get homeHoroscopeTabsYearly => 'Yearly';

  @override
  String get homeHoroscopeEmpty => 'Horoscope guidance is not ready yet.';

  @override
  String get homeHoroscopeError => 'Horoscope could not be loaded.';

  @override
  String get dreamTitle => 'Dream Interpreter';

  @override
  String get dreamHint => 'Describe your dream...';

  @override
  String get dreamSubmit => 'Interpret my dream';

  @override
  String get dreamLoading => 'We are reading your dream...';

  @override
  String get dreamError => 'Something went wrong. Please try again.';

  @override
  String get dreamEmpty => 'Write a dream to interpret.';

  @override
  String get coffeeTitle => 'Coffee Reading';

  @override
  String get coffeeHint => 'Upload photos of your cup and saucer';

  @override
  String get coffeeAddPhotos => 'Add photo';

  @override
  String get coffeeSubmit => 'Read my fortune';

  @override
  String get coffeeLoading => 'Preparing your reading...';

  @override
  String get coffeeResultGeneral => 'General';

  @override
  String get coffeeResultLove => 'Love';

  @override
  String get coffeeResultCareer => 'Career';

  @override
  String get coffeeResultWarnings => 'Warnings';

  @override
  String get coffeeEmpty => 'Add at least one photo.';

  @override
  String get coffeeLimit => 'You can upload up to three photos.';

  @override
  String get coffeeHistory => 'Recent readings';

  @override
  String get coffeePrivacy => 'Images are used only for interpretation and stay on your device.';

  @override
  String get compatibilityTitle => 'Zodiac Compatibility';

  @override
  String get compatibilityLove => 'Love';

  @override
  String get compatibilityFamily => 'Family';

  @override
  String get compatibilityCareer => 'Career';

  @override
  String get compatibilityScore => 'Score';

  @override
  String get compatibilityAdvice => 'Advice';

  @override
  String get compatibilitySummary => 'Summary';

  @override
  String compatibilityLoveTemplate(Object first, Object second, Object tone) {
    return 'Love energy between $first and $second feels $tone.';
  }

  @override
  String compatibilityFamilyTemplate(Object tone) {
    return 'Family dynamics offer a $tone connection.';
  }

  @override
  String compatibilityCareerTemplate(Object tone) {
    return 'Work partnerships flow in a $tone rhythm.';
  }

  @override
  String compatibilityAdviceTemplate(Object advice, Object first, Object second) {
    return 'Tip for $first and $second today: $advice.';
  }

  @override
  String get toneHigh => 'vibrant';

  @override
  String get toneBalanced => 'balanced';

  @override
  String get toneFlux => 'in flux';

  @override
  String get toneTransform => 'transforming';

  @override
  String get adviceHigh => 'Celebrate the harmony and plan a shared ritual.';

  @override
  String get adviceBalanced => 'Stay curious about each other to keep balance.';

  @override
  String get adviceFlux => 'Give space for differences and listen deeply.';

  @override
  String get adviceTransform => 'Transform tension with honest yet gentle conversations.';

  @override
  String get commentsTitle => 'Comments';

  @override
  String get commentsEmpty => 'Be the first to comment!';

  @override
  String get commentsLogin => 'Sign in to comment.';

  @override
  String get commentsHint => 'Share your thoughts';

  @override
  String get commentsSubmit => 'Post';

  @override
  String get commentsProfanity => 'Please keep it respectful.';

  @override
  String get commentsTooLong => 'Your comment is too long.';

  @override
  String get commentsFailure => 'Could not save your comment. Try again.';

  @override
  String get commentsSuccess => 'Comment posted!';

  @override
  String get commentsLocalUser => 'You';

  @override
  String horoscopeDetailTitle(Object sign) {
    return '$sign Sign';
  }

  @override
  String get horoscopeDetailToday => 'Today\'s Themes';

  @override
  String get horoscopeDetailOpenComments => 'View comments';

  @override
  String get loading => 'Loading...';

  @override
  String get error => 'An error occurred.';

  @override
  String get menuLanguagePrompt => 'Choose language';

  @override
  String get menuDreamsSubtitle => 'AI-powered insights';

  @override
  String get menuHomeSubtitle => 'Personal astro feed';

  @override
  String get menuHoroscopesSubtitle => 'Daily guidance';

  @override
  String get menuPalmistrySubtitle => 'Secrets in your palm';

  @override
  String get menuCompatibilitySubtitle => 'Love, family, work';

  @override
  String get menuCoffeeSubtitle => 'Fortune from photos';

  @override
  String get menuSettingsSubtitle => 'App preferences';

  @override
  String get coffeeSaved => 'Reading saved';

  @override
  String get coffeeHistoryEmpty => 'No saved readings yet.';

  @override
  String get insightSunDefault => 'Trust your intuition to balance today\'s energy.';

  @override
  String get insightRisingDefault => 'Strengthen connections around you.';

  @override
  String get pickerSun => 'Sun Sign';

  @override
  String get pickerRising => 'Rising Sign';

  @override
  String get dateToday => 'Today';

  @override
  String horoscopeCommentsTitle(Object date, Object sign) {
    return '$sign comments - $date';
  }

  @override
  String get languageSwitchSaved => 'Language preference saved.';
}
