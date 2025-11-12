import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../core/config/app_secrets.dart';
import '../models/daily_ai_insights.dart';

class AiContentService {
  AiContentService({http.Client? client, SharedPreferences? preferences})
      : _client = client ?? http.Client(),
        _prefsFuture = preferences != null
            ? Future.value(preferences)
            : SharedPreferences.getInstance();

  final http.Client _client;
  final Future<SharedPreferences> _prefsFuture;

  Future<DailyAiInsights> fetchDailyInsights({
    required String sunSign,
    required String risingSign,
    required Locale locale,
  }) async {
    final today = DateTime.now();
    final dayKey = '${today.year}-${today.month}-${today.day}';
    final prefs = await _prefsFuture;
    final cacheKey = 'ai_insight_${locale.languageCode}_${sunSign}_$dayKey';
    final cached = DailyAiInsights.tryParse(prefs.getString(cacheKey));
    if (cached != null) {
      return cached;
    }

    DailyAiInsights? insight;
    final apiKey = AppSecrets.openAiApiKey;
    if (apiKey != null && apiKey.isNotEmpty) {
      try {
        insight = await _fetchFromOpenAi(
          apiKey: apiKey,
          sunSign: sunSign,
          risingSign: risingSign,
          locale: locale,
        );
      } catch (e) {
        debugPrint('AI service fallback: $e');
      }
    }

    insight ??= _generateFallback(
      sunSign: sunSign,
      risingSign: risingSign,
      locale: locale,
    );

    await prefs.setString(cacheKey, jsonEncode(insight.toJson()));
    return insight;
  }

  Future<Map<String, String>> fetchCompatibility({
    required String firstSign,
    required String secondSign,
    required Locale locale,
  }) async {
    final today = DateTime.now();
    final dayKey = '${today.year}-${today.month}-${today.day}';
    final prefs = await _prefsFuture;
    final cacheKey =
        'ai_compat_${locale.languageCode}_${firstSign}_$secondSign_$dayKey';
    final cached = prefs.getString(cacheKey);
    if (cached != null) {
      try {
        final decoded = jsonDecode(cached) as Map<String, dynamic>;
        return decoded.map((key, value) => MapEntry('$key', '$value'));
      } catch (_) {
        // ignore
      }
    }

    Map<String, String>? response;
    final apiKey = AppSecrets.openAiApiKey;
    if (apiKey != null && apiKey.isNotEmpty) {
      try {
        response = await _fetchCompatibilityFromOpenAi(
          apiKey: apiKey,
          firstSign: firstSign,
          secondSign: secondSign,
          locale: locale,
        );
      } catch (e) {
        debugPrint('Compatibility fallback: $e');
      }
    }

    response ??= _generateCompatibilityFallback(
      firstSign: firstSign,
      secondSign: secondSign,
      locale: locale,
    );

    await prefs.setString(cacheKey, jsonEncode(response));
    return response;
  }

  Future<DailyAiInsights> _fetchFromOpenAi({
    required String apiKey,
    required String sunSign,
    required String risingSign,
    required Locale locale,
  }) async {
    final prompt = _dailyPrompt(
      sunSign: sunSign,
      risingSign: risingSign,
      locale: locale,
    );
    final response = await _client.post(
      Uri.parse('https://api.openai.com/v1/chat/completions'),
      headers: {
        'Authorization': 'Bearer $apiKey',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'model': 'gpt-4o-mini',
        'temperature': 1.05,
        'messages': [
          {
            'role': 'system',
            'content': locale.languageCode == 'tr'
                ? 'Sen duygusal zekası yüksek, modern Türkçe konuşan kozmik bir arkadaşsın.'
                : 'You are a poetic cosmic guide who speaks with warmth and emotional intelligence.',
          },
          {'role': 'user', 'content': prompt},
        ],
        'response_format': {'type': 'json_object'},
      }),
    );

    if (response.statusCode >= 400) {
      throw Exception('OpenAI error: ${response.statusCode}');
    }

    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    final content = decoded['choices']?[0]?['message']?['content'];
    if (content is! String) {
      throw const FormatException('Unexpected OpenAI response');
    }
    final parsed = jsonDecode(content) as Map<String, dynamic>;
    return DailyAiInsights.fromJson(parsed);
  }

  Future<Map<String, String>> _fetchCompatibilityFromOpenAi({
    required String apiKey,
    required String firstSign,
    required String secondSign,
    required Locale locale,
  }) async {
    final prompt = _compatibilityPrompt(
      firstSign: firstSign,
      secondSign: secondSign,
      locale: locale,
    );
    final response = await _client.post(
      Uri.parse('https://api.openai.com/v1/chat/completions'),
      headers: {
        'Authorization': 'Bearer $apiKey',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'model': 'gpt-4o-mini',
        'temperature': 1.1,
        'messages': [
          {
            'role': 'system',
            'content': locale.languageCode == 'tr'
                ? 'Türkçe konuşan empatik bir astroloji rehberisin.'
                : 'You are an empathic astrology storyteller.',
          },
          {'role': 'user', 'content': prompt},
        ],
        'response_format': {'type': 'json_object'},
      }),
    );

    if (response.statusCode >= 400) {
      throw Exception('OpenAI error: ${response.statusCode}');
    }

    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    final content = decoded['choices']?[0]?['message']?['content'];
    if (content is! String) {
      throw const FormatException('Unexpected OpenAI response');
    }
    final parsed = jsonDecode(content) as Map<String, dynamic>;
    return parsed.map((key, value) => MapEntry('$key', '$value'));
  }

  DailyAiInsights _generateFallback({
    required String sunSign,
    required String risingSign,
    required Locale locale,
  }) {
    final seedString =
        '${sunSign.toLowerCase()}-${risingSign.toLowerCase()}-${DateTime.now().toIso8601String().substring(0, 10)}-${locale.languageCode}';
    final seed = seedString.hashCode;
    final random = Random(seed);
    final tone = _tonePool(locale).elementAt(random.nextInt(_tonePool(locale).length));
    final summary = tone.replaceAll('{sun}', sunSign).replaceAll('{rise}', risingSign);

    final categories = <String>['love', 'career', 'spiritual', 'social'];
    final sections = <String, String>{};
    for (final key in categories) {
      sections[key] = _fallbackSection(
        locale: locale,
        random: random,
        key: key,
        sunSign: sunSign,
        risingSign: risingSign,
      );
    }

    final focus = {
      'love': _focusLine(locale, random, 'love'),
      'career': _focusLine(locale, random, 'career'),
      'spiritual': _focusLine(locale, random, 'spiritual'),
      'social': _focusLine(locale, random, 'social'),
    };

    final cosmicGuide = _cosmicGuide(locale, random, sunSign);

    return DailyAiInsights(
      summary: summary,
      energyFocus: focus,
      cosmicGuide: cosmicGuide,
      sections: sections,
      generatedAt: DateTime.now(),
    );
  }

  Map<String, String> _generateCompatibilityFallback({
    required String firstSign,
    required String secondSign,
    required Locale locale,
  }) {
    final seedString =
        '${firstSign.toLowerCase()}-${secondSign.toLowerCase()}-${DateTime.now().toIso8601String().substring(0, 10)}-${locale.languageCode}';
    final random = Random(seedString.hashCode);
    String template(String love, String growth, String action) {
      if (locale.languageCode == 'tr') {
        return '$love\n\n$growth\n\n$action';
      }
      return '$love\n\n$growth\n\n$action';
    }

    final love = locale.languageCode == 'tr'
        ? '${firstSign} ve ${secondSign} arasındaki çekim bugün belirgin.'
        : 'The pull between $firstSign and $secondSign hums loudly today.';
    final growth = locale.languageCode == 'tr'
        ? 'Birlikte büyümek için ${['cesur adımlar', 'sakin bir dinleme', 'ortak hayaller'][random.nextInt(3)]} gerekiyor.'
        : 'To grow together, lean into ${['bold honesty', 'soft listening', 'shared dreams'][random.nextInt(3)]}.';
    final action = locale.languageCode == 'tr'
        ? 'Küçük bir jest veya ortak ritüel enerjinizi hizalayacak.'
        : 'A tiny ritual or shared gesture will align your energies.';

    return {
      'love': template(love, growth, action),
      'family': locale.languageCode == 'tr'
          ? 'Aile dinamiklerinde açık sınırlar kurmak bugün sizi rahatlatacak.'
          : 'Clear boundaries in family spaces will soothe both of you today.',
      'career': locale.languageCode == 'tr'
          ? 'İş birliğinde rollerinizi bilmek ve birbirinizi yormamak ön planda.'
          : 'In shared responsibilities, honour the pace of each other to avoid burnout.',
      'summary': locale.languageCode == 'tr'
          ? '${firstSign} & ${secondSign} arasında dönüşen bir ritim var; yumuşak kalın.'
          : 'There is a transforming rhythm between $firstSign & $secondSign—stay tender.',
    };
  }

  Iterable<String> _tonePool(Locale locale) {
    if (locale.languageCode == 'tr') {
      return const [
        '{sun} burcunun ateşini {rise} yükseleni ile birlikte nazikçe yumuşat. Bugün sezgilerin konuşuyor.',
        'Gökyüzü senin adına fısıldıyor {sun}. {rise} yükselenin kalbini açık tutmanı istiyor.',
        'Bugün {sun} enerjin yeni yollar açarken, {rise} yükselenin sana şiir gibi rehberlik ediyor.',
      ];
    }
    return const [
      'Let your {sun} fire soften under the hush of your {rise} rising; intuition is steering.',
      'The cosmos is whispering for you, {sun}. Your {rise} rising asks you to hold your heart open.',
      'Today your {sun} energy opens new corridors while your {rise} rising narrates in quiet poetry.',
    ];
  }

  String _fallbackSection({
    required Locale locale,
    required Random random,
    required String key,
    required String sunSign,
    required String risingSign,
  }) {
    final phrases = locale.languageCode == 'tr'
        ? {
            'love': [
              '{sun} ruhunun romantik tarafı bugün {adjective} hissediyor; {rise} yükselenin ise iletişim kurmanı istiyor.',
              'Kalbinde {metaphor} var, {sun}. {rise} yükselenin sana nazikçe dengeni hatırlatıyor.',
            ],
            'career': [
              '{sun} sezgilerin iş hayatında {adjective} kapılar açıyor; {rise} yükselenin sana sabırla nefes aldırıyor.',
              'Planların çok katmanlı; {rise} yükselenin detayları görmeni sağlıyor.',
            ],
            'spiritual': [
              'Ritüellerine yeni bir nefes getir, {sun}. {rise} yükselenin sana {metaphor} gibi eşlik ediyor.',
              'Sessiz kal ve kalbini dinle; kozmik rüzgar {adjective} bir şarkı çalıyor.',
            ],
            'social': [
              'Yakın çevrende sıcaklık yay; {rise} yükselenin seni {metaphor} gibi parlatıyor.',
              '{sun} enerjin bir arada olmayı özlüyor, nazikçe davet et.',
            ],
          }
        : {
            'love': [
              'Your {sun} heart feels {adjective} today, while your {rise} rising nudges you to speak softly.',
              'There is {metaphor} in your chest, {sun}. Your {rise} rising reminds you to stay balanced.',
            ],
            'career': [
              '{sun} instincts open {adjective} doors at work; your {rise} rising lets you pause and breathe.',
              'Your plans are layered; {rise} rising helps you notice the tiny threads.',
            ],
            'spiritual': [
              'Breathe new air into your rituals. Your {rise} rising sits beside you like {metaphor}.',
              'Be still and listen; the cosmic wind hums a {adjective} song for you.',
            ],
            'social': [
              'Share your warmth today; your {rise} rising lets you glow like {metaphor}.',
              'Your {sun} energy craves connection—invite softly and see who appears.',
            ],
          };

    final adjectives = locale.languageCode == 'tr'
        ? ['pembemsi', 'yumuşacık', 'saklı', 'ışıklı']
        : ['honeyed', 'luminous', 'gentle', 'hidden'];
    final metaphors = locale.languageCode == 'tr'
        ? ['okyanus kıyısında dalga', 'kadife bir gölge', 'fısıldayan rüzgar']
        : ['a tide on the shore', 'a velvet shadow', 'a whispering wind'];
    final templateList = phrases[key] ?? phrases['love']!;
    final template = templateList[random.nextInt(templateList.length)];
    return template
        .replaceAll('{sun}', sunSign)
        .replaceAll('{rise}', risingSign)
        .replaceAll('{adjective}', adjectives[random.nextInt(adjectives.length)])
        .replaceAll('{metaphor}', metaphors[random.nextInt(metaphors.length)]);
  }

  String _focusLine(Locale locale, Random random, String key) {
    final values = locale.languageCode == 'tr'
        ? {
            'love': ['Nazik sohbet', 'Açık kalp', 'Şefkatli bakış'],
            'career': ['Net plan', 'İlham arası', 'Sessiz odak'],
            'spiritual': ['Derin nefes', 'Gölge çalışması', 'Kutsal dinlenme'],
            'social': ['Yumuşak paylaşım', 'Şeffaf sınır', 'Mutlu buluşma'],
          }
        : {
            'love': ['Tender dialogue', 'Open heart', 'Compassionate gaze'],
            'career': ['Clear plan', 'Spark pause', 'Quiet focus'],
            'spiritual': ['Deep breath', 'Shadow work', 'Sacred rest'],
            'social': ['Soft sharing', 'Transparent boundary', 'Joyful gathering'],
          };
    final list = values[key] ?? values['love']!;
    return list[random.nextInt(list.length)];
  }

  String _cosmicGuide(Locale locale, Random random, String sunSign) {
    final list = locale.languageCode == 'tr'
        ? [
            '$sunSign, gökyüzü bugün seni nazikçe ileri çağırıyor.',
            'Ruhunun melodisini duy ve onunla birlikte yürü.',
            'Bugünün rehberi: kalbinden akan şiire kulak ver.',
          ]
        : [
            '$sunSign, the sky is softly nudging you forward today.',
            'Hear the melody of your spirit and walk beside it.',
            'Today\'s guide: listen to the poem spilling from your chest.',
          ];
    return list[random.nextInt(list.length)];
  }

  String _dailyPrompt({
    required String sunSign,
    required String risingSign,
    required Locale locale,
  }) {
    if (locale.languageCode == 'tr') {
      return 'Lütfen JSON döndür: {"summary":string,"energyFocus":{love,career,spiritual,social},"cosmicGuide":string,"sections":{love,career,spiritual,social}}. ' \
          'Ton: samimi, şiirsel. Türkçe konuş. Girdi: Güneş burcu $sunSign, yükselen $risingSign. Her kategori için benzersiz, duygusal cümleler yaz.';
    }
    return 'Return JSON: {"summary":string,"energyFocus":{love,career,spiritual,social},"cosmicGuide":string,"sections":{love,career,spiritual,social}}. ' \
        'Tone: intimate, poetic. Language: English. Input: Sun sign $sunSign, rising $risingSign. Provide unique emotional sentences for each category.';
  }

  String _compatibilityPrompt({
    required String firstSign,
    required String secondSign,
    required Locale locale,
  }) {
    if (locale.languageCode == 'tr') {
      return 'JSON döndür: {"summary":string,"love":string,"family":string,"career":string}. ' \
          '$firstSign ve $secondSign burçlarının bugünkü enerjisini şiirsel ve duygusal anlat. Türkçe yaz.';
    }
    return 'Return JSON: {"summary":string,"love":string,"family":string,"career":string}. ' \
        'Describe today\'s energy between $firstSign and $secondSign with poetic emotional tone in English.';
  }
}
