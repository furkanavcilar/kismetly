import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class GreetingService {
  static const String _lastGreetingDateKey = 'last_greeting_date';
  static const String _dailyOpenCountKey = 'daily_open_count';

  /// Get time-aware greeting based on hour of day
  String getTimeAwareGreeting({
    required DateTime now,
    required String name,
    required String language,
  }) {
    final hour = now.hour;
    
    if (language == 'tr') {
      if (hour >= 5 && hour < 12) {
        return 'Günaydın, $name';
      } else if (hour >= 12 && hour < 17) {
        return 'Tünaydın, $name';
      } else if (hour >= 17 && hour < 22) {
        return 'İyi akşamlar, $name';
      } else {
        return 'İyi geceler, $name';
      }
    } else {
      if (hour >= 5 && hour < 12) {
        return 'Good morning, $name';
      } else if (hour >= 12 && hour < 17) {
        return 'Good afternoon, $name';
      } else if (hour >= 17 && hour < 22) {
        return 'Good evening, $name';
      } else {
        return 'Good night, $name';
      }
    }
  }

  /// Get greeting with visit frequency awareness
  Future<String> getGreeting({
    required DateTime now,
    required String name,
    required String language,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final todayKey = DateFormat('yyyy-MM-dd').format(now);
    final lastDate = prefs.getString(_lastGreetingDateKey);
    final openCount = prefs.getInt('${_dailyOpenCountKey}_$todayKey') ?? 0;

    // Update counters
    if (lastDate != todayKey) {
      // New day - reset
      await prefs.setString(_lastGreetingDateKey, todayKey);
      await prefs.setInt('${_dailyOpenCountKey}_$todayKey', 1);
    } else {
      // Same day - increment
      await prefs.setInt('${_dailyOpenCountKey}_$todayKey', openCount + 1);
    }

    // Use "welcome back" occasionally if user opens multiple times
    if (openCount > 0 && openCount % 3 == 0) {
      if (language == 'tr') {
        return 'Tekrar hoş geldin, $name';
      } else {
        return 'Welcome back, $name';
      }
    }

    // Otherwise use time-aware greeting
    return getTimeAwareGreeting(now: now, name: name, language: language);
  }
}

