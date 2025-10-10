import 'package:flutter_test/flutter_test.dart';
import 'package:petfolio/features/care_plans/domain/care_plan.dart';
import 'package:petfolio/features/care_plans/domain/care_task.dart';
import 'package:petfolio/features/care_plans/domain/feeding_schedule.dart';
import 'package:petfolio/features/care_plans/domain/medication.dart';
import 'package:petfolio/features/care_plans/services/care_task_generator.dart';
import '../../helpers/test_helpers.dart';

void main() {
  group('CareTaskGenerator Tests', () {
    late CareTaskGenerator generator;
    late MockClock mockClock;

    setUp(() {
      mockClock = MockClock();
      generator = CareTaskGenerator(clock: mockClock, maxTasksPerType: 3);
    });

    group('Task Generation Tests', () {
      test('should generate feeding tasks from active schedules', () {
        // Arrange
        mockClock.setTime(DateTime(2024, 1, 15, 10, 0)); // Monday 10:00 AM
        final feedingSchedule = TestDataFactory.createTestFeedingSchedule(
          label: 'Morning Feeding',
          times: ['07:00', '19:00'],
          daysOfWeek: null, // Daily
          active: true,
        );
        final carePlan = TestDataFactory.createTestCarePlan(
          feedingSchedules: [feedingSchedule],
          medications: [],
        );

        // Act
        final tasks = generator.generateUpcomingTasks(carePlan);

        // Assert
        expect(tasks, isNotEmpty);
        final feedingTasks =
            tasks.where((t) => t.type == CareTaskType.feeding).toList();
        expect(feedingTasks.length, greaterThan(0));

        // Check first feeding task
        final firstFeedingTask = feedingTasks.first;
        expect(firstFeedingTask.title, equals('Morning Feeding'));
        expect(firstFeedingTask.description, contains('Feed your pet at'));
        expect(firstFeedingTask.petId, equals(carePlan.petId));
        expect(firstFeedingTask.carePlanId, equals(carePlan.id));
      });

      test('should generate medication tasks from active medications', () {
        // Arrange
        mockClock.setTime(DateTime(2024, 1, 15, 10, 0)); // Monday 10:00 AM
        final medication = TestDataFactory.createTestMedication(
          name: 'Heart Medicine',
          dosage: '1 tablet',
          times: ['08:00'],
          daysOfWeek: [1, 2, 3, 4, 5], // Weekdays only
          active: true,
        );
        final carePlan = TestDataFactory.createTestCarePlan(
          feedingSchedules: [],
          medications: [medication],
        );

        // Act
        final tasks = generator.generateUpcomingTasks(carePlan);

        // Assert
        expect(tasks, isNotEmpty);
        final medicationTasks =
            tasks.where((t) => t.type == CareTaskType.medication).toList();
        expect(medicationTasks.length, greaterThan(0));

        // Check first medication task
        final firstMedicationTask = medicationTasks.first;
        expect(firstMedicationTask.title, equals('Heart Medicine'));
        expect(firstMedicationTask.description, contains('Give 1 tablet'));
        expect(firstMedicationTask.petId, equals(carePlan.petId));
        expect(firstMedicationTask.carePlanId, equals(carePlan.id));
      });

      test('should not generate tasks from inactive schedules', () {
        // Arrange
        final inactiveFeeding = TestDataFactory.createTestFeedingSchedule(
          active: false,
        );
        final inactiveMedication = TestDataFactory.createTestMedication(
          active: false,
        );
        final carePlan = TestDataFactory.createTestCarePlan(
          feedingSchedules: [inactiveFeeding],
          medications: [inactiveMedication],
        );

        // Act
        final tasks = generator.generateUpcomingTasks(carePlan);

        // Assert
        expect(tasks, isEmpty);
      });

      test('should respect maxTasksPerType limit', () {
        // Arrange
        mockClock.setTime(DateTime(2024, 1, 15, 10, 0));
        final feedingSchedule = TestDataFactory.createTestFeedingSchedule(
          times: ['07:00', '08:00', '09:00', '10:00', '11:00'], // 5 times
          active: true,
        );
        final carePlan = TestDataFactory.createTestCarePlan(
          feedingSchedules: [feedingSchedule],
          medications: [],
        );

        // Act
        final tasks = generator.generateUpcomingTasks(carePlan);

        // Assert
        final feedingTasks =
            tasks.where((t) => t.type == CareTaskType.feeding).toList();
        expect(
          feedingTasks.length,
          lessThanOrEqualTo(15),
        ); // 5 times × 3 max per time = 15 tasks
      });

      test('should sort tasks by scheduled time', () {
        // Arrange
        mockClock.setTime(DateTime(2024, 1, 15, 10, 0));
        final feedingSchedule = TestDataFactory.createTestFeedingSchedule(
          times: ['19:00', '07:00'], // Evening first, then morning
          active: true,
        );
        final medication = TestDataFactory.createTestMedication(
          times: ['08:00'], // Between feeding times
          active: true,
        );
        final carePlan = TestDataFactory.createTestCarePlan(
          feedingSchedules: [feedingSchedule],
          medications: [medication],
        );

        // Act
        final tasks = generator.generateUpcomingTasks(carePlan);

        // Assert
        expect(tasks.length, greaterThan(1));
        for (int i = 0; i < tasks.length - 1; i++) {
          expect(
            tasks[i].scheduledTime.isBefore(tasks[i + 1].scheduledTime) ||
                tasks[i].scheduledTime.isAtSameMomentAs(
                  tasks[i + 1].scheduledTime,
                ),
            isTrue,
          );
        }
      });

      test('should generate tasks for specific days of week', () {
        // Arrange
        mockClock.setTime(DateTime(2024, 1, 15, 10, 0)); // Monday 10:00 AM
        final feedingSchedule = TestDataFactory.createTestFeedingSchedule(
          times: ['12:00'],
          daysOfWeek: [1, 3, 5], // Monday, Wednesday, Friday only
          active: true,
        );
        final carePlan = TestDataFactory.createTestCarePlan(
          feedingSchedules: [feedingSchedule],
          medications: [],
        );

        // Act
        final tasks = generator.generateUpcomingTasks(carePlan);

        // Assert
        expect(tasks, isNotEmpty);

        // All tasks should be on Monday, Wednesday, or Friday
        for (final task in tasks) {
          final dayOfWeek = task.scheduledTime.weekday % 7;
          expect([1, 3, 5], contains(dayOfWeek));
        }
      });

      test('should only generate future tasks', () {
        // Arrange
        mockClock.setTime(DateTime(2024, 1, 15, 18, 0)); // Monday 6:00 PM
        final feedingSchedule = TestDataFactory.createTestFeedingSchedule(
          times: ['07:00', '19:00'], // Morning has passed, evening is upcoming
          active: true,
        );
        final carePlan = TestDataFactory.createTestCarePlan(
          feedingSchedules: [feedingSchedule],
          medications: [],
        );

        // Act
        final tasks = generator.generateUpcomingTasks(carePlan);

        // Assert
        expect(tasks, isNotEmpty);

        // All tasks should be in the future
        for (final task in tasks) {
          expect(task.scheduledTime.isAfter(mockClock.nowLocal()), isTrue);
        }
      });
    });

    group('Task Filtering Tests', () {
      late List<CareTask> testTasks;

      setUp(() {
        mockClock.setTime(DateTime(2024, 1, 15, 12, 0)); // Monday noon
        testTasks = [
          // Overdue task (yesterday)
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
          // Recent task (30 minutes ago)
          CareTask(
            id: 'recent_task',
            petId: 'test_pet',
            carePlanId: 'test_plan',
            type: CareTaskType.feeding,
            title: 'Recent Task',
            description: 'Recent',
            scheduledTime: DateTime(2024, 1, 15, 11, 30), // 30 minutes ago
            completed: false,
          ),
          // Task due soon (15 minutes from now)
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
          // Future task (2 hours from now)
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

      test('should get overdue tasks correctly', () {
        // Act
        final overdueTasks = generator.getOverdueTasks(testTasks);

        // Assert
        expect(overdueTasks, hasLength(2)); // overdue_task and recent_task
        expect(
          overdueTasks.map((t) => t.id),
          containsAll(['overdue_task', 'recent_task']),
        );

        // All overdue tasks should be in the past and not completed
        for (final task in overdueTasks) {
          expect(task.scheduledTime.isBefore(mockClock.nowLocal()), isTrue);
          expect(task.completed, isFalse);
        }
      });

      test('should get tasks due soon correctly', () {
        // Act
        final tasksDueSoon = generator.getTasksDueSoon(testTasks);

        // Assert
        expect(tasksDueSoon, hasLength(1)); // due_soon_task
        expect(tasksDueSoon.first.id, equals('due_soon_task'));

        // Task should be in the next 30 minutes and not completed
        final task = tasksDueSoon.first;
        expect(task.scheduledTime.isAfter(mockClock.nowLocal()), isTrue);
        expect(
          task.scheduledTime.isBefore(
            mockClock.nowLocal().add(Duration(minutes: 30)),
          ),
          isTrue,
        );
        expect(task.completed, isFalse);
      });

      test('should get today tasks correctly', () {
        // Act
        final todayTasks = generator.getTodayTasks(testTasks);

        // Assert
        expect(
          todayTasks,
          hasLength(3),
        ); // recent_task, due_soon_task, future_task
        expect(
          todayTasks.map((t) => t.id),
          containsAll(['recent_task', 'due_soon_task', 'future_task']),
        );

        // All tasks should be today and not completed
        final today = DateTime(
          mockClock.nowLocal().year,
          mockClock.nowLocal().month,
          mockClock.nowLocal().day,
        );
        final tomorrow = today.add(Duration(days: 1));

        for (final task in todayTasks) {
          expect(task.scheduledTime.isAfter(today), isTrue);
          expect(task.scheduledTime.isBefore(tomorrow), isTrue);
          expect(task.completed, isFalse);
        }
      });

      test('should exclude completed tasks from filtering', () {
        // Act
        final overdueTasks = generator.getOverdueTasks(testTasks);
        final tasksDueSoon = generator.getTasksDueSoon(testTasks);
        final todayTasks = generator.getTodayTasks(testTasks);

        // Assert
        expect(
          overdueTasks.map((t) => t.id),
          isNot(contains('completed_task')),
        );
        expect(
          tasksDueSoon.map((t) => t.id),
          isNot(contains('completed_task')),
        );
        expect(todayTasks.map((t) => t.id), isNot(contains('completed_task')));
      });
    });

    group('Edge Cases', () {
      test('should handle empty care plan', () {
        // Arrange
        final emptyCarePlan = TestDataFactory.createTestCarePlan(
          feedingSchedules: [],
          medications: [],
        );

        // Act
        final tasks = generator.generateUpcomingTasks(emptyCarePlan);

        // Assert
        expect(tasks, isEmpty);
      });

      test('should handle care plan with no active schedules', () {
        // Arrange
        final inactiveFeeding = TestDataFactory.createTestFeedingSchedule(
          active: false,
        );
        final inactiveMedication = TestDataFactory.createTestMedication(
          active: false,
        );
        final carePlan = TestDataFactory.createTestCarePlan(
          feedingSchedules: [inactiveFeeding],
          medications: [inactiveMedication],
        );

        // Act
        final tasks = generator.generateUpcomingTasks(carePlan);

        // Assert
        expect(tasks, isEmpty);
      });

      test('should handle feeding schedule with empty times', () {
        // Arrange
        final emptyFeedingSchedule = TestDataFactory.createTestFeedingSchedule(
          times: [],
          active: true,
        );
        final carePlan = TestDataFactory.createTestCarePlan(
          feedingSchedules: [emptyFeedingSchedule],
          medications: [],
        );

        // Act
        final tasks = generator.generateUpcomingTasks(carePlan);

        // Assert
        expect(tasks, isEmpty);
      });

      test('should handle medication with empty times', () {
        // Arrange
        final emptyMedication = TestDataFactory.createTestMedication(
          times: [],
          active: true,
        );
        final carePlan = TestDataFactory.createTestCarePlan(
          feedingSchedules: [],
          medications: [emptyMedication],
        );

        // Act
        final tasks = generator.generateUpcomingTasks(carePlan);

        // Assert
        expect(tasks, isEmpty);
      });

      test('should generate unique task IDs', () {
        // Arrange
        final feedingSchedule = TestDataFactory.createTestFeedingSchedule(
          times: ['07:00', '08:00'],
          active: true,
        );
        final carePlan = TestDataFactory.createTestCarePlan(
          feedingSchedules: [feedingSchedule],
          medications: [],
        );

        // Act
        final tasks = generator.generateUpcomingTasks(carePlan);

        // Assert
        final taskIds = tasks.map((t) => t.id).toSet();
        expect(
          taskIds.length,
          equals(tasks.length),
        ); // All IDs should be unique
      });

      test(
        'should include medication with food information in description',
        () {
          // Arrange
          final medicationWithFood = TestDataFactory.createTestMedication(
            name: 'Vitamins',
            dosage: '1 tablet',
            times: ['08:00'],
            active: true,
            withFood: true,
          );
          final medicationWithoutFood = TestDataFactory.createTestMedication(
            name: 'Pain Relief',
            dosage: '0.5 tablet',
            times: ['20:00'],
            active: true,
            withFood: false,
          );
          final carePlan = TestDataFactory.createTestCarePlan(
            feedingSchedules: [],
            medications: [medicationWithFood, medicationWithoutFood],
          );

          // Act
          final tasks = generator.generateUpcomingTasks(carePlan);

          // Assert
          final medicationTasks =
              tasks.where((t) => t.type == CareTaskType.medication).toList();
          expect(
            medicationTasks.length,
            equals(6),
          ); // 2 medications × 3 max per time = 6 tasks

          final withFoodTask = medicationTasks.firstWhere(
            (t) => t.title == 'Vitamins',
          );
          expect(withFoodTask.description, contains('with food'));

          final withoutFoodTask = medicationTasks.firstWhere(
            (t) => t.title == 'Pain Relief',
          );
          expect(withoutFoodTask.description, isNot(contains('with food')));
        },
      );
    });
  });
}
