import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;

class AiService {
  AiService({String? apiKey, String? model})
      : _apiKey = apiKey ?? const String.fromEnvironment('OPENAI_API_KEY'),
        _model = model ?? const String.fromEnvironment('OPENAI_MODEL', defaultValue: 'gpt-4o-mini');

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
      return 'You are an encouraging Turkish astrology expert who replies in fluent English with culturally aware dream interpretations.';
    }
    return 'Sen sıcak, pozitif ve kültürel bağlama hakim bir Türk astrologsun. Rüya yorumlarını umut verici ve yerel simgelere referansla yap.';
  }

  String _coffeeSystemPrompt(String language) {
    if (language == 'en') {
      return 'You are a friendly Turkish coffee reader. Interpret cup images in English with cultural context and positive tone.';
    }
    return 'Sen deneyimli bir Türk kahve falı yorumcususun. Görselleri umut verici, kültüre uygun ve yapıcı şekilde yorumla.';
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
        'general': 'The shapes hint at a hopeful transition. Stay receptive to guidance from trusted friends.',
        'love': 'Warm swirls show affectionate conversations blooming.',
        'career': 'A rising pattern signals steady progress at work.',
        'warnings': 'Avoid rushing; let plans brew slowly for the best outcome.',
      };
    }
    return {
      'general': 'Şekiller umutlu bir geçişe işaret ediyor. Güvendiğiniz dostların rehberliğine açık olun.',
      'love': 'Sıcak desenler sevgi dolu konuşmaların canlanacağını gösteriyor.',
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
