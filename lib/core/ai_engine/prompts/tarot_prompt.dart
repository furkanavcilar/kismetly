class TarotPrompt {
  final String systemPrompt;
  final String userPrompt;

  TarotPrompt({
    required this.systemPrompt,
    required this.userPrompt,
  });

  static TarotPrompt build({
    required List<String> cardNames,
    required String spreadType,
    required String language,
    Map<String, dynamic>? userContext,
  }) {
    final systemPrompt = language == 'tr'
        ? '''Sen deneyimli bir tarot okuyucususun. Kartları derinlemesine yorumlar, hikayelerini birleştirir ve anlamlı rehberlik sağlarsın. Mistik, bilge ve empatik bir ton kullan. Kişiye doğrudan "sen" diye hitap et. Yapay zeka, modeller veya teknolojiden asla bahsetme. Her yorum 6+ paragraf olmalı ve benzersiz olmalı.'''
        : '''You are an experienced tarot reader. You interpret cards in depth, weave their stories together, and provide meaningful guidance. Use a mystical, wise, and empathetic tone. Speak directly to the person using "you". Never mention AI, models, or technology. Each reading must be 6+ paragraphs and unique.''';

    final cardsStr = cardNames.join(', ');
    final contextStr = userContext != null
        ? ' Kullanıcı bağlamı: ${userContext.toString()}'
        : '';

    final userPrompt = language == 'tr'
        ? '''Çekilen kartlar: $cardsStr. Yayılım tipi: $spreadType.

Bu kartları bir hikaye olarak birleştir ve detaylı bir tarot yorumu yap. Şu konuları kapsa:

- Geçmiş, şimdi ve gelecek enerjileri (2 paragraf)
- Gizli etkiler ve görünmeyen faktörler (1 paragraf)
- Sonuç ve potansiyel çıktılar (1 paragraf)
- Her kartın özel anlamı ve diğer kartlarla ilişkisi (2 paragraf)

Toplam 6+ paragraf yaz. Her yorum benzersiz olmalı. Kişiye doğrudan "sen" diye hitap et. Mistik ve bilge bir ton kullan.$contextStr'''
        : '''Drawn cards: $cardsStr. Spread type: $spreadType.

Combine these cards as a story and provide a detailed tarot reading. Cover these topics:

- Past, present, and future energies (2 paragraphs)
- Hidden influences and unseen factors (1 paragraph)
- Outcome and potential results (1 paragraph)
- Each card's special meaning and relationship with other cards (2 paragraphs)

Write 6+ paragraphs total. Each reading must be unique. Speak directly to the person using "you". Use a mystical and wise tone.$contextStr''';

    return TarotPrompt(
      systemPrompt: systemPrompt,
      userPrompt: userPrompt,
    );
  }
}

