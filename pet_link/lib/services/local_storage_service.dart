import 'package:shared_preferences/shared_preferences.dart';

/// Service for managing local storage using SharedPreferences.
/// Handles onboarding state and other app-level preferences.
class LocalStorageService {
  static const String _onboardingCompleteKey = 'onboarding_complete';
  static const String _hasSeenWelcomeKey = 'has_seen_welcome';

  /// Get the SharedPreferences instance.
  Future<SharedPreferences> get _prefs async {
    return await SharedPreferences.getInstance();
  }

  /// Check if the user has completed onboarding.
  Future<bool> hasCompletedOnboarding() async {
    final prefs = await _prefs;
    return prefs.getBool(_onboardingCompleteKey) ?? false;
  }

  /// Mark onboarding as complete.
  Future<void> setOnboardingComplete() async {
    final prefs = await _prefs;
    await prefs.setBool(_onboardingCompleteKey, true);
  }

  /// Reset onboarding state (useful for testing or if user wants to see onboarding again).
  Future<void> resetOnboarding() async {
    final prefs = await _prefs;
    await prefs.remove(_onboardingCompleteKey);
  }

  /// Check if the user has seen the welcome screen.
  Future<bool> hasSeenWelcome() async {
    final prefs = await _prefs;
    return prefs.getBool(_hasSeenWelcomeKey) ?? false;
  }

  /// Mark that the user has seen the welcome screen.
  Future<void> setHasSeenWelcome() async {
    final prefs = await _prefs;
    await prefs.setBool(_hasSeenWelcomeKey, true);
  }

  /// Reset welcome screen state.
  Future<void> resetWelcome() async {
    final prefs = await _prefs;
    await prefs.remove(_hasSeenWelcomeKey);
  }

  /// Clear all onboarding-related data.
  Future<void> clearOnboardingData() async {
    final prefs = await _prefs;
    await prefs.remove(_onboardingCompleteKey);
    await prefs.remove(_hasSeenWelcomeKey);
  }
}
