import 'package:flutter_test/flutter_test.dart';
import 'package:petfolio/services/local_storage_service.dart';
import 'package:petfolio/app/config.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('LocalStorageService', () {
    late LocalStorageService service;

    setUp(() {
      service = LocalStorageService();
      SharedPreferences.setMockInitialValues({});
    });

    test('hasCompletedOnboarding returns false by default', () async {
      // Act
      final result = await service.hasCompletedOnboarding();

      // Assert
      expect(result, isFalse);
    });

    test('setOnboardingComplete sets onboarding flag', () async {
      // Act
      await service.setOnboardingComplete();
      final result = await service.hasCompletedOnboarding();

      // Assert
      expect(result, isTrue);
    });

    test('resetOnboarding clears onboarding flag', () async {
      // Arrange
      await service.setOnboardingComplete();

      // Act
      await service.resetOnboarding();
      final result = await service.hasCompletedOnboarding();

      // Assert
      expect(result, isFalse);
    });

    test('hasSeenWelcome returns false by default', () async {
      // Act
      final result = await service.hasSeenWelcome();

      // Assert
      expect(result, isFalse);
    });

    test('setHasSeenWelcome sets welcome flag', () async {
      // Act
      await service.setHasSeenWelcome();
      final result = await service.hasSeenWelcome();

      // Assert
      expect(result, isTrue);
    });

    test('resetWelcome clears welcome flag', () async {
      // Arrange
      await service.setHasSeenWelcome();

      // Act
      await service.resetWelcome();
      final result = await service.hasSeenWelcome();

      // Assert
      expect(result, isFalse);
    });

    test('clearOnboardingData clears both onboarding and welcome flags', () async {
      // Arrange
      await service.setOnboardingComplete();
      await service.setHasSeenWelcome();

      // Act
      await service.clearOnboardingData();

      // Assert
      expect(await service.hasCompletedOnboarding(), isFalse);
      expect(await service.hasSeenWelcome(), isFalse);
    });

    test('uses correct preference keys', () async {
      // Act
      await service.setOnboardingComplete();
      await service.setHasSeenWelcome();
      final prefs = await SharedPreferences.getInstance();

      // Assert
      expect(prefs.getBool(PrefsKeys.onboardingComplete), isTrue);
      expect(prefs.getBool(PrefsKeys.hasSeenWelcome), isTrue);
    });
  });
}


