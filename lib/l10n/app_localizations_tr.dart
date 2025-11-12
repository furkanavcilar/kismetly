// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AppLocalizationsTr extends AppLocalizations {
  AppLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String get appTitle => 'Kismetly';

  @override
  String get menuHome => 'Ana Sayfa';

  @override
  String get menuDreams => 'Rüya Yorumla';

  @override
  String get menuHoroscopes => 'Burç Yorumları';

  @override
  String get menuPalmistry => 'El Falı';

  @override
  String get menuCompatibility => 'Zodyak Uyumu';

  @override
  String get menuCoffee => 'Kahve Falı';

  @override
  String get menuSettings => 'Ayarlar';

  @override
  String get menuLanguage => 'Dil';

  @override
  String get languageTurkish => 'Türkçe';

  @override
  String get languageEnglish => 'English';

  @override
  String get homeDailyTitle => 'Bugünün Astrolojik İçgörüleri';

  @override
  String get homeSetSun => 'Güneş burcunuzu seçin';

  @override
  String get homeSetRising => 'Yükselen burcunuzu seçin';

  @override
  String homeSunInsight(Object message, Object sign) {
    return '$sign burcunun bugünkü enerjisi: $message';
  }

  @override
  String homeRisingInsight(Object message, Object sign) {
    return 'Yükseleniniz $sign: $message';
  }

  @override
  String get homePickSign => 'Burç seçin';

  @override
  String get homeOpenCompatibility => 'Uyumluluklara bak';

  @override
  String get homeTrending => 'Trend Özellikler';

  @override
  String get homeDailyEnergy => 'Günlük Enerji';

  @override
  String get homeDailyQuote => 'Günün Sözü';

  @override
  String get homeDailyCardTitle => 'Güneş & Yükselen';

  @override
  String get homeNoSelection => 'Burçlarınızı seçerek kişiselleştirilmiş içgörülere ulaşın.';

  @override
  String get homeShortcutDream => 'Rüya Yorumla';

  @override
  String get homeShortcutCoffee => 'Kahve Falı';

  @override
  String get homeShortcutCompatibility => 'Uyum Analizi';

  @override
  String get homeLoveMatch => 'Aşk Uyumu';

  @override
  String get homeFriendMatch => 'Arkadaşlık Uyumu';

  @override
  String get homeWorkMatch => 'İş Uyumu';

  @override
  String get homeSelectPrompt => 'Burç seçin';

  @override
  String get homeQuoteError => 'Söz alınamadı.';

  @override
  String get homeQuoteEmpty => 'Bugüne ait söz bulunamadı.';

  @override
  String get homeEnergyFocusLove => 'Aşk';

  @override
  String get homeEnergyFocusCareer => 'Kariyer';

  @override
  String get homeEnergyFocusSpirit => 'Ruhsal';

  @override
  String get homeEnergyFocusSocial => 'Sosyal';

  @override
  String get homeInteractionsTitle => 'Bugünün Etkileşimleri';

  @override
  String homeInteractionsDescription(Object first, Object score, Object second, Object tone) {
    return '$first ve $second arasında enerji $tone seviyesinde (%$score).';
  }

  @override
  String get homeInteractionsHint => 'Detaylı uyumu görmek için dokunun.';

  @override
  String homeHoroscopeTitle(Object sign) {
    return '$sign için rehber';
  }

  @override
  String get homeHoroscopeTabsDaily => 'Günlük';

  @override
  String get homeHoroscopeTabsMonthly => 'Aylık';

  @override
  String get homeHoroscopeTabsYearly => 'Yıllık';

  @override
  String get homeHoroscopeEmpty => 'Burç yorumu henüz hazır değil.';

  @override
  String get homeHoroscopeError => 'Burç yorumu alınamadı.';

  @override
  String get dreamTitle => 'Rüya Yorumlama';

  @override
  String get dreamHint => 'Rüyanızı yazın...';

  @override
  String get dreamSubmit => 'Rüyamı yorumla';

  @override
  String get dreamLoading => 'Rüyanız yorumlanıyor...';

  @override
  String get dreamError => 'Yorumlanırken bir sorun oluştu. Lütfen tekrar deneyin.';

  @override
  String get dreamEmpty => 'Paylaşılacak bir rüya yazın.';

  @override
  String get coffeeTitle => 'Kahve Falı';

  @override
  String get coffeeHint => 'Kahve fincanı ve tabağınızın fotoğraflarını yükleyin';

  @override
  String get coffeeAddPhotos => 'Fotoğraf ekle';

  @override
  String get coffeeSubmit => 'Falımı yorumla';

  @override
  String get coffeeLoading => 'Fal yorumunuz hazırlanıyor...';

  @override
  String get coffeeResultGeneral => 'Genel';

  @override
  String get coffeeResultLove => 'Aşk';

  @override
  String get coffeeResultCareer => 'İş';

  @override
  String get coffeeResultWarnings => 'Uyarılar';

  @override
  String get coffeeEmpty => 'En az bir fotoğraf ekleyin.';

  @override
  String get coffeeLimit => 'En fazla üç fotoğraf yükleyebilirsiniz.';

  @override
  String get coffeeHistory => 'Son fal kayıtlarınız';

  @override
  String get coffeePrivacy => 'Fotoğraflar sadece yorum için kullanılır ve cihazınızda saklanır.';

  @override
  String get compatibilityTitle => 'Zodyak Uyumu';

  @override
  String get compatibilityLove => 'Aşk';

  @override
  String get compatibilityFamily => 'Aile';

  @override
  String get compatibilityCareer => 'İş';

  @override
  String get compatibilityScore => 'Skor';

  @override
  String get compatibilityAdvice => 'Öneri';

  @override
  String get compatibilitySummary => 'Özet';

  @override
  String compatibilityLoveTemplate(Object first, Object second, Object tone) {
    return '$first ve $second arasında aşk enerjisi $tone.';
  }

  @override
  String compatibilityFamilyTemplate(Object tone) {
    return 'Aile dinamikleri $tone bir bağ sunuyor.';
  }

  @override
  String compatibilityCareerTemplate(Object tone) {
    return 'İş birlikleri $tone şekilde ilerliyor.';
  }

  @override
  String compatibilityAdviceTemplate(Object advice, Object first, Object second) {
    return 'Bugün $first ve $second için öneri: $advice.';
  }

  @override
  String get toneHigh => 'yüksek';

  @override
  String get toneBalanced => 'uyumlu';

  @override
  String get toneFlux => 'denge arayan';

  @override
  String get toneTransform => 'dönüşen';

  @override
  String get adviceHigh => 'Uyumu kutlayın ve ortak bir ritüel planlayın.';

  @override
  String get adviceBalanced => 'Dengede kalmak için birbirinizi merak edin.';

  @override
  String get adviceFlux => 'Farklılıklara alan açıp dikkatle dinleyin.';

  @override
  String get adviceTransform => 'Samimi ama yumuşak sohbetlerle dönüşümü başlatın.';

  @override
  String get commentsTitle => 'Yorumlar';

  @override
  String get commentsEmpty => 'İlk yorumu siz yazın!';

  @override
  String get commentsLogin => 'Yorum yapmak için giriş yapın.';

  @override
  String get commentsHint => 'Düşüncelerinizi paylaşın';

  @override
  String get commentsSubmit => 'Gönder';

  @override
  String get commentsProfanity => 'Lütfen saygılı bir dil kullanın.';

  @override
  String get commentsTooLong => 'Yorumunuz çok uzun.';

  @override
  String get commentsFailure => 'Yorum kaydedilemedi. Lütfen tekrar deneyin.';

  @override
  String get commentsSuccess => 'Yorumunuz paylaşıldı!';

  @override
  String get commentsLocalUser => 'Siz';

  @override
  String horoscopeDetailTitle(Object sign) {
    return '$sign Burcu';
  }

  @override
  String get horoscopeDetailToday => 'Bugünün Temaları';

  @override
  String get horoscopeDetailOpenComments => 'Yorumları gör';

  @override
  String get loading => 'Yükleniyor...';

  @override
  String get error => 'Bir hata oluştu.';

  @override
  String get menuLanguagePrompt => 'Dil seçin';

  @override
  String get menuDreamsSubtitle => 'Yapay zekâ destekli içgörüler';

  @override
  String get menuHomeSubtitle => 'Kişisel astrolojik akış';

  @override
  String get menuHoroscopesSubtitle => 'Günlük rehber';

  @override
  String get menuPalmistrySubtitle => 'Avuç içi sırları';

  @override
  String get menuCompatibilitySubtitle => 'Aşk, aile, iş';

  @override
  String get menuCoffeeSubtitle => 'Fotoğraflardan fal';

  @override
  String get menuSettingsSubtitle => 'Uygulama tercihleri';

  @override
  String get coffeeSaved => 'Fal kaydedildi';

  @override
  String get coffeeHistoryEmpty => 'Henüz kayıtlı falınız yok.';

  @override
  String get insightSunDefault => 'Bugün enerjinizi dengelemek için sezgilerinize güvenin.';

  @override
  String get insightRisingDefault => 'Çevrenizle kurduğunuz bağları güçlendirin.';

  @override
  String get pickerSun => 'Güneş Burcu';

  @override
  String get pickerRising => 'Yükselen Burcu';

  @override
  String get dateToday => 'Bugün';

  @override
  String horoscopeCommentsTitle(Object date, Object sign) {
    return '$sign yorumları - $date';
  }

  @override
  String get languageSwitchSaved => 'Dil tercihi kaydedildi.';
}
