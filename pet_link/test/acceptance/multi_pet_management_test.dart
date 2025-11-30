// Acceptance test: Multi-Pet Management Journey
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:petfolio/features/pets/presentation/pages/home_page.dart';
import 'package:petfolio/features/pets/domain/pet.dart';
import 'package:petfolio/features/pets/data/pets_repository.dart';
import 'package:petfolio/features/pets/presentation/state/pet_list_provider.dart';
import 'package:petfolio/features/auth/data/auth_service.dart';
import 'package:petfolio/features/auth/presentation/state/auth_provider.dart';
import 'package:petfolio/features/auth/domain/user.dart' as app_user;
import '../helpers/test_helpers.dart';
import '../test_config.dart';
import 'multi_pet_management_test.mocks.dart';

// Generate mocks
@GenerateMocks([
  PetsRepository,
  AuthService,
])
void main() {
  group('Acceptance: Multi-Pet Management Journey', () {
    late MockPetsRepository mockPetsRepository;
    late MockAuthService mockAuthService;
    late ProviderContainer container;

    setUp(() {
      setupTestEnvironment();
      mockPetsRepository = MockPetsRepository();
      mockAuthService = MockAuthService();

      final testUser = TestDataFactory.createTestUser();
      when(mockAuthService.authStateChanges)
          .thenAnswer((_) => const Stream.empty());
      when(mockAuthService.getCurrentAppUser())
          .thenAnswer((_) async => testUser);

      container = ProviderContainer(
        overrides: [
          petsRepositoryProvider.overrideWithValue(mockPetsRepository),
          authServiceProvider.overrideWithValue(mockAuthService),
          // Override authProvider using overrideWithProvider for StateNotifierProvider
          authProvider.overrideWithProvider(
            StateNotifierProvider<AuthNotifier, AsyncValue<app_user.User?>>(
              (ref) {
                final notifier = AuthNotifier(mockAuthService, ref);
                // Set initial state
                notifier.state = AsyncValue.data(testUser);
                return notifier;
              },
            ),
          ),
        ],
      );
    });

    tearDown(() {
      container.dispose();
      cleanupTestEnvironment();
    });



  });
}

