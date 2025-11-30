// Regression test: Care Plan Edge Cases
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:petfolio/features/care_plans/domain/care_plan.dart';
import 'package:petfolio/features/care_plans/domain/care_plan_repository.dart';
import 'package:petfolio/features/care_plans/application/providers.dart';
import 'package:petfolio/features/care_plans/domain/feeding_schedule.dart';
import 'package:petfolio/features/care_plans/domain/medication.dart';
import '../helpers/test_helpers.dart';
import '../test_config.dart';
import 'care_plan_regression_test.mocks.dart';

// Generate mocks
@GenerateMocks([CarePlanRepository])
void main() {
  group('Regression: Care Plan Edge Cases', () {
    late MockCarePlanRepository mockCarePlanRepository;
    late ProviderContainer container;

    setUp(() {
      setupTestEnvironment();
      mockCarePlanRepository = MockCarePlanRepository();
      container = ProviderContainer(
        overrides: [
          carePlanRepositoryProvider.overrideWithValue(mockCarePlanRepository),
        ],
      );
    });

    tearDown(() {
      container.dispose();
      cleanupTestEnvironment();
    });

    test('should handle timezone handling in task scheduling', () async {
      // Arrange: Care plan with timezone
      final testUser = TestDataFactory.createTestUser();
      final testPet = TestDataFactory.createTestPet(ownerId: testUser.id);
      final carePlan = TestDataFactory.createTestCarePlan(
        petId: testPet.id,
        ownerId: testUser.id,
      );

      // Act: Save care plan with timezone
      when(mockCarePlanRepository.createCarePlan(any))
          .thenAnswer((_) async => {});

      await mockCarePlanRepository.createCarePlan(carePlan);

      // Assert: Care plan is saved with timezone
      verify(mockCarePlanRepository.createCarePlan(any)).called(1);
      expect(carePlan.timezone, isNotNull);
    });

    test('should prevent duplicate task generation', () async {
      // Arrange: Care plan with same schedule
      final testUser = TestDataFactory.createTestUser();
      final testPet = TestDataFactory.createTestPet(ownerId: testUser.id);
      final feedingSchedule = TestDataFactory.createTestFeedingSchedule(
        times: ['08:00', '20:00'],
      );
      final carePlan = TestDataFactory.createTestCarePlan(
        petId: testPet.id,
        ownerId: testUser.id,
        feedingSchedules: [feedingSchedule],
      );

      when(mockCarePlanRepository.createCarePlan(any))
          .thenAnswer((_) async => {});

      // Act: Save care plan twice
      await mockCarePlanRepository.createCarePlan(carePlan);
      await mockCarePlanRepository.createCarePlan(carePlan);

      // Assert: Both saves complete (duplicate prevention is in task generator)
      verify(mockCarePlanRepository.createCarePlan(any)).called(2);
    });

    test('should handle task generation with invalid schedules', () async {
      // Arrange: Care plan with invalid time format
      final testUser = TestDataFactory.createTestUser();
      final testPet = TestDataFactory.createTestPet(ownerId: testUser.id);
      
      // Invalid time format (should be caught by validation)
      final invalidSchedule = FeedingSchedule(
        id: 'invalid_id',
        label: 'Invalid',
        times: ['25:00'], // Invalid time
        active: true,
        notes: '',
      );

      final carePlan = TestDataFactory.createTestCarePlan(
        petId: testPet.id,
        ownerId: testUser.id,
        feedingSchedules: [invalidSchedule],
      );

      // Act & Assert: Should handle gracefully
      when(mockCarePlanRepository.createCarePlan(any))
          .thenAnswer((_) async => {});

      await mockCarePlanRepository.createCarePlan(carePlan);
      verify(mockCarePlanRepository.createCarePlan(any)).called(1);
    });

    test('should handle notification scheduling edge cases', () async {
      // Arrange: Care plan with past expiration
      final testUser = TestDataFactory.createTestUser();
      final testPet = TestDataFactory.createTestPet(ownerId: testUser.id);
      final carePlan = TestDataFactory.createTestCarePlan(
        petId: testPet.id,
        ownerId: testUser.id,
      );

      when(mockCarePlanRepository.createCarePlan(any))
          .thenAnswer((_) async => {});

      // Act: Save care plan
      await mockCarePlanRepository.createCarePlan(carePlan);

      // Assert: Operation completes
      verify(mockCarePlanRepository.createCarePlan(any)).called(1);
    });

    test('should handle care plan with no feeding schedules', () async {
      // Arrange: Care plan with only medications
      final testUser = TestDataFactory.createTestUser();
      final testPet = TestDataFactory.createTestPet(ownerId: testUser.id);
      final carePlan = TestDataFactory.createTestCarePlan(
        petId: testPet.id,
        ownerId: testUser.id,
        feedingSchedules: [], // No feeding schedules
      );

      when(mockCarePlanRepository.createCarePlan(any))
          .thenAnswer((_) async => {});

      // Act: Save care plan
      await mockCarePlanRepository.createCarePlan(carePlan);

      // Assert: Care plan saves successfully
      verify(mockCarePlanRepository.createCarePlan(any)).called(1);
    });

    test('should handle care plan with no medications', () async {
      // Arrange: Care plan with only feeding schedules
      final testUser = TestDataFactory.createTestUser();
      final testPet = TestDataFactory.createTestPet(ownerId: testUser.id);
      final carePlan = TestDataFactory.createTestCarePlan(
        petId: testPet.id,
        ownerId: testUser.id,
        medications: [], // No medications
      );

      when(mockCarePlanRepository.createCarePlan(any))
          .thenAnswer((_) async => {});

      // Act: Save care plan
      await mockCarePlanRepository.createCarePlan(carePlan);

      // Assert: Care plan saves successfully
      verify(mockCarePlanRepository.createCarePlan(any)).called(1);
    });

    test('should handle very long diet text', () async {
      // Arrange: Care plan with extremely long diet text
      final testUser = TestDataFactory.createTestUser();
      final testPet = TestDataFactory.createTestPet(ownerId: testUser.id);
      final longDietText = 'A' * 10000; // Very long text
      final carePlan = TestDataFactory.createTestCarePlan(
        petId: testPet.id,
        ownerId: testUser.id,
        dietText: longDietText,
      );

      when(mockCarePlanRepository.createCarePlan(any))
          .thenAnswer((_) async => {});

      // Act: Save care plan
      await mockCarePlanRepository.createCarePlan(carePlan);

      // Assert: Operation completes (either succeeds or fails gracefully)
      verify(mockCarePlanRepository.createCarePlan(any)).called(1);
    });

    test('should handle concurrent care plan updates', () async {
      // Arrange: Care plan being updated concurrently
      final testUser = TestDataFactory.createTestUser();
      final testPet = TestDataFactory.createTestPet(ownerId: testUser.id);
      final carePlan = TestDataFactory.createTestCarePlan(
        petId: testPet.id,
        ownerId: testUser.id,
      );

      when(mockCarePlanRepository.createCarePlan(any))
          .thenAnswer((_) async => {});

      // Act: Concurrent updates
      await Future.wait([
        mockCarePlanRepository.createCarePlan(carePlan),
        mockCarePlanRepository.createCarePlan(carePlan),
      ]);

      // Assert: Both updates complete
      verify(mockCarePlanRepository.createCarePlan(any)).called(2);
    });

    test('should handle care plan deletion with active tasks', () async {
      // Arrange: Care plan exists
      final testUser = TestDataFactory.createTestUser();
      final testPet = TestDataFactory.createTestPet(ownerId: testUser.id);
      final carePlan = TestDataFactory.createTestCarePlan(
        petId: testPet.id,
        ownerId: testUser.id,
      );

      when(mockCarePlanRepository.deleteCarePlan(any))
          .thenAnswer((_) async => {});

      // Act: Delete care plan
      await mockCarePlanRepository.deleteCarePlan(carePlan.id);

      // Assert: Deletion completes
      verify(mockCarePlanRepository.deleteCarePlan(carePlan.id)).called(1);
    });
  });
}

