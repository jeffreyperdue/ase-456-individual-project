import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:petfolio/features/auth/domain/user.dart';
import 'package:petfolio/features/pets/domain/pet.dart';
import 'package:petfolio/features/care_plans/domain/care_plan.dart';
import 'package:petfolio/features/care_plans/domain/feeding_schedule.dart';
import 'package:petfolio/features/care_plans/domain/medication.dart';
import 'package:petfolio/features/care_plans/domain/care_task.dart';
import 'package:petfolio/features/care_plans/services/care_task_generator.dart';
import 'package:petfolio/features/care_plans/services/clock.dart';
import 'package:petfolio/features/care_plans/application/generate_care_tasks_use_case.dart';
import '../helpers/test_helpers.dart';
import 'care_plan_workflow_test.mocks.dart';

// Generate mocks
@GenerateMocks([CareTaskGenerator, Clock])
void main() {
  group('Care Plan Workflow Integration Tests', () {
    late MockCareTaskGenerator mockGenerator;
    late MockClock mockClock;
    late GenerateCareTasksUseCase useCase;

    setUp(() {
      mockGenerator = MockCareTaskGenerator();
      mockClock = MockClock();
      useCase = GenerateCareTasksUseCase(mockGenerator);
    });

    group('Care Plan Creation and Management', () {
      test('should create valid care plan with feeding schedules', () {
        // Arrange
        final owner = TestDataFactory.createTestUser();
        final pet = TestDataFactory.createTestPet(ownerId: owner.id);

        final feedingSchedule = TestDataFactory.createTestFeedingSchedule(
          label: 'Morning Feeding',
          times: ['07:00', '19:00'],
          daysOfWeek: null, // Daily
          active: true,
        );

        // Act
        final carePlan = TestDataFactory.createTestCarePlan(
          petId: pet.id,
          ownerId: owner.id,
          feedingSchedules: [feedingSchedule],
          medications: [],
        );

        // Assert
        expect(carePlan.petId, equals(pet.id));
        expect(carePlan.ownerId, equals(owner.id));
        expect(carePlan.feedingSchedules, hasLength(1));
        expect(carePlan.medications, isEmpty);
        expect(carePlan.hasActiveSchedules, isTrue);
        expect(carePlan.activeFeedingSchedules, hasLength(1));
      });

      test('should create valid care plan with medications', () {
        // Arrange
        final owner = TestDataFactory.createTestUser();
        final pet = TestDataFactory.createTestPet(ownerId: owner.id);

        final medication = TestDataFactory.createTestMedication(
          name: 'Heart Medicine',
          dosage: '1 tablet',
          times: ['08:00'],
          daysOfWeek: [1, 2, 3, 4, 5], // Weekdays only
          active: true,
        );

        // Act
        final carePlan = TestDataFactory.createTestCarePlan(
          petId: pet.id,
          ownerId: owner.id,
          feedingSchedules: [],
          medications: [medication],
        );

        // Assert
        expect(carePlan.petId, equals(pet.id));
        expect(carePlan.ownerId, equals(owner.id));
        expect(carePlan.feedingSchedules, isEmpty);
        expect(carePlan.medications, hasLength(1));
        expect(carePlan.hasActiveSchedules, isTrue);
        expect(carePlan.activeMedications, hasLength(1));
      });

      test('should validate care plan data correctly', () {
        // Arrange
        final owner = TestDataFactory.createTestUser();
        final pet = TestDataFactory.createTestPet(ownerId: owner.id);

        final validCarePlan = TestDataFactory.createTestCarePlan(
          petId: pet.id,
          ownerId: owner.id,
        );

        // Act
        final validationErrors = validCarePlan.validate();

        // Assert
        expect(validationErrors, isEmpty);
      });

      test('should detect validation errors in care plan', () {
        // Arrange
        final owner = TestDataFactory.createTestUser();
        final pet = TestDataFactory.createTestPet(ownerId: owner.id);

        final invalidCarePlan = TestDataFactory.createTestCarePlan(
          petId: pet.id,
          ownerId: owner.id,
          feedingSchedules: [], // No feeding schedules
          medications: [
            TestDataFactory.createTestMedication(
              name: '', // Empty name
              dosage: '', // Empty dosage
              times: [], // No times
            ),
          ],
        );

        // Act
        final validationErrors = invalidCarePlan.validate();

        // Assert
        expect(validationErrors, hasLength(4));
        expect(
          validationErrors,
          contains('At least one feeding schedule is required'),
        );
        expect(validationErrors, contains('Medication name is required'));
        expect(validationErrors, contains('Medication dosage is required'));
        expect(
          validationErrors,
          contains('Medication "Test Medication" must have at least one time'),
        );
      });
    });

    group('Care Task Generation Workflow', () {
      test('should generate feeding tasks from care plan', () {
        // Arrange
        final carePlan = TestDataFactory.createTestCarePlan(
          feedingSchedules: [
            TestDataFactory.createTestFeedingSchedule(
              label: 'Morning Feeding',
              times: ['07:00', '19:00'],
              active: true,
            ),
          ],
          medications: [],
        );

        final expectedTasks = [
          CareTask(
            id: 'task_1',
            petId: carePlan.petId,
            carePlanId: carePlan.id,
            type: CareTaskType.feeding,
            title: 'Morning Feeding',
            description: 'Feed your pet at 7:00 AM',
            scheduledTime: DateTime(2024, 1, 15, 7, 0),
            completed: false,
          ),
          CareTask(
            id: 'task_2',
            petId: carePlan.petId,
            carePlanId: carePlan.id,
            type: CareTaskType.feeding,
            title: 'Morning Feeding',
            description: 'Feed your pet at 7:00 PM',
            scheduledTime: DateTime(2024, 1, 15, 19, 0),
            completed: false,
          ),
        ];

        when(
          mockGenerator.generateUpcomingTasks(carePlan),
        ).thenReturn(expectedTasks);

        // Act
        final tasks = useCase.execute(carePlan);

        // Assert
        expect(tasks, equals(expectedTasks));
        expect(tasks, hasLength(2));
        expect(tasks.every((t) => t.type == CareTaskType.feeding), isTrue);

        verify(mockGenerator.generateUpcomingTasks(carePlan)).called(1);
      });

      test('should generate medication tasks from care plan', () {
        // Arrange
        final carePlan = TestDataFactory.createTestCarePlan(
          feedingSchedules: [],
          medications: [
            TestDataFactory.createTestMedication(
              name: 'Vitamins',
              dosage: '1 tablet',
              times: ['08:00'],
              active: true,
            ),
          ],
        );

        final expectedTasks = [
          CareTask(
            id: 'med_task_1',
            petId: carePlan.petId,
            carePlanId: carePlan.id,
            type: CareTaskType.medication,
            title: 'Vitamins',
            description: 'Give 1 tablet with food',
            scheduledTime: DateTime(2024, 1, 15, 8, 0),
            completed: false,
          ),
        ];

        when(
          mockGenerator.generateUpcomingTasks(carePlan),
        ).thenReturn(expectedTasks);

        // Act
        final tasks = useCase.execute(carePlan);

        // Assert
        expect(tasks, equals(expectedTasks));
        expect(tasks, hasLength(1));
        expect(tasks.every((t) => t.type == CareTaskType.medication), isTrue);

        verify(mockGenerator.generateUpcomingTasks(carePlan)).called(1);
      });

      test('should generate mixed feeding and medication tasks', () {
        // Arrange
        final carePlan = TestDataFactory.createTestCarePlan(
          feedingSchedules: [
            TestDataFactory.createTestFeedingSchedule(
              times: ['07:00'],
              active: true,
            ),
          ],
          medications: [
            TestDataFactory.createTestMedication(
              times: ['08:00'],
              active: true,
            ),
          ],
        );

        final expectedTasks = [
          CareTask(
            id: 'feeding_task',
            petId: carePlan.petId,
            carePlanId: carePlan.id,
            type: CareTaskType.feeding,
            title: 'Morning Feeding',
            description: 'Feed your pet at 7:00 AM',
            scheduledTime: DateTime(2024, 1, 15, 7, 0),
            completed: false,
          ),
          CareTask(
            id: 'med_task',
            petId: carePlan.petId,
            carePlanId: carePlan.id,
            type: CareTaskType.medication,
            title: 'Test Medication',
            description: 'Give 1 tablet with food',
            scheduledTime: DateTime(2024, 1, 15, 8, 0),
            completed: false,
          ),
        ];

        when(
          mockGenerator.generateUpcomingTasks(carePlan),
        ).thenReturn(expectedTasks);

        // Act
        final tasks = useCase.execute(carePlan);

        // Assert
        expect(tasks, equals(expectedTasks));
        expect(tasks, hasLength(2));
        expect(tasks.any((t) => t.type == CareTaskType.feeding), isTrue);
        expect(tasks.any((t) => t.type == CareTaskType.medication), isTrue);
      });
    });

    group('Task Filtering Workflow', () {
      late List<CareTask> testTasks;

      setUp(() {
        testTasks = [
          // Overdue task
          CareTask(
            id: 'overdue_task',
            petId: 'test_pet',
            carePlanId: 'test_plan',
            type: CareTaskType.feeding,
            title: 'Overdue Task',
            description: 'Overdue',
            scheduledTime: DateTime(2024, 1, 14, 10, 0), // Yesterday
            completed: false,
          ),
          // Task due soon
          CareTask(
            id: 'due_soon_task',
            petId: 'test_pet',
            carePlanId: 'test_plan',
            type: CareTaskType.medication,
            title: 'Due Soon Task',
            description: 'Due Soon',
            scheduledTime: DateTime(2024, 1, 15, 12, 15), // 15 minutes from now
            completed: false,
          ),
          // Future task
          CareTask(
            id: 'future_task',
            petId: 'test_pet',
            carePlanId: 'test_plan',
            type: CareTaskType.feeding,
            title: 'Future Task',
            description: 'Future',
            scheduledTime: DateTime(2024, 1, 15, 14, 0), // 2 hours from now
            completed: false,
          ),
          // Completed task
          CareTask(
            id: 'completed_task',
            petId: 'test_pet',
            carePlanId: 'test_plan',
            type: CareTaskType.feeding,
            title: 'Completed Task',
            description: 'Completed',
            scheduledTime: DateTime(2024, 1, 15, 10, 0), // 2 hours ago
            completed: true,
          ),
        ];
      });

      test('should filter overdue tasks correctly', () {
        // Arrange
        final expectedOverdueTasks = [testTasks[0]]; // overdue_task

        when(
          mockGenerator.getOverdueTasks(testTasks),
        ).thenReturn(expectedOverdueTasks);

        // Act
        final overdueTasks = useCase.getOverdueTasks(testTasks);

        // Assert
        expect(overdueTasks, equals(expectedOverdueTasks));
        expect(overdueTasks, hasLength(1));
        expect(overdueTasks.first.id, equals('overdue_task'));

        verify(mockGenerator.getOverdueTasks(testTasks)).called(1);
      });

      test('should filter tasks due soon correctly', () {
        // Arrange
        final expectedDueSoonTasks = [testTasks[1]]; // due_soon_task

        when(
          mockGenerator.getTasksDueSoon(testTasks),
        ).thenReturn(expectedDueSoonTasks);

        // Act
        final dueSoonTasks = useCase.getTasksDueSoon(testTasks);

        // Assert
        expect(dueSoonTasks, equals(expectedDueSoonTasks));
        expect(dueSoonTasks, hasLength(1));
        expect(dueSoonTasks.first.id, equals('due_soon_task'));

        verify(mockGenerator.getTasksDueSoon(testTasks)).called(1);
      });

      test('should filter today tasks correctly', () {
        // Arrange
        final expectedTodayTasks = [
          testTasks[1],
          testTasks[2],
        ]; // due_soon_task, future_task

        when(
          mockGenerator.getTodayTasks(testTasks),
        ).thenReturn(expectedTodayTasks);

        // Act
        final todayTasks = useCase.getTodayTasks(testTasks);

        // Assert
        expect(todayTasks, equals(expectedTodayTasks));
        expect(todayTasks, hasLength(2));
        expect(
          todayTasks.map((t) => t.id),
          containsAll(['due_soon_task', 'future_task']),
        );

        verify(mockGenerator.getTodayTasks(testTasks)).called(1);
      });
    });

    group('Care Plan State Management', () {
      test('should update care plan with new feeding schedule', () {
        // Arrange
        final originalCarePlan = TestDataFactory.createTestCarePlan(
          feedingSchedules: [
            TestDataFactory.createTestFeedingSchedule(
              label: 'Morning',
              times: ['07:00'],
            ),
          ],
        );

        final newFeedingSchedule = TestDataFactory.createTestFeedingSchedule(
          label: 'Evening',
          times: ['19:00'],
        );

        // Act
        final updatedCarePlan = originalCarePlan.copyWith(
          feedingSchedules: [
            ...originalCarePlan.feedingSchedules,
            newFeedingSchedule,
          ],
        );

        // Assert
        expect(updatedCarePlan.feedingSchedules, hasLength(2));
        expect(
          updatedCarePlan.feedingSchedules.map((s) => s.label),
          containsAll(['Morning', 'Evening']),
        );
        expect(updatedCarePlan.hasActiveSchedules, isTrue);
      });

      test('should update care plan with new medication', () {
        // Arrange
        final originalCarePlan = TestDataFactory.createTestCarePlan(
          medications: [
            TestDataFactory.createTestMedication(
              name: 'Vitamins',
              times: ['08:00'],
            ),
          ],
        );

        final newMedication = TestDataFactory.createTestMedication(
          name: 'Pain Relief',
          times: ['20:00'],
        );

        // Act
        final updatedCarePlan = originalCarePlan.copyWith(
          medications: [...originalCarePlan.medications, newMedication],
        );

        // Assert
        expect(updatedCarePlan.medications, hasLength(2));
        expect(
          updatedCarePlan.medications.map((m) => m.name),
          containsAll(['Vitamins', 'Pain Relief']),
        );
        expect(updatedCarePlan.hasActiveSchedules, isTrue);
      });

      test('should deactivate schedules in care plan', () {
        // Arrange
        final activeFeeding = TestDataFactory.createTestFeedingSchedule(
          label: 'Morning',
          active: true,
        );
        final activeMedication = TestDataFactory.createTestMedication(
          name: 'Vitamins',
          active: true,
        );

        final carePlan = TestDataFactory.createTestCarePlan(
          feedingSchedules: [activeFeeding],
          medications: [activeMedication],
        );

        // Act
        final updatedCarePlan = carePlan.copyWith(
          feedingSchedules: [activeFeeding.copyWith(active: false)],
          medications: [activeMedication.copyWith(active: false)],
        );

        // Assert
        expect(updatedCarePlan.hasActiveSchedules, isFalse);
        expect(updatedCarePlan.activeFeedingSchedules, isEmpty);
        expect(updatedCarePlan.activeMedications, isEmpty);
      });
    });

    group('Care Plan Summary Generation', () {
      test('should generate summary with feeding and medication counts', () {
        // Arrange
        final carePlan = TestDataFactory.createTestCarePlan(
          feedingSchedules: [
            TestDataFactory.createTestFeedingSchedule(active: true),
            TestDataFactory.createTestFeedingSchedule(active: true),
          ],
          medications: [
            TestDataFactory.createTestMedication(active: true),
            TestDataFactory.createTestMedication(active: true),
            TestDataFactory.createTestMedication(active: true),
          ],
        );

        // Act
        final summary = carePlan.summary;

        // Assert
        expect(summary, contains('2 feedings'));
        expect(summary, contains('3 medications'));
      });

      test('should generate summary with single items', () {
        // Arrange
        final carePlan = TestDataFactory.createTestCarePlan(
          feedingSchedules: [
            TestDataFactory.createTestFeedingSchedule(active: true),
          ],
          medications: [TestDataFactory.createTestMedication(active: true)],
        );

        // Act
        final summary = carePlan.summary;

        // Assert
        expect(summary, contains('1 feeding'));
        expect(summary, contains('1 medication'));
      });

      test('should generate "No active schedules" for inactive care plan', () {
        // Arrange
        final carePlan = TestDataFactory.createTestCarePlan(
          feedingSchedules: [
            TestDataFactory.createTestFeedingSchedule(active: false),
          ],
          medications: [TestDataFactory.createTestMedication(active: false)],
        );

        // Act
        final summary = carePlan.summary;

        // Assert
        expect(summary, equals('No active schedules'));
      });
    });

    group('Error Handling', () {
      test('should handle empty care plan gracefully', () {
        // Arrange
        final emptyCarePlan = TestDataFactory.createTestCarePlan(
          feedingSchedules: [],
          medications: [],
        );

        when(mockGenerator.generateUpcomingTasks(emptyCarePlan)).thenReturn([]);

        // Act
        final tasks = useCase.execute(emptyCarePlan);

        // Assert
        expect(tasks, isEmpty);
        verify(mockGenerator.generateUpcomingTasks(emptyCarePlan)).called(1);
      });

      test('should handle care plan with only inactive schedules', () {
        // Arrange
        final inactiveCarePlan = TestDataFactory.createTestCarePlan(
          feedingSchedules: [
            TestDataFactory.createTestFeedingSchedule(active: false),
          ],
          medications: [TestDataFactory.createTestMedication(active: false)],
        );

        when(
          mockGenerator.generateUpcomingTasks(inactiveCarePlan),
        ).thenReturn([]);

        // Act
        final tasks = useCase.execute(inactiveCarePlan);

        // Assert
        expect(tasks, isEmpty);
        verify(mockGenerator.generateUpcomingTasks(inactiveCarePlan)).called(1);
      });
    });
  });
}
