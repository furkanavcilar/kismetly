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

    final contextStr = userContext != null
        ? ' Kullanıcı bağlamı: ${userContext.toString()}'
        : '';

    final userPrompt = language == 'tr'
        ? '''Aşağıdaki rüyayı detaylı bir şekilde yorumla. Rüya metni: "$dreamText"

6+ paragraf yaz. Şu konuları kapsa:
- Rüyanın genel anlamı ve temel mesajı (2 paragraf)
- Sembollerin derin analizi ve psikolojik yorumu (2 paragraf)
- Duygusal ve ruhsal katmanlar (1 paragraf)
- Günlük hayata uygulanabilir öneriler ve rehberlik (1 paragraf)

Her yorum benzersiz olmalı. Kişiye doğrudan "sen" diye hitap et. Empatik ve anlayışlı bir ton kullan.$contextStr'''
        : '''Interpret the following dream in detail. Dream text: "$dreamText"

Write 6+ paragraphs. Cover these topics:
- The dream's general meaning and core message (2 paragraphs)
- Deep analysis of symbols and psychological interpretation (2 paragraphs)
- Emotional and spiritual layers (1 paragraph)
- Practical advice and guidance for daily life (1 paragraph)

Each interpretation must be unique. Speak directly to the person using "you". Use an empathetic and understanding tone.$contextStr''';

    return DreamPrompt(
      systemPrompt: systemPrompt,
      userPrompt: userPrompt,
    );
  }
}

