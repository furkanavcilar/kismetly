/// Application configuration flags
/// 
/// IMPORTANT: Set `kIsDevPreview = false` before shipping to production!
/// When false, all daily limits and paywalls will be enforced normally.
/// When true, certain limits are bypassed for testing purposes.
class AppConfig {
  /// Development preview mode - bypasses daily limits for testing
  /// 
  /// Set to `false` before production release!
  /// When true:
  /// - Daily limits for dreams, compatibility, tarot, palm, coffee are bypassed
  /// - Test users (by email domain) can use features without paywall
  static const bool kIsDevPreview = true;

  /// Test user email domains that bypass paywalls in dev mode
  /// 
  /// Only active when `kIsDevPreview == true`
  static const List<String> kTestUserDomains = [
    '@hotmail.com',
    '@gmail.com',
    '@outlook.com',
  ];

  /// Check if a user email should bypass limits (dev mode only)
  static bool shouldBypassLimits(String? userEmail) {
    if (!kIsDevPreview) return false;
    if (userEmail == null || userEmail.isEmpty) return false;
    return kTestUserDomains.any((domain) => userEmail.endsWith(domain));
  }
}

