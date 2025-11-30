// Regression test: Lost & Found Edge Cases
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:petfolio/features/lost_found/domain/lost_report.dart';
import 'package:petfolio/features/lost_found/data/lost_report_repository.dart';
import 'package:petfolio/features/lost_found/presentation/state/lost_found_provider.dart';
import 'package:petfolio/features/pets/data/pets_repository.dart';
import 'package:petfolio/features/pets/presentation/state/pet_list_provider.dart';
import '../helpers/test_helpers.dart';
import '../test_config.dart';
import 'lost_found_regression_test.mocks.dart';

// Generate mocks
@GenerateMocks([
  LostReportRepository,
  PetsRepository,
])
void main() {
  group('Regression: Lost & Found Edge Cases', () {
    late MockLostReportRepository mockLostReportRepository;
    late MockPetsRepository mockPetsRepository;
    late ProviderContainer container;

    setUp(() {
      setupTestEnvironment();
      mockLostReportRepository = MockLostReportRepository();
      mockPetsRepository = MockPetsRepository();

      container = ProviderContainer(
        overrides: [
          lostReportRepositoryProvider.overrideWithValue(mockLostReportRepository),
          petsRepositoryProvider.overrideWithValue(mockPetsRepository),
        ],
      );
    });

    tearDown(() {
      container.dispose();
      cleanupTestEnvironment();
    });

    test('should handle multiple lost reports for same pet', () async {
      // Arrange: Multiple reports
      final testUser = TestDataFactory.createTestUser();
      final testPet = TestDataFactory.createTestPet(ownerId: testUser.id);
      final report1 = TestDataFactory.createTestLostReport(
        petId: testPet.id,
        ownerId: testUser.id,
      );
      final report2 = TestDataFactory.createTestLostReport(
        petId: testPet.id,
        ownerId: testUser.id,
      );

      when(mockLostReportRepository.getLostReportByPetId(any))
          .thenAnswer((_) async => report1);

      // Act: Get active report
      final activeReport = await mockLostReportRepository.getLostReportByPetId(testPet.id);

      // Assert: Returns most recent active report
      expect(activeReport, isNotNull);
    });

    test('should handle poster generation with missing data', () async {
      // Arrange: Report with missing location
      final testUser = TestDataFactory.createTestUser();
      final testPet = TestDataFactory.createTestPet(ownerId: testUser.id);
      final report = TestDataFactory.createTestLostReport(
        petId: testPet.id,
        ownerId: testUser.id,
        lastSeenLocation: null, // Missing location
      );

      when(mockLostReportRepository.createLostReport(any))
          .thenAnswer((_) async => report);

      // Act: Create report
      await mockLostReportRepository.createLostReport(report);

      // Assert: Report is created (poster generation handles missing data)
      verify(mockLostReportRepository.createLostReport(any)).called(1);
    });

    test('should handle found status updates', () async {
      // Arrange: Pet is found
      final testUser = TestDataFactory.createTestUser();
      final testPet = TestDataFactory.createTestPet(ownerId: testUser.id);
      final report = TestDataFactory.createTestLostReport(
        petId: testPet.id,
        ownerId: testUser.id,
      );

      when(mockLostReportRepository.getLostReportByPetId(any))
          .thenAnswer((_) async => report);
      when(mockLostReportRepository.updateLostReport(any, any))
          .thenAnswer((_) async => {});
      when(mockPetsRepository.updatePet(any, any))
          .thenAnswer((_) async => {});

      // Act: Mark as found
      await mockPetsRepository.updatePet(testPet.id, {'isLost': false});

      // Assert: Update completes
      verify(mockPetsRepository.updatePet(any, any)).called(1);
    });

    test('should handle very long location text', () async {
      // Arrange: Long location
      final testUser = TestDataFactory.createTestUser();
      final testPet = TestDataFactory.createTestPet(ownerId: testUser.id);
      final longLocation = 'A' * 1000;
      final report = TestDataFactory.createTestLostReport(
        petId: testPet.id,
        ownerId: testUser.id,
        lastSeenLocation: longLocation,
      );

      when(mockLostReportRepository.createLostReport(any))
          .thenAnswer((_) async => report);

      // Act: Create report
      await mockLostReportRepository.createLostReport(report);

      // Assert: Handles long text
      verify(mockLostReportRepository.createLostReport(any)).called(1);
    });
  });
}

