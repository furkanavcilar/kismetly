import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart' as geo;
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

class LocationService {
  static Future<LocationSnapshot?> currentLocation() async {
    try {
      final enabled = await Geolocator.isLocationServiceEnabled();
      if (!enabled) return null;

      var perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.denied ||
          perm == LocationPermission.deniedForever) {
        return null;
      }

      Position? pos;
      try {
        pos = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.best,
          timeLimit: const Duration(seconds: 8),
        );
      } catch (e) {
        debugPrint('getCurrentPosition hata: $e');
      }
      pos ??= await Geolocator.getLastKnownPosition();
      if (pos == null) return null;

      List<geo.Placemark> placemarks = const [];
      try {
        // geocoding ^3.0.0 -> localeIdentifier parametresi yok!
        placemarks = await geo.placemarkFromCoordinates(
          pos.latitude,
          pos.longitude,
        );
      } catch (e) {
        debugPrint('placemark hata: $e');
      }

      String? resolvedCity;
      String? resolvedCountry;
      if (placemarks.isNotEmpty) {
        final p = placemarks.first;
        String? clean(String? v) {
          final t = v?.trim();
          return (t != null && t.isNotEmpty) ? t : null;
        }

        resolvedCity = clean(p.locality) ??
            clean(p.subAdministrativeArea) ??
            clean(p.administrativeArea);
        resolvedCountry = clean(p.country);
      }

      return LocationSnapshot(
        latitude: pos.latitude,
        longitude: pos.longitude,
        city: resolvedCity,
        country: resolvedCountry,
      );
    } catch (e) {
      debugPrint('Konum çözümleme hatası: $e');
      return null;
    }
  }
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

class CompatibilityReport {
  const CompatibilityReport({
    required this.score,
    required this.tone,
    required this.summary,
    required this.highlights,
  });

  final double score;
  final String tone;
  final String summary;
  final List<String> highlights;
}

class PlanetInfo {
  const PlanetInfo({required this.name, required this.headline, required this.detail});
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

class AstroService {
  static const _signs = [
    'Koç','Boğa','İkizler','Yengeç','Aslan','Başak',
    'Terazi','Akrep','Yay','Oğlak','Kova','Balık'
  ];

  static const Map<String, String> _elements = {
    'Koç': 'Ateş',
    'Boğa': 'Toprak',
    'İkizler': 'Hava',
    'Yengeç': 'Su',
    'Aslan': 'Ateş',
    'Başak': 'Toprak',
    'Terazi': 'Hava',
    'Akrep': 'Su',
    'Yay': 'Ateş',
    'Oğlak': 'Toprak',
    'Kova': 'Hava',
    'Balık': 'Su',
  };

  static const _signMap = {
    'Koç':'aries','Boğa':'taurus','İkizler':'gemini','Yengeç':'cancer',
    'Aslan':'leo','Başak':'virgo','Terazi':'libra','Akrep':'scorpio',
    'Yay':'sagittarius','Oğlak':'capricorn','Kova':'aquarius','Balık':'pisces',
  };

  static List<String> get signs => List.unmodifiable(_signs);

  static String sunSign(DateTime d) {
    final m=d.month, day=d.day;
    if ((m==3 && day>=21)||(m==4 && day<=19)) return 'Koç';
    if ((m==4 && day>=20)||(m==5 && day<=20)) return 'Boğa';
    if ((m==5 && day>=21)||(m==6 && day<=20)) return 'İkizler';
    if ((m==6 && day>=21)||(m==7 && day<=22)) return 'Yengeç';
    if ((m==7 && day>=23)||(m==8 && day<=22)) return 'Aslan';
    if ((m==8 && day>=23)||(m==9 && day<=22)) return 'Başak';
    if ((m==9 && day>=23)||(m==10 && day<=22)) return 'Terazi';
    if ((m==10 && day>=23)||(m==11 && day<=21)) return 'Akrep';
    if ((m==11 && day>=22)||(m==12 && day<=21)) return 'Yay';
    if ((m==12 && day>=22)||(m==1 && day<=19)) return 'Oğlak';
    if ((m==1 && day>=20)||(m==2 && day<=18)) return 'Kova';
    return 'Balık';
  }

  static String approxAscendant(TimeOfDay t) {
    final slot=((t.hour%24)/2).floor()%12;
    return _signs[slot];
  }

  static CompatibilityReport compatibility(String first, String second) {
    final safeFirst = _signs.contains(first) ? first : _signs.first;
    final safeSecond = _signs.contains(second) ? second : _signs.first;
    final indexA = _signs.indexOf(safeFirst);
    final indexB = _signs.indexOf(safeSecond);
    final diff = (indexA - indexB).abs();
    final wrappedDiff = diff > 6 ? 12 - diff : diff;
    final orbitScore = 1 - (wrappedDiff / 6);

    double elementSynergy(String elementA, String elementB) {
      if (elementA == elementB) return 0.88;
      const affinities = {
        'Ateş': {'Hava': 0.78, 'Su': 0.52, 'Toprak': 0.58},
        'Hava': {'Ateş': 0.78, 'Su': 0.55, 'Toprak': 0.60},
        'Su': {'Toprak': 0.80, 'Ateş': 0.52, 'Hava': 0.55},
        'Toprak': {'Su': 0.80, 'Ateş': 0.58, 'Hava': 0.60},
      };
      return affinities[elementA]?[elementB] ?? 0.6;
    }

    final elementA = _elements[safeFirst] ?? 'Element';
    final elementB = _elements[safeSecond] ?? 'Element';
    final synergy = elementSynergy(elementA, elementB);
    final baseScore = ((synergy + orbitScore) / 2).clamp(0.0, 1.0);
    final score = (baseScore + (elementA == elementB ? 0.08 : 0))
        .clamp(0.0, 1.0);

    String tone;
    if (score >= 0.78) {
      tone = 'Yüksek uyum';
    } else if (score >= 0.62) {
      tone = 'Dengeli bağ';
    } else {
      tone = 'Öğretici eşleşme';
    }

    final elementFocus = elementA == elementB
        ? '$elementA elementinin ortak titreşimi'
        : '$elementA & $elementB elementlerinin köprüsü';

    final summary =
        '$safeFirst ile $safeSecond arasındaki bağ $tone düzeyinde. '
        'Element dengesi $elementFocus üzerinde yoğunlaşıyor.';

    final List<String> highlights = [
      if (score >= 0.75)
        'Birlikte hareket etmek doğal geliyor; risk alırken bile birbirinizi destekliyorsunuz.'
      else if (score >= 0.6)
        'İletişimi açık tuttuğunuzda, farklı bakış açıları üretkenliğe dönüşüyor.'
      else
        'Ritminizi bulmak için net sınırlar ve düzenli check-in’ler belirleyin.',
      if (elementA == elementB)
        'Benzer motivasyonlar yaratıcı projeleri hızlandırıyor.'
      else
        'Zıt elementler, birbirinizin eksik hissettiği noktaları tamamlamanızı sağlıyor.',
      if (orbitScore > 0.8)
        'Gökyüzünde burçlar yan yana olduğu için duygusal tempo hızla uyumlanıyor.'
      else if (orbitScore < 0.4)
        'Burçlar uzak konumda; bu da uzun vadeli planlarda ekstra sabır gerektiriyor.'
      else
        'Orta seviyede astrolojik mesafe, ilişkide sağlıklı bir dinamizm yaratıyor.',
    ];

    return CompatibilityReport(
      score: double.parse(score.toStringAsFixed(2)),
      tone: tone,
      summary: summary,
      highlights: highlights,
    );
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
      final r= await http.get(
        Uri.parse('https://api.quotable.io/random?tags=inspirational|wisdom'),
      ).timeout(const Duration(seconds: 6));
      if (r.statusCode==200){
        final m=jsonDecode(r.body) as Map<String,dynamic>;
        final s=(m['content'] as String?)?.trim();
        if(s!=null && s.isNotEmpty) return s;
      }
    } catch(_) {}
    return fallback[DateTime.now().day % fallback.length];
  }

  static Future<HoroscopeBundle> fetchHoroscopeBundle(String sign) async {
    final en=_signMap[sign];
    Future<String> load(String period) async {
      try {
        final u=Uri.parse('https://horoscope-app-api.vercel.app/api/v1/get-horoscope/$period?sign=$en');
        final r=await http.get(u).timeout(const Duration(seconds: 8));
        if(r.statusCode==200){
          final data=(jsonDecode(r.body) as Map<String,dynamic>)['data'] as Map<String,dynamic>?;
          final txt=data?['horoscope_data'] as String?;
          if (txt!=null && txt.trim().isNotEmpty) return txt.trim();
        }
      } catch(_){}
      return 'Bugünün enerjisini sezgilerinle dengele.';
    }

    final res=await Future.wait([load('daily'),load('monthly'),load('yearly')]);
    return HoroscopeBundle(daily: res[0], monthly: res[1], yearly: res[2]);
  }

  static Future<PlanetarySnapshot> fetchPlanetarySnapshot() async {
    Future<PlanetInfo?> load(String label, String slug) async {
      try {
        final r=await http.get(
          Uri.parse('https://api.le-systeme-solaire.net/rest/bodies/$slug'),
        ).timeout(const Duration(seconds: 8));
        if(r.statusCode==200){
          final b=jsonDecode(r.body) as Map<String,dynamic>;
          final avg=b['avgTemp']; final g=b['gravity']; final orb=b['sideralOrbit'];
          final head= b['englishName']?.toString() ?? label;
          final s=[
            if(avg!=null) 'Ortalama sıcaklık: $avg°C',
            if(g!=null) 'Yerçekimi: $g m/s²',
          ].join(' · ');
          final d= s.isEmpty ? 'Veri yok' : s;
          final tail=orb!=null ? '\nGüneş etrafında tur: ~$orb gün' : '';
          return PlanetInfo(name: label, headline: head, detail: '$d$tail');
        }
      } catch(_){}
      return null;
    }
    final out = await Future.wait([
      load('Mars','mars'),
      load('Venüs','venus'),
      load('Merkür','mercury'),
    ]);
    final list=out.whereType<PlanetInfo>().toList();
    if(list.isEmpty){
      return const PlanetarySnapshot([
        PlanetInfo(name:'Mars',headline:'Kızıl Gezegen',detail:'Ortalama sıcaklık: -63°C'),
        PlanetInfo(name:'Venüs',headline:'İç ısı ve tutku',detail:'Ortalama sıcaklık: 464°C'),
      ]);
    }
    return PlanetarySnapshot(list);
  }
}

class WeatherService {
  static Future<WeatherSnapshot?> fetchWeather({
    required double latitude,
    required double longitude,
  }) async {
    try {
      final uri = Uri.https('api.open-meteo.com','/v1/forecast',{
        'latitude': latitude.toStringAsFixed(4),
        'longitude': longitude.toStringAsFixed(4),
        'current':'temperature_2m,apparent_temperature,relative_humidity_2m,weather_code,wind_speed_10m',
        'daily':'temperature_2m_max,temperature_2m_min',
        'timezone':'auto',
      });
      final r=await http.get(uri).timeout(const Duration(seconds: 8));
      if(r.statusCode!=200) return null;
      final d=jsonDecode(r.body) as Map<String,dynamic>;
      final cur=d['current'] as Map<String,dynamic>?;
      final daily=d['daily'] as Map<String,dynamic>?;
      if(cur==null || daily==null) return null;

      return WeatherSnapshot(
        temperature: (cur['temperature_2m'] as num?)?.toDouble() ?? 0,
        apparentTemperature: (cur['apparent_temperature'] as num?)?.toDouble() ?? 0,
        description: _desc((cur['weather_code'] as num?)?.toInt()),
        windSpeed: (cur['wind_speed_10m'] as num?)?.toDouble() ?? 0,
        humidity: (cur['relative_humidity_2m'] as num?)?.toDouble() ?? 0,
        minTemp: ((daily['temperature_2m_min'] as List?)?.first as num?)?.toDouble() ?? 0,
        maxTemp: ((daily['temperature_2m_max'] as List?)?.first as num?)?.toDouble() ?? 0,
        observationTime: DateTime.tryParse((cur['time'] as String?) ?? '')?.toLocal() ?? DateTime.now(),
      );
    } catch(e){
      debugPrint('Weather error: $e');
      return null;
    }
  }

  static String _desc(int? code){
    switch(code){
      case 0: return 'Açık';
      case 1:
      case 2: return 'Az bulutlu';
      case 3: return 'Bulutlu';
      case 45:
      case 48: return 'Sisli';
      case 51:
      case 53:
      case 55: return 'Çise';
      case 61:
      case 63:
      case 65: return 'Yağmurlu';
      case 71:
      case 73:
      case 75: return 'Karlı';
      case 80:
      case 81:
      case 82: return 'Sağanak';
      case 95:
      case 96:
      case 99: return 'Fırtına';
      default: return 'Durum bilinmiyor';
    }
  }
}

class NetworkTimeService {
  static Future<NetworkTimeSnapshot?> fetchTime({
    required double latitude,
    required double longitude,
  }) async {
    try {
      final r=await http.get(Uri.parse(
        'https://www.timeapi.io/api/Time/current/coordinate'
        '?latitude=${latitude.toStringAsFixed(4)}&longitude=${longitude.toStringAsFixed(4)}',
      )).timeout(const Duration(seconds: 6));
      if(r.statusCode!=200) return null;
      final m=jsonDecode(r.body) as Map<String,dynamic>;
      final s=m['dateTime'] as String?;
      if(s==null) return null;
      return NetworkTimeSnapshot(
        dateTime: DateTime.parse(s).toLocal(),
        timeZone: (m['timeZone'] as String?) ?? 'Bilinmiyor',
        utcOffset: (m['timeZoneOffset'] as String?) ?? '',
      );
    } catch(e){
      debugPrint('Time error: $e');
      return null;
    }
  }
}
