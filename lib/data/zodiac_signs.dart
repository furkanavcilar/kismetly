class ZodiacSign {
  const ZodiacSign({
    required this.id,
    required this.labels,
    this.emoji,
    this.dateRange,
  });

  final String id;
  final Map<String, String> labels;
  final String? emoji;
  final String? dateRange;

  String labelFor(String languageCode) {
    return labels[languageCode] ?? labels['tr'] ?? id;
  }
}

const zodiacSigns = [
  ZodiacSign(id: 'aries', labels: {'tr': 'Koç', 'en': 'Aries'}, emoji: '♈', dateRange: '21 Mart - 19 Nisan'),
  ZodiacSign(id: 'taurus', labels: {'tr': 'Boğa', 'en': 'Taurus'}, emoji: '♉', dateRange: '20 Nisan - 20 Mayıs'),
  ZodiacSign(id: 'gemini', labels: {'tr': 'İkizler', 'en': 'Gemini'}, emoji: '♊', dateRange: '21 Mayıs - 20 Haziran'),
  ZodiacSign(id: 'cancer', labels: {'tr': 'Yengeç', 'en': 'Cancer'}, emoji: '♋', dateRange: '21 Haziran - 22 Temmuz'),
  ZodiacSign(id: 'leo', labels: {'tr': 'Aslan', 'en': 'Leo'}, emoji: '♌', dateRange: '23 Temmuz - 22 Ağustos'),
  ZodiacSign(id: 'virgo', labels: {'tr': 'Başak', 'en': 'Virgo'}, emoji: '♍', dateRange: '23 Ağustos - 22 Eylül'),
  ZodiacSign(id: 'libra', labels: {'tr': 'Terazi', 'en': 'Libra'}, emoji: '♎', dateRange: '23 Eylül - 22 Ekim'),
  ZodiacSign(id: 'scorpio', labels: {'tr': 'Akrep', 'en': 'Scorpio'}, emoji: '♏', dateRange: '23 Ekim - 21 Kasım'),
  ZodiacSign(id: 'sagittarius', labels: {'tr': 'Yay', 'en': 'Sagittarius'}, emoji: '♐', dateRange: '22 Kasım - 21 Aralık'),
  ZodiacSign(id: 'capricorn', labels: {'tr': 'Oğlak', 'en': 'Capricorn'}, emoji: '♑', dateRange: '22 Aralık - 19 Ocak'),
  ZodiacSign(id: 'aquarius', labels: {'tr': 'Kova', 'en': 'Aquarius'}, emoji: '♒', dateRange: '20 Ocak - 18 Şubat'),
  ZodiacSign(id: 'pisces', labels: {'tr': 'Balık', 'en': 'Pisces'}, emoji: '♓', dateRange: '19 Şubat - 20 Mart'),
];

ZodiacSign? findZodiacById(String id) {
  return zodiacSigns.firstWhere(
    (element) => element.id == id,
    orElse: () => const ZodiacSign(id: 'unknown', labels: {'tr': 'Bilinmeyen'}),
  );
}
