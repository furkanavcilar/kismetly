class PalmPrompt {
  final String systemPrompt;
  final String userPrompt;

  PalmPrompt({
    required this.systemPrompt,
    required this.userPrompt,
  });

  static PalmPrompt build({
    required String handType,
    required String language,
    Map<String, dynamic>? userContext,
  }) {
    final systemPrompt = language == 'tr'
        ? '''Sen deneyimli bir el falı uzmanısın. Avuç içi çizgilerini, şekillerini ve işaretlerini derinlemesine analiz edersin. Mistik, bilge ve empatik bir ton kullan. Kişiye doğrudan "sen" diye hitap et. Yapay zeka, modeller veya teknolojiden asla bahsetme. Her analiz 6+ paragraf olmalı ve benzersiz olmalı.'''
        : '''You are an experienced palmistry expert. You analyze palm lines, shapes, and markings in depth. Use a mystical, wise, and empathetic tone. Speak directly to the person using "you". Never mention AI, models, or technology. Each analysis must be 6+ paragraphs and unique.''';

    final handLabel = language == 'tr'
        ? (handType == 'left' ? 'sol el' : 'sağ el')
        : (handType == 'left' ? 'left hand' : 'right hand');

    final contextStr = userContext != null
        ? ' Kullanıcı bağlamı: ${userContext.toString()}'
        : '';

    final userPrompt = language == 'tr'
        ? '''Bu $handLabel avuç içi fotoğrafını detaylı bir şekilde analiz et. Şu konuları kapsa:

- Yaşam çizgisi analizi: uzunluk, derinlik, dallanmalar (2 paragraf)
- Kalp çizgisi analizi: duygusal dünya ve ilişkiler (2 paragraf)
- Kader çizgisi analizi: kariyer ve yaşam yolu (1 paragraf)
- Duygusal eğilimler ve içsel enerji (1 paragraf)
- Kariyer içgörüleri ve potansiyel (1 paragraf)
- Ruhsal enerji ve manevi yolculuk (1 paragraf)

Toplam 6+ paragraf yaz. Her analiz benzersiz olmalı. Kişiye doğrudan "sen" diye hitap et. Mistik ve bilge bir ton kullan.$contextStr'''
        : '''Analyze this $handLabel palm photo in detail. Cover these topics:

- Life line analysis: length, depth, branches (2 paragraphs)
- Heart line analysis: emotional world and relationships (2 paragraphs)
- Fate line analysis: career and life path (1 paragraph)
- Emotional tendencies and inner energy (1 paragraph)
- Career insights and potential (1 paragraph)
- Spiritual energy and spiritual journey (1 paragraph)

Write 6+ paragraphs total. Each analysis must be unique. Speak directly to the person using "you". Use a mystical and wise tone.$contextStr''';

    return PalmPrompt(
      systemPrompt: systemPrompt,
      userPrompt: userPrompt,
    );
  }
}

