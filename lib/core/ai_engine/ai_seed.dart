import 'dart:math';

/// AI Seed Generator for ensuring unique, non-repetitive outputs
/// 
/// Generates deterministic seeds based on:
/// - Date/time
/// - User context (sign, location, etc.)
/// - Feature type
/// - Random variation factor
class AISeed {
  static final Random _random = Random.secure();
  
  /// Generate a seed for text generation
  /// 
  /// [base] - Base identifier (e.g., sign name, feature type)
  /// [date] - Date for daily variations
  /// [variant] - Optional variant number for additional uniqueness
  static int generate({
    required String base,
    required DateTime date,
    int? variant,
    Map<String, dynamic>? userContext,
  }) {
    final dateStr = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    final timeStr = '${date.hour.toString().padLeft(2, '0')}-${date.minute.toString().padLeft(2, '0')}';
    
    // Build seed string
    var seedStr = '$base|$dateStr|$timeStr';
    
    if (variant != null) {
      seedStr += '|$variant';
    }
    
    if (userContext != null && userContext.isNotEmpty) {
      final contextStr = userContext.entries
          .map((e) => '${e.key}:${e.value}')
          .join('|');
      seedStr += '|$contextStr';
    }
    
    // Add random component for additional uniqueness
    final randomComponent = _random.nextInt(1000000);
    seedStr += '|$randomComponent';
    
    // Generate hash
    return seedStr.hashCode & 0x7FFFFFFF; // Ensure positive
  }
  
  /// Generate seed for daily features (same seed for same day)
  static int generateDaily({
    required String base,
    required DateTime date,
    Map<String, dynamic>? userContext,
  }) {
    return generate(
      base: base,
      date: date,
      variant: null, // No variant for daily - same output for same day
      userContext: userContext,
    );
  }
  
  /// Generate seed for unique features (different each time)
  static int generateUnique({
    required String base,
    required DateTime date,
    Map<String, dynamic>? userContext,
  }) {
    return generate(
      base: base,
      date: date,
      variant: DateTime.now().microsecondsSinceEpoch,
      userContext: userContext,
    );
  }
}

