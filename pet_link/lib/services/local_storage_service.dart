import 'package:shared_preferences/shared_preferences.dart';
import 'package:petfolio/app/config.dart';

/// Service for managing local storage using SharedPreferences.
/// Handles onboarding state and other app-level preferences.
class LocalStorageService {
  /// Get the SharedPreferences instance.
  Future<SharedPreferences> get _prefs async {
    return SharedPreferences.getInstance();
  }

  /// Check if the user has completed onboarding.
  Future<bool> hasCompletedOnboarding() async {
    final prefs = await _prefs;
    return prefs.getBool(PrefsKeys.onboardingComplete) ?? false;
  }

  /// Mark onboarding as complete.
  Future<void> setOnboardingComplete() async {
    final prefs = await _prefs;
    await prefs.setBool(PrefsKeys.onboardingComplete, true);
  }

  /// Reset onboarding state (useful for testing or if user wants to see onboarding again).
  Future<void> resetOnboarding() async {
    final prefs = await _prefs;
    await prefs.remove(PrefsKeys.onboardingComplete);
  }

  /// Check if the user has seen the welcome screen.
  Future<bool> hasSeenWelcome() async {
    final prefs = await _prefs;
    return prefs.getBool(PrefsKeys.hasSeenWelcome) ?? false;
  }

  /// Mark that the user has seen the welcome screen.
  Future<void> setHasSeenWelcome() async {
    final prefs = await _prefs;
    await prefs.setBool(PrefsKeys.hasSeenWelcome, true);
  }

  /// Reset welcome screen state.
  Future<void> resetWelcome() async {
    final prefs = await _prefs;
    await prefs.remove(PrefsKeys.hasSeenWelcome);
  }

  /// Clear all onboarding-related data.
  Future<void> clearOnboardingData() async {
    final prefs = await _prefs;
    await prefs.remove(PrefsKeys.onboardingComplete);
    await prefs.remove(PrefsKeys.hasSeenWelcome);
  }
}
