import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/care_plan.dart';
import '../domain/care_task.dart';
import '../../sharing/domain/task_completion.dart';
import '../../sharing/application/task_completion_provider.dart';
import 'providers.dart';

/// Provider for generating care tasks from a care plan.
final careTasksProvider = Provider.family<List<CareTask>, CarePlan?>((
  ref,
  carePlan,
) {
  if (carePlan == null) return [];

  final generator = ref.read(generateCareTasksUseCaseProvider);
  return generator.execute(carePlan);
});

/// Provider for overdue care tasks.
final overdueCareTasksProvider = Provider.family<List<CareTask>, CarePlan?>((
  ref,
  carePlan,
) {
  if (carePlan == null) return [];

  final tasks = ref.read(careTasksProvider(carePlan));
  final generator = ref.read(generateCareTasksUseCaseProvider);
  return generator.getOverdueTasks(tasks);
});

/// Provider for care tasks due soon (within 30 minutes).
final careTasksDueSoonProvider = Provider.family<List<CareTask>, CarePlan?>((
  ref,
  carePlan,
) {
  if (carePlan == null) return [];

  final tasks = ref.read(careTasksProvider(carePlan));
  final generator = ref.read(generateCareTasksUseCaseProvider);
  return generator.getTasksDueSoon(tasks);
});

/// Provider for today's care tasks.
final todayCareTasksProvider = Provider.family<List<CareTask>, CarePlan?>((
  ref,
  carePlan,
) {
  if (carePlan == null) return [];

  final tasks = ref.read(careTasksProvider(carePlan));
  final generator = ref.read(generateCareTasksUseCaseProvider);
  return generator.getTodayTasks(tasks);
});

/// Provider for care task statistics.
final careTaskStatsProvider = Provider.family<CareTaskStats, CarePlan?>((
  ref,
  carePlan,
) {
  if (carePlan == null) {
    return const CareTaskStats(total: 0, overdue: 0, dueSoon: 0, today: 0);
  }

  final tasks = ref.read(careTasksProvider(carePlan));
  final overdue = ref.read(overdueCareTasksProvider(carePlan));
  final dueSoon = ref.read(careTasksDueSoonProvider(carePlan));
  final today = ref.read(todayCareTasksProvider(carePlan));

  return CareTaskStats(
    total: tasks.length,
    overdue: overdue.length,
    dueSoon: dueSoon.length,
    today: today.length,
  );
});

/// Enhanced care task with completion status from TaskCompletion records.
class CareTaskWithCompletion {
  final CareTask task;
  final TaskCompletion? latestCompletion;

  CareTaskWithCompletion({
    required this.task,
    this.latestCompletion,
  });

  /// Whether this task is completed.
  bool get isCompleted => latestCompletion != null;

  /// User ID who completed the task (if completed).
  String? get completedByUserId => latestCompletion?.completedBy;

  /// When the task was completed (if completed).
  DateTime? get completedAt => latestCompletion?.completedAt;

  /// Notes from the completion (if any).
  String? get completionNotes => latestCompletion?.notes;

  /// Create a copy with updated fields.
  CareTaskWithCompletion copyWith({
    CareTask? task,
    TaskCompletion? latestCompletion,
  }) {
    return CareTaskWithCompletion(
      task: task ?? this.task,
      latestCompletion: latestCompletion ?? this.latestCompletion,
    );
  }
}

/// Provider that combines CareTask with real-time TaskCompletion status.
final careTaskWithCompletionProvider = StreamProvider.family<
    List<CareTaskWithCompletion>, 
    ({CarePlan? carePlan, String petId})>((ref, params) {
  final carePlan = params.carePlan;
  final petId = params.petId;

  if (carePlan == null) {
    return Stream.value([]);
  }

  // Get care tasks from care plan
  final tasks = ref.read(careTasksProvider(carePlan));

  // Watch task completions for this pet in real-time
  final taskCompletionRepository = ref.read(taskCompletionRepositoryProvider);
  final completionsStream = taskCompletionRepository.watchTaskCompletionsForPet(petId);

  // Combine tasks with completion status in real-time
  return completionsStream.map((completions) {
    return tasks.map((task) {
      // Find the latest completion for this task
      final completion = completions
          .where((c) => c.careTaskId == task.id)
          .fold<TaskCompletion?>(
            null,
            (latest, current) {
              if (latest == null) return current;
              return current.completedAt.isAfter(latest.completedAt) ? current : latest;
            },
          );
      
      return CareTaskWithCompletion(
        task: task,
        latestCompletion: completion,
      );
    }).toList();
  });
});

/// Statistics about care tasks.
class CareTaskStats {
  final int total;
  final int overdue;
  final int dueSoon;
  final int today;

  const CareTaskStats({
    required this.total,
    required this.overdue,
    required this.dueSoon,
    required this.today,
  });

  /// Check if there are any urgent tasks (overdue or due soon).
  bool get hasUrgentTasks => overdue > 0 || dueSoon > 0;

  /// Get a summary string for display.
  String get summary {
    if (total == 0) return 'No tasks';
    if (overdue > 0) return '$overdue overdue, $today today';
    if (dueSoon > 0) return '$dueSoon due soon, $today today';
    return '$today tasks today';
  }
}

