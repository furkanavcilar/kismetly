import 'dart:math';

const Map<String, List<String>> _sunMessagesEn = {
  'aries': [
    'Your bold spirit inspires those around you.',
    'Doors open for fresh beginnings today.',
    'Channel your spark into creative plans.',
  ],
  'taurus': [
    'Your steady presence builds trust.',
    'Take grounded steps with finances.',
    'Comfort moments refuel your energy.',
  ],
  'gemini': [
    'Curiosity connects you with new allies.',
    'Clear conversations empower you.',
    'Flexibility keeps the day light.',
  ],
  'cancer': [
    'Your intuition points toward the right path.',
    'Support from loved ones uplifts you.',
    'Let your heart guide your choices.',
  ],
  'leo': [
    'Your radiant energy captures attention.',
    'Confidence motivates your circle.',
    'Step into the spotlight and share your ideas.',
  ],
  'virgo': [
    'Detail focus sets you apart.',
    'Planning brings calm and clarity.',
    'Your caring nature builds trust.',
  ],
  'libra': [
    'Balanced actions strengthen relationships.',
    'Harmony leads your collaborations.',
    'Beauty moments restore your spirit.',
  ],
  'scorpio': [
    'Your determination empowers others.',
    'Expressing deep feelings is healing.',
    'Channel passion into transformation.',
  ],
  'sagittarius': [
    'Adventure calls you toward wider horizons.',
    'Free thinking reveals new routes.',
    'Let your joy be contagious.',
  ],
  'capricorn': [
    'Discipline delivers lasting results.',
    'Great day to clarify your goals.',
    'You manage responsibilities with mastery.',
  ],
  'aquarius': [
    'Original ideas create ripples.',
    'Your social impact is appreciated.',
    'Draw inspiration from your community.',
  ],
  'pisces': [
    'Compassionate energy surrounds you.',
    'Showcase your artistic visions.',
    'Sharing dreams empowers you.',
  ],
};

const Map<String, List<String>> _risingMessagesEn = {
  'aries': [
    'Your brave stance stands out.',
    'Quick choices put you ahead.',
    'Leadership instincts are strong.',
  ],
  'taurus': [
    'Calm aura brings comfort.',
    'Your aesthetic eye shapes spaces.',
    'Resolve makes you memorable.',
  ],
  'gemini': [
    'Communication skills shine.',
    'Curiosity draws people in.',
    'Sharing knowledge brings joy.',
  ],
  'cancer': [
    'Protective warmth surrounds you.',
    'Intuitive moves guide the way.',
    'Home-centered plans take focus.',
  ],
  'leo': [
    'Spotlights find you easily.',
    'Joy and generosity inspire others.',
    'You crave self-expression.',
  ],
  'virgo': [
    'Organized style earns respect.',
    'Attention to detail helps you adapt.',
    'Being helpful feels rewarding.',
  ],
  'libra': [
    'Kind tone creates harmony.',
    'Partnership balance is highlighted.',
    'Your eye for aesthetics is bright.',
  ],
  'scorpio': [
    'Mystique sparks curiosity.',
    'Sharing passion deepens bonds.',
    'Transformative energy is active.',
  ],
  'sagittarius': [
    'Outgoing spirit spreads quickly.',
    'Quest for discovery motivates.',
    'Positive words lift everyone.',
  ],
  'capricorn': [
    'Serious stance earns trust.',
    'Practical moves take the lead.',
    'Long-term goals are in focus.',
  ],
  'aquarius': [
    'Independent vibe is unmistakable.',
    'Friendships bring innovative sparks.',
    'Community projects call you.',
  ],
  'pisces': [
    'Empathy wraps everyone gently.',
    'Imagination flows freely.',
    'Going with the flow brings peace.',
  ],
};

String sunInsightForEn(String signId, DateTime date) {
  final entries = _sunMessagesEn[signId] ?? [''];
  if (entries.isEmpty) return '';
  final index = date.day % entries.length;
  return entries[index];
}

String risingInsightForEn(String signId, DateTime date) {
  final entries = _risingMessagesEn[signId] ?? [''];
  if (entries.isEmpty) return '';
  final index = date.month % entries.length;
  return entries[index];
}

String randomFallbackInsightEn() {
  final values = _sunMessagesEn.values.expand((element) => element).toList();
  return values[Random(24).nextInt(values.length)];
}
