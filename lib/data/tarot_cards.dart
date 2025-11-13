class TarotCard {
  const TarotCard({
    required this.id,
    required this.labels,
    this.emoji,
  });

  final String id;
  final Map<String, String> labels;
  final String? emoji;

  String labelFor(String languageCode) {
    return labels[languageCode] ?? labels['en'] ?? id;
  }
}

// Major Arcana cards
const majorArcana = [
  TarotCard(id: 'fool', labels: {'tr': 'Fool', 'en': 'The Fool'}, emoji: '🃏'),
  TarotCard(id: 'magician', labels: {'tr': 'Magician', 'en': 'The Magician'}, emoji: '🪄'),
  TarotCard(id: 'priestess', labels: {'tr': 'High Priestess', 'en': 'The High Priestess'}, emoji: '🌙'),
  TarotCard(id: 'empress', labels: {'tr': 'Empress', 'en': 'The Empress'}, emoji: '👑'),
  TarotCard(id: 'emperor', labels: {'tr': 'Emperor', 'en': 'The Emperor'}, emoji: '⚔️'),
  TarotCard(id: 'hierophant', labels: {'tr': 'Hierophant', 'en': 'The Hierophant'}, emoji: '📿'),
  TarotCard(id: 'lovers', labels: {'tr': 'Lovers', 'en': 'The Lovers'}, emoji: '💑'),
  TarotCard(id: 'chariot', labels: {'tr': 'Chariot', 'en': 'The Chariot'}, emoji: '🏛️'),
  TarotCard(id: 'strength', labels: {'tr': 'Strength', 'en': 'Strength'}, emoji: '💪'),
  TarotCard(id: 'hermit', labels: {'tr': 'Hermit', 'en': 'The Hermit'}, emoji: '🕯️'),
  TarotCard(id: 'wheel', labels: {'tr': 'Wheel of Fortune', 'en': 'Wheel of Fortune'}, emoji: '🎡'),
  TarotCard(id: 'justice', labels: {'tr': 'Justice', 'en': 'Justice'}, emoji: '⚖️'),
  TarotCard(id: 'hanged', labels: {'tr': 'Hanged Man', 'en': 'The Hanged Man'}, emoji: '🪢'),
  TarotCard(id: 'death', labels: {'tr': 'Death', 'en': 'Death'}, emoji: '💀'),
  TarotCard(id: 'temperance', labels: {'tr': 'Temperance', 'en': 'Temperance'}, emoji: '⚗️'),
  TarotCard(id: 'devil', labels: {'tr': 'Devil', 'en': 'The Devil'}, emoji: '😈'),
  TarotCard(id: 'tower', labels: {'tr': 'Tower', 'en': 'The Tower'}, emoji: '🗼'),
  TarotCard(id: 'star', labels: {'tr': 'Star', 'en': 'The Star'}, emoji: '⭐'),
  TarotCard(id: 'moon', labels: {'tr': 'Moon', 'en': 'The Moon'}, emoji: '🌙'),
  TarotCard(id: 'sun', labels: {'tr': 'Sun', 'en': 'The Sun'}, emoji: '☀️'),
  TarotCard(id: 'judgement', labels: {'tr': 'Judgement', 'en': 'Judgement'}, emoji: '📯'),
  TarotCard(id: 'world', labels: {'tr': 'World', 'en': 'The World'}, emoji: '🌍'),
];

