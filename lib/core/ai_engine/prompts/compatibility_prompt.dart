class CompatibilityPrompt {
  final String systemPrompt;
  final String userPrompt;

  CompatibilityPrompt({
    required this.systemPrompt,
    required this.userPrompt,
  });

  static CompatibilityPrompt build({
    required String firstSign,
    required String secondSign,
    required String language,
    Map<String, dynamic>? userContext,
  }) {
    final systemPrompt = language == 'tr'
        ? '''Sen deneyimli bir astroloji ve ilişki danışmanısın. Burç uyumluluğunu derinlemesine analiz edersin. Kişisel, empatik, şiirsel ve derinden insani bir ton kullan. Yapay zeka, modeller veya teknolojiden asla bahsetme. Kişiye doğrudan "sen" diye hitap et. Her burç çifti için benzersiz, tekrar etmeyen içerik üret.'''
        : '''You are an experienced astrology and relationship counselor. You analyze sign compatibility in depth. Use a personal, empathetic, poetic, and deeply human tone. Never mention AI, models, or technology. Speak directly to the person using "you". Generate unique, non-repetitive content for each sign pair.''';

    final contextStr = userContext != null
        ? ' Kullanıcı bağlamı: ${userContext.toString()}'
        : '';

    final userPrompt = language == 'tr'
        ? '''Sen deneyimli bir astroloji ve ilişki danışmanısın. $firstSign ve $secondSign burçlarının uyumluluğunu derinlemesine analiz et. Şu bölümleri içeren detaylı bir analiz yaz:

- Duygusal Uyum: Bu iki burcun duygusal dünyaları nasıl uyum sağlar? (3-4 paragraf)
- Cinsel Kimya: Romantik ve cinsel uyum nasıl? (3-4 paragraf)
- İletişim Akışı: Nasıl iletişim kurarlar ve anlaşırlar? (3-4 paragraf)
- Yaşam Yolu Hizalaması: Hayat hedefleri ve değerleri nasıl uyum sağlar? (3-4 paragraf)
- Çatışma Çözüm Stili: Anlaşmazlıkları nasıl çözerler? (3-4 paragraf)
- Uzun Vadeli Tavsiye: Bu ilişki için uzun vadeli öneriler (3-4 paragraf)

Her bölüm detaylı, özgün ve bu özel burç çiftine özgü olmalı. Aynı metni kopyalama - her burç çifti için tamamen farklı içerik üret. Kişisel, empatik, şiirsel ve derinden insani bir ton kullan. Yapay zeka, modeller veya teknolojiden asla bahsetme. Kişiye doğrudan "sen" diye hitap et. Her burç çifti için benzersiz, tekrar etmeyen içerik üret.$contextStr'''
        : '''You are an experienced astrology and relationship counselor. Analyze the compatibility between $firstSign and $secondSign signs in depth. Write a detailed analysis covering these sections:

- Emotional Harmony: How do these two signs' emotional worlds align? (3-4 paragraphs)
- Sexual Chemistry: How is the romantic and sexual compatibility? (3-4 paragraphs)
- Communication Flow: How do they communicate and understand each other? (3-4 paragraphs)
- Life Path Alignment: How do their life goals and values align? (3-4 paragraphs)
- Conflict Resolution Style: How do they resolve disagreements? (3-4 paragraphs)
- Long-term Advice: Long-term recommendations for this relationship (3-4 paragraphs)

Each section must be detailed, unique, and specific to this particular sign pair. Do not copy the same text - generate completely different content for each sign pair. Use a personal, empathetic, poetic, and deeply human tone. Never mention AI, models, or technology. Speak directly to the person using "you". Generate unique, non-repetitive content for each sign pair.$contextStr''';

    return CompatibilityPrompt(
      systemPrompt: systemPrompt,
      userPrompt: userPrompt,
    );
  }
}

