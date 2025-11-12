import 'package:flutter/foundation.dart';

/// Represents a saved dream interpretation that can be persisted locally.
@immutable
class DreamHistoryEntry {
  const DreamHistoryEntry({
    required this.id,
    required this.prompt,
    required this.interpretation,
    required this.createdAt,
    required this.localeCode,
  });

  factory DreamHistoryEntry.create({
    required String prompt,
    required String interpretation,
    required String localeCode,
    DateTime? createdAt,
  }) {
    final timestamp = createdAt ?? DateTime.now();
    return DreamHistoryEntry(
      id: timestamp.microsecondsSinceEpoch.toString(),
      prompt: prompt,
      interpretation: interpretation,
      createdAt: timestamp,
      localeCode: localeCode,
    );
  }

  factory DreamHistoryEntry.fromMap(Map<String, dynamic> map) {
    final createdAtRaw = map['createdAt'];
    DateTime createdAt;
    if (createdAtRaw is int) {
      createdAt = DateTime.fromMillisecondsSinceEpoch(createdAtRaw);
    } else if (createdAtRaw is String) {
      createdAt = DateTime.tryParse(createdAtRaw) ?? DateTime.now();
    } else {
      createdAt = DateTime.now();
    }

    return DreamHistoryEntry(
      id: (map['id'] ?? createdAt.microsecondsSinceEpoch.toString()).toString(),
      prompt: (map['prompt'] ?? '') as String,
      interpretation: (map['interpretation'] ?? '') as String,
      createdAt: createdAt,
      localeCode: (map['localeCode'] ?? 'tr') as String,
    );
  }

  final String id;
  final String prompt;
  final String interpretation;
  final DateTime createdAt;
  final String localeCode;

  Map<String, dynamic> toMap() => <String, dynamic>{
        'id': id,
        'prompt': prompt,
        'interpretation': interpretation,
        'createdAt': createdAt.toIso8601String(),
        'localeCode': localeCode,
      };
}
