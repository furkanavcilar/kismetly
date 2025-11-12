import 'dart:convert';
import 'dart:math';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/weather_report.dart';

class WeatherService {
  WeatherService({http.Client? client, SharedPreferences? preferences})
      : _client = client ?? http.Client(),
        _prefsFuture = preferences != null
            ? Future.value(preferences)
            : SharedPreferences.getInstance();

  final http.Client _client;
  final Future<SharedPreferences> _prefsFuture;

  String _dayStamp(DateTime date) {
    final mm = date.month.toString().padLeft(2, '0');
    final dd = date.day.toString().padLeft(2, '0');
    return '${date.year}-$mm-$dd';
  }

  int _hashString(String value) {
    const int fnvPrime = 16777619;
    const int offset = 2166136261;
    var hash = offset;
    for (final code in value.codeUnits) {
      hash ^= code;
      hash = (hash * fnvPrime) & 0x7fffffff;
    }
    return hash;
  }

  Future<WeatherReport?> fetchWeather({
    required String city,
    required double latitude,
    required double longitude,
    String localeCode = 'tr',
  }) async {
    final prefs = await _prefsFuture;
    final dayKey = _dayStamp(DateTime.now());
    final cacheKey = 'weather_${city.toLowerCase()}_${localeCode}_$dayKey';
    final cached = prefs.getString(cacheKey);
    if (cached != null) {
      try {
        return WeatherReport.fromJson(jsonDecode(cached) as Map<String, dynamic>);
      } catch (_) {
        // ignore invalid cache
      }
    }

    final url = Uri.parse(
      'https://api.open-meteo.com/v1/forecast?latitude=$latitude&longitude=$longitude&current=temperature_2m,weather_code&hourly=temperature_2m&timezone=auto',
    );
    final response = await _client.get(url);
    if (response.statusCode >= 400) {
      return cached != null
          ? WeatherReport.fromJson(jsonDecode(cached) as Map<String, dynamic>)
          : null;
    }

    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    final current = decoded['current'] as Map<String, dynamic>?;
    if (current == null) {
      return null;
    }
    final code = (current['weather_code'] as num?)?.toInt() ?? 0;
    final condition = _describe(code, localeCode, dayKey, city);
    final icon = _iconFor(code);
    final report = WeatherReport(
      temperature: (current['temperature_2m'] as num?)?.toDouble() ?? 0,
      condition: condition,
      icon: icon,
      city: city,
      lastUpdated: DateTime.tryParse(current['time'] as String? ?? '') ?? DateTime.now(),
      narrative: _composeNarrative(
        localeCode: localeCode,
        city: city,
        condition: condition,
        temperature: (current['temperature_2m'] as num?)?.toDouble() ?? 0,
        code: code,
        dayKey: dayKey,
      ),
      vibeTag: _vibeTag(
        localeCode: localeCode,
        code: code,
        dayKey: dayKey,
        city: city,
      ),
    );
    await prefs.setString(cacheKey, jsonEncode(report.toJson()));
    return report;
  }

  String _describe(int code, String locale, String dayKey, String city) {
    final map = locale == 'tr'
        ? {
            0: 'Açık',
            1: 'Parçalı bulutlu',
            2: 'Bulutlu',
            3: 'Kapalı',
            45: 'Sisli',
            48: 'Kırağılı sis',
            51: 'Hafif çise',
            61: 'Hafif yağmur',
            63: 'Yağmur',
            65: 'Şiddetli yağmur',
            71: 'Hafif kar',
            80: 'Sağanak',
          }
        : {
            0: 'Clear',
            1: 'Partly cloudy',
            2: 'Cloudy',
            3: 'Overcast',
            45: 'Foggy',
            48: 'Freezing fog',
            51: 'Light drizzle',
            61: 'Light rain',
            63: 'Rain',
            65: 'Heavy rain',
            71: 'Light snow',
            80: 'Showers',
          };
    final base = map[code] ?? (locale == 'tr' ? 'Kozmik hava' : 'Cosmic weather');
    final nuances = locale == 'tr'
        ? ['• hafif bir esinti', '• parlayan bir serinlik', '• iç ısıtan bir titreşim']
        : ['• a soft breeze', '• a glowing calm', '• a comforting hush'];
    final random = Random(_hashString('$dayKey|$city|$locale|$code'));
    final nuance = nuances[random.nextInt(nuances.length)];
    return '$base $nuance';
  }

  String _composeNarrative({
    required String localeCode,
    required String city,
    required String condition,
    required double temperature,
    required int code,
    required String dayKey,
  }) {
    final seed = _hashString('$dayKey|$city|$code|$localeCode');
    final random = Random(seed);
    if (localeCode == 'tr') {
      final sensations = [
        'ipeksi bir esintiyi taşıyor',
        'nazik bir sisle sarılıyor',
        'yumuşak titreşimler yayıyor',
      ];
      final invitations = [
        'Pencereleri arala ve gökyüzüne kısa bir teşekkür gönder.',
        'Ritüel fincanını doldur; koku duyularını uyandırsın.',
        'Derin bir nefes al ve bugünün ritmine kalbini ayarla.',
      ];
      final sensation = sensations[random.nextInt(sensations.length)];
      final invitation = invitations[random.nextInt(invitations.length)];
      final temperatureLine = _temperatureLine(temperature, localeCode, random);
      return '$city üzerinde $condition $sensation. $temperatureLine $invitation';
    }
    final sensations = [
      'carries a velvet breeze',
      'wraps the streets in a silver hush',
      'glows with a gentle shimmer',
    ];
    final invitations = [
      'Crack a window and whisper gratitude toward the sky.',
      'Brew something warm and let the steam join your ritual.',
      'Breathe deeply and let your pulse sync with the day’s rhythm.',
    ];
    final sensation = sensations[random.nextInt(sensations.length)];
    final invitation = invitations[random.nextInt(invitations.length)];
    final temperatureLine = _temperatureLine(temperature, localeCode, random);
    return 'Over $city, $condition $sensation. $temperatureLine $invitation';
  }

  String _temperatureLine(double temperature, String localeCode, Random random) {
    if (localeCode == 'tr') {
      if (temperature <= 5) {
        final options = [
          'Hava serin; şalını hazır tut.',
          'Soğuk havaya karşı sıcak içecekler iyi gelecek.',
        ];
        return options[random.nextInt(options.length)];
      }
      if (temperature <= 18) {
        final options = [
          'İklim dengeli; kısa bir yürüyüş zihnini açabilir.',
          'İlkbahar tınısı var; ritüellerine hafif hareketler ekle.',
        ];
        return options[random.nextInt(options.length)];
      }
      final options = [
        'Hava sıcak; bol su iç ve hafif kumaşları seç.',
        'Sıcaklık yüksek; gölgeli alanlarda nefeslen.',
      ];
      return options[random.nextInt(options.length)];
    }
    if (temperature <= 5) {
      final options = [
        'It’s brisk; wrap yourself in layers of softness.',
        'The chill invites warm drinks and slower steps.',
      ];
      return options[random.nextInt(options.length)];
    }
    if (temperature <= 18) {
      final options = [
        'The air is tempered; a mindful walk will clear the mind.',
        'Mild weather—perfect for stretching rituals outdoors.',
      ];
      return options[random.nextInt(options.length)];
    }
    final options = [
      'Heat is lingering; hydrate and reach for breathable fabrics.',
      'Warmth surrounds you; seek shade and slow-paced rituals.',
    ];
    return options[random.nextInt(options.length)];
  }

  String _vibeTag({
    required String localeCode,
    required int code,
    required String dayKey,
    required String city,
  }) {
    final random = Random(_hashString('tag|$dayKey|$code|$city|$localeCode'));
    final tags = localeCode == 'tr'
        ? ['Aurora Akışı', 'Kadife Esinti', 'Lunar Fısıltı', 'Güneş Parıltısı']
        : ['Aurora Drift', 'Velvet Breeze', 'Lunar Whisper', 'Solar Glow'];
    return tags[random.nextInt(tags.length)];
  }

  String _iconFor(int code) {
    if (code == 0) return '☀️';
    if (code == 1 || code == 2) return '⛅️';
    if (code == 3) return '☁️';
    if (code == 45 || code == 48) return '🌫️';
    if (code == 51 || code == 61) return '🌦️';
    if (code == 63 || code == 65 || code == 80) return '🌧️';
    if (code == 71) return '❄️';
    return '✨';
  }
}
