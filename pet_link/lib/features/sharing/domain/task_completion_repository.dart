import 'task_completion.dart';

/// Repository interface for managing task completions.
abstract class TaskCompletionRepository {
  /// Create a new task completion record.
  Future<TaskCompletion> createTaskCompletion(TaskCompletion completion);

  /// Get a task completion by its ID.
  Future<TaskCompletion?> getTaskCompletion(String completionId);

  /// Get all task completions for a specific pet.
  Future<List<TaskCompletion>> getTaskCompletionsForPet(String petId);

  /// Get all task completions by a specific user.
  Future<List<TaskCompletion>> getTaskCompletionsByUser(String userId);

  /// Get task completions for a specific care task.
  Future<List<TaskCompletion>> getTaskCompletionsForTask(String careTaskId);

  /// Update a task completion.
  Future<void> updateTaskCompletion(TaskCompletion completion);

  /// Delete a task completion.
  Future<void> deleteTaskCompletion(String completionId);

  /// Check if a task has been completed by a specific user.
  Future<bool> isTaskCompletedByUser(String careTaskId, String userId);

  /// Get the latest completion for a specific task.
  Future<TaskCompletion?> getLatestCompletionForTask(String careTaskId);

  /// Watch task completions for a specific pet in real-time.
  Stream<List<TaskCompletion>> watchTaskCompletionsForPet(String petId);

  /// Watch task completions for a specific care task in real-time.
  Stream<List<TaskCompletion>> watchTaskCompletionsForTask(String careTaskId);

  /// Watch the latest completion for a specific task in real-time.
  Stream<TaskCompletion?> watchLatestCompletionForTask(String careTaskId);
}
