import 'dart:convert';

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

  Future<WeatherReport?> fetchWeather({
    required String city,
    required double latitude,
    required double longitude,
    String localeCode = 'tr',
  }) async {
    final prefs = await _prefsFuture;
    final key = 'weather_${city.toLowerCase()}_${DateTime.now().toIso8601String().substring(0, 10)}';
    final cached = prefs.getString(key);
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
    final condition = _describe(code, localeCode);
    final icon = _iconFor(code);
    final report = WeatherReport(
      temperature: (current['temperature_2m'] as num?)?.toDouble() ?? 0,
      condition: condition,
      icon: icon,
      city: city,
      lastUpdated: DateTime.tryParse(current['time'] as String? ?? '') ?? DateTime.now(),
    );
    await prefs.setString(key, jsonEncode(report.toJson()));
    return report;
  }

  String _describe(int code, String locale) {
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
    return map[code] ?? (locale == 'tr' ? 'Kozmik hava' : 'Cosmic weather');
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
