/// App Configuration for Demo
///
/// This demo version always runs in mock mode.
/// No environment variables needed - just run the app!
class AppConfig {
  /// Demo mode: Always use mock data, no real backend
  static const bool useSupabaseAuth = false;

  /// Demo mode: No real Node API needed
  static const String nodeApiBaseUrl = 'mock://demo';
}
