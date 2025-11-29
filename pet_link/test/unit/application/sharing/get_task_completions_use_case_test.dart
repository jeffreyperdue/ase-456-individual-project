import 'package:flutter_test/flutter_test.dart';
import 'package:petfolio/features/sharing/application/get_task_completions_use_case.dart';
import 'package:petfolio/features/sharing/domain/sharing_exceptions.dart';
import 'package:petfolio/features/sharing/domain/task_completion.dart';
import 'package:petfolio/features/sharing/domain/task_completion_repository.dart';

class _FakeTaskCompletionRepository implements TaskCompletionRepository {
  final List<TaskCompletion> completions;
  bool throwOnGet = false;

  _FakeTaskCompletionRepository(this.completions);

  @override
  Future<List<TaskCompletion>> getTaskCompletionsForPet(String petId) async {
    if (throwOnGet) throw Exception('pet error');
    return completions.where((c) => c.petId == petId).toList();
  }

  @override
  Future<List<TaskCompletion>> getTaskCompletionsByUser(String userId) async {
    if (throwOnGet) throw Exception('user error');
    return completions.where((c) => c.completedBy == userId).toList();
  }

  @override
  Future<List<TaskCompletion>> getTaskCompletionsForTask(
    String careTaskId,
  ) async {
    if (throwOnGet) throw Exception('task error');
    return completions.where((c) => c.careTaskId == careTaskId).toList();
  }

  @override
  Future<TaskCompletion?> getTaskCompletion(String completionId) async {
    if (throwOnGet) throw Exception('id error');
    try {
      return completions.firstWhere((c) => c.id == completionId);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<bool> isTaskCompletedByUser(
          String careTaskId, String userId) async =>
      false;

  @override
  Future<TaskCompletion?> getLatestCompletionForTask(String careTaskId) async =>
      null;

  @override
  Future<TaskCompletion> createTaskCompletion(TaskCompletion completion) async =>
      completion;

  @override
  Future<void> updateTaskCompletion(TaskCompletion completion) async {}

  @override
  Future<void> deleteTaskCompletion(String completionId) async {}

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
  group('GetTaskCompletionsUseCase', () {
    late List<TaskCompletion> completions;
    late _FakeTaskCompletionRepository repository;
    late GetTaskCompletionsUseCase useCase;

    setUp(() {
      completions = [
        TaskCompletion(
          id: '1',
          petId: 'pet1',
          careTaskId: 'task1',
          completedBy: 'user1',
          completedAt: DateTime.now().subtract(const Duration(days: 1)),
        ),
        TaskCompletion(
          id: '2',
          petId: 'pet1',
          careTaskId: 'task2',
          completedBy: 'user1',
          completedAt: DateTime.now().subtract(const Duration(days: 10)),
        ),
        TaskCompletion(
          id: '3',
          petId: 'pet2',
          careTaskId: 'task3',
          completedBy: 'user2',
          completedAt: DateTime.now(),
        ),
      ];
      repository = _FakeTaskCompletionRepository(completions);
      useCase = GetTaskCompletionsUseCase(repository);
    });

    test('getCompletionsForPet returns completions for pet', () async {
      final result = await useCase.getCompletionsForPet('pet1');
      expect(result.length, 2);
    });

    test('getCompletionsByUser returns completions for user', () async {
      final result = await useCase.getCompletionsByUser('user1');
      expect(result.length, 2);
    });

    test('getCompletionsForTask returns completions for task', () async {
      final result = await useCase.getCompletionsForTask('task3');
      expect(result.length, 1);
      expect(result.first.id, '3');
    });

    test('getCompletionById returns specific completion', () async {
      final result = await useCase.getCompletionById('1');
      expect(result, isNotNull);
      expect(result!.id, '1');
    });

    test('getCompletionStats computes stats correctly', () async {
      final stats = await useCase.getCompletionStats('pet1');
      expect(stats.totalCompletions, 2);
      expect(stats.uniqueTasksCompleted, 2);
      expect(stats.recentCompletions, greaterThanOrEqualTo(1));
    });

    test('wraps repository errors in AccessTokenException', () async {
      repository.throwOnGet = true;
      expect(
        () => useCase.getCompletionsForPet('pet1'),
        throwsA(isA<AccessTokenException>()),
      );
    });
  });
}


