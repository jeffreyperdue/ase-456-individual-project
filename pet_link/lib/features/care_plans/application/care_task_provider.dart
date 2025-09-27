import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/care_plan.dart';
import '../domain/care_task.dart';
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

