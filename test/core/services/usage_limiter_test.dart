import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:kismetly/core/services/usage_limiter.dart';

void main() {
  group('UsageLimiter', () {
    late SharedPreferences prefs;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
    });

    tearDown(() async {
      await prefs.clear();
    });

    test('canUseFeature returns true for first use', () async {
      final limiter = UsageLimiter(prefs: prefs, monetizationService: null);
      final canUse = await limiter.canUseFeature('test_feature');
      expect(canUse, isTrue);
    });

    test('canUseFeature returns false after 3 uses', () async {
      final limiter = UsageLimiter(prefs: prefs, monetizationService: null);
      const featureKey = 'test_feature';

      // Record 3 uses
      await limiter.recordUsage(featureKey);
      await limiter.recordUsage(featureKey);
      await limiter.recordUsage(featureKey);

      // Fourth use should be denied
      final canUse = await limiter.canUseFeature(featureKey);
      expect(canUse, isFalse);
    });

    test('getRemainingUses returns correct count', () async {
      final limiter = UsageLimiter(prefs: prefs, monetizationService: null);
      const featureKey = 'test_feature';

      // Initially 3 uses available
      var remaining = await limiter.getRemainingUses(featureKey);
      expect(remaining, equals(3));

      // After 1 use
      await limiter.recordUsage(featureKey);
      remaining = await limiter.getRemainingUses(featureKey);
      expect(remaining, equals(2));

      // After 3 uses
      await limiter.recordUsage(featureKey);
      await limiter.recordUsage(featureKey);
      remaining = await limiter.getRemainingUses(featureKey);
      expect(remaining, equals(0));
    });

    test('resetUsage clears usage for feature', () async {
      final limiter = UsageLimiter(prefs: prefs, monetizationService: null);
      const featureKey = 'test_feature';

      // Record uses
      await limiter.recordUsage(featureKey);
      await limiter.recordUsage(featureKey);

      // Reset
      await limiter.resetUsage(featureKey);

      // Should be able to use again
      final canUse = await limiter.canUseFeature(featureKey);
      expect(canUse, isTrue);
    });
  });
}

