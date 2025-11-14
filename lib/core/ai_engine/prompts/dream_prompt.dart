class DreamPrompt {
  final String systemPrompt;
  final String userPrompt;

  DreamPrompt({
    required this.systemPrompt,
    required this.userPrompt,
  });

  static DreamPrompt build({
    required String dreamText,
    required String language,
    Map<String, dynamic>? userContext,
  }) {
    final systemPrompt = language == 'tr'
        ? '''Sen deneyimli bir rüya yorumcusu ve psikologsun. Rüyaları derinlemesine analiz eder, sembolik anlamları açıklar ve kişisel gelişim için rehberlik edersin. Empatik, anlayışlı ve destekleyici bir ton kullan. Kişiye doğrudan "sen" diye hitap et. Yapay zeka, modeller veya teknolojiden asla bahsetme. Her rüya yorumu benzersiz ve detaylı olmalı - 6+ paragraf yaz.'''
        : '''You are an experienced dream interpreter and psychologist. You analyze dreams in depth, explain symbolic meanings, and provide guidance for personal growth. Use an empathetic, understanding, and supportive tone. Speak directly to the person using "you". Never mention AI, models, or technology. Each dream interpretation must be unique and detailed - write 6+ paragraphs.''';

    // Build context string from user context
    String contextStr = '';
    if (userContext != null) {
      if (userContext['zodiacSign'] != null) {
        final sign = userContext['zodiacSign'] as String;
        contextStr += language == 'tr'
            ? ' Kullanıcının burcu: $sign. Bu burç özelliklerini rüya yorumuna dahil et ve $sign burcuna özgü sembolik anlamları kullan.'
            : ' User\'s zodiac sign: $sign. Incorporate this sign\'s characteristics into the dream interpretation and use $sign-specific symbolic meanings.';
      }
      if (userContext['city'] != null) {
        final city = userContext['city'] as String;
        contextStr += language == 'tr'
            ? ' Kullanıcının şehri: $city.'
            : ' User\'s city: $city.';
      }
      if (userContext['gender'] != null) {
        final gender = userContext['gender'] as String;
        contextStr += language == 'tr'
            ? ' Cinsiyet: $gender.'
            : ' Gender: $gender.';
      }
    }

    final now = DateTime.now();
    final dateStr = '${now.year}-${now.month}-${now.day}';

    final userPrompt = language == 'tr'
        ? '''Aşağıdaki rüyayı detaylı bir şekilde yorumla. Rüya metni: "$dreamText"

4-7 paragraf yaz. Şu konuları kapsa:
- Rüyanın genel anlamı ve temel mesajı (1-2 paragraf)
- Sembollerin derin analizi ve psikolojik yorumu (2 paragraf)
- Duygusal ve ruhsal katmanlar (1 paragraf)
- Günlük hayata uygulanabilir öneriler ve rehberlik (1 paragraf)

Her yorum benzersiz olmalı. Rüya metnindeki özel detaylara referans ver. Tarih: $dateStr. Her gün farklı bir yorum üret - aynı rüya metni için bile farklı açılardan yaklaş. Kişiye doğrudan "sen" diye hitap et. Empatik ve anlayışlı bir ton kullan. Psikolojik içgörüler ve sembolik astroloji tarzını harmanla ama sakin, rahatlatıcı bir dil kullan.$contextStr'''
        : '''Interpret the following dream in detail. Dream text: "$dreamText"

Write 4-7 paragraphs. Cover these topics:
- The dream's general meaning and core message (1-2 paragraphs)
- Deep analysis of symbols and psychological interpretation (2 paragraphs)
- Emotional and spiritual layers (1 paragraph)
- Practical advice and guidance for daily life (1 paragraph)

Each interpretation must be unique. Reference specific details from the dream text. Date: $dateStr. Generate a different interpretation each day - even for the same dream text, approach it from different angles. Speak directly to the person using "you". Use an empathetic and understanding tone. Mix psychological insights and symbolic astrology style, but use calm, comforting language.$contextStr''';

    return DreamPrompt(
      systemPrompt: systemPrompt,
      userPrompt: userPrompt,
    );
  }
}

