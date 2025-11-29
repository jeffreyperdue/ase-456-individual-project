import 'package:flutter_test/flutter_test.dart';
import 'package:petfolio/features/sharing/domain/task_completion.dart';

void main() {
  group('TaskCompletion', () {
    test('copyWith updates selected fields and preserves others', () {
      final original = TaskCompletion(
        id: '1',
        petId: 'pet1',
        careTaskId: 'task1',
        completedBy: 'user1',
        completedAt: DateTime(2024, 1, 15, 12, 0),
        notes: 'Original',
        additionalData: {'key': 'value'},
      );

      final updated = original.copyWith(
        notes: 'Updated',
        completedBy: 'user2',
      );

      expect(updated.id, original.id);
      expect(updated.petId, original.petId);
      expect(updated.careTaskId, original.careTaskId);
      expect(updated.completedBy, 'user2');
      expect(updated.completedAt, original.completedAt);
      expect(updated.notes, 'Updated');
      expect(updated.additionalData, original.additionalData);
    });

    test('toJson and fromJson round-trip correctly', () {
      final completion = TaskCompletion(
        id: '1',
        petId: 'pet1',
        careTaskId: 'task1',
        completedBy: 'user1',
        completedAt: DateTime(2024, 1, 15, 12, 0),
        notes: 'Done',
        additionalData: {'mood': 'happy'},
      );

      final json = completion.toJson();
      final fromJson = TaskCompletion.fromJson(json);

      expect(fromJson, equals(completion));
      expect(fromJson.additionalData, completion.additionalData);
    });
  });
}


