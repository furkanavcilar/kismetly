import 'dart:convert';

class DailyAiInsights {
  const DailyAiInsights({
    required this.summary,
    required this.energyFocus,
    required this.cosmicGuide,
    required this.sections,
    required this.generatedAt,
  });

  final String summary;
  final Map<String, String> energyFocus;
  final String cosmicGuide;
  final Map<String, String> sections;
  final DateTime generatedAt;

  Map<String, dynamic> toJson() {
    return {
      'summary': summary,
      'energyFocus': energyFocus,
      'cosmicGuide': cosmicGuide,
      'sections': sections,
      'generatedAt': generatedAt.toIso8601String(),
    };
  }

  static DailyAiInsights fromJson(Map<String, dynamic> json) {
    return DailyAiInsights(
      summary: json['summary'] as String? ?? '',
      energyFocus: (json['energyFocus'] as Map?)
              ?.map((key, value) => MapEntry('$key', '$value')) ??
          <String, String>{},
      cosmicGuide: json['cosmicGuide'] as String? ?? '',
      sections: (json['sections'] as Map?)
              ?.map((key, value) => MapEntry('$key', '$value')) ??
          <String, String>{},
      generatedAt: DateTime.tryParse(json['generatedAt'] as String? ?? '') ??
          DateTime.now(),
    );
  }

  static DailyAiInsights? tryParse(String? raw) {
    if (raw == null) return null;
    try {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      return DailyAiInsights.fromJson(decoded);
    } catch (_) {
      return null;
    }
  }
}
