import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/task_completion.dart';
import '../data/task_completion_repository_impl.dart';
import 'complete_task_use_case.dart';
import 'get_task_completions_use_case.dart';

/// Provider for the task completion repository.
final taskCompletionRepositoryProvider = Provider<TaskCompletionRepositoryImpl>(
  (ref) {
    return TaskCompletionRepositoryImpl();
  },
);

/// Provider for the complete task use case.
final completeTaskUseCaseProvider = Provider<CompleteTaskUseCase>((ref) {
  final repository = ref.watch(taskCompletionRepositoryProvider);
  return CompleteTaskUseCase(repository);
});

/// Provider for the get task completions use case.
final getTaskCompletionsUseCaseProvider = Provider<GetTaskCompletionsUseCase>((
  ref,
) {
  final repository = ref.watch(taskCompletionRepositoryProvider);
  return GetTaskCompletionsUseCase(repository);
});

/// Provider for task completions for a specific pet.
final petTaskCompletionsProvider =
    FutureProvider.family<List<TaskCompletion>, String>((ref, petId) async {
      final useCase = ref.watch(getTaskCompletionsUseCaseProvider);
      return await useCase.getCompletionsForPet(petId);
    });

/// Provider for task completions by a specific user.
final userTaskCompletionsProvider =
    FutureProvider.family<List<TaskCompletion>, String>((ref, userId) async {
      final useCase = ref.watch(getTaskCompletionsUseCaseProvider);
      return await useCase.getCompletionsByUser(userId);
    });

/// Provider for task completion statistics for a pet.
final taskCompletionStatsProvider =
    FutureProvider.family<TaskCompletionStats, String>((ref, petId) async {
      final useCase = ref.watch(getTaskCompletionsUseCaseProvider);
      return await useCase.getCompletionStats(petId);
    });

/// State notifier for managing task completion operations.
class TaskCompletionNotifier
    extends StateNotifier<AsyncValue<TaskCompletion?>> {
  final CompleteTaskUseCase _completeTaskUseCase;

  TaskCompletionNotifier(this._completeTaskUseCase)
    : super(const AsyncValue.data(null));

  /// Complete a task.
  Future<void> completeTask({
    required String petId,
    required String careTaskId,
    required String completedBy,
    String? notes,
    Map<String, dynamic>? additionalData,
  }) async {
    state = const AsyncValue.loading();

    try {
      final completion = await _completeTaskUseCase.execute(
        petId: petId,
        careTaskId: careTaskId,
        completedBy: completedBy,
        notes: notes,
        additionalData: additionalData,
      );

      state = AsyncValue.data(completion);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  /// Check if a task is completed.
  Future<bool> isTaskCompleted({
    required String careTaskId,
    required String userId,
  }) async {
    try {
      return await _completeTaskUseCase.isTaskCompleted(
        careTaskId: careTaskId,
        userId: userId,
      );
    } catch (e) {
      return false;
    }
  }

  /// Clear the current state.
  void clear() {
    state = const AsyncValue.data(null);
  }
}

/// Provider for the task completion notifier.
final taskCompletionNotifierProvider =
    StateNotifierProvider<TaskCompletionNotifier, AsyncValue<TaskCompletion?>>((
      ref,
    ) {
      final useCase = ref.watch(completeTaskUseCaseProvider);
      return TaskCompletionNotifier(useCase);
    });
