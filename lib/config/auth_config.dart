/// Authentication Configuration
/// Controls whether to use mock or real Firebase authentication
class AuthConfig {
  /// Set to true to use mock authentication for testing
  /// Set to false to use real Firebase authentication
  static const bool useMockAuth = false;

  /// Mock credentials for testing
  static const String mockEmail = 'test@example.com';
  static const String mockPassword = 'password123';
}
