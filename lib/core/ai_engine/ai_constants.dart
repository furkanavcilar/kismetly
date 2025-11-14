/// Constants for AI Engine configuration
class AIConstants {
  // API timeout durations
  static const Duration textGenerationTimeout = Duration(seconds: 30);
  static const Duration imageGenerationTimeout = Duration(seconds: 60);
  
  // Retry configuration
  static const int maxRetries = 3;
  static const int baseRetryDelayMs = 1000;
  
  // Temperature ranges
  static const double defaultTemperature = 0.95;
  static const double highVariationTemperature = 1.15;
  static const double lowVariationTemperature = 0.85;
  
  // Token limits
  static const int defaultMaxTokens = 4096;
  static const int extendedMaxTokens = 8192;
  static const int horoscopeMaxTokens = 900;
  static const int zodiacMaxTokens = 2000;
  static const int tarotMaxTokens = 1500;
  static const int compatibilityMaxTokens = 1200;
  
  // Cache durations
  static const Duration horoscopeCacheDuration = Duration(hours: 24);
  static const Duration zodiacCacheDuration = Duration(hours: 12);
  static const Duration dailyEnergyCacheDuration = Duration(hours: 24);
  
  // Provider priority order
  static const List<String> providerPriority = [
    'openai',
    'gemini',
    'claude',
  ];
  
  // Feature keys
  static const String featureHoroscope = 'horoscope';
  static const String featureZodiac = 'zodiac';
  static const String featureTarot = 'tarot';
  static const String featureCoffee = 'coffee';
  static const String featurePalm = 'palm';
  static const String featureDream = 'dream';
  static const String featureGreeting = 'greeting';
  static const String featureCompatibility = 'compatibility';
  static const String featureDailyEnergy = 'daily_energy';
}

