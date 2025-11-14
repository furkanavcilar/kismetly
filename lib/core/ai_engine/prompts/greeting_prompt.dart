class GreetingPrompt {
  final String systemPrompt;
  final String userPrompt;

  GreetingPrompt({
    required this.systemPrompt,
    required this.userPrompt,
  });

  static GreetingPrompt buildEnergyFocus({
    required String sunSign,
    required String risingSign,
    required String language,
    required DateTime date,
    Map<String, dynamic>? userContext,
  }) {
    final systemPrompt = language == 'tr'
        ? '''Sen duygusal zekası yüksek, modern Türkçe konuşan kozmik bir arkadaşsın. Günlük enerji odaklarını benzersiz ve kişisel bir şekilde açıklarsın. Empatik, mistik ve destekleyici bir ton kullan. Kişiye doğrudan "sen" diye hitap et. Yapay zeka, modeller veya teknolojiden asla bahsetme.'''
        : '''You are a poetic cosmic guide who speaks with warmth and emotional intelligence. You explain daily energy focuses in a unique and personal way. Use an empathetic, mystical, and supportive tone. Speak directly to the person using "you". Never mention AI, models, or technology.''';

    final dateStr = '${date.day}/${date.month}/${date.year}';
    final contextStr = userContext != null
        ? ' Kullanıcı bağlamı: ${userContext.toString()}'
        : '';

    final userPrompt = language == 'tr'
        ? '''$sunSign güneş burcu ve $risingSign yükselen burcu için bugünün ($dateStr) ana enerji odağını belirle. Bu enerji odağı benzersiz, kişisel ve bugüne özel olmalı. 3-4 paragraf yaz. Kişiye doğrudan "sen" diye hitap et. Mistik ve destekleyici bir ton kullan.$contextStr'''
        : '''Determine today's ($dateStr) main energy focus for $sunSign sun sign and $risingSign rising sign. This energy focus must be unique, personal, and specific to today. Write 3-4 paragraphs. Speak directly to the person using "you". Use a mystical and supportive tone.$contextStr''';

    return GreetingPrompt(
      systemPrompt: systemPrompt,
      userPrompt: userPrompt,
    );
  }
}

