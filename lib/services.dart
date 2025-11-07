import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart' as geo;
import 'package:geolocator/geolocator.dart';

/// Şehir bulma (konum servisleri)
class LocationService {
  static Future<String?> currentCity() async {
    try {
      final enabled = await Geolocator.isLocationServiceEnabled();
      if (!enabled) {
        return null;
      }

      LocationPermission perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }

      if (perm == LocationPermission.deniedForever || perm == LocationPermission.denied) {
        return null;
      }

      Position? pos;
      try {
        pos = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.best,
          timeLimit: const Duration(seconds: 8),
        );
      } on Exception catch (err) {
        debugPrint('Konum alınamadı (anlık): $err');
      }

      pos ??= await Geolocator.getLastKnownPosition();
      if (pos == null) return null;

      final placemarks = await geo.placemarkFromCoordinates(
        pos.latitude,
        pos.longitude,
        localeIdentifier: 'tr_TR',
      );

      if (placemarks.isEmpty) return null;
      final place = placemarks.first;
      return place.locality ?? place.subAdministrativeArea ?? place.administrativeArea ?? place.country;
    } catch (e) {
      debugPrint('Konum çözümlenemedi: $e');
      return null;
    }
  }
}

/// Burç hesaplama + günlük yorum/“günün sözü”
class AstroService {
  static const _signs = [
    'Koç', 'Boğa', 'İkizler', 'Yengeç', 'Aslan', 'Başak',
    'Terazi', 'Akrep', 'Yay', 'Oğlak', 'Kova', 'Balık'
  ];

  static String sunSign(DateTime d) {
    final m = d.month, day = d.day;
    if ((m == 3 && day >= 21) || (m == 4 && day <= 19)) return 'Koç';
    if ((m == 4 && day >= 20) || (m == 5 && day <= 20)) return 'Boğa';
    if ((m == 5 && day >= 21) || (m == 6 && day <= 20)) return 'İkizler';
    if ((m == 6 && day >= 21) || (m == 7 && day <= 22)) return 'Yengeç';
    if ((m == 7 && day >= 23) || (m == 8 && day <= 22)) return 'Aslan';
    if ((m == 8 && day >= 23) || (m == 9 && day <= 22)) return 'Başak';
    if ((m == 9 && day >= 23) || (m == 10 && day <= 22)) return 'Terazi';
    if ((m == 10 && day >= 23) || (m == 11 && day <= 21)) return 'Akrep';
    if ((m == 11 && day >= 22) || (m == 12 && day <= 21)) return 'Yay';
    if ((m == 12 && day >= 22) || (m == 1 && day <= 19)) return 'Oğlak';
    if ((m == 1 && day >= 20) || (m == 2 && day <= 18)) return 'Kova';
    return 'Balık';
  }

  static String approxAscendant(TimeOfDay t) {
    final order = _signs;
    final slot = ((t.hour % 24) / 2).floor() % 12;
    return order[slot];
  }

  static String dailyQuote() {
    const quotes = [
      'Kaderin yazdığına sen nokta koyarsın.',
      'Duygularına kulak ver; aklın yol gösterecek.',
      'Bugün basit olan kazanır.',
      'Kendine nazik ol.',
      'Az konuş, çok sez.',
    ];
    return quotes[DateTime.now().day % quotes.length];
  }

  static String dailyHoroscope(String sign) {
    final base = {
      'Koç': 'Enerjin yüksek. Kısa riskler lehine dönebilir.',
      'Boğa': 'Sabırlı adımlar getirili. Maddi kararlarında temkinli ol.',
      'İkizler': 'İletişim kanalları açık. Haberleşmeden kazanç var.',
      'Yengeç': 'Yakın çevreden destek. Ev/yuva odağın.',
      'Aslan': 'Sahne sende. Göründüğün kadar güçlüsün.',
      'Başak': 'Detaylar kurtarıyor. Planlarını sadeleştir.',
      'Terazi': 'Denge bugün anahtar. İlişkilerde adil kal.',
      'Akrep': 'Sezgilerin keskin. Gizli kalanlar ortaya çıkar.',
      'Yay': 'Ufku genişlet. Küçük bir yol/öğrenme fırsatı var.',
      'Oğlak': 'Sorumluluklar netleşiyor. Emek karşılığını alır.',
      'Kova': 'Farklı düşün; çözüm yenide.',
      'Balık': 'Duygular yükselişte; kendine şefkat göster.',
    };
    return base[sign]!;
  }
}
