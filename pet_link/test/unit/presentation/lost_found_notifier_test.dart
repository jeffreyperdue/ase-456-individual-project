import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:petfolio/features/lost_found/presentation/state/lost_found_provider.dart';
import 'package:petfolio/features/lost_found/data/lost_report_repository.dart';
import 'package:petfolio/features/lost_found/domain/lost_report.dart';
import 'package:petfolio/features/pets/data/pets_repository.dart';
import 'package:petfolio/features/pets/presentation/state/pet_list_provider.dart';
import '../../helpers/test_helpers.dart';
import 'lost_found_notifier_test.mocks.dart';

// Generate mocks
@GenerateMocks([
  LostReportRepository,
  PetsRepository,
])
void main() {
  group('LostFoundNotifier Tests', () {
    late MockLostReportRepository mockLostReportRepository;
    late MockPetsRepository mockPetsRepository;
    late LostFoundNotifier notifier;
    late ProviderContainer container;

    setUp(() {
      mockLostReportRepository = MockLostReportRepository();
      mockPetsRepository = MockPetsRepository();
      notifier = LostFoundNotifier(
        mockLostReportRepository,
        mockPetsRepository,
      );
      container = ProviderContainer(
        overrides: [
          lostReportRepositoryProvider
              .overrideWithValue(mockLostReportRepository),
          petsRepositoryProvider.overrideWithValue(mockPetsRepository),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    group('markPetAsLost', () {
      test('should mark pet as lost successfully', () async {
        // Arrange
        final owner = TestDataFactory.createTestUser();
        final pet = TestDataFactory.createTestPet(ownerId: owner.id);
        const lastSeenLocation = 'Central Park';
        const notes = 'Last seen near the pond';

        when(mockPetsRepository.updatePet(pet.id, {'isLost': true}))
            .thenAnswer((_) async => Future<void>.value());
        when(mockLostReportRepository.createLostReport(any))
            .thenAnswer((_) async => Future<void>.value());

        // Act
        await notifier.markPetAsLost(
          pet: pet,
          owner: owner,
          lastSeenLocation: lastSeenLocation,
          notes: notes,
        );

        // Assert
        verify(mockPetsRepository.updatePet(pet.id, {'isLost': true}))
            .called(1);
        verify(mockLostReportRepository.createLostReport(any)).called(1);
        expect(notifier.state.hasValue, isTrue);
      });

      test('should create lost report with correct data', () async {
        // Arrange
        final owner = TestDataFactory.createTestUser();
        final pet = TestDataFactory.createTestPet(ownerId: owner.id);
        const lastSeenLocation = 'Central Park';
        const notes = 'Last seen near the pond';

        when(mockPetsRepository.updatePet(pet.id, {'isLost': true}))
            .thenAnswer((_) async => Future<void>.value());
        when(mockLostReportRepository.createLostReport(any))
            .thenAnswer((_) async => Future<void>.value());

        // Act
        await notifier.markPetAsLost(
          pet: pet,
          owner: owner,
          lastSeenLocation: lastSeenLocation,
          notes: notes,
        );

        // Assert
        verify(mockLostReportRepository.createLostReport(
          argThat(
            predicate((report) =>
                report is LostReport &&
                report.petId == pet.id &&
                report.ownerId == owner.id &&
                report.lastSeenLocation == lastSeenLocation &&
                report.notes == notes),
          ),
        )).called(1);
      });

      test('should create lost report without optional fields', () async {
        // Arrange
        final owner = TestDataFactory.createTestUser();
        final pet = TestDataFactory.createTestPet(ownerId: owner.id);

        when(mockPetsRepository.updatePet(pet.id, {'isLost': true}))
            .thenAnswer((_) async => Future<void>.value());
        when(mockLostReportRepository.createLostReport(any))
            .thenAnswer((_) async => Future<void>.value());

        // Act
        await notifier.markPetAsLost(
          pet: pet,
          owner: owner,
        );

        // Assert
        verify(mockLostReportRepository.createLostReport(
          argThat(
            predicate((report) =>
                report is LostReport &&
                report.petId == pet.id &&
                report.ownerId == owner.id &&
                report.lastSeenLocation == null &&
                report.notes == null),
          ),
        )).called(1);
      });

      test('should set loading state during operation', () async {
        // Arrange
        final owner = TestDataFactory.createTestUser();
        final pet = TestDataFactory.createTestPet(ownerId: owner.id);

        when(mockPetsRepository.updatePet(pet.id, {'isLost': true}))
            .thenAnswer((_) async => Future.delayed(
                  const Duration(milliseconds: 100),
                ));
        when(mockLostReportRepository.createLostReport(any))
            .thenAnswer((_) async => Future<void>.value());

        // Act
        final future = notifier.markPetAsLost(
          pet: pet,
          owner: owner,
        );

        // Assert - check loading state
        expect(notifier.state.isLoading, isTrue);

        // Wait for completion
        await future;

        // Assert - check final state
        expect(notifier.state.hasValue, isTrue);
      });

      test('should handle pet update failure', () async {
        // Arrange
        final owner = TestDataFactory.createTestUser();
        final pet = TestDataFactory.createTestPet(ownerId: owner.id);

        when(mockPetsRepository.updatePet(pet.id, {'isLost': true}))
            .thenThrow(Exception('Failed to update pet'));

        // Act & Assert
        expect(
          () => notifier.markPetAsLost(
            pet: pet,
            owner: owner,
          ),
          throwsException,
        );

        expect(notifier.state.hasError, isTrue);
        verifyNever(mockLostReportRepository.createLostReport(any));
      });

      test('should handle lost report creation failure', () async {
        // Arrange
        final owner = TestDataFactory.createTestUser();
        final pet = TestDataFactory.createTestPet(ownerId: owner.id);

        when(mockPetsRepository.updatePet(pet.id, {'isLost': true}))
            .thenAnswer((_) async => Future<void>.value());
        when(mockLostReportRepository.createLostReport(any))
            .thenThrow(Exception('Failed to create lost report'));

        // Act & Assert
        try {
          await notifier.markPetAsLost(
            pet: pet,
            owner: owner,
          );
          fail('Expected exception to be thrown');
        } catch (e) {
          // Exception was thrown as expected
        }

        expect(notifier.state.hasError, isTrue);
      });
    });

    group('markPetAsFound', () {
      test('should mark pet as found successfully', () async {
        // Arrange
        final owner = TestDataFactory.createTestUser();
        final pet = TestDataFactory.createTestPet(ownerId: owner.id);
        final lostReport = TestDataFactory.createTestLostReport(
          petId: pet.id,
          ownerId: owner.id,
        );

        when(mockPetsRepository.updatePet(pet.id, {'isLost': false}))
            .thenAnswer((_) async => Future<void>.value());
        when(mockLostReportRepository.deleteLostReport(lostReport.id))
            .thenAnswer((_) async => Future<void>.value());

        // Act
        await notifier.markPetAsFound(
          pet: pet,
          lostReport: lostReport,
        );

        // Assert
        verify(mockPetsRepository.updatePet(pet.id, {'isLost': false}))
            .called(1);
        verify(mockLostReportRepository.deleteLostReport(lostReport.id))
            .called(1);
        expect(notifier.state.hasValue, isTrue);
      });

      test('should handle missing lost report gracefully', () async {
        // Arrange
        final owner = TestDataFactory.createTestUser();
        final pet = TestDataFactory.createTestPet(ownerId: owner.id);

        when(mockPetsRepository.updatePet(pet.id, {'isLost': false}))
            .thenAnswer((_) async => Future<void>.value());

        // Act
        await notifier.markPetAsFound(
          pet: pet,
          lostReport: null,
        );

        // Assert
        verify(mockPetsRepository.updatePet(pet.id, {'isLost': false}))
            .called(1);
        verifyNever(mockLostReportRepository.deleteLostReport(any));
        expect(notifier.state.hasValue, isTrue);
      });

      test('should set loading state during operation', () async {
        // Arrange
        final owner = TestDataFactory.createTestUser();
        final pet = TestDataFactory.createTestPet(ownerId: owner.id);
        final lostReport = TestDataFactory.createTestLostReport(
          petId: pet.id,
          ownerId: owner.id,
        );

        when(mockPetsRepository.updatePet(pet.id, {'isLost': false}))
            .thenAnswer((_) async => Future.delayed(
                  const Duration(milliseconds: 100),
                ));
        when(mockLostReportRepository.deleteLostReport(lostReport.id))
            .thenAnswer((_) async => Future<void>.value());

        // Act
        final future = notifier.markPetAsFound(
          pet: pet,
          lostReport: lostReport,
        );

        // Assert - check loading state
        expect(notifier.state.isLoading, isTrue);

        // Wait for completion
        await future;

        // Assert - check final state
        expect(notifier.state.hasValue, isTrue);
      });

      test('should handle pet update failure', () async {
        // Arrange
        final owner = TestDataFactory.createTestUser();
        final pet = TestDataFactory.createTestPet(ownerId: owner.id);
        final lostReport = TestDataFactory.createTestLostReport(
          petId: pet.id,
          ownerId: owner.id,
        );

        when(mockPetsRepository.updatePet(pet.id, {'isLost': false}))
            .thenThrow(Exception('Failed to update pet'));

        // Act & Assert
        expect(
          () => notifier.markPetAsFound(
            pet: pet,
            lostReport: lostReport,
          ),
          throwsException,
        );

        expect(notifier.state.hasError, isTrue);
        verifyNever(mockLostReportRepository.deleteLostReport(any));
      });

      test('should handle lost report deletion failure', () async {
        // Arrange
        final owner = TestDataFactory.createTestUser();
        final pet = TestDataFactory.createTestPet(ownerId: owner.id);
        final lostReport = TestDataFactory.createTestLostReport(
          petId: pet.id,
          ownerId: owner.id,
        );

        when(mockPetsRepository.updatePet(pet.id, {'isLost': false}))
            .thenAnswer((_) async => Future<void>.value());
        when(mockLostReportRepository.deleteLostReport(lostReport.id))
            .thenThrow(Exception('Failed to delete lost report'));

        // Act & Assert
        try {
          await notifier.markPetAsFound(
            pet: pet,
            lostReport: lostReport,
          );
          fail('Expected exception to be thrown');
        } catch (e) {
          // Exception was thrown as expected
        }

        expect(notifier.state.hasError, isTrue);
      });
    });

    group('State Management', () {
      test('should initialize with data state', () {
        // Assert
        expect(notifier.state.hasValue, isTrue);
        expect(notifier.state.isLoading, isFalse);
        expect(notifier.state.hasError, isFalse);
      });

      test('should update state correctly on success', () async {
        // Arrange
        final owner = TestDataFactory.createTestUser();
        final pet = TestDataFactory.createTestPet(ownerId: owner.id);

        when(mockPetsRepository.updatePet(pet.id, {'isLost': true}))
            .thenAnswer((_) async => Future<void>.value());
        when(mockLostReportRepository.createLostReport(any))
            .thenAnswer((_) async => Future<void>.value());

        // Act
        await notifier.markPetAsLost(
          pet: pet,
          owner: owner,
        );

        // Assert
        expect(notifier.state.hasValue, isTrue);
        expect(notifier.state.isLoading, isFalse);
        expect(notifier.state.hasError, isFalse);
      });

      test('should update state correctly on error', () async {
        // Arrange
        final owner = TestDataFactory.createTestUser();
        final pet = TestDataFactory.createTestPet(ownerId: owner.id);

        when(mockPetsRepository.updatePet(pet.id, {'isLost': true}))
            .thenThrow(Exception('Failed to update pet'));

        // Act
        try {
          await notifier.markPetAsLost(
            pet: pet,
            owner: owner,
          );
        } catch (e) {
          // Expected to throw
        }

        // Assert
        expect(notifier.state.hasError, isTrue);
        expect(notifier.state.isLoading, isFalse);
      });
    });
  });
}

