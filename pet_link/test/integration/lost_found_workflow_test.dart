import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:petfolio/features/lost_found/presentation/state/lost_found_provider.dart';
import 'package:petfolio/features/lost_found/data/lost_report_repository.dart';
import 'package:petfolio/features/lost_found/domain/lost_report.dart';
import 'package:petfolio/features/pets/data/pets_repository.dart';
import 'package:petfolio/features/pets/domain/pet.dart';
import 'package:petfolio/features/pets/presentation/state/pet_list_provider.dart';
import 'package:petfolio/features/auth/domain/user.dart' as app_user;
import '../helpers/test_helpers.dart';
import 'lost_found_workflow_test.mocks.dart';

// Generate mocks
@GenerateMocks([
  LostReportRepository,
  PetsRepository,
])
void main() {
  group('Lost & Found Workflow Integration Tests', () {
    late MockLostReportRepository mockLostReportRepository;
    late MockPetsRepository mockPetsRepository;
    late ProviderContainer container;
    late app_user.User owner;
    late Pet pet;

    setUp(() {
      mockLostReportRepository = MockLostReportRepository();
      mockPetsRepository = MockPetsRepository();
      owner = TestDataFactory.createTestUser();
      pet = TestDataFactory.createTestPet(ownerId: owner.id);

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

    group('Mark Pet as Lost Workflow', () {
      test('should mark pet as lost and create lost report', () async {
        // Arrange
        const lastSeenLocation = 'Central Park';
        const notes = 'Last seen near the pond';

        when(mockPetsRepository.updatePet(pet.id, {'isLost': true}))
            .thenAnswer((_) async => Future<void>.value());
        when(mockLostReportRepository.createLostReport(any))
            .thenAnswer((_) async => Future<void>.value());
        when(mockPetsRepository.watchPetsForOwner(owner.id))
            .thenAnswer((_) => Stream.value([pet]));

        // Act
        final notifier = container.read(lostFoundNotifierProvider.notifier);
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

        // Verify lost report data
        verify(mockLostReportRepository.createLostReport(
          argThat(
            predicate<LostReport>((report) =>
                report.petId == pet.id &&
                report.ownerId == owner.id &&
                report.lastSeenLocation == lastSeenLocation &&
                report.notes == notes),
          ),
        )).called(1);
      });

      test('should mark pet as lost without optional fields', () async {
        // Arrange
        when(mockPetsRepository.updatePet(pet.id, {'isLost': true}))
            .thenAnswer((_) async => Future<void>.value());
        when(mockLostReportRepository.createLostReport(any))
            .thenAnswer((_) async => Future<void>.value());

        // Act
        final notifier = container.read(lostFoundNotifierProvider.notifier);
        await notifier.markPetAsLost(
          pet: pet,
          owner: owner,
        );

        // Assert
        verify(mockPetsRepository.updatePet(pet.id, {'isLost': true}))
            .called(1);
        verify(mockLostReportRepository.createLostReport(
          argThat(
            predicate<LostReport>((report) =>
                report.petId == pet.id &&
                report.ownerId == owner.id &&
                report.lastSeenLocation == null &&
                report.notes == null),
          ),
        )).called(1);
      });

      test('should handle errors during mark as lost', () async {
        // Arrange
        when(mockPetsRepository.updatePet(pet.id, {'isLost': true}))
            .thenThrow(Exception('Failed to update pet'));

        // Act & Assert
        final notifier = container.read(lostFoundNotifierProvider.notifier);
        expect(
          () => notifier.markPetAsLost(
            pet: pet,
            owner: owner,
          ),
          throwsException,
        );

        verify(mockPetsRepository.updatePet(pet.id, {'isLost': true}))
            .called(1);
        verifyNever(mockLostReportRepository.createLostReport(any));
      });
    });

    group('Mark Pet as Found Workflow', () {
      test('should mark pet as found and delete lost report', () async {
        // Arrange
        final lostReport = TestDataFactory.createTestLostReport(
          petId: pet.id,
          ownerId: owner.id,
        );

        when(mockPetsRepository.updatePet(pet.id, {'isLost': false}))
            .thenAnswer((_) async => Future<void>.value());
        when(mockLostReportRepository.deleteLostReport(lostReport.id))
            .thenAnswer((_) async => Future<void>.value());

        // Act
        final notifier = container.read(lostFoundNotifierProvider.notifier);
        await notifier.markPetAsFound(
          pet: pet,
          lostReport: lostReport,
        );

        // Assert
        verify(mockPetsRepository.updatePet(pet.id, {'isLost': false}))
            .called(1);
        verify(mockLostReportRepository.deleteLostReport(lostReport.id))
            .called(1);
      });

      test('should mark pet as found even when lost report is missing', () async {
        // Arrange
        when(mockPetsRepository.updatePet(pet.id, {'isLost': false}))
            .thenAnswer((_) async => Future<void>.value());

        // Act
        final notifier = container.read(lostFoundNotifierProvider.notifier);
        await notifier.markPetAsFound(
          pet: pet,
          lostReport: null,
        );

        // Assert
        verify(mockPetsRepository.updatePet(pet.id, {'isLost': false}))
            .called(1);
        verifyNever(mockLostReportRepository.deleteLostReport(any));
      });

      test('should handle errors during mark as found', () async {
        // Arrange
        final lostReport = TestDataFactory.createTestLostReport(
          petId: pet.id,
          ownerId: owner.id,
        );

        when(mockPetsRepository.updatePet(pet.id, {'isLost': false}))
            .thenThrow(Exception('Failed to update pet'));

        // Act & Assert
        final notifier = container.read(lostFoundNotifierProvider.notifier);
        expect(
          () => notifier.markPetAsFound(
            pet: pet,
            lostReport: lostReport,
          ),
          throwsException,
        );

        verify(mockPetsRepository.updatePet(pet.id, {'isLost': false}))
            .called(1);
        verifyNever(mockLostReportRepository.deleteLostReport(any));
      });
    });

    group('Complete Lost & Found Workflow', () {
      test('should complete full workflow: lost -> found', () async {
        // Arrange
        const lastSeenLocation = 'Central Park';
        const notes = 'Last seen near the pond';
        final lostReport = TestDataFactory.createTestLostReport(
          petId: pet.id,
          ownerId: owner.id,
          lastSeenLocation: lastSeenLocation,
          notes: notes,
        );

        // Mock mark as lost
        when(mockPetsRepository.updatePet(pet.id, {'isLost': true}))
            .thenAnswer((_) async => Future<void>.value());
        when(mockLostReportRepository.createLostReport(any))
            .thenAnswer((_) async => Future<void>.value());

        // Mock mark as found
        when(mockPetsRepository.updatePet(pet.id, {'isLost': false}))
            .thenAnswer((_) async => Future<void>.value());
        when(mockLostReportRepository.deleteLostReport(lostReport.id))
            .thenAnswer((_) async => Future<void>.value());

        // Act - Mark as lost
        final notifier = container.read(lostFoundNotifierProvider.notifier);
        await notifier.markPetAsLost(
          pet: pet,
          owner: owner,
          lastSeenLocation: lastSeenLocation,
          notes: notes,
        );

        // Assert - Verify lost
        verify(mockPetsRepository.updatePet(pet.id, {'isLost': true}))
            .called(1);
        verify(mockLostReportRepository.createLostReport(any)).called(1);

        // Act - Mark as found
        await notifier.markPetAsFound(
          pet: pet,
          lostReport: lostReport,
        );

        // Assert - Verify found
        verify(mockPetsRepository.updatePet(pet.id, {'isLost': false}))
            .called(1);
        verify(mockLostReportRepository.deleteLostReport(lostReport.id))
            .called(1);
      });

      test('should handle workflow with multiple pets', () async {
        // Arrange
        final pet1 = TestDataFactory.createTestPet(
          ownerId: owner.id,
          id: 'pet1',
          name: 'Pet 1',
        );
        final pet2 = TestDataFactory.createTestPet(
          ownerId: owner.id,
          id: 'pet2',
          name: 'Pet 2',
        );
        final lostReport1 = TestDataFactory.createTestLostReport(
          petId: pet1.id,
          ownerId: owner.id,
          id: 'report1',
        );
        // Note: lostReport2 would represent the lost report for pet2 which remains lost
        // but is not needed for this test since we only mark pet1 as found

        // Mock mark as lost for pet1
        when(mockPetsRepository.updatePet(pet1.id, {'isLost': true}))
            .thenAnswer((_) async => Future<void>.value());
        when(mockLostReportRepository.createLostReport(any))
            .thenAnswer((_) async => Future<void>.value());

        // Mock mark as lost for pet2
        when(mockPetsRepository.updatePet(pet2.id, {'isLost': true}))
            .thenAnswer((_) async => Future<void>.value());

        // Mock mark as found for pet1
        when(mockPetsRepository.updatePet(pet1.id, {'isLost': false}))
            .thenAnswer((_) async => Future<void>.value());
        when(mockLostReportRepository.deleteLostReport(lostReport1.id))
            .thenAnswer((_) async => Future<void>.value());

        // Act - Mark pet1 as lost
        final notifier = container.read(lostFoundNotifierProvider.notifier);
        await notifier.markPetAsLost(
          pet: pet1,
          owner: owner,
        );

        // Act - Mark pet2 as lost
        await notifier.markPetAsLost(
          pet: pet2,
          owner: owner,
        );

        // Act - Mark pet1 as found
        await notifier.markPetAsFound(
          pet: pet1,
          lostReport: lostReport1,
        );

        // Assert
        verify(mockPetsRepository.updatePet(pet1.id, {'isLost': true}))
            .called(1);
        verify(mockPetsRepository.updatePet(pet2.id, {'isLost': true}))
            .called(1);
        verify(mockPetsRepository.updatePet(pet1.id, {'isLost': false}))
            .called(1);
        verify(mockLostReportRepository.deleteLostReport(lostReport1.id))
            .called(1);
        // Pet2 should still be lost
        verifyNever(mockPetsRepository.updatePet(pet2.id, {'isLost': false}));
      });
    });

    group('State Management Integration', () {
      test('should update state correctly during workflow', () async {
        // Arrange
        when(mockPetsRepository.updatePet(pet.id, {'isLost': true}))
            .thenAnswer((_) async => Future<void>.value());
        when(mockLostReportRepository.createLostReport(any))
            .thenAnswer((_) async => Future<void>.value());

        // Act
        final notifier = container.read(lostFoundNotifierProvider.notifier);
        final future = notifier.markPetAsLost(
          pet: pet,
          owner: owner,
        );

        // Assert - Check loading state
        final loadingState = container.read(lostFoundNotifierProvider);
        expect(loadingState.isLoading, isTrue);

        // Wait for completion
        await future;

        // Assert - Check final state
        final finalState = container.read(lostFoundNotifierProvider);
        expect(finalState.hasValue, isTrue);
        expect(finalState.isLoading, isFalse);
        expect(finalState.hasError, isFalse);
      });

      test('should handle state updates on error', () async {
        // Arrange
        when(mockPetsRepository.updatePet(pet.id, {'isLost': true}))
            .thenThrow(Exception('Failed to update pet'));

        // Act
        final notifier = container.read(lostFoundNotifierProvider.notifier);
        try {
          await notifier.markPetAsLost(
            pet: pet,
            owner: owner,
          );
        } catch (e) {
          // Expected to throw
        }

        // Assert
        final state = container.read(lostFoundNotifierProvider);
        expect(state.hasError, isTrue);
        expect(state.isLoading, isFalse);
      });
    });
  });
}

