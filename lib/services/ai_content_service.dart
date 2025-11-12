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

  int _dailySeed({
    required String sunSign,
    required String risingSign,
    required Locale locale,
    required String dayKey,
    int? variant,
  }) {
    final base =
        '$dayKey|${locale.languageCode}|${sunSign.toLowerCase()}|${risingSign.toLowerCase()}';
    final salt = variant != null ? '$base|$variant' : base;
    return _hashString(salt);
  }

  int _compatibilitySeed({
    required String firstSign,
    required String secondSign,
    required Locale locale,
    required String dayKey,
    int? variant,
  }) {
    final base =
        '$dayKey|${locale.languageCode}|${firstSign.toLowerCase()}|${secondSign.toLowerCase()}';
    final salt = variant != null ? '$base|$variant' : base;
    return _hashString(salt);
  }

  Future<DailyAiInsights> fetchDailyInsights({
    required String sunSign,
    required String risingSign,
    required Locale locale,
    bool forceRefresh = false,
  }) async {
    final today = DateTime.now();
    final dayKey = _dayStamp(today);
    final prefs = await _prefsFuture;
    final cacheKey =
        'ai_insight_${locale.languageCode}_${sunSign}_$risingSign_$dayKey';
    final cached = DailyAiInsights.tryParse(prefs.getString(cacheKey));
    if (cached != null && !forceRefresh) {
      return cached;
    }

    DailyAiInsights? insight;
    final apiKey = AppSecrets.openAiApiKey;
    final dailySeed = _dailySeed(
      sunSign: sunSign,
      risingSign: risingSign,
      locale: locale,
      dayKey: dayKey,
      variant: forceRefresh ? DateTime.now().microsecondsSinceEpoch : null,
    );
    if (apiKey != null && apiKey.isNotEmpty) {
      try {
        insight = await _fetchFromOpenAi(
          apiKey: apiKey,
          sunSign: sunSign,
          risingSign: risingSign,
          locale: locale,
          seed: dailySeed,
        );
      } catch (e) {
        debugPrint('AI service fallback: $e');
      }
    }

    insight ??= _generateFallback(
      sunSign: sunSign,
      risingSign: risingSign,
      locale: locale,
      seed: dailySeed,
    );

    await prefs.setString(cacheKey, jsonEncode(insight.toJson()));
    return insight;
  }

  Future<Map<String, String>> fetchCompatibility({
    required String firstSign,
    required String secondSign,
    required Locale locale,
    bool forceRefresh = false,
  }) async {
    final today = DateTime.now();
    final dayKey = _dayStamp(today);
    final prefs = await _prefsFuture;
    final cacheKey =
        'ai_compat_${locale.languageCode}_${firstSign}_$secondSign_$dayKey';
    final cached = prefs.getString(cacheKey);
    if (cached != null && !forceRefresh) {
      try {
        final decoded = jsonDecode(cached) as Map<String, dynamic>;
        return decoded.map((key, value) => MapEntry('$key', '$value'));
      } catch (_) {
        // ignore invalid cache
      }
    }

    Map<String, String>? response;
    final apiKey = AppSecrets.openAiApiKey;
    final compatSeed = _compatibilitySeed(
      firstSign: firstSign,
      secondSign: secondSign,
      locale: locale,
      dayKey: dayKey,
      variant: forceRefresh ? DateTime.now().microsecondsSinceEpoch : null,
    );
    if (apiKey != null && apiKey.isNotEmpty) {
      try {
        response = await _fetchCompatibilityFromOpenAi(
          apiKey: apiKey,
          firstSign: firstSign,
          secondSign: secondSign,
          locale: locale,
          seed: compatSeed,
        );
      } catch (e) {
        debugPrint('Compatibility fallback: $e');
      }
    }

    response ??= _generateCompatibilityFallback(
      firstSign: firstSign,
      secondSign: secondSign,
      locale: locale,
      seed: compatSeed,
    );

    await prefs.setString(cacheKey, jsonEncode(response));
    return response;
  }

  Future<DailyAiInsights> _fetchFromOpenAi({
    required String apiKey,
    required String sunSign,
    required String risingSign,
    required Locale locale,
    required int seed,
  }) async {
    final prompt = _dailyPrompt(
      sunSign: sunSign,
      risingSign: risingSign,
      locale: locale,
      seed: seed,
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
    required int seed,
  }) async {
    final prompt = _compatibilityPrompt(
      firstSign: firstSign,
      secondSign: secondSign,
      locale: locale,
      seed: seed,
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
    required int seed,
  }) {
    final styleLine = _styleSentence(
      locale: locale,
      sunSign: sunSign,
      risingSign: risingSign,
      seed: seed,
    );
    final summary = _summaryLine(
      locale: locale,
      sunSign: sunSign,
      risingSign: risingSign,
      seed: seed,
      base: styleLine,
    );

    final categories = <String>['love', 'career', 'spiritual', 'social'];
    final sections = <String, String>{
      for (final key in categories)
        key: _fallbackSection(
          locale: locale,
          seed: seed,
          key: key,
          sunSign: sunSign,
          risingSign: risingSign,
        ),
    };

    final focus = <String, String>{
      for (final key in categories) key: _focusLine(locale, seed, key),
    };

    final cosmicGuide = _cosmicGuide(
      locale: locale,
      seed: seed,
      sunSign: sunSign,
    );

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
    required int seed,
  }) {
    final summary = _compatibilityStyle(
      locale: locale,
      firstSign: firstSign,
      secondSign: secondSign,
      seed: seed,
    );
    return {
      'summary': summary,
      'love': _compatibilitySection(
        locale: locale,
        firstSign: firstSign,
        secondSign: secondSign,
        seed: seed,
        key: 'love',
      ),
      'family': _compatibilitySection(
        locale: locale,
        firstSign: firstSign,
        secondSign: secondSign,
        seed: seed,
        key: 'family',
      ),
      'career': _compatibilitySection(
        locale: locale,
        firstSign: firstSign,
        secondSign: secondSign,
        seed: seed,
        key: 'career',
      ),
    };
  }

  String _summaryLine({
    required Locale locale,
    required String sunSign,
    required String risingSign,
    required int seed,
    required String base,
  }) {
    final random = Random(seed ^ 0x9e37);
    final suffixes = locale.languageCode == 'tr'
        ? [
            '{sun}, kozmik hava senin tarafında; ritmini kalbinden ayarla.',
            'Bugün adımların şiirsel, sezgilerine güven.',
            'Gökyüzü sana yumuşak ama kararlı bir kapı açıyor.',
          ]
        : [
            '{sun}, the cosmos leans in your favour—move with the tempo of your heart.',
            'Your steps read like poetry today; trust the quiet instincts.',
            'The sky opens a soft yet certain door for you.',
          ];
    final suffix = suffixes[random.nextInt(suffixes.length)];
    return '${base.trim()} ${_fillTemplate(suffix, {
      'sun': sunSign,
      'rise': risingSign,
    })}'.trim();
  }

  String _styleSentence({
    required Locale locale,
    required String sunSign,
    required String risingSign,
    required int seed,
  }) {
    final random = Random(seed ^ 0x4d593);
    if (locale.languageCode == 'tr') {
      final textures = [
        'loş şiirli bir ışık',
        'ipeksi bir titreşim',
        'ufukta dalgalanan zarif bir melodi',
        'sabaha yayılan kozmik bir sis',
      ];
      final moods = [
        'şefkatli cesaret',
        'içsel neşe',
        'dingin merhamet',
        'oyuncu bir zarafet',
      ];
      final motions = [
        'nazikçe genişliyor',
        'kalbine dönüyor',
        'yeni diyaloğa akıyor',
        'günün ritmini belirliyor',
      ];
      final texture = textures[random.nextInt(textures.length)];
      final mood = moods[random.nextInt(moods.length)];
      final motion = motions[random.nextInt(motions.length)];
      return '$sunSign Güneşin ile $risingSign yükseleninin enerjisi bugün $texture içinde $mood ile $motion.';
    }
    final textures = [
      'a hush of twilight poetry',
      'a silken pulse of dawn',
      'a gentle aurora of intuition',
      'a slow-burning meteor glow',
    ];
    final moods = [
      'tender courage',
      'magnetic curiosity',
      'hushed optimism',
      'buoyant stillness',
    ];
    final motions = [
      'expands in quiet waves',
      'spirals back toward your chest',
      'reaches for meaningful dialogue',
      'conducts today’s rhythm',
    ];
    final texture = textures[random.nextInt(textures.length)];
    final mood = moods[random.nextInt(moods.length)];
    final motion = motions[random.nextInt(motions.length)];
    return 'Your $sunSign sun and $risingSign rising move through $texture, carrying $mood as it $motion.';
  }

  String _fallbackSection({
    required Locale locale,
    required int seed,
    required String key,
    required String sunSign,
    required String risingSign,
  }) {
    final random = Random(seed ^ _hashString(key));
    final texturePool = locale.languageCode == 'tr'
        ? ['kadife bir rüzgar', 'deniz köpüğü', 'geceyi parlatan buğu', 'gümüşi ay ışığı']
        : ['velvet wind', 'seafoam shimmer', 'moonlit mist', 'silver dawn'];
    final gesturePool = locale.languageCode == 'tr'
        ? ['yumuşak bir bakış', 'içten bir dokunuş', 'derin bir nefes', 'nazik bir kahkaha']
        : ['a soft glance', 'an earnest touch', 'a deep inhale', 'a gentle laugh'];
    final closingPool = locale.languageCode == 'tr'
        ? [
            'Kalbine uyan küçük bir ritüel seç ve gün boyunca ona tutun.',
            'Bugün paylaşacağın her kelime yeni bir köprü kuracak.',
            'Ritmini sezgilerinle ayarladığında evren yanıt verecek.',
          ]
        : [
            'Choose a tiny ritual and let it anchor you all day.',
            'Every word you share today builds another bridge.',
            'Tune your rhythm to intuition and the universe replies.',
          ];
    final texture = texturePool[random.nextInt(texturePool.length)];
    final gesture = gesturePool[random.nextInt(gesturePool.length)];
    final closing = closingPool[random.nextInt(closingPool.length)];
    final replacements = {
      'sun': sunSign,
      'rise': risingSign,
      'texture': texture,
      'gesture': gesture,
    };

    Map<String, List<String>> openings;
    Map<String, List<String>> developments;
    if (locale.languageCode == 'tr') {
      openings = {
        'love': [
          '{sun} kalbin bugün {texture} gibi dalgalanıyor.',
          '{rise} yükselenin romantik alanları ışıkla dolduruyor.',
        ],
        'career': [
          '{sun} enerjin iş planlarını şiir gibi düzenliyor.',
          'Günün görevi için {rise} yükselenin berrak yollar çiziyor.',
        ],
        'spiritual': [
          'Ruhsal alanında {sun} sezgisi fısıltıyla konuşuyor.',
          '{rise} yükselenin içsel ritüeller için sakin bir sahne açıyor.',
        ],
        'social': [
          '{sun} ışığın çevrendekileri ısıtıyor.',
          '{rise} yükselenin sohbetleri narin bir dokuyla bağlıyor.',
        ],
      };
      developments = {
        'love': [
          'Nazikçe {gesture} paylaş ve hislerini dürüstçe anlat.',
          'Duygularını saklamadan, küçük jestlerle güvenli alan yarat.',
        ],
        'career': [
          'Planlarını küçük adımlara böl ve aralara sessiz nefesler yerleştir.',
          'Toplantılarına arkadaş sohbeti sıcaklığı kat.',
        ],
        'spiritual': [
          'Meditasyonuna tatlı bir soru ekle: bugün kalbim neye hazır?',
          'Ritüellerini duyusal bir detayla süsle; mum, koku veya melodi.',
        ],
        'social': [
          'Yakınlarına içten bir mesaj gönder ve ortak bir anı hatırla.',
          'Davetlerini yumuşakça yap; samimiyet enerjiyi dengeler.',
        ],
      };
    } else {
      openings = {
        'love': [
          'Your {sun} heart ripples like {texture}.',
          'The {rise} rising lights up romantic corners with warmth.',
        ],
        'career': [
          'Your {sun} drive arranges projects like gentle constellations.',
          'The {rise} rising sketches clear pathways for today’s work.',
        ],
        'spiritual': [
          'Your {sun} intuition hums softly in sacred space.',
          '{rise} rising opens a calm stage for ritual.',
        ],
        'social': [
          'Your {sun} glow becomes a hearth for your circle.',
          '{rise} rising threads conversations with delicate texture.',
        ],
      };
      developments = {
        'love': [
          'Share {gesture} and speak with steady honesty.',
          'Let tiny gestures craft a refuge where feelings can stretch.',
        ],
        'career': [
          'Break the workload into tender steps and breathe between them.',
          'Shape meetings with the warmth of a trusted dialogue.',
        ],
        'spiritual': [
          'Add a sensory detail to your ritual—candle, scent, or melody.',
          'Ask softly what your spirit is ready to receive today.',
        ],
        'social': [
          'Send a heartfelt note and revive a shared memory.',
          'Invite others gently; sincerity softens every gathering.',
        ],
      };
    }

    final openerList = openings[key] ?? openings['love']!;
    final developList = developments[key] ?? developments['love']!;
    final opener = openerList[random.nextInt(openerList.length)];
    final develop = developList[random.nextInt(developList.length)];
    final filledClosing = _fillTemplate(closing, replacements);
    return '${_fillTemplate(opener, replacements)} ${_fillTemplate(develop, replacements)} $filledClosing';
  }

  String _focusLine(Locale locale, int seed, String key) {
    final random = Random(seed ^ _hashString('focus_$key'));
    final values = locale.languageCode == 'tr'
        ? {
            'love': ['Şefkatli ritüel', 'Yumuşak yüzleşme', 'Kalpten paylaşım', 'Derin dinleme'],
            'career': ['Odaklı plan', 'İlham molası', 'Nazik liderlik', 'Zaman bloklama'],
            'spiritual': ['Niyet nefesi', 'Kutsal alan', 'Gölge sohbeti', 'Sessiz yürüyüş'],
            'social': ['Samimi mesaj', 'Şeffaf sınır', 'Mutlu buluşma', 'Şükran notu'],
          }
        : {
            'love': ['Devoted ritual', 'Soft truth-telling', 'Heartfelt sharing', 'Deep listening'],
            'career': ['Focused blueprint', 'Inspiration break', 'Gentle leadership', 'Time anchoring'],
            'spiritual': ['Breath with intention', 'Sacred nook', 'Shadow dialogue', 'Silent wandering'],
            'social': ['Candid message', 'Transparent boundary', 'Joyful meet-up', 'Gratitude note'],
          };
    final list = values[key] ?? values['love']!;
    return list[random.nextInt(list.length)];
  }

  String _cosmicGuide({
    required Locale locale,
    required int seed,
    required String sunSign,
  }) {
    final random = Random(seed ^ 0x51f7);
    final list = locale.languageCode == 'tr'
        ? [
            '$sunSign, gökyüzü bugün niyetlerini şiir gibi yazmanı istiyor.',
            'Bugünün rehberi: kalbinden taşan melodiyi paylaş.',
            '$sunSign ışığını minik adımlarla da olsa dünyaya yay.',
            'Evren kulağına “yavaşla ve hisset” diye fısıldıyor.',
          ]
        : [
            '$sunSign, the stars want your intentions written like a poem.',
            'Today’s guide: share the melody spilling from your chest.',
            'Let your $sunSign light seep into the world, even in tiny steps.',
            'The cosmos whispers: slow down and feel everything.',
          ];
    return list[random.nextInt(list.length)];
  }

  String _compatibilityStyle({
    required Locale locale,
    required String firstSign,
    required String secondSign,
    required int seed,
  }) {
    final random = Random(seed ^ 0x81bd);
    final bridges = locale.languageCode == 'tr'
        ? [
            'aynı şiirin iki kıtası',
            'aynı dalganın farklı kıyıları',
            'zıt ama uyumlu iki ritim',
            'gizli bir kozmik diyalog',
          ]
        : [
            'two verses of the same poem',
            'different shores of the same tide',
            'contrasting yet aligned rhythms',
            'a secret cosmic dialogue',
          ];
    final invitation = locale.languageCode == 'tr'
        ? ['nazik açıklık', 'oyuncu merhamet', 'duygusal cesaret', 'samimi ritüeller']
        : ['tender openness', 'playful mercy', 'emotional courage', 'honest rituals'];
    final bridge = bridges[random.nextInt(bridges.length)];
    final invite = invitation[random.nextInt(invitation.length)];
    if (locale.languageCode == 'tr') {
      return '$firstSign ve $secondSign arasında $bridge var; enerji $invite ile güçleniyor.';
    }
    return '$firstSign and $secondSign meet as $bridge; their energy thrives on $invite.';
  }

  String _compatibilitySection({
    required Locale locale,
    required String firstSign,
    required String secondSign,
    required int seed,
    required String key,
  }) {
    final random = Random(seed ^ _hashString('compat_$key'));
    final metaphorPool = locale.languageCode == 'tr'
        ? ['kıvılcımlı bir kamp ateşi', 'sessiz bir deniz feneri', 'şafakta uyanan bir şehir', 'gümüşi bir nehir']
        : ['a crackling campfire', 'a silent lighthouse', 'a city waking at dawn', 'a silver river'];
    final gesturePool = locale.languageCode == 'tr'
        ? ['ortak bir günlük', 'yumuşak dokunuşlar', 'beklenmedik kahkahalar', 'paylaşılan nefes egzersizleri']
        : ['shared journaling', 'soft touches', 'surprise laughter', 'synchronized breathing'];
    final actionPool = locale.languageCode == 'tr'
        ? ['küçük bir ritüel planlayın', 'günün sonunda dürüstçe konuşun', 'birlikte yaratıcı bir şey deneyin', 'birbirinize minnet notu bırakın']
        : ['plan a tiny ritual', 'hold an honest end-of-day check-in', 'co-create something playful', 'leave each other a gratitude note'];
    final metaphor = metaphorPool[random.nextInt(metaphorPool.length)];
    final gesture = gesturePool[random.nextInt(gesturePool.length)];
    final action = actionPool[random.nextInt(actionPool.length)];
    final replacements = {
      'first': firstSign,
      'second': secondSign,
      'metaphor': metaphor,
      'gesture': gesture,
      'action': action,
    };

    Map<String, List<String>> frames;
    Map<String, List<String>> closings;
    if (locale.languageCode == 'tr') {
      frames = {
        'love': [
          '{first} ve {second} kalpleri {metaphor} gibi kıvılcımlanıyor.',
          'Aranızdaki çekim {metaphor} sıcaklığında titreşiyor.',
        ],
        'family': [
          'Aile alanında enerjiniz {metaphor} kadar sabırlı.',
          '{first} yapısı ile {second} duygusu ailede nazik bir denge kuruyor.',
        ],
        'career': [
          'Ortak projeleriniz {metaphor} gibi akıyor.',
          'İş birliğiniz {metaphor} huzurunda kıvam buluyor.',
        ],
      };
      closings = {
        'love': [
          '{gesture} paylaşın ve {action}; kalpleriniz uyumlanacak.',
          'Bugün {action} ve sevginizi hafifçe dile getirin.',
        ],
        'family': [
          'Sınırlarınızı {gesture} ile ifade edin ve {action}.',
          'Aile içinde {action}; sıcaklık sizinle olacak.',
        ],
        'career': [
          'Rolleri netleştirip {action}; üretkenlik şefkatle artacak.',
          'Temponuzu {gesture} kadar yumuşatın ve {action}.',
        ],
      };
    } else {
      frames = {
        'love': [
          '{first} and {second} hearts glow like {metaphor}.',
          'Between {first} and {second} a hush like {metaphor} forms.',
        ],
        'family': [
          'In family spaces you stand like {metaphor}.',
          '{first} brings structure while {second} offers tide-like empathy.',
        ],
        'career': [
          'Working together feels like {metaphor}.',
          'Your collaboration drifts like {metaphor}, steady and present.',
        ],
      };
      closings = {
        'love': [
          'Share {gesture} and {action}; your bond will soften beautifully.',
          'Today, {action} and keep tenderness near.',
        ],
        'family': [
          'State boundaries with {gesture} and {action} for balance.',
          'Let {gesture} guide the household and {action} at day’s end.',
        ],
        'career': [
          'Trade leadership gently, {gesture}, and {action}.',
          'Lean on {gesture} and {action} to align your shared pace.',
        ],
      };
    }

    final frameList = frames[key] ?? frames['love']!;
    final closingList = closings[key] ?? closings['love']!;
    final frame = frameList[random.nextInt(frameList.length)];
    final closing = closingList[random.nextInt(closingList.length)];
    return '${_fillTemplate(frame, replacements)} ${_fillTemplate(closing, replacements)}';
  }

  List<String> _dailyInstructionLines({
    required Locale locale,
    required int seed,
    required String sunSign,
    required String risingSign,
  }) {
    final random = Random(seed ^ 0x2f9b);
    Map<String, List<String>> instructions;
    if (locale.languageCode == 'tr') {
      instructions = {
        'love': [
          'Aşk: {sun} duygusuna sıcak bir metafor ekle, {rise} yükseleninle iletişim cesaretini hatırlat.',
          'Aşk: ortak ritüeller ve güvenli alan vurgusu yap.',
        ],
        'career': [
          'Kariyer: {sun} kararlılığına nazik bir mola önerisi ekle.',
          'Kariyer: net plan ve sezgisel küçük ayarlardan bahset.',
        ],
        'spiritual': [
          'Ruhsal: gündelik ritüelleri duyusal detaylarla zenginleştir.',
          'Ruhsal: nefes, meditasyon veya yazı ritüelini davet et.',
        ],
        'social': [
          'Sosyal: şeffaf sınır ve yumuşak davetler öner.',
          'Sosyal: toplulukla paylaşılacak bir minnet veya yaratıcı fikir ekle.',
        ],
      };
    } else {
      instructions = {
        'love': [
          'Love: weave in a sensory metaphor and encourage safe vulnerability for {sun} and {rise}.',
          'Love: highlight shared rituals and honest check-ins.',
        ],
        'career': [
          'Career: pair {sun} drive with moments of mindful pausing.',
          'Career: suggest a clear blueprint plus intuitive adjustments.',
        ],
        'spiritual': [
          'Spiritual: enrich rituals with texture—sound, scent, or touch.',
          'Spiritual: invite breathing practices or reflective journaling.',
        ],
        'social': [
          'Social: encourage transparent boundaries and soft invitations.',
          'Social: offer a gratitude message or creative gathering idea.',
        ],
      };
    }

    final replacements = {
      'sun': sunSign,
      'rise': risingSign,
    };
    final loveList = instructions['love']!;
    final careerList = instructions['career']!;
    final spiritualList = instructions['spiritual']!;
    final socialList = instructions['social']!;
    return [
      _fillTemplate(loveList[random.nextInt(loveList.length)], replacements),
      _fillTemplate(careerList[random.nextInt(careerList.length)], replacements),
      _fillTemplate(spiritualList[random.nextInt(spiritualList.length)], replacements),
      _fillTemplate(socialList[random.nextInt(socialList.length)], replacements),
    ];
  }

  List<String> _compatibilityInstructionLines({
    required Locale locale,
    required int seed,
    required String firstSign,
    required String secondSign,
  }) {
    final random = Random(seed ^ 0x77d1);
    final base = locale.languageCode == 'tr'
        ? [
            'Aşk bölümünde duyusal bir detay ve ortak ritüel öner.',
            'Aile bölümünde sınır ve empatik iletişimi vurgula.',
            'Kariyer bölümünde tempo ayarı ve ortak hedeflerden söz et.',
            'Özet satırında {first} & {second} enerjisinin duygusal tonunu belirt.',
          ]
        : [
            'In love, include a sensory detail plus a shared ritual suggestion.',
            'For family, emphasise boundaries with empathic dialogue.',
            'For career, speak about pacing and collaborative goals.',
            'In the summary, name the emotional tone between {first} & {second}.',
          ];
    final replacements = {
      'first': firstSign,
      'second': secondSign,
    };
    base.shuffle(random);
    return base.map((note) => _fillTemplate(note, replacements)).toList();
  }

  String _variationToken(Locale locale, int seed) {
    final code = seed.abs().toRadixString(16).padLeft(8, '0').substring(0, 8).toUpperCase();
    return locale.languageCode == 'tr' ? 'varyasyon-$code' : 'variation-$code';
  }

  String _dailyPrompt({
    required String sunSign,
    required String risingSign,
    required Locale locale,
    required int seed,
  }) {
    final style = _styleSentence(
      locale: locale,
      sunSign: sunSign,
      risingSign: risingSign,
      seed: seed,
    );
    final notes = _dailyInstructionLines(
      locale: locale,
      seed: seed,
      sunSign: sunSign,
      risingSign: risingSign,
    );
    final token = _variationToken(locale, seed ^ 0x3f15);
    final bullets = notes.map((note) => '- $note').join('\n');

    if (locale.languageCode == 'tr') {
      return '''JSON döndür: {"summary":string,"energyFocus":{love,career,spiritual,social},"cosmicGuide":string,"sections":{love,career,spiritual,social}}.
Yazım tarzı: $style
Varyasyon etiketi: $token
Notlar:
$bullets
Güneş burcu $sunSign, yükselen $risingSign. Her bölüm konuşma tonunda 2-3 cümle olsun, metafor ve uygulanabilir öneriler içersin. Türkçe yanıt ver.''';
    }
    return '''Return JSON: {"summary":string,"energyFocus":{love,career,spiritual,social},"cosmicGuide":string,"sections":{love,career,spiritual,social}}.
Writing style: $style
Variation token: $token
Notes:
$bullets
Sun sign $sunSign, rising $risingSign. Each section must be conversational, 2-3 sentences, with sensory metaphors and actionable advice. Respond in English.''';
  }

  String _compatibilityPrompt({
    required String firstSign,
    required String secondSign,
    required Locale locale,
    required int seed,
  }) {
    final style = _compatibilityStyle(
      locale: locale,
      firstSign: firstSign,
      secondSign: secondSign,
      seed: seed,
    );
    final notes = _compatibilityInstructionLines(
      locale: locale,
      seed: seed,
      firstSign: firstSign,
      secondSign: secondSign,
    );
    final token = _variationToken(locale, seed ^ 0x6b4d);
    final bullets = notes.map((note) => '- $note').join('\n');

    if (locale.languageCode == 'tr') {
      return '''JSON döndür: {"summary":string,"love":string,"family":string,"career":string}.
Üslup: $style
Varyasyon etiketi: $token
Notlar:
$bullets
$firstSign ve $secondSign arasındaki enerjiyi şiirsel, empatik ve sohbet tadında anlat. Her bölüm 2-3 cümle olsun ve uygulanabilir bir öneriyle bitsin. Türkçe yaz.''';
    }
    return '''Return JSON: {"summary":string,"love":string,"family":string,"career":string}.
Style: $style
Variation token: $token
Notes:
$bullets
Describe the energy between $firstSign and $secondSign in poetic, empathic English. Each section should be 2-3 sentences and end with an actionable suggestion.''';
  }

  String _fillTemplate(String template, Map<String, String> values) {
    var result = template;
    values.forEach((key, value) {
      result = result.replaceAll('{$key}', value);
    });
    return result;
  }
}
