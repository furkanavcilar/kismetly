import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:shared_preferences/shared_preferences.dart';
import 'ai_content_service.dart';
import '../features/profile/user_profile_storage.dart';
import '../data/zodiac_signs.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;
    
    tz.initializeTimeZones();
    
    // Request permissions for Android 13+
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );
    
    // Request Android 13+ notification permission
    final androidImplementation = _notifications.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    if (androidImplementation != null) {
      androidImplementation.requestNotificationsPermission();
    }
    
    _initialized = true;
  }

  void _onNotificationTapped(NotificationResponse response) {
    // Handle notification tap - could navigate to specific screen
    debugPrint('Notification tapped: ${response.payload}');
  }

  Future<void> scheduleDailyHoroscope() async {
    await initialize();
    
    final prefs = await SharedPreferences.getInstance();
    final enabled = prefs.getBool('notifications_daily_horoscope') ?? true;
    if (!enabled) {
      await cancelDailyHoroscope();
      return;
    }

    try {
      final localeStr = prefs.getString('app_locale') ?? 'tr';
      final locale = Locale(localeStr);
      
      // Schedule for 9:00 AM local time
      final notificationText = await _getDailyHoroscopeText();
      await _notifications.zonedSchedule(
        1,
        locale.languageCode == 'tr' ? 'Günlük Horoskop' : 'Daily Horoscope',
        notificationText,
        _nextInstanceOfTime(9, 0),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'daily_horoscope',
            'Daily Horoscope',
            channelDescription: 'Daily horoscope notifications',
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    } catch (e) {
      debugPrint('Error scheduling daily horoscope: $e');
    }
  }

  Future<void> scheduleNightlyMotivation() async {
    await initialize();
    
    final prefs = await SharedPreferences.getInstance();
    final enabled = prefs.getBool('notifications_nightly_motivation') ?? true;
    if (!enabled) {
      await cancelNightlyMotivation();
      return;
    }

    try {
      final localeStr = prefs.getString('app_locale') ?? 'tr';
      final locale = Locale(localeStr);
      
      // Schedule for 22:30 (10:30 PM) local time
      final notificationText = await _getNightlyMotivationText();
      final title = locale.languageCode == 'tr' ? 'Akşam Rehberliği' : 'Nightly Guidance';
      
      await _notifications.zonedSchedule(
        2,
        title,
        notificationText,
        _nextInstanceOfTime(22, 30),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'nightly_motivation',
            'Nightly Motivation',
            channelDescription: 'Nightly motivation notifications',
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );
      
      // Mark as scheduled for today
      final todayKey = DateTime.now().toIso8601String().split('T')[0];
      await prefs.setString('last_nightly_motivation_date', todayKey);
    } catch (e) {
      debugPrint('Error scheduling nightly motivation: $e');
    }
  }

  Future<void> cancelDailyHoroscope() async {
    await _notifications.cancel(1);
  }

  Future<void> cancelNightlyMotivation() async {
    await _notifications.cancel(2);
  }

  tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }

  Future<String> _getDailyHoroscopeText() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final localeStr = prefs.getString('app_locale') ?? 'tr';
      final locale = Locale(localeStr);
      
      // Get user's sign from profile
      final storage = UserProfileStorage(prefs);
      final profile = storage.load();
      
      if (profile?.sunSign != null) {
        final sign = findZodiacById(profile!.sunSign!);
        if (sign != null) {
          final signLabel = sign.labelFor(locale.languageCode);
          
          // Fetch horoscope from AI service
          final aiService = AiContentService();
          final horoscope = await aiService.fetchDailyHoroscope(
            sign: signLabel,
            locale: locale,
            date: DateTime.now(),
            forceRefresh: false, // Can use cache for notifications
          );
          
          // Extract first 1-2 sentences for notification (keep it short)
          final sentences = horoscope.split(RegExp(r'[.!?]\s+'));
          if (sentences.isNotEmpty) {
            final preview = sentences.take(2).join('. ');
            // Limit to 120 characters for notification
            if (preview.length > 120) {
              return '${preview.substring(0, 117)}...';
            }
            return preview;
          }
        }
      }
    } catch (e) {
      debugPrint('Error getting horoscope text: $e');
    }
    // Fallback
    final localeStr = (await SharedPreferences.getInstance()).getString('app_locale') ?? 'tr';
    return localeStr == 'tr' 
        ? 'Günlük kozmik rehberliğin hazır.'
        : 'Your daily cosmic guidance is ready.';
  }

  Future<String> _getNightlyMotivationText() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final localeStr = prefs.getString('app_locale') ?? 'tr';
      final locale = Locale(localeStr);
      
      // Generate a short motivation message via AI
      final aiService = AiContentService();
      final today = DateTime.now();
      
      // Use horoscope generation as base, but with motivation focus
      final profile = UserProfileStorage(prefs).load();
      if (profile?.sunSign != null) {
        final sign = findZodiacById(profile!.sunSign!);
        if (sign != null) {
          final signLabel = sign.labelFor(locale.languageCode);
          // Get a short horoscope and extract motivation from it
          final horoscope = await aiService.fetchDailyHoroscope(
            sign: signLabel,
            locale: locale,
            date: today,
            forceRefresh: false,
          );
          
          // Extract a comforting sentence from the horoscope
          final sentences = horoscope.split(RegExp(r'[.!?]\s+'));
          if (sentences.isNotEmpty) {
            // Pick a sentence that sounds motivational (prefer later sentences)
            final motivationalSentence = sentences.length > 2 
                ? sentences[sentences.length - 2] 
                : sentences.last;
            if (motivationalSentence.length <= 120) {
              return motivationalSentence;
            }
            return '${motivationalSentence.substring(0, 117)}...';
          }
        }
      }
      
      // Fallback
      return locale.languageCode == 'tr'
          ? 'Bugünün kozmik enerjilerini düşün ve yarın için umutla uyu.'
          : 'Reflect on today\'s cosmic energies and sleep with hope for tomorrow.';
    } catch (e) {
      debugPrint('Error getting nightly motivation: $e');
    }
    final localeStr = (await SharedPreferences.getInstance()).getString('app_locale') ?? 'tr';
    return localeStr == 'tr'
        ? 'Bugünün kozmik enerjilerini düşün.'
        : 'Take a moment to reflect on today\'s cosmic energies.';
  }
}

