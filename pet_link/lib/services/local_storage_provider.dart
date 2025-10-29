import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petfolio/services/local_storage_service.dart';

/// Provider for the LocalStorageService.
final localStorageServiceProvider = Provider<LocalStorageService>((ref) {
  return LocalStorageService();
});

/// Provider to check if onboarding is complete.
final onboardingCompleteProvider = FutureProvider<bool>((ref) async {
  final localStorage = ref.watch(localStorageServiceProvider);
  return await localStorage.hasCompletedOnboarding();
});

/// Provider to check if user has seen welcome screen.
final hasSeenWelcomeProvider = FutureProvider<bool>((ref) async {
  final localStorage = ref.watch(localStorageServiceProvider);
  return await localStorage.hasSeenWelcome();
});

