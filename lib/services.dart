import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart' as geo;
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

class LocationSnapshot {
  const LocationSnapshot({
    required this.latitude,
    required this.longitude,
    this.city,
    this.country,
  });

  final double latitude;
  final double longitude;
  final String? city;
  final String? country;
}

/// Şehir ve koordinat bilgisi (konum servisleri)
class LocationService {
  static Future<LocationSnapshot?> currentLocation() async {
    LocationSnapshot? ipSnapshot;
    Future<LocationSnapshot?> ensureIpSnapshot() async {
      ipSnapshot ??= await _fallbackLocationFromIP();
      return ipSnapshot;
    }

    try {
      final enabled = await Geolocator.isLocationServiceEnabled();
      if (!enabled) {
        debugPrint('Konum servisleri kapalı veya devre dışı.');
        return await ensureIpSnapshot();
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied) {
        debugPrint('Konum izni reddedildi.');
        return await ensureIpSnapshot();
      }

      if (permission == LocationPermission.deniedForever) {
        debugPrint('Konum izni kalıcı olarak reddedildi.');
        return await ensureIpSnapshot();
      }

      Position? position;
      try {
        position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.best,
          timeLimit: const Duration(seconds: 8),
        );
      } on Exception catch (error) {
        debugPrint('Anlık konum alınamadı: $error');
      }

      if (position == null) {
        try {
          position = await Geolocator.getLastKnownPosition();
        } catch (error) {
          debugPrint('Önceki konum alınamadı: $error');
        }
      }
      if (position == null) {
        return await ensureIpSnapshot();
      }

      List<geo.Placemark> placemarks = const [];
      try {
        placemarks = await geo.placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );
      } catch (error) {
        debugPrint('Geocode alınamadı: $error');
      }

      String? resolvedCity;
      String? resolvedCountry;
      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        resolvedCity = _localizePlace(place.locality) ??
            _localizePlace(place.subAdministrativeArea) ??
            _localizePlace(place.administrativeArea);
        resolvedCountry = _localizePlace(place.country);
      }

      if (resolvedCity == null || resolvedCountry == null) {
        await ensureIpSnapshot();
        resolvedCity ??= ipSnapshot?.city;
        resolvedCountry ??= ipSnapshot?.country;
      }

      return LocationSnapshot(
        latitude: position.latitude,
        longitude: position.longitude,
        city: resolvedCity,
        country: resolvedCountry,
      );
    } catch (error) {
      debugPrint('Konum çözümlenemedi: $error');
      return await ensureIpSnapshot();
    }
  }

  static Future<String?> currentCity() async {
    final snapshot = await currentLocation();
    return snapshot?.city;
  }

  static String? _localizePlace(String? value) {
    final cleaned = _cleanPlace(value);
    if (cleaned == null) return null;

    final lower = cleaned.toLowerCase();
    if (_placeTranslations.containsKey(lower)) {
      return _placeTranslations[lower];
    }

    if (lower.endsWith(' province')) {
      final base = cleaned.substring(0, cleaned.length - ' province'.length).trim();
      final translatedBase = _placeTranslations[base.toLowerCase()];
      return translatedBase ?? base;
    }

    if (lower.contains('metropolitan municipality')) {
      final base = cleaned
          .toLowerCase()
          .replaceAll('metropolitan municipality', '')
          .trim();
      if (base.isNotEmpty) {
        final translatedBase = _placeTranslations[base];
        if (translatedBase != null) {
          return translatedBase;
        }
        return base
            .split(' ')
            .where((part) => part.isNotEmpty)
            .map(
              (part) =>
                  part.substring(0, 1).toUpperCase() + (part.length > 1 ? part.substring(1) : ''),
            )
            .join(' ');
      }
    }

    return cleaned;
  }

  static String? _cleanPlace(String? value) {
    final trimmed = value?.trim();
    if (trimmed == null || trimmed.isEmpty) return null;

    final normalized = trimmed.replaceAll(RegExp(r'\s+'), ' ');
    final lower = normalized.toLowerCase();
    if (lower == 'null' || lower == 'unknown' || lower == '-' || lower == '--') {
      return null;
    }

    return normalized;
  }

  static Future<LocationSnapshot?> _fallbackLocationFromIP() async {
    try {
      final uri = Uri.parse('https://ipapi.co/json/');
      final response = await http.get(uri).timeout(const Duration(seconds: 6));
      if (response.statusCode != 200) {
        return null;
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final lat = (data['latitude'] as num?)?.toDouble();
      final lon = (data['longitude'] as num?)?.toDouble();
      if (lat == null || lon == null) {
        return null;
      }

      final city = _localizePlace(data['city'] as String?);
      final country = _localizePlace(
        (data['country_name'] as String?) ?? (data['country'] as String?),
      );

      debugPrint(
        'IP tabanlı konum kullanılıyor: ${(city ?? 'Bilinmiyor')} / ${(country ?? 'Bilinmiyor')}',
      );

      return LocationSnapshot(
        latitude: lat,
        longitude: lon,
        city: city,
        country: country,
      );
    } catch (error) {
      debugPrint('IP tabanlı konum alınamadı: $error');
      return null;
    }
  }

  static const Map<String, String> _placeTranslations = {
    'turkey': 'Türkiye',
    'republic of turkey': 'Türkiye',
    'turkiye': 'Türkiye',
    'türkiye': 'Türkiye',
    'ankara': 'Ankara',
    'ankara province': 'Ankara',
    'izmir': 'İzmir',
    'izmir province': 'İzmir',
    'istanbul': 'İstanbul',
    'istanbul province': 'İstanbul',
    'antalya': 'Antalya',
    'bursa': 'Bursa',
    'adana': 'Adana',
    'mersin': 'Mersin',
    'konya': 'Konya',
    'kayseri': 'Kayseri',
    'eskisehir': 'Eskişehir',
    'eskişehir': 'Eskişehir',
    'trabzon': 'Trabzon',
    'edirne': 'Edirne',
    'gaziantep': 'Gaziantep',
  };
}

class HoroscopeBundle {
  const HoroscopeBundle({
    required this.daily,
    required this.monthly,
    required this.yearly,
  });

  final String daily;
  final String monthly;
  final String yearly;
}

class PlanetInfo {
  const PlanetInfo({
    required this.name,
    required this.headline,
    required this.detail,
  });

  final String name;
  final String headline;
  final String detail;
}

class PlanetarySnapshot {
  const PlanetarySnapshot(this.planets);

  final List<PlanetInfo> planets;
}

class WeatherSnapshot {
  const WeatherSnapshot({
    required this.temperature,
    required this.apparentTemperature,
    required this.description,
    required this.windSpeed,
    required this.humidity,
    required this.minTemp,
    required this.maxTemp,
    required this.observationTime,
  });

  final double temperature;
  final double apparentTemperature;
  final String description;
  final double windSpeed;
  final double humidity;
  final double minTemp;
  final double maxTemp;
  final DateTime observationTime;
}

class NetworkTimeSnapshot {
  const NetworkTimeSnapshot({
    required this.dateTime,
    required this.timeZone,
    required this.utcOffset,
  });

  final DateTime dateTime;
  final String timeZone;
  final String utcOffset;
}

/// Burç hesaplama + internetten günlük yorum/“günün sözü”
class AstroService {
  static const _signs = [
    'Koç',
    'Boğa',
    'İkizler',
    'Yengeç',
    'Aslan',
    'Başak',
    'Terazi',
    'Akrep',
    'Yay',
    'Oğlak',
    'Kova',
    'Balık'
  ];

  static const _signMap = {
    'Koç': 'aries',
    'Boğa': 'taurus',
    'İkizler': 'gemini',
    'Yengeç': 'cancer',
    'Aslan': 'leo',
    'Başak': 'virgo',
    'Terazi': 'libra',
    'Akrep': 'scorpio',
    'Yay': 'sagittarius',
    'Oğlak': 'capricorn',
    'Kova': 'aquarius',
    'Balık': 'pisces',
  };

  static const Map<String, Map<String, String>> _fallbackHoroscopes = {
    'Koç': {
      'daily': 'Enerjin yüksek. Kısa riskler lehine dönebilir.',
      'monthly': 'Ay boyunca yeni projeler seni bekliyor. Cesur adımlar at.',
      'yearly': 'Bu yıl liderliğinle fark yaratacak ve yeni kariyer fırsatları kazanacaksın.'
    },
    'Boğa': {
      'daily': 'Sabırlı adımlar getirili. Maddi kararlarında temkinli ol.',
      'monthly': 'Finansal disiplinin, keyifli yatırımlar yapmanı sağlayacak.',
      'yearly': 'Uzun vadeli planların olgunlaşıyor; emeklerinin karşılığını alacaksın.'
    },
    'İkizler': {
      'daily': 'İletişim kanalları açık. Haberleşmeden kazanç var.',
      'monthly': 'Sosyal çevren genişliyor, yeni iş birlikleri ufkunu açacak.',
      'yearly': 'Eğitim ve seyahat fırsatları ufkunu genişletecek.'
    },
    'Yengeç': {
      'daily': 'Yakın çevreden destek. Ev/yuva odağın.',
      'monthly': 'Aile bağların güçleniyor, duygusal derinlik artacak.',
      'yearly': 'Yeni bir yuva ya da taşınma ihtimali gündeme gelebilir.'
    },
    'Aslan': {
      'daily': 'Sahne sende. Göründüğün kadar güçlüsün.',
      'monthly': 'Yaratıcılığın tavan yapıyor, projelerinde parlayacaksın.',
      'yearly': 'Kariyerinde ışığını saçacak, liderlik yeteneklerini sergileyeceksin.'
    },
    'Başak': {
      'daily': 'Detaylar kurtarıyor. Planlarını sadeleştir.',
      'monthly': 'Rutinlerini gözden geçir, verimliliğini artıracak düzenlemeler yap.',
      'yearly': 'Sağlık ve iş alanlarında kalıcı iyileşmeler mümkün.'
    },
    'Terazi': {
      'daily': 'Denge bugün anahtar. İlişkilerde adil kal.',
      'monthly': 'İkili ilişkilerde yeni bir sayfa açılıyor.',
      'yearly': 'Uzun soluklu ortaklıklar ve romantik bağlar güçlenecek.'
    },
    'Akrep': {
      'daily': 'Sezgilerin keskin. Gizli kalanlar ortaya çıkar.',
      'monthly': 'Finansal ve duygusal dönüşümler seni bekliyor.',
      'yearly': 'Yıl boyunca dönüşümün ve güçlenmenin sonuçlarını göreceksin.'
    },
    'Yay': {
      'daily': 'Ufku genişlet. Küçük bir yol/öğrenme fırsatı var.',
      'monthly': 'Keşiflerin ve öğrenme isteğin artıyor.',
      'yearly': 'Yurt dışı ve eğitim fırsatlarıyla ufkun açılıyor.'
    },
    'Oğlak': {
      'daily': 'Sorumluluklar netleşiyor. Emek karşılığını alır.',
      'monthly': 'Kariyerinde stratejik hamleler seni başarıya taşıyacak.',
      'yearly': 'Disiplinin sayesinde finansal istikrar yakalayacaksın.'
    },
    'Kova': {
      'daily': 'Farklı düşün; çözüm yenide.',
      'monthly': 'Sosyal çevrende yenilikçi fikirlerin destek buluyor.',
      'yearly': 'Toplumsal projelerde sesini duyuracaksın.'
    },
    'Balık': {
      'daily': 'Duygular yükselişte; kendine şefkat göster.',
      'monthly': 'Spiritüel çalışmalar iç huzurunu güçlendirecek.',
      'yearly': 'Sanatsal üretimin ve sezgisel gücün tavan yapacak.'
    },
  };

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
    final slot = ((t.hour % 24) / 2).floor() % 12;
    return _signs[slot];
  }

  static Future<String> fetchDailyQuote() async {
    const fallback = [
      'Kaderin yazdığına sen nokta koyarsın.',
      'Duygularına kulak ver; aklın yol gösterecek.',
      'Bugün basit olan kazanır.',
      'Kendine nazik ol.',
      'Az konuş, çok sez.',
    ];

    try {
      final uri = Uri.parse('https://api.quotable.io/random?tags=inspirational|wisdom');
      final response = await http.get(uri).timeout(const Duration(seconds: 6));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final content = (data['content'] as String?)?.trim();
        if (content != null && content.isNotEmpty) {
          return content;
        }
      }
    } catch (error) {
      debugPrint('Günün sözü alınamadı: $error');
    }

    return fallback[DateTime.now().day % fallback.length];
  }

  static Future<HoroscopeBundle> fetchHoroscopeBundle(String sign) async {
    final english = _signMap[sign];
    if (english == null) return _fallbackHoroscope(sign);

    Future<String> load(String period) async {
      try {
        final uri = Uri.parse(
          'https://horoscope-app-api.vercel.app/api/v1/get-horoscope/$period?sign=$english',
        );
        final response = await http.get(uri).timeout(const Duration(seconds: 8));
        if (response.statusCode == 200) {
          final decoded = jsonDecode(response.body) as Map<String, dynamic>;
          final data = decoded['data'] as Map<String, dynamic>?;
          final text = data?["horoscope_data"] as String?;
          if (text != null && text.trim().isNotEmpty) {
            return text.trim();
          }
        }
      } catch (error) {
        debugPrint('Horoskop $period getirilemedi: $error');
      }
      final fallbackKey = _resolveFallbackKey(sign);
      final fallbackMap = _fallbackHoroscopes[fallbackKey]!;
      return fallbackMap[period] ?? '';
    }

    try {
      final results = await Future.wait([
        load('daily'),
        load('monthly'),
        load('yearly'),
      ]);
      return HoroscopeBundle(
        daily: results[0],
        monthly: results[1],
        yearly: results[2],
      );
    } catch (_) {
      final fallback = _fallbackHoroscope(sign);
      return HoroscopeBundle(
        daily: fallback.daily,
        monthly: fallback.monthly,
        yearly: fallback.yearly,
      );
    }
  }

  static HoroscopeBundle _fallbackHoroscope(String sign) {
    final key = _resolveFallbackKey(sign);
    final map = _fallbackHoroscopes[key]!;
    return HoroscopeBundle(
      daily: map['daily']!,
      monthly: map['monthly']!,
      yearly: map['yearly']!,
    );
  }

  static String _resolveFallbackKey(String sign) {
    if (_fallbackHoroscopes.containsKey(sign)) return sign;
    return 'Koç';
  }

  static Future<PlanetarySnapshot> fetchPlanetarySnapshot() async {
    const planets = {
      'Mars': 'mars',
      'Venüs': 'venus',
      'Merkür': 'mercury',
    };

    Future<PlanetInfo?> load(String label, String slug) async {
      try {
        final uri = Uri.parse('https://api.le-systeme-solaire.net/rest/bodies/$slug');
        final response = await http.get(uri).timeout(const Duration(seconds: 8));
        if (response.statusCode == 200) {
          final body = jsonDecode(response.body) as Map<String, dynamic>;
          final avgTemp = body['avgTemp'];
          final gravity = body['gravity'];
          final sideralOrbit = body['sideralOrbit'];
          final summary = StringBuffer();
          if (avgTemp != null) {
            summary.write('Ortalama sıcaklık: ${avgTemp.toString()}°C');
          }
          if (gravity != null) {
            if (summary.isNotEmpty) summary.write(' · ');
            summary.write('Yerçekimi: ${gravity.toString()} m/s²');
          }
          final detail = body['englishName'] ?? label;
          final orbit = sideralOrbit != null ? '\nGüneş etrafında tur: ~$sideralOrbit gün' : '';
          return PlanetInfo(
            name: label,
            headline: detail.toString(),
            detail: '${summary.toString()}$orbit',
          );
        }
      } catch (error) {
        debugPrint('Gezegen bilgisi alınamadı ($label): $error');
      }
      return null;
    }

    final futures = planets.entries.map((entry) => load(entry.key, entry.value));
    final results = await Future.wait(futures);
    final filtered = results.whereType<PlanetInfo>().toList();

    if (filtered.isEmpty) {
      return const PlanetarySnapshot([
        PlanetInfo(
          name: 'Mars',
          headline: 'Kızıl Gezegen',
          detail: 'Ortalama sıcaklık: -63°C · Yerçekimi: 3.71 m/s²\nGüneş etrafında tur: ~687 gün',
        ),
        PlanetInfo(
          name: 'Venüs',
          headline: 'İç ısı ve tutku',
          detail: 'Ortalama sıcaklık: 464°C · Yerçekimi: 8.87 m/s²\nGüneş etrafında tur: ~225 gün',
        ),
        PlanetInfo(
          name: 'Merkür',
          headline: 'Işığa en yakın',
          detail: 'Ortalama sıcaklık: 167°C · Yerçekimi: 3.7 m/s²\nGüneş etrafında tur: ~88 gün',
        ),
      ]);
    }

    return PlanetarySnapshot(filtered);
  }
}

class WeatherService {
  static Future<WeatherSnapshot?> fetchWeather({
    required double latitude,
    required double longitude,
  }) async {
    try {
      final uri = Uri.https('api.open-meteo.com', '/v1/forecast', {
        'latitude': latitude.toStringAsFixed(4),
        'longitude': longitude.toStringAsFixed(4),
        'current': 'temperature_2m,apparent_temperature,relative_humidity_2m,weather_code,wind_speed_10m',
        'daily': 'temperature_2m_max,temperature_2m_min',
        'timezone': 'auto',
      });
      final response = await http.get(uri).timeout(const Duration(seconds: 8));
      if (response.statusCode != 200) return null;

      final decoded = jsonDecode(response.body) as Map<String, dynamic>;
      final current = decoded['current'] as Map<String, dynamic>?;
      final daily = decoded['daily'] as Map<String, dynamic>?;
      if (current == null || daily == null) return null;

      final minTemps = daily['temperature_2m_min'] as List<dynamic>?;
      final maxTemps = daily['temperature_2m_max'] as List<dynamic>?;
      final timeStr = current['time'] as String?;

      return WeatherSnapshot(
        temperature: (current['temperature_2m'] as num?)?.toDouble() ?? 0,
        apparentTemperature: (current['apparent_temperature'] as num?)?.toDouble() ?? 0,
        description: _weatherCodeMeaning((current['weather_code'] as num?)?.toInt()),
        windSpeed: (current['wind_speed_10m'] as num?)?.toDouble() ?? 0,
        humidity: (current['relative_humidity_2m'] as num?)?.toDouble() ?? 0,
        minTemp: (minTemps?.first as num?)?.toDouble() ?? 0,
        maxTemp: (maxTemps?.first as num?)?.toDouble() ?? 0,
        observationTime: timeStr != null ? DateTime.parse(timeStr).toLocal() : DateTime.now(),
      );
    } catch (error) {
      debugPrint('Hava durumu alınamadı: $error');
      return null;
    }
  }

  static String _weatherCodeMeaning(int? code) {
    switch (code) {
      case 0:
        return 'Açık';
      case 1:
      case 2:
        return 'Az bulutlu';
      case 3:
        return 'Bulutlu';
      case 45:
      case 48:
        return 'Sisli';
      case 51:
      case 53:
      case 55:
        return 'Çise';
      case 61:
      case 63:
      case 65:
        return 'Yağmurlu';
      case 71:
      case 73:
      case 75:
        return 'Karlı';
      case 80:
      case 81:
      case 82:
        return 'Sağanak';
      case 95:
      case 96:
      case 99:
        return 'Fırtına';
      default:
        return 'Durum bilinmiyor';
    }
  }
}

class NetworkTimeService {
  static Future<NetworkTimeSnapshot?> fetchTime({
    required double latitude,
    required double longitude,
  }) async {
    try {
      final uri = Uri.parse(
        'https://www.timeapi.io/api/Time/current/coordinate?latitude=${latitude.toStringAsFixed(4)}&longitude=${longitude.toStringAsFixed(4)}',
      );
      final response = await http.get(uri).timeout(const Duration(seconds: 6));
      if (response.statusCode != 200) return null;

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final dateTimeStr = data['dateTime'] as String?;
      if (dateTimeStr == null) return null;

      return NetworkTimeSnapshot(
        dateTime: DateTime.parse(dateTimeStr).toLocal(),
        timeZone: (data['timeZone'] as String?) ?? 'Bilinmiyor',
        utcOffset: (data['timeZoneOffset'] as String?) ?? '',
      );
    } catch (error) {
      debugPrint('Ağ zamanı alınamadı: $error');
      return null;
    }
  }
}
