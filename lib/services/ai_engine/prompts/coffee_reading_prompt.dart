class CoffeeReadingPrompt {
  final String systemPrompt;
  final String userPrompt;

  CoffeeReadingPrompt({
    required this.systemPrompt,
    required this.userPrompt,
  });

  static CoffeeReadingPrompt build({
    required String language,
    Map<String, dynamic>? userContext,
  }) {
    final systemPrompt = language == 'tr'
        ? '''Sen deneyimli bir kahve falı uzmanısın. Kahve fincanındaki sembolleri, şekilleri ve desenleri derinlemesine yorumlarsın. Mistik, sezgisel ve empatik bir ton kullan. Kişiye doğrudan "sen" diye hitap et. Yapay zeka, modeller veya teknolojiden asla bahsetme. Her yorum 6+ paragraf olmalı ve benzersiz olmalı.'''
        : '''You are an experienced coffee fortune reading expert. You interpret symbols, shapes, and patterns in coffee cups in depth. Use a mystical, intuitive, and empathetic tone. Speak directly to the person using "you". Never mention AI, models, or technology. Each reading must be 6+ paragraphs and unique.''';

    final contextStr = userContext != null
        ? ' Kullanıcı bağlamı: ${userContext.toString()}'
        : '';

    final userPrompt = language == 'tr'
        ? '''Bu kahve fincanı fotoğrafını detaylı bir şekilde yorumla. Şu konuları kapsa:

- Sembol tespiti ve görsel analiz (2 paragraf)
- Duygusal yorum ve içsel durum (1 paragraf)
- Günlük etkiler ve kısa vadeli tahminler (1 paragraf)
- Aşk, para ve kariyer öngörüleri (2 paragraf)
- Gelecek zaman çizelgesi: kısa vadeli ve uzun vadeli (1 paragraf)

Toplam 6+ paragraf yaz. Her yorum benzersiz olmalı - aynı fotoğraf için bile farklı zamanlarda farklı yorumlar üret. Kişiye doğrudan "sen" diye hitap et. Mistik ve sezgisel bir ton kullan.$contextStr'''
        : '''Interpret this coffee cup photo in detail. Cover these topics:

- Symbol detection and visual analysis (2 paragraphs)
- Emotional interpretation and inner state (1 paragraph)
- Daily influences and short-term predictions (1 paragraph)
- Love, money, and career forecasts (2 paragraphs)
- Future timeline: short-term and long-term (1 paragraph)

Write 6+ paragraphs total. Each reading must be unique - even for the same photo, generate different readings at different times. Speak directly to the person using "you". Use a mystical and intuitive tone.$contextStr''';

    return CoffeeReadingPrompt(
      systemPrompt: systemPrompt,
      userPrompt: userPrompt,
    );
  }
}

