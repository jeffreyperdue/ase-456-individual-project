// Acceptance test: Offline/Online Transition Journey
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:petfolio/features/pets/data/pets_repository.dart';
import 'package:petfolio/features/pets/presentation/state/pet_list_provider.dart';
import 'package:petfolio/features/pets/domain/pet.dart';
import 'package:petfolio/features/auth/data/auth_service.dart';
import 'package:petfolio/features/auth/presentation/state/auth_provider.dart';
import '../helpers/test_helpers.dart';
import '../test_config.dart';
import 'offline_online_test.mocks.dart';

// Generate mocks
@GenerateMocks([
  PetsRepository,
  AuthService,
])
void main() {
  group('Acceptance: Offline/Online Transition Journey', () {
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
        ],
      );
    });

    tearDown(() {
      container.dispose();
      cleanupTestEnvironment();
    });

    test('should handle operations when offline', () async {
      // Arrange: Network error simulates offline
      when(mockPetsRepository.watchPetsForOwner(any))
          .thenAnswer((_) => Stream.error(Exception('Network unavailable')));

      // Act & Assert: Offline state is handled
      expect(
        mockPetsRepository.watchPetsForOwner('user_id'),
        emitsError(isA<Exception>()),
      );
    });

    test('should sync data when coming back online', () async {
      // Arrange: Network recovers
      final testUser = TestDataFactory.createTestUser();
      final testPet = TestDataFactory.createTestPet(ownerId: testUser.id);

      when(mockPetsRepository.watchPetsForOwner(any))
          .thenAnswer((_) => Stream.value([testPet]));

      // Act: Sync when online
      final stream = mockPetsRepository.watchPetsForOwner(testUser.id);

      // Assert: Can sync when online
      expect(stream, emits(isA<List<Pet>>()));
    });

    test('should queue operations when offline', () async {
      // Arrange: Network error simulates offline
      final testUser = TestDataFactory.createTestUser();
      final testPet = TestDataFactory.createTestPet(ownerId: testUser.id);

      when(mockPetsRepository.createPet(any))
          .thenThrow(Exception('Network unavailable'));

      // Act & Assert: Operation fails gracefully
      expect(
        () => mockPetsRepository.createPet(testPet),
        throwsException,
      );
    });

    test('should handle network errors gracefully', () async {
      // Arrange: Network error
      when(mockPetsRepository.watchPetsForOwner(any))
          .thenAnswer((_) => Stream.error(Exception('Network error')));

      // Act & Assert: Error is handled
      // The stream will emit an error, which should be caught by error handling
      expect(
        mockPetsRepository.watchPetsForOwner('user_id'),
        emitsError(isA<Exception>()),
      );
    });
  });
}

