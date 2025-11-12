class WeatherReport {
  const WeatherReport({
    required this.temperature,
    required this.condition,
    required this.icon,
    required this.city,
    required this.lastUpdated,
    this.narrative,
    this.vibeTag,
  });

  final double temperature;
  final String condition;
  final String icon;
  final String city;
  final DateTime lastUpdated;
  final String? narrative;
  final String? vibeTag;

  Map<String, dynamic> toJson() {
    return {
      'temperature': temperature,
      'condition': condition,
      'icon': icon,
      'city': city,
      'lastUpdated': lastUpdated.toIso8601String(),
      if (narrative != null) 'narrative': narrative,
      if (vibeTag != null) 'vibeTag': vibeTag,
    };
  }

  static WeatherReport fromJson(Map<String, dynamic> json) {
    return WeatherReport(
      temperature: (json['temperature'] as num?)?.toDouble() ?? 0,
      condition: json['condition'] as String? ?? '',
      icon: json['icon'] as String? ?? '',
      city: json['city'] as String? ?? '',
      lastUpdated:
          DateTime.tryParse(json['lastUpdated'] as String? ?? '') ?? DateTime.now(),
      narrative: json['narrative'] as String?,
      vibeTag: json['vibeTag'] as String?,
    );
  }
}
