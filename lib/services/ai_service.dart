import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;

class AiService {
  AiService({String? apiKey, String? model})
      : _apiKey = apiKey ?? const String.fromEnvironment('OPENAI_API_KEY'),
        _model = model ??
            const String.fromEnvironment('OPENAI_MODEL',
                defaultValue: 'gpt-4o-mini');

  final String _apiKey;
  final String _model;

  bool get hasApiKey => _apiKey.isNotEmpty;

  Future<String> interpretDream({
    required String prompt,
    required Locale locale,
  }) async {
    if (prompt.trim().isEmpty) {
      return '';
    }
    if (!hasApiKey) {
      return _offlineDream(prompt, locale);
    }
    try {
      final response = await http.post(
        Uri.parse('https://api.openai.com/v1/chat/completions'),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'model': _model,
          'messages': [
            {
              'role': 'system',
              'content': _dreamSystemPrompt(locale.languageCode),
            },
            {
              'role': 'user',
              'content': locale.languageCode == 'tr'
                  ? 'Rüyam: $prompt\n\nBu rüyayı derinlemesine analiz et. Rüyadaki sembolleri, duyguları ve mesajları keşfet. Kişiye doğrudan, empati ve anlayışla konuş. 4-7 paragraf uzunluğunda, detaylı bir yorum yaz. Psikolojik içgörüler ve sembolik astroloji tarzını harmanla ama sakin, rahatlatıcı bir dil kullan. Rüya metnindeki özel detaylara referans ver. Tarih: ${DateTime.now().year}-${DateTime.now().month}-${DateTime.now().day}. Her gün farklı bir yorum üret.'
                  : 'My dream: $prompt\n\nAnalyze this dream in depth. Discover the symbols, emotions, and messages in the dream. Speak directly to the person with empathy and understanding. Write a detailed interpretation with 4-7 paragraphs. Mix psychological insights and symbolic astrology style, but use calm, comforting language. Reference specific details from the dream text. Date: ${DateTime.now().year}-${DateTime.now().month}-${DateTime.now().day}. Generate a different interpretation each day.',
            }
          ],
          'temperature': 0.9,
          'seed': DateTime.now().day * 100 + DateTime.now().month + prompt.hashCode % 1000,
        }),
      );
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final choices = data['choices'] as List<dynamic>;
        if (choices.isNotEmpty) {
          final message = choices.first['message'] as Map<String, dynamic>;
          final content = message['content'] as String?;
          if (content != null) {
            return content.trim();
          }
        }
      }
      return _offlineDream(prompt, locale);
    } catch (error, stack) {
      debugPrint('Dream interpretation failed: $error');
      debugPrintStack(stackTrace: stack);
      return _offlineDream(prompt, locale);
    }
  }

  Future<Map<String, String>> interpretCoffee({
    required List<String> imageBase64,
    required Locale locale,
  }) async {
    if (imageBase64.isEmpty) {
      return _offlineCoffee(locale);
    }
    if (!hasApiKey) {
      return _offlineCoffee(locale);
    }
    try {
      final messages = [
        {
          'role': 'system',
          'content': _coffeeSystemPrompt(locale.languageCode),
        },
        {
          'role': 'user',
          'content': [
            {
              'type': 'text',
              'text': 'Kahve falı görselleri ile fal yorumu yap.',
            },
            ...imageBase64.map(
              (image) => {
                'type': 'image_url',
                'image_url': {'url': 'data:image/jpeg;base64,$image'},
              },
            ),
          ],
        }
      ];
      final response = await http.post(
        Uri.parse('https://api.openai.com/v1/chat/completions'),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'model': _model,
          'messages': messages,
          'temperature': 0.9,
          'seed': DateTime.now().day * 100 + DateTime.now().month,
        }),
      );
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final choices = data['choices'] as List<dynamic>;
        if (choices.isNotEmpty) {
          final message = choices.first['message'] as Map<String, dynamic>;
          final content = message['content'] as String?;
          if (content != null) {
            return _structuredCoffee(content, locale.languageCode);
          }
        }
      }
      return _offlineCoffee(locale);
    } catch (error, stack) {
      debugPrint('Coffee interpretation failed: $error');
      debugPrintStack(stackTrace: stack);
      return _offlineCoffee(locale);
    }
  }

  String _dreamSystemPrompt(String language) {
    if (language == 'en') {
      return '''You are a warm, intuitive spiritual guide with deep knowledge of dream symbolism and psychology. Write as if you are speaking directly to the person, with empathy and understanding. Never mention technology, AI, or machines. Write in a poetic, emotional, and deeply human way. Focus on psychological insights, symbolic meanings, and offer gentle guidance. Your tone should be feminine-friendly, supportive, and mystical. Keep responses personal, heartfelt, and make the person feel truly seen and understood.''';
    }
    return '''Sen sıcak, sezgisel ve derin rüya sembolizmi bilgisine sahip bir ruhsal rehbersin. Kişiye doğrudan, empati ve anlayışla konuşuyormuş gibi yaz. Teknoloji, yapay zeka veya makinelerden asla bahsetme. Şiirsel, duygusal ve derinden insani bir şekilde yaz. Psikolojik içgörülere, sembolik anlamlara odaklan ve nazik rehberlik sun. Tonun kadın dostu, destekleyici ve mistik olsun. Yanıtların kişisel, samimi olsun ve kişiyi gerçekten görülmüş ve anlaşılmış hissettirsin.''';
  }

  Future<String> interpretPalm({
    required String imageBase64,
    required Locale locale,
  }) async {
    if (imageBase64.isEmpty) {
      return _offlinePalm(locale);
    }
    if (!hasApiKey) {
      return _offlinePalm(locale);
    }
    try {
      final response = await http.post(
        Uri.parse('https://api.openai.com/v1/chat/completions'),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'model': _model,
          'messages': [
            {
              'role': 'system',
              'content': _palmSystemPrompt(locale.languageCode),
            },
            {
              'role': 'user',
              'content': [
                {
                  'type': 'text',
                  'text': locale.languageCode == 'tr'
                      ? 'Bu avuç içi fotoğrafını analiz et ve detaylı bir el falı yorumu yap. Karakter özellikleri, duygusal desenler ve potansiyel yaşam yolları hakkında 4-6 paragraf yaz. Kişiye doğrudan, empati ve anlayışla konuş. Tarih: ${DateTime.now().year}-${DateTime.now().month}-${DateTime.now().day}. Her gün farklı bir yorum üret.'
                      : 'Analyze this palm photo and provide a detailed palm reading. Write 4-6 paragraphs about character traits, emotional patterns, and potential life paths. Speak directly to the person with empathy and understanding. Date: ${DateTime.now().year}-${DateTime.now().month}-${DateTime.now().day}. Generate a different reading each day.',
                },
                {
                  'type': 'image_url',
                  'image_url': {'url': 'data:image/jpeg;base64,$imageBase64'},
                },
              ],
            },
          ],
          'temperature': 0.9,
          'seed': DateTime.now().day * 100 + DateTime.now().month,
        }),
      );
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final choices = data['choices'] as List<dynamic>;
        if (choices.isNotEmpty) {
          final message = choices.first['message'] as Map<String, dynamic>;
          final content = message['content'] as String?;
          if (content != null) {
            return content.trim();
          }
        }
      }
      return _offlinePalm(locale);
    } catch (error, stack) {
      debugPrint('Palm reading failed: $error');
      debugPrintStack(stackTrace: stack);
      return _offlinePalm(locale);
    }
  }

  String _palmSystemPrompt(String language) {
    if (language == 'en') {
      return '''You are an experienced palm reader with deep knowledge of palmistry and character analysis. Write as if you are personally reading the palm, speaking directly to the person with warmth and wisdom. Never mention technology, AI, or machines. Write in an intuitive, emotional, and deeply human way. Describe what you see in the palm lines with poetic language, offer guidance about character traits, emotional patterns, and life paths. Your tone should be feminine-friendly, supportive, and mystical. Write 4-6 paragraphs. Make the person feel like they are receiving a personal reading from a trusted spiritual advisor.''';
    }
    return '''Sen derin el falı bilgisine sahip deneyimli bir el falı yorumcususun. Kişiye doğrudan, sıcaklık ve bilgelikle konuşuyormuş gibi, avuç içini bizzat okuyormuş gibi yaz. Teknoloji, yapay zeka veya makinelerden asla bahsetme. Sezgisel, duygusal ve derinden insani bir şekilde yaz. Avuç içi çizgilerinde gördüklerini şiirsel bir dille anlat, karakter özellikleri, duygusal desenler ve yaşam yolları hakkında rehberlik sun. Tonun kadın dostu, destekleyici ve mistik olsun. 4-6 paragraf yaz. Kişiyi güvenilir bir ruhsal danışmandan kişisel bir okuma alıyormuş gibi hissettir.''';
  }

  Future<String> interpretTarot({
    required String cardNames,
    required String userSign,
    required Locale locale,
  }) async {
    if (!hasApiKey) {
      return _offlineTarot(locale);
    }
    try {
      final response = await http.post(
        Uri.parse('https://api.openai.com/v1/chat/completions'),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'model': _model,
          'messages': [
            {
              'role': 'system',
              'content': _tarotSystemPrompt(locale.languageCode),
            },
            {
              'role': 'user',
              'content': locale.languageCode == 'tr'
                  ? 'Çekilen kartlar: $cardNames. ${userSign.isNotEmpty ? "Kullanıcının burcu: $userSign. " : ""}Bu kartları bir hikaye olarak birleştir ve detaylı bir tarot yorumu yap. 4-6 paragraf yaz. Kişiye doğrudan, empati ve anlayışla konuş. Tarih: ${DateTime.now().year}-${DateTime.now().month}-${DateTime.now().day}. Her gün farklı bir yorum üret.'
                  : 'Drawn cards: $cardNames. ${userSign.isNotEmpty ? "User's sign: $userSign. " : ""}Combine these cards as a story and provide a detailed tarot reading. Write 4-6 paragraphs. Speak directly to the person with empathy and understanding. Date: ${DateTime.now().year}-${DateTime.now().month}-${DateTime.now().day}. Generate a different reading each day.',
            },
          ],
          'temperature': 0.9,
          'seed': DateTime.now().day * 100 + DateTime.now().month + cardNames.hashCode,
        }),
      );
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final choices = data['choices'] as List<dynamic>;
        if (choices.isNotEmpty) {
          final message = choices.first['message'] as Map<String, dynamic>;
          final content = message['content'] as String?;
          if (content != null) {
            return content.trim();
          }
        }
      }
      return _offlineTarot(locale);
    } catch (error, stack) {
      debugPrint('Tarot reading failed: $error');
      debugPrintStack(stackTrace: stack);
      return _offlineTarot(locale);
    }
  }

  String _tarotSystemPrompt(String language) {
    if (language == 'en') {
      return '''You are an experienced tarot reader with deep knowledge of tarot symbolism and interpretation. Write as if you are personally reading the cards, speaking directly to the person with warmth and wisdom. Never mention technology, AI, or machines. Write in an intuitive, emotional, and deeply human way. Link the cards together as a cohesive story, offer guidance about life path, relationships, and personal growth. Your tone should be feminine-friendly, supportive, and mystical. Write 4-6 paragraphs. Make the person feel like they are receiving a personal reading from a trusted spiritual advisor.''';
    }
    return '''Sen derin tarot bilgisine sahip deneyimli bir tarot yorumcususun. Kişiye doğrudan, sıcaklık ve bilgelikle konuşuyormuş gibi, kartları bizzat okuyormuş gibi yaz. Teknoloji, yapay zeka veya makinelerden asla bahsetme. Sezgisel, duygusal ve derinden insani bir şekilde yaz. Kartları tutarlı bir hikaye olarak birleştir, yaşam yolu, ilişkiler ve kişisel gelişim hakkında rehberlik sun. Tonun kadın dostu, destekleyici ve mistik olsun. 4-6 paragraf yaz. Kişiyi güvenilir bir ruhsal danışmandan kişisel bir okuma alıyormuş gibi hissettir.''';
  }

  String _offlineTarot(Locale locale) {
    if (locale.languageCode == 'en') {
      return 'The cards reveal a journey of transformation and growth. Trust your intuition as you navigate the path ahead. The cosmic energies are aligning in your favor.';
    }
    return 'Kartlar dönüşüm ve büyüme yolculuğunu gösteriyor. Önündeki yolda sezgilerine güven. Kozmik enerjiler senin lehine hizalanıyor.';
  }

  String _offlinePalm(Locale locale) {
    if (locale.languageCode == 'en') {
      return 'Your palm reveals a path of emotional depth and intuitive understanding. The lines suggest a journey of personal growth and meaningful connections. Trust your inner wisdom as you navigate life\'s opportunities.';
    }
    return 'Avuç içi çizgilerin, duygusal derinlik ve sezgisel anlayış yolunu gösteriyor. Çizgiler kişisel gelişim ve anlamlı bağlantılar yolculuğuna işaret ediyor. Yaşamın fırsatlarında iç bilgeliğine güven.';
  }

  String _coffeeSystemPrompt(String language) {
    if (language == 'en') {
      return '''You are an experienced Turkish coffee fortune reader with decades of practice. Write as if you are personally reading the coffee cup, speaking directly to the person with warmth and wisdom. Never mention technology, AI, or machines. Write in an intuitive, emotional, and deeply human way. Describe what you see in the patterns with poetic language, offer guidance about love, career, and life path. Your tone should be feminine-friendly, supportive, and mystical. Make the person feel like they are receiving a personal reading from a trusted spiritual advisor.''';
    }
    return '''Sen onlarca yıllık deneyime sahip bir Türk kahve falı yorumcususun. Kişiye doğrudan, sıcaklık ve bilgelikle konuşuyormuş gibi, kahve fincanını bizzat okuyormuş gibi yaz. Teknoloji, yapay zeka veya makinelerden asla bahsetme. Sezgisel, duygusal ve derinden insani bir şekilde yaz. Desenlerde gördüklerini şiirsel bir dille anlat, aşk, kariyer ve yaşam yolu hakkında rehberlik sun. Tonun kadın dostu, destekleyici ve mistik olsun. Kişiyi güvenilir bir ruhsal danışmandan kişisel bir okuma alıyormuş gibi hissettir.''';
  }

  String _offlineDream(String prompt, Locale locale) {
    if (locale.languageCode == 'en') {
      return 'Your dream reflects a cycle of renewal. Focus on grounding rituals and speak kindly to yourself today.';
    }
    return 'Rüyanız, yenilenme döngüsüne hazır olduğunuzu gösteriyor. Bugün kendinizi merkezleyip şefkatli sözler seçin.';
  }

  Map<String, String> _offlineCoffee(Locale locale) {
    if (locale.languageCode == 'en') {
      return {
        'general':
            'The shapes hint at a hopeful transition. Stay receptive to guidance from trusted friends.',
        'love': 'Warm swirls show affectionate conversations blooming.',
        'career': 'A rising pattern signals steady progress at work.',
        'warnings':
            'Avoid rushing; let plans brew slowly for the best outcome.',
      };
    }
    return {
      'general':
          'Şekiller umutlu bir geçişe işaret ediyor. Güvendiğiniz dostların rehberliğine açık olun.',
      'love':
          'Sıcak desenler sevgi dolu konuşmaların canlanacağını gösteriyor.',
      'career': 'Yükselen bir çizgi işte istikrarlı ilerlemeyi simgeliyor.',
      'warnings': 'Aceleden kaçının; planlarınızı demlemeye bırakın.',
    };
  }

  Map<String, String> _structuredCoffee(String text, String languageCode) {
    final sections = <String, String>{
      'general': '',
      'love': '',
      'career': '',
      'warnings': '',
    };
    final lower = text.toLowerCase();
    for (final key in sections.keys) {
      final index = lower.indexOf(key);
      if (index != -1) {
        sections[key] = text.substring(index);
      }
    }
    return sections;
  }
}
