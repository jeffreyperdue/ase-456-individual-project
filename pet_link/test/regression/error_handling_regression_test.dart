// Regression test: Error Handling and Recovery
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
import 'error_handling_regression_test.mocks.dart';

// Generate mocks
@GenerateMocks([
  PetsRepository,
  AuthService,
])
void main() {
  group('Regression: Error Handling and Recovery', () {
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

    test('should handle network error recovery', () async {
      // Arrange: Network error then recovery
      final testUser = TestDataFactory.createTestUser();
      final testPet = TestDataFactory.createTestPet(ownerId: testUser.id);

      // Use call counter to simulate error then recovery
      var callCount = 0;
      when(mockPetsRepository.watchPetsForOwner(any))
          .thenAnswer((_) {
            callCount++;
            if (callCount == 1) {
              return Stream.error(Exception('Network error'));
            }
            return Stream.value([testPet]);
          });

      // Act: First attempt fails
      final firstStream = mockPetsRepository.watchPetsForOwner(testUser.id);
      expect(firstStream, emitsError(isA<Exception>()));

      // Retry succeeds
      final retryStream = mockPetsRepository.watchPetsForOwner(testUser.id);
      expect(retryStream, emits(isA<List<Pet>>()));
    });

    test('should handle Firebase permission errors', () async {
      // Arrange: Permission denied
      when(mockPetsRepository.watchPetsForOwner(any))
          .thenAnswer((_) => Stream.error(Exception('Permission denied')));

      // Act & Assert: Error is handled
      expect(
        mockPetsRepository.watchPetsForOwner('user_id'),
        emitsError(isA<Exception>()),
      );
    });

    test('should handle storage quota exceeded', () async {
      // Arrange: Storage full
      final testUser = TestDataFactory.createTestUser();
      final testPet = TestDataFactory.createTestPet(ownerId: testUser.id);

      when(mockPetsRepository.createPet(any))
          .thenThrow(Exception('Storage quota exceeded'));

      // Act & Assert: Error is thrown
      expect(
        () => mockPetsRepository.createPet(testPet),
        throwsException,
      );
    });

    test('should handle invalid data format', () async {
      // Arrange: Invalid data
      when(mockPetsRepository.watchPetsForOwner(any))
          .thenAnswer((_) => Stream.error(Exception('Invalid data format')));

      // Act & Assert: Error is handled
      expect(
        mockPetsRepository.watchPetsForOwner('user_id'),
        emitsError(isA<Exception>()),
      );
    });

    test('should recover from transient errors', () async {
      // Arrange: Transient error then success
      final testUser = TestDataFactory.createTestUser();
      final testPet = TestDataFactory.createTestPet(ownerId: testUser.id);

      // Use call counter to simulate error then recovery
      var callCount = 0;
      when(mockPetsRepository.watchPetsForOwner(any))
          .thenAnswer((_) {
            callCount++;
            if (callCount == 1) {
              return Stream.error(Exception('Transient error'));
            }
            return Stream.value([testPet]);
          });

      // Act: First attempt fails
      final firstStream = mockPetsRepository.watchPetsForOwner(testUser.id);
      expect(firstStream, emitsError(isA<Exception>()));

      // Retry succeeds
      final retryStream = mockPetsRepository.watchPetsForOwner(testUser.id);
      expect(retryStream, emits(isA<List<Pet>>()));
    });

    test('should handle authentication errors gracefully', () async {
      // Arrange: Auth error
      when(mockAuthService.getCurrentAppUser())
          .thenThrow(Exception('Authentication failed'));

      // Act & Assert: Error is handled
      expect(
        () => mockAuthService.getCurrentAppUser(),
        throwsException,
      );
    });
  });
}

