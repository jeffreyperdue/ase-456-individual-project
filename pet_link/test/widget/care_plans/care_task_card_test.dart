// Widget test: Care Task Card
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petfolio/features/care_plans/presentation/widgets/care_task_card.dart';
import 'package:petfolio/features/care_plans/domain/care_task.dart';
import '../../helpers/test_helpers.dart';
import '../../test_config.dart';

void main() {
  group('CareTaskCard Widget Tests', () {
    setUp(() {
      setupTestEnvironment();
    });

    tearDown(() {
      cleanupTestEnvironment();
    });

    testWidgets('should render correctly with task', (
      WidgetTester tester,
    ) async {
      // Arrange: Create a test task
      final testTask = CareTask(
        id: 'test_task_id',
        petId: 'test_pet_id',
        carePlanId: 'test_care_plan_id',
        type: CareTaskType.feeding,
        scheduledTime: DateTime(2024, 1, 15, 8, 0),
        title: 'Morning Feeding',
        description: 'Feed the pet',
        completed: false,
      );

      // Act
      await tester.pumpWidget(
        TestWidgetWrapper(
          child: CareTaskCard(task: testTask),
        ),
      );
      await tester.pumpAndSettle();

      // Assert: Task information is displayed
      expect(find.text('Morning Feeding'), findsOneWidget);
      expect(find.text('Feed the pet'), findsOneWidget);
    });

    testWidgets('should display completed state', (
      WidgetTester tester,
    ) async {
      // Arrange: Completed task
      final completedTask = CareTask(
        id: 'test_task_id',
        petId: 'test_pet_id',
        carePlanId: 'test_care_plan_id',
        type: CareTaskType.feeding,
        scheduledTime: DateTime(2024, 1, 15, 8, 0),
        title: 'Morning Feeding',
        description: 'Feed the pet',
        completed: true,
      );

      // Act
      await tester.pumpWidget(
        TestWidgetWrapper(
          child: CareTaskCard(task: completedTask),
        ),
      );
      await tester.pumpAndSettle();

      // Assert: Task is displayed (completed state is visual)
      expect(find.text('Morning Feeding'), findsOneWidget);
    });

    testWidgets('should display urgent state', (
      WidgetTester tester,
    ) async {
      // Arrange: Urgent task
      final urgentTask = CareTask(
        id: 'test_task_id',
        petId: 'test_pet_id',
        carePlanId: 'test_care_plan_id',
        type: CareTaskType.medication,
        scheduledTime: DateTime(2024, 1, 15, 8, 0),
        title: 'Give Medication',
        description: 'Important medication',
        completed: false,
      );

      // Act
      await tester.pumpWidget(
        TestWidgetWrapper(
          child: CareTaskCard(
            task: urgentTask,
            isUrgent: true,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Assert: Task is displayed with urgent styling
      expect(find.text('Give Medication'), findsOneWidget);
    });

    testWidgets('should handle tap callback', (
      WidgetTester tester,
    ) async {
      // Arrange
      var tapped = false;
      final testTask = CareTask(
        id: 'test_task_id',
        petId: 'test_pet_id',
        carePlanId: 'test_care_plan_id',
        type: CareTaskType.feeding,
        scheduledTime: DateTime(2024, 1, 15, 8, 0),
        title: 'Morning Feeding',
        description: 'Feed the pet',
        completed: false,
      );

      // Act
      await tester.pumpWidget(
        TestWidgetWrapper(
          child: CareTaskCard(
            task: testTask,
            onTap: () => tapped = true,
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byType(CareTaskCard));
      await tester.pump();

      // Assert: Callback was called
      expect(tapped, isTrue);
    });
  });
}

