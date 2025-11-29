import 'package:flutter_test/flutter_test.dart';
import 'package:petfolio/features/care_plans/domain/care_task.dart';

void main() {
  group('CareTask', () {
    test('copyWith updates selected fields and preserves others', () {
      final original = CareTask(
        id: '1',
        petId: 'pet1',
        carePlanId: 'plan1',
        type: CareTaskType.feeding,
        title: 'Breakfast',
        description: 'Feed breakfast',
        scheduledTime: DateTime(2024, 1, 15, 8, 0),
        notes: 'Original notes',
        completed: false,
      );

      final updated = original.copyWith(
        title: 'Updated Breakfast',
        completed: true,
      );

      expect(updated.id, original.id);
      expect(updated.petId, original.petId);
      expect(updated.carePlanId, original.carePlanId);
      expect(updated.type, original.type);
      expect(updated.title, 'Updated Breakfast');
      expect(updated.description, original.description);
      expect(updated.scheduledTime, original.scheduledTime);
      expect(updated.notes, original.notes);
      expect(updated.completed, isTrue);
    });

    test('equality and hashCode consider all fields', () {
      final a = CareTask(
        id: '1',
        petId: 'pet1',
        carePlanId: 'plan1',
        type: CareTaskType.feeding,
        title: 'Task',
        description: 'Desc',
        scheduledTime: DateTime(2024, 1, 15, 8, 0),
        notes: 'Notes',
        completed: false,
        completedAt: null,
      );

      final b = CareTask(
        id: '1',
        petId: 'pet1',
        carePlanId: 'plan1',
        type: CareTaskType.feeding,
        title: 'Task',
        description: 'Desc',
        scheduledTime: DateTime(2024, 1, 15, 8, 0),
        notes: 'Notes',
        completed: false,
        completedAt: null,
      );

      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('icon returns correct emoji for each type', () {
      final expectations = <CareTaskType, String>{
        CareTaskType.feeding: '🍽️',
        CareTaskType.medication: '💊',
        CareTaskType.exercise: '🏃',
        CareTaskType.grooming: '🛁',
        CareTaskType.vet: '🏥',
        CareTaskType.other: '📝',
      };

      expectations.forEach((type, expectedIcon) {
        final task = CareTask(
          id: '1',
          petId: 'pet1',
          carePlanId: 'plan1',
          type: type,
          title: 'Task',
          description: 'Desc',
          scheduledTime: DateTime(2024, 1, 15, 8, 0),
        );

        expect(task.icon, expectedIcon);
      });
    });

    test('CareTaskTypeExtension.displayName returns human readable name', () {
      expect(CareTaskType.feeding.displayName, 'Feeding');
      expect(CareTaskType.medication.displayName, 'Medication');
      expect(CareTaskType.exercise.displayName, 'Exercise');
      expect(CareTaskType.grooming.displayName, 'Grooming');
      expect(CareTaskType.vet.displayName, 'Vet Appointment');
      expect(CareTaskType.other.displayName, 'Other');
    });
  });
}


