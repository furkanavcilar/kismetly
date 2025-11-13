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
              'content': prompt,
            }
          ],
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
