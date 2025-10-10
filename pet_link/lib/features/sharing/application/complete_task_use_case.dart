import '../domain/task_completion.dart';
import '../domain/task_completion_repository.dart';
import '../domain/sharing_exceptions.dart';

/// Use case for completing care tasks by sitters.
class CompleteTaskUseCase {
  final TaskCompletionRepository _repository;

  CompleteTaskUseCase(this._repository);

  /// Complete a care task.
  ///
  /// [petId] - ID of the pet
  /// [careTaskId] - ID of the care task to complete
  /// [completedBy] - User ID of the person completing the task
  /// [notes] - Optional notes from the sitter
  /// [additionalData] - Optional additional data
  Future<TaskCompletion> execute({
    required String petId,
    required String careTaskId,
    required String completedBy,
    String? notes,
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      // Generate unique completion ID
      final completionId = _generateCompletionId();

      // Create the task completion
      final completion = TaskCompletion(
        id: completionId,
        petId: petId,
        careTaskId: careTaskId,
        completedBy: completedBy,
        completedAt: DateTime.now(),
        notes: notes,
        additionalData: additionalData,
      );

      return await _repository.createTaskCompletion(completion);
    } catch (e) {
      if (e is AccessTokenException) {
        rethrow;
      }
      throw AccessTokenException('Failed to complete task: $e');
    }
  }

  /// Check if a task has already been completed by a user.
  Future<bool> isTaskCompleted({
    required String careTaskId,
    required String userId,
  }) async {
    try {
      return await _repository.isTaskCompletedByUser(careTaskId, userId);
    } catch (e) {
      throw AccessTokenException('Failed to check task completion: $e');
    }
  }

  /// Get the latest completion for a task.
  Future<TaskCompletion?> getLatestCompletion({
    required String careTaskId,
  }) async {
    try {
      return await _repository.getLatestCompletionForTask(careTaskId);
    } catch (e) {
      throw AccessTokenException('Failed to get latest completion: $e');
    }
  }

  /// Generate a unique completion ID using timestamp and random string.
  String _generateCompletionId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = (timestamp % 10000).toString().padLeft(4, '0');
    return 'completion_${timestamp}_$random';
  }
}
