class ZodiacSign {
  const ZodiacSign({
    required this.id,
    required this.labels,
  });

  final String id;
  final Map<String, String> labels;

  String labelFor(String languageCode) {
    return labels[languageCode] ?? labels['tr'] ?? id;
  }
}

const zodiacSigns = [
  ZodiacSign(id: 'aries', labels: {'tr': 'Koç', 'en': 'Aries'}),
  ZodiacSign(id: 'taurus', labels: {'tr': 'Boğa', 'en': 'Taurus'}),
  ZodiacSign(id: 'gemini', labels: {'tr': 'İkizler', 'en': 'Gemini'}),
  ZodiacSign(id: 'cancer', labels: {'tr': 'Yengeç', 'en': 'Cancer'}),
  ZodiacSign(id: 'leo', labels: {'tr': 'Aslan', 'en': 'Leo'}),
  ZodiacSign(id: 'virgo', labels: {'tr': 'Başak', 'en': 'Virgo'}),
  ZodiacSign(id: 'libra', labels: {'tr': 'Terazi', 'en': 'Libra'}),
  ZodiacSign(id: 'scorpio', labels: {'tr': 'Akrep', 'en': 'Scorpio'}),
  ZodiacSign(id: 'sagittarius', labels: {'tr': 'Yay', 'en': 'Sagittarius'}),
  ZodiacSign(id: 'capricorn', labels: {'tr': 'Oğlak', 'en': 'Capricorn'}),
  ZodiacSign(id: 'aquarius', labels: {'tr': 'Kova', 'en': 'Aquarius'}),
  ZodiacSign(id: 'pisces', labels: {'tr': 'Balık', 'en': 'Pisces'}),
];

ZodiacSign? findZodiacById(String id) {
  return zodiacSigns.firstWhere(
    (element) => element.id == id,
    orElse: () => const ZodiacSign(id: 'unknown', labels: {'tr': 'Bilinmeyen'}),
  );
}
