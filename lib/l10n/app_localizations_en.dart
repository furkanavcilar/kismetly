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
  String get dreamSave => 'Save interpretation';

  @override
  String get dreamSaved => 'Dream saved to history.';

  @override
  String get dreamAlreadySaved => 'This interpretation is already saved.';

  @override
  String get dreamHistoryTitle => 'Saved interpretations';

  @override
  String get dreamHistoryEmpty => 'You haven\'t saved any interpretations yet.';

  @override
  String get dreamDelete => 'Delete';

  @override
  String get dreamDeleteConfirmation => 'Remove this saved interpretation?';

  @override
  String get dreamDeleteSuccess => 'Entry removed.';

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
  String get menuDreamsSubtitle => 'Let\'s explore the emotional message behind your dream';

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
  String get menuZodiacSubtitle => 'Zodiac encyclopedia';

  @override
  String get menuTarotSubtitle => 'Secrets of the cards';

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

  @override
  String get actionRetry => 'Retry';

  @override
  String get homeTitle => 'Cosmic Dashboard';

  @override
  String get homeDailyZodiac => 'Today\'s Chart';

  @override
  String homeSunRising(Object rising, Object sun) {
    return 'Sun $sun • Rising $rising';
  }

  @override
  String get homeInsightError => 'Insights could not load.';

  @override
  String get homeEnergyFocusTitle => 'Main energy focus';

  @override
  String get homeEnergyLove => 'Love';

  @override
  String get homeEnergyCareer => 'Career';

  @override
  String get homeEnergySpiritual => 'Spiritual';

  @override
  String get homeEnergySocial => 'Social';

  @override
  String get homeInsightEmpty => 'Insights will appear soon.';

  @override
  String get homeCosmicGuideTitle => 'Today\'s cosmic guide';

  @override
  String get homeWeatherErrorTitle => 'Weather unavailable';

  @override
  String get compatibilityErrorTitle => 'Connection unavailable right now';

  @override
  String get compatibilityEmpty => 'No insight yet — try again soon.';

  @override
  String get onboardingGreeting => 'Welcome to Kismetly';

  @override
  String get onboardingIntro => 'Your cosmic companion is ready to write daily guidance just for you.';

  @override
  String get onboardingSignGoogle => 'Sign in with Google';

  @override
  String get onboardingContinueGuest => 'Continue as guest';

  @override
  String get onboardingDetailsTitle => 'Tell us about you';

  @override
  String get onboardingWelcome => 'Hoş geldin 🌟 Let\'s attune to your energy.';

  @override
  String get onboardingName => 'Name';

  @override
  String get onboardingNameError => 'Please share your name.';

  @override
  String get onboardingBirthDate => 'Birth date';

  @override
  String get onboardingBirthTime => 'Birth time';

  @override
  String get onboardingBirthCity => 'Birth city';

  @override
  String get onboardingGenderOptional => 'Gender (optional)';

  @override
  String get onboardingMissingDate => 'Select your birth date and time.';

  @override
  String get onboardingCityError => 'We couldn\'t find that city. Try again.';

  @override
  String get onboardingFinish => 'Begin my journey';

  @override
  String get premiumTitle => 'Kismetly Pro';

  @override
  String get premiumSubtitle => 'Unlimited cosmic guidance';

  @override
  String get premiumMonthly => 'Monthly';

  @override
  String get premiumAnnual => 'Annual';

  @override
  String get premiumPriceMonthly => '\$\$7.99/month';

  @override
  String get premiumPriceAnnual => '\$\$49.99/year';

  @override
  String get premiumFeatureUnlimited => 'Unlimited AI Astrologer Questions';

  @override
  String get premiumFeatureReports => 'Monthly & Annual Personalized Reports';

  @override
  String get premiumFeatureCompatibility => 'Premium Compatibility Deep Dive';

  @override
  String get premiumFeatureAdFree => 'Ad-free Experience';

  @override
  String get premiumUpgrade => 'Upgrade to Pro';

  @override
  String get premiumRestore => 'Restore Purchases';

  @override
  String get premiumCurrent => 'Pro Member';

  @override
  String premiumExpires(Object date) {
    return 'Your Pro membership expires on $date';
  }

  @override
  String get creditsTitle => 'Credit Store';

  @override
  String creditsBalance(Object credits) {
    return 'Balance: $credits credits';
  }

  @override
  String get creditsPack20 => '20 Credits';

  @override
  String get creditsPack50 => '50 Credits';

  @override
  String get creditsPack100 => '100 Credits';

  @override
  String get creditsPrice20 => '\$\$4.99';

  @override
  String get creditsPrice50 => '\$\$9.99';

  @override
  String get creditsPrice100 => '\$\$17.99';

  @override
  String get creditsInsufficient => 'Insufficient Credits';

  @override
  String creditsNeeded(Object amount) {
    return 'This feature requires $amount credits.';
  }

  @override
  String get creditsBuy => 'Buy Credits';

  @override
  String get creditsUpgrade => 'Upgrade to Pro';

  @override
  String get lockPremium => 'This feature is for Pro members';

  @override
  String lockCredits(Object amount) {
    return 'This feature requires $amount credits';
  }

  @override
  String get lockUnlock => 'Unlock';

  @override
  String get lockUpgrade => 'Upgrade';

  @override
  String get paywallTitle => 'Premium Features';

  @override
  String get paywallSubtitle => 'Deepen your cosmic journey';

  @override
  String get paywallFeature1 => 'Unlimited personal guidance access';

  @override
  String get paywallFeature2 => 'Detailed compatibility reports';

  @override
  String get paywallFeature3 => 'Monthly and annual personal charts';

  @override
  String get paywallFeature4 => 'Ad-free experience';

  @override
  String get paywallTrial => '7-day free trial';

  @override
  String get paywallTerms => 'By continuing, you agree to Terms of Use and Privacy Policy.';

  @override
  String get creditCostDream => 'Dream interpretation: 3 credits';

  @override
  String get creditCostCoffee => 'Coffee reading: 5 credits';

  @override
  String get creditCostChat => 'Personal guidance question: 5 credits';

  @override
  String get creditCostChart => 'Guest chart: 10 credits';

  @override
  String get purchaseSuccess => 'Purchase successful!';

  @override
  String get purchaseError => 'Purchase failed. Please try again.';

  @override
  String get purchaseRestoreSuccess => 'Purchases restored.';

  @override
  String get purchaseRestoreError => 'No purchases found to restore.';

  @override
  String get menuProfile => 'Profile';

  @override
  String get menuProfileSubtitle => 'Your personal information';

  @override
  String get settingsTheme => 'Theme';

  @override
  String get settingsThemeLight => 'Light';

  @override
  String get settingsThemeDark => 'Dark';

  @override
  String get settingsThemeSystem => 'System';

  @override
  String get settingsThemeSaved => 'Theme saved';

  @override
  String get settingsNotifications => 'Notifications';

  @override
  String get settingsNotificationsDailyHoroscope => 'Daily Horoscope';

  @override
  String get settingsNotificationsDailyHoroscopeDesc => 'Receive daily horoscope notifications';

  @override
  String get settingsNotificationsNightly => 'Nightly Motivation';

  @override
  String get settingsNotificationsNightlyDesc => 'Receive nightly motivation messages';

  @override
  String get settingsData => 'Data';

  @override
  String get settingsClearCache => 'Clear Cache';

  @override
  String get settingsClearCacheDesc => 'Clear saved readings cache';

  @override
  String get settingsCacheCleared => 'Cache cleared';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsLanguageTurkish => 'Turkish';

  @override
  String get settingsLanguageEnglish => 'English';

  @override
  String get settingsLanguageChanged => 'Language changed. Please restart the app.';

  @override
  String get settingsPurchases => 'Purchases';

  @override
  String get settingsRestorePurchases => 'Restore Purchases';

  @override
  String get settingsRestorePurchasesDesc => 'Restore your previous purchases';

  @override
  String get errorConnectionDesc => 'Please check your internet connection';
}
