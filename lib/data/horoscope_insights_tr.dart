import 'dart:math';

const Map<String, List<String>> _sunMessagesTr = {
  'aries': [
    'Cesaretiniz çevrenize ilham veriyor.',
    'Bugün yeni başlangıçlar için kapılar aralanıyor.',
    'Enerjinizi yaratıcı projelere yönlendirin.',
  ],
  'taurus': [
    'Sabırlı tavrınız güven ortamı yaratıyor.',
    'Maddi konularda sağlam adımlar atabilirsiniz.',
    'Rahatınıza vakit ayırmak enerjinizi tazeliyor.',
  ],
  'gemini': [
    'Merakınız yeni bağlantılar kurmanızı sağlıyor.',
    'İletişimde açık olmak sizi güçlendiriyor.',
    'Esnek kalmak gününüzü kolaylaştıracak.',
  ],
  'cancer': [
    'Sezgileriniz size doğru yolu fısıldıyor.',
    'Ailenizden alacağınız destek moral veriyor.',
    'Kalbinizi dinlemekten çekinmeyin.',
  ],
  'leo': [
    'Parlak enerjiniz dikkatleri üzerine topluyor.',
    'Özgüveninizle çevrenizi motive ediyorsunuz.',
    'Sahne sizin; fikirlerinizi paylaşın.',
  ],
  'virgo': [
    'Detaylara verdiğiniz önem fark yaratıyor.',
    'Planlı hareket etmek sizi rahatlatıyor.',
    'Şefkatli yaklaşımınız güven veriyor.',
  ],
  'libra': [
    'Dengeli tavrınız ilişkileri güçlendiriyor.',
    'Paylaşımlarınızda uyum ön planda.',
    'Güzellikleri fark etmek ruhunuza iyi geliyor.',
  ],
  'scorpio': [
    'Kararlılığınız çevrenizdekilere güç katıyor.',
    'Derin duygularınızı ifade etmek şifa veriyor.',
    'Tutkularınızı dönüştürücü şekilde kullanın.',
  ],
  'sagittarius': [
    'Macera isteğiniz ufuklar açıyor.',
    'Özgür düşünmek yeni yollar gösteriyor.',
    'Neşeniz bulaşıcı, yayılmasına izin verin.',
  ],
  'capricorn': [
    'Disiplininiz kalıcı sonuçlar getiriyor.',
    'Hedeflerinizi netleştirmek için uygun gün.',
    'Sorumluluklarınızı ustalıkla yönetiyorsunuz.',
  ],
  'aquarius': [
    'Orijinal fikirleriniz fark yaratıyor.',
    'Toplumsal katkınız takdir topluyor.',
    'Arkadaş çevrenizden ilham alın.',
  ],
  'pisces': [
    'Şefkatli enerjiniz çevrenizi sarıyor.',
    'Sanatsal yönünüzü ifade edin.',
    'Hayallerinizi paylaşmak sizi güçlendiriyor.',
  ],
};

const Map<String, List<String>> _risingMessagesTr = {
  'aries': [
    'Cesur duruşunuz dikkat çekiyor.',
    'Hızlı kararlarınız sizi öne çıkarıyor.',
    'Liderlik içgüdünüz güçlü.',
  ],
  'taurus': [
    'Sakin tavrınız güven veriyor.',
    'Estetik bakışınız çevrenizi etkiliyor.',
    'Kararlılığınızla fark yaratıyorsunuz.',
  ],
  'gemini': [
    'İletişim gücünüz parlıyor.',
    'Meraklı ruhunuz insanları çekiyor.',
    'Bilgiyi paylaşmak sizi mutlu ediyor.',
  ],
  'cancer': [
    'Koruyucu enerjiniz sıcaklık yayıyor.',
    'Sezgisel yaklaşımlarınız rehberlik ediyor.',
    'Evinize dair planlar öne çıkıyor.',
  ],
  'leo': [
    'Sahne ışıkları size dönük.',
    'Neşe ve cömertliğinizle ilham veriyorsunuz.',
    'Kendinizi gösterme isteğiniz artıyor.',
  ],
  'virgo': [
    'Düzenli yaklaşımınız takdir topluyor.',
    'Detayları fark etmek avantaj sağlıyor.',
    'Faydalı olmak sizi mutlu ediyor.',
  ],
  'libra': [
    'Nazik üslubunuz uyum yaratıyor.',
    'İlişkilerde denge arayışınız öne çıkıyor.',
    'Estetik zevkleriniz vurgulanıyor.',
  ],
  'scorpio': [
    'Gizemli duruşunuz merak uyandırıyor.',
    'Tutkunuzu paylaşmak sizi yakınlaştırıyor.',
    'Dönüştürücü enerjiniz aktif.',
  ],
  'sagittarius': [
    'Dışa dönük tavrınız yayılıyor.',
    'Keşfetme arzunuz motive ediyor.',
    'Pozitif sözleriniz moral veriyor.',
  ],
  'capricorn': [
    'Ciddi duruşunuz güven telkin ediyor.',
    'Planlı davranışlarınız öne çıkıyor.',
    'Uzun vadeli hedefler gündemde.',
  ],
  'aquarius': [
    'Bağımsız ruhunuz hissediliyor.',
    'Arkadaşlıklarınızda yenilik var.',
    'Toplumsal projeler ilginizi çekiyor.',
  ],
  'pisces': [
    'Empatiniz herkesi sarıyor.',
    'Hayal gücünüz yoğun.',
    'Akışta kalmak huzur veriyor.',
  ],
};

String sunInsightForTr(String signId, DateTime date) {
  final entries = _sunMessagesTr[signId] ?? [''];
  if (entries.isEmpty) return '';
  final index = date.day % entries.length;
  return entries[index];
}

String risingInsightForTr(String signId, DateTime date) {
  final entries = _risingMessagesTr[signId] ?? [''];
  if (entries.isEmpty) return '';
  final index = date.month % entries.length;
  return entries[index];
}

String randomFallbackInsightTr() {
  final values = _sunMessagesTr.values.expand((element) => element).toList();
  return values[Random(42).nextInt(values.length)];
}
