import '../domain/task_completion.dart';
import '../domain/task_completion_repository.dart';
import '../domain/sharing_exceptions.dart';

/// Use case for retrieving task completion data.
class GetTaskCompletionsUseCase {
  final TaskCompletionRepository _repository;

  GetTaskCompletionsUseCase(this._repository);

  /// Get all task completions for a specific pet.
  Future<List<TaskCompletion>> getCompletionsForPet(String petId) async {
    try {
      return await _repository.getTaskCompletionsForPet(petId);
    } catch (e) {
      throw AccessTokenException('Failed to get task completions for pet: $e');
    }
  }

  /// Get all task completions by a specific user.
  Future<List<TaskCompletion>> getCompletionsByUser(String userId) async {
    try {
      return await _repository.getTaskCompletionsByUser(userId);
    } catch (e) {
      throw AccessTokenException('Failed to get task completions by user: $e');
    }
  }

  /// Get task completions for a specific care task.
  Future<List<TaskCompletion>> getCompletionsForTask(String careTaskId) async {
    try {
      return await _repository.getTaskCompletionsForTask(careTaskId);
    } catch (e) {
      throw AccessTokenException('Failed to get task completions for task: $e');
    }
  }

  /// Get a specific task completion by ID.
  Future<TaskCompletion?> getCompletionById(String completionId) async {
    try {
      return await _repository.getTaskCompletion(completionId);
    } catch (e) {
      throw AccessTokenException('Failed to get task completion: $e');
    }
  }

  /// Get completion statistics for a pet.
  Future<TaskCompletionStats> getCompletionStats(String petId) async {
    try {
      final completions = await _repository.getTaskCompletionsForPet(petId);

      final totalCompletions = completions.length;
      final uniqueTasks = completions.map((c) => c.careTaskId).toSet().length;
      final recentCompletions =
          completions
              .where(
                (c) => c.completedAt.isAfter(
                  DateTime.now().subtract(const Duration(days: 7)),
                ),
              )
              .length;

      return TaskCompletionStats(
        totalCompletions: totalCompletions,
        uniqueTasksCompleted: uniqueTasks,
        recentCompletions: recentCompletions,
      );
    } catch (e) {
      throw AccessTokenException('Failed to get completion stats: $e');
    }
  }
}

/// Statistics about task completions.
class TaskCompletionStats {
  final int totalCompletions;
  final int uniqueTasksCompleted;
  final int recentCompletions;

  const TaskCompletionStats({
    required this.totalCompletions,
    required this.uniqueTasksCompleted,
    required this.recentCompletions,
  });
}
