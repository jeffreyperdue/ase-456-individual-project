import 'package:flutter_test/flutter_test.dart';
import 'package:petfolio/features/sharing/application/complete_task_use_case.dart';
import 'package:petfolio/features/sharing/domain/sharing_exceptions.dart';
import 'package:petfolio/features/sharing/domain/task_completion.dart';
import 'package:petfolio/features/sharing/domain/task_completion_repository.dart';

class _FakeTaskCompletionRepository implements TaskCompletionRepository {
  final Map<String, TaskCompletion> completions = {};
  bool throwOnCreate = false;

  @override
  Future<TaskCompletion> createTaskCompletion(TaskCompletion completion) async {
    if (throwOnCreate) {
      throw Exception('create error');
    }
    completions[completion.id] = completion;
    return completion;
  }

  @override
  Future<TaskCompletion?> getTaskCompletion(String completionId) async {
    return completions[completionId];
  }

  @override
  Future<List<TaskCompletion>> getTaskCompletionsForPet(String petId) async {
    return completions.values.where((c) => c.petId == petId).toList();
  }

  @override
  Future<List<TaskCompletion>> getTaskCompletionsByUser(String userId) async {
    return completions.values.where((c) => c.completedBy == userId).toList();
  }

  @override
  Future<List<TaskCompletion>> getTaskCompletionsForTask(
    String careTaskId,
  ) async {
    return completions.values.where((c) => c.careTaskId == careTaskId).toList();
  }

  @override
  Future<void> updateTaskCompletion(TaskCompletion completion) async {
    completions[completion.id] = completion;
  }

  @override
  Future<void> deleteTaskCompletion(String completionId) async {
    completions.remove(completionId);
  }

  @override
  Future<bool> isTaskCompletedByUser(
    String careTaskId,
    String userId,
  ) async {
    return completions.values.any(
      (c) => c.careTaskId == careTaskId && c.completedBy == userId,
    );
  }

  @override
  Future<TaskCompletion?> getLatestCompletionForTask(String careTaskId) async {
    final list = completions.values
        .where((c) => c.careTaskId == careTaskId)
        .toList()
      ..sort((a, b) => b.completedAt.compareTo(a.completedAt));
    return list.isEmpty ? null : list.first;
  }

  @override
  Stream<List<TaskCompletion>> watchTaskCompletionsForPet(String petId) =>
      const Stream.empty();

  @override
  Stream<List<TaskCompletion>> watchTaskCompletionsForTask(
    String careTaskId,
  ) =>
      const Stream.empty();

  @override
  Stream<TaskCompletion?> watchLatestCompletionForTask(String careTaskId) =>
      const Stream.empty();
}

void main() {
  group('CompleteTaskUseCase', () {
    late _FakeTaskCompletionRepository repository;
    late CompleteTaskUseCase useCase;

    setUp(() {
      repository = _FakeTaskCompletionRepository();
      useCase = CompleteTaskUseCase(repository);
    });

    test('execute creates a new TaskCompletion and stores it', () async {
      final result = await useCase.execute(
        petId: 'pet1',
        careTaskId: 'task1',
        completedBy: 'user1',
        notes: 'Done',
      );

      expect(result.petId, 'pet1');
      expect(result.careTaskId, 'task1');
      expect(result.completedBy, 'user1');
      expect(result.notes, 'Done');

      final stored = await repository.getTaskCompletion(result.id);
      expect(stored, equals(result));
    });

    test('execute wraps unknown errors in AccessTokenException', () async {
      repository.throwOnCreate = true;

      expect(
        () => useCase.execute(
          petId: 'pet1',
          careTaskId: 'task1',
          completedBy: 'user1',
        ),
        throwsA(isA<AccessTokenException>()),
      );
    });

    test('isTaskCompleted delegates to repository', () async {
      final completion = TaskCompletion(
        id: '1',
        petId: 'pet1',
        careTaskId: 'task1',
        completedBy: 'user1',
        completedAt: DateTime(2024, 1, 15),
      );
      repository.completions[completion.id] = completion;

      final result = await useCase.isTaskCompleted(
        careTaskId: 'task1',
        userId: 'user1',
      );

      expect(result, isTrue);
    });

    test('getLatestCompletion returns latest completion from repository',
        () async {
      final older = TaskCompletion(
        id: '1',
        petId: 'pet1',
        careTaskId: 'task1',
        completedBy: 'user1',
        completedAt: DateTime(2024, 1, 15),
      );
      final newer = older.copyWith(
        id: '2',
        completedAt: DateTime(2024, 1, 16),
      );
      repository.completions[older.id] = older;
      repository.completions[newer.id] = newer;

      final latest = await useCase.getLatestCompletion(careTaskId: 'task1');

      expect(latest, equals(newer));
    });
  });
}


