class AppConfig {
  static const String appName = 'VitalPulse';
  static const String appVersion = '1.0.0';
  
  // Mock API configuration (for future real backend integration)
  static const String apiBaseUrl = 'https://mock.vitalpulse.local/api/v1';
  static const int mockNetworkDelayMs = 800; // Simulate network latency

  // Shared preferences keys
  static const String keyIsDarkMode = 'is_dark_mode';
  static const String keyIsLoggedIn = 'is_logged_in';
}
