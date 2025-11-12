import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'dream_history_entry.dart';

class DreamHistoryStore {
  DreamHistoryStore._(this._prefs);

  static const _storageKey = 'dream_history_entries';
  static const _maxEntries = 20;

  final SharedPreferences _prefs;

  static Future<DreamHistoryStore> load() async {
    final prefs = await SharedPreferences.getInstance();
    return DreamHistoryStore._(prefs);
  }

  List<DreamHistoryEntry> readEntries() {
    final raw = _prefs.getStringList(_storageKey);
    if (raw == null) {
      return const [];
    }
    return raw
        .map((entry) {
          try {
            final decoded = jsonDecode(entry) as Map<String, dynamic>;
            return DreamHistoryEntry.fromMap(decoded);
          } catch (_) {
            return null;
          }
        })
        .whereType<DreamHistoryEntry>()
        .toList();
  }

  Future<void> saveEntries(List<DreamHistoryEntry> entries) async {
    final trimmed = entries.take(_maxEntries).toList();
    final serialized = trimmed.map((e) => jsonEncode(e.toMap())).toList();
    await _prefs.setStringList(_storageKey, serialized);
  }
}
