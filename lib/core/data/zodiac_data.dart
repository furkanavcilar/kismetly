/// Static zodiac encyclopedia data
/// 
/// Accurate information for each zodiac sign:
/// - element (fire, earth, air, water)
/// - modality (cardinal, fixed, mutable)
/// - ruling planet
/// - compatible signs
/// - challenging signs
/// - traits list
class ZodiacData {
  final String id;
  final Map<String, String> element; // fire, earth, air, water
  final Map<String, String> modality; // cardinal, fixed, mutable
  final Map<String, String> rulingPlanet;
  final List<String> compatibleSigns;
  final List<String> challengingSigns;
  final Map<String, List<String>> traits; // language -> list of traits

  const ZodiacData({
    required this.id,
    required this.element,
    required this.modality,
    required this.rulingPlanet,
    required this.compatibleSigns,
    required this.challengingSigns,
    required this.traits,
  });
}

const List<ZodiacData> zodiacData = [
  ZodiacData(
    id: 'aries',
    element: {'tr': 'Ateş', 'en': 'Fire'},
    modality: {'tr': 'Öncü', 'en': 'Cardinal'},
    rulingPlanet: {'tr': 'Mars', 'en': 'Mars'},
    compatibleSigns: ['leo', 'sagittarius', 'gemini', 'aquarius'],
    challengingSigns: ['cancer', 'capricorn'],
    traits: {
      'tr': [
        'Cesur ve maceracı',
        'Liderlik özellikleri güçlü',
        'Enerjik ve coşkulu',
        'Bağımsız ruh',
        'Dürüst ve direkt',
        'Sabırsız ve dürtüsel',
        'Rekabetçi',
        'Yenilikçi',
      ],
      'en': [
        'Brave and adventurous',
        'Strong leadership qualities',
        'Energetic and enthusiastic',
        'Independent spirit',
        'Honest and direct',
        'Impatient and impulsive',
        'Competitive',
        'Innovative',
      ],
    },
  ),
  ZodiacData(
    id: 'taurus',
    element: {'tr': 'Toprak', 'en': 'Earth'},
    modality: {'tr': 'Sabit', 'en': 'Fixed'},
    rulingPlanet: {'tr': 'Venüs', 'en': 'Venus'},
    compatibleSigns: ['virgo', 'capricorn', 'cancer', 'pisces'],
    challengingSigns: ['leo', 'aquarius'],
    traits: {
      'tr': [
        'Pratik ve güvenilir',
        'Sabırlı ve kararlı',
        'Duyusal ve zevk sever',
        'Sadık ve özel',
        'Maddi güvenlik önemli',
        'İnatçı olabilir',
        'Değişime dirençli',
        'Sanatsal ve yaratıcı',
      ],
      'en': [
        'Practical and reliable',
        'Patient and determined',
        'Sensual and pleasure-loving',
        'Loyal and devoted',
        'Material security important',
        'Can be stubborn',
        'Resistant to change',
        'Artistic and creative',
      ],
    },
  ),
  ZodiacData(
    id: 'gemini',
    element: {'tr': 'Hava', 'en': 'Air'},
    modality: {'tr': 'Değişken', 'en': 'Mutable'},
    rulingPlanet: {'tr': 'Merkür', 'en': 'Mercury'},
    compatibleSigns: ['libra', 'aquarius', 'aries', 'leo'],
    challengingSigns: ['virgo', 'pisces'],
    traits: {
      'tr': [
        'Zeki ve meraklı',
        'İletişim becerileri yüksek',
        'Esnek ve uyumlu',
        'Çok yönlü ilgi alanları',
        'Sosyal ve cana yakın',
        'Kararsız olabilir',
        'Yüzeysel görünebilir',
        'Yenilikçi ve değişken',
      ],
      'en': [
        'Intelligent and curious',
        'Strong communication skills',
        'Flexible and adaptable',
        'Varied interests',
        'Social and friendly',
        'Can be indecisive',
        'May seem superficial',
        'Innovative and changeable',
      ],
    },
  ),
  ZodiacData(
    id: 'cancer',
    element: {'tr': 'Su', 'en': 'Water'},
    modality: {'tr': 'Öncü', 'en': 'Cardinal'},
    rulingPlanet: {'tr': 'Ay', 'en': 'Moon'},
    compatibleSigns: ['scorpio', 'pisces', 'taurus', 'virgo'],
    challengingSigns: ['aries', 'libra'],
    traits: {
      'tr': [
        'Sezgisel ve duygusal',
        'Ailesine düşkün',
        'Koruyucu ve şefkatli',
        'Yaratıcı ve hayal gücü kuvvetli',
        'Hassas ve kırılgan',
        'Duygusal dalgalanmalar',
        'Geçmişe bağlı',
        'Empati yeteneği yüksek',
      ],
      'en': [
        'Intuitive and emotional',
        'Family-oriented',
        'Protective and caring',
        'Creative and imaginative',
        'Sensitive and fragile',
        'Emotional fluctuations',
        'Attached to the past',
        'High empathy',
      ],
    },
  ),
  ZodiacData(
    id: 'leo',
    element: {'tr': 'Ateş', 'en': 'Fire'},
    modality: {'tr': 'Sabit', 'en': 'Fixed'},
    rulingPlanet: {'tr': 'Güneş', 'en': 'Sun'},
    compatibleSigns: ['aries', 'sagittarius', 'gemini', 'libra'],
    challengingSigns: ['taurus', 'scorpio'],
    traits: {
      'tr': [
        'Gururlu ve asil',
        'Yaratıcı ve sanatsal',
        'Cömert ve sıcak',
        'Liderlik özellikleri',
        'Kendine güvenen',
        'Bencil olabilir',
        'Dikkat çekmek ister',
        'Dramatik ve gösterişli',
      ],
      'en': [
        'Proud and noble',
        'Creative and artistic',
        'Generous and warm',
        'Leadership qualities',
        'Self-confident',
        'Can be selfish',
        'Seeks attention',
        'Dramatic and showy',
      ],
    },
  ),
  ZodiacData(
    id: 'virgo',
    element: {'tr': 'Toprak', 'en': 'Earth'},
    modality: {'tr': 'Değişken', 'en': 'Mutable'},
    rulingPlanet: {'tr': 'Merkür', 'en': 'Mercury'},
    compatibleSigns: ['taurus', 'capricorn', 'cancer', 'scorpio'],
    challengingSigns: ['gemini', 'sagittarius'],
    traits: {
      'tr': [
        'Analitik ve detaycı',
        'Pratik ve düzenli',
        'Mükemmeliyetçi',
        'Yardımsever ve hizmetkar',
        'Dikkatli ve titiz',
        'Eleştirel olabilir',
        'Endişeli ve kaygılı',
        'Zeki ve meraklı',
      ],
      'en': [
        'Analytical and detail-oriented',
        'Practical and organized',
        'Perfectionist',
        'Helpful and service-oriented',
        'Careful and meticulous',
        'Can be critical',
        'Anxious and worried',
        'Intelligent and curious',
      ],
    },
  ),
  ZodiacData(
    id: 'libra',
    element: {'tr': 'Hava', 'en': 'Air'},
    modality: {'tr': 'Öncü', 'en': 'Cardinal'},
    rulingPlanet: {'tr': 'Venüs', 'en': 'Venus'},
    compatibleSigns: ['gemini', 'aquarius', 'leo', 'sagittarius'],
    challengingSigns: ['cancer', 'capricorn'],
    traits: {
      'tr': [
        'Dengeli ve adil',
        'Estetik ve zarif',
        'Uyumlu ve diplomatik',
        'Sosyal ve sevecen',
        'Kararsız olabilir',
        'Çatışmadan kaçınır',
        'Partnerlik önemli',
        'Sanatsal ve yaratıcı',
      ],
      'en': [
        'Balanced and fair',
        'Aesthetic and graceful',
        'Harmonious and diplomatic',
        'Social and affectionate',
        'Can be indecisive',
        'Avoids conflict',
        'Partnership important',
        'Artistic and creative',
      ],
    },
  ),
  ZodiacData(
    id: 'scorpio',
    element: {'tr': 'Su', 'en': 'Water'},
    modality: {'tr': 'Sabit', 'en': 'Fixed'},
    rulingPlanet: {'tr': 'Pluto', 'en': 'Pluto'},
    compatibleSigns: ['cancer', 'pisces', 'virgo', 'capricorn'],
    challengingSigns: ['leo', 'aquarius'],
    traits: {
      'tr': [
        'Derin ve gizemli',
        'Güçlü ve tutkulu',
        'Sezgisel ve psikolojik',
        'Sadık ve özel',
        'Dönüşüm yeteneği',
        'Kıskanç olabilir',
        'Aşırı yoğun',
        'Dayanıklı ve dirençli',
      ],
      'en': [
        'Deep and mysterious',
        'Intense and passionate',
        'Intuitive and psychological',
        'Loyal and devoted',
        'Transformation ability',
        'Can be jealous',
        'Overly intense',
        'Resilient and resistant',
      ],
    },
  ),
  ZodiacData(
    id: 'sagittarius',
    element: {'tr': 'Ateş', 'en': 'Fire'},
    modality: {'tr': 'Değişken', 'en': 'Mutable'},
    rulingPlanet: {'tr': 'Jüpiter', 'en': 'Jupiter'},
    compatibleSigns: ['aries', 'leo', 'libra', 'aquarius'],
    challengingSigns: ['virgo', 'pisces'],
    traits: {
      'tr': [
        'Özgür ruh ve maceracı',
        'Felsefi ve bilge',
        'İyimser ve coşkulu',
        'Dürüst ve direkt',
        'Seyahat tutkusu',
        'Dikkatsiz olabilir',
        'Bağlılık zorluğu',
        'Açık fikirli ve toleranslı',
      ],
      'en': [
        'Free-spirited and adventurous',
        'Philosophical and wise',
        'Optimistic and enthusiastic',
        'Honest and direct',
        'Passion for travel',
        'Can be careless',
        'Commitment difficulty',
        'Open-minded and tolerant',
      ],
    },
  ),
  ZodiacData(
    id: 'capricorn',
    element: {'tr': 'Toprak', 'en': 'Earth'},
    modality: {'tr': 'Öncü', 'en': 'Cardinal'},
    rulingPlanet: {'tr': 'Satürn', 'en': 'Saturn'},
    compatibleSigns: ['taurus', 'virgo', 'scorpio', 'pisces'],
    challengingSigns: ['aries', 'libra'],
    traits: {
      'tr': [
        'Hırslı ve disiplinli',
        'Pratik ve sorumlu',
        'Geleneksel ve tutucu',
        'Sabırlı ve kararlı',
        'Kariyer odaklı',
        'Ciddi ve mesafeli',
        'Kontrolcü olabilir',
        'Güvenilir ve sadık',
      ],
      'en': [
        'Ambitious and disciplined',
        'Practical and responsible',
        'Traditional and conservative',
        'Patient and determined',
        'Career-focused',
        'Serious and distant',
        'Can be controlling',
        'Reliable and loyal',
      ],
    },
  ),
  ZodiacData(
    id: 'aquarius',
    element: {'tr': 'Hava', 'en': 'Air'},
    modality: {'tr': 'Sabit', 'en': 'Fixed'},
    rulingPlanet: {'tr': 'Uranüs', 'en': 'Uranus'},
    compatibleSigns: ['gemini', 'libra', 'aries', 'sagittarius'],
    challengingSigns: ['taurus', 'scorpio'],
    traits: {
      'tr': [
        'Özgün ve bağımsız',
        'İnsancıl ve ilerici',
        'Yenilikçi ve değişimci',
        'Dostane ve sosyal',
        'Entelektüel ve objektif',
        'Duygusal mesafe',
        'İnatçı ve sabit',
        'Gelecek odaklı',
      ],
      'en': [
        'Original and independent',
        'Humanitarian and progressive',
        'Innovative and revolutionary',
        'Friendly and social',
        'Intellectual and objective',
        'Emotional distance',
        'Stubborn and fixed',
        'Future-oriented',
      ],
    },
  ),
  ZodiacData(
    id: 'pisces',
    element: {'tr': 'Su', 'en': 'Water'},
    modality: {'tr': 'Değişken', 'en': 'Mutable'},
    rulingPlanet: {'tr': 'Neptün', 'en': 'Neptune'},
    compatibleSigns: ['cancer', 'scorpio', 'taurus', 'capricorn'],
    challengingSigns: ['gemini', 'virgo'],
    traits: {
      'tr': [
        'Sezgisel ve hassas',
        'Hayalperest ve yaratıcı',
        'Empatik ve şefkatli',
        'Ruhsal ve mistik',
        'Uyumlu ve uyumlu',
        'Gerçeklikten kaçınma',
        'Sınırları belirsiz',
        'Sanatsal ve ilham verici',
      ],
      'en': [
        'Intuitive and sensitive',
        'Dreamy and creative',
        'Empathetic and compassionate',
        'Spiritual and mystical',
        'Adaptable and flexible',
        'Reality avoidance',
        'Blurred boundaries',
        'Artistic and inspiring',
      ],
    },
  ),
];

/// Get zodiac data by ID
ZodiacData? getZodiacDataById(String id) {
  try {
    return zodiacData.firstWhere((data) => data.id == id);
  } catch (_) {
    return null;
  }
}

