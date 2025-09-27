import '../domain/care_plan.dart';
import '../domain/care_task.dart';
import 'clock.dart';

/// Service for generating care tasks from care plans.
///
/// This derives the next N tasks that should be performed
/// based on the current time and schedule.
class CareTaskGenerator {
  final Clock _clock;
  final int _maxTasksPerType;

  CareTaskGenerator({required Clock clock, int maxTasksPerType = 3})
    : _clock = clock,
      _maxTasksPerType = maxTasksPerType;

  /// Generate upcoming care tasks for a care plan.
  ///
  /// Returns tasks for the next 7 days, limited by [maxTasksPerType].
  List<CareTask> generateUpcomingTasks(CarePlan carePlan) {
    final tasks = <CareTask>[];

    // Generate feeding tasks
    tasks.addAll(_generateFeedingTasks(carePlan));

    // Generate medication tasks
    tasks.addAll(_generateMedicationTasks(carePlan));

    // Sort by scheduled time
    tasks.sort((a, b) => a.scheduledTime.compareTo(b.scheduledTime));

    return tasks;
  }

  /// Generate feeding tasks from active feeding schedules.
  List<CareTask> _generateFeedingTasks(CarePlan carePlan) {
    final tasks = <CareTask>[];

    for (final schedule in carePlan.activeFeedingSchedules) {
      for (final time in schedule.times) {
        final occurrences = _generateTimeOccurrences(
          time,
          schedule.daysOfWeek,
          daysAhead: 7,
        );

        for (int i = 0; i < occurrences.length && i < _maxTasksPerType; i++) {
          final scheduledTime = occurrences[i];

          tasks.add(
            CareTask(
              id: _generateTaskId(
                carePlan.petId,
                'feeding',
                time,
                scheduledTime,
              ),
              petId: carePlan.petId,
              carePlanId: carePlan.id,
              type: CareTaskType.feeding,
              title: schedule.label ?? 'Feeding',
              description: 'Feed your pet at ${_formatTimeForDisplay(time)}',
              scheduledTime: scheduledTime,
              notes: schedule.notes,
            ),
          );
        }
      }
    }

    return tasks;
  }

  /// Generate medication tasks from active medications.
  List<CareTask> _generateMedicationTasks(CarePlan carePlan) {
    final tasks = <CareTask>[];

    for (final medication in carePlan.activeMedications) {
      for (final time in medication.times) {
        final occurrences = _generateTimeOccurrences(
          time,
          medication.daysOfWeek,
          daysAhead: 7,
        );

        for (int i = 0; i < occurrences.length && i < _maxTasksPerType; i++) {
          final scheduledTime = occurrences[i];

          final description =
              'Give ${medication.dosage}${medication.withFood ? ' with food' : ''}';

          tasks.add(
            CareTask(
              id: _generateTaskId(
                carePlan.petId,
                'medication',
                time,
                scheduledTime,
              ),
              petId: carePlan.petId,
              carePlanId: carePlan.id,
              type: CareTaskType.medication,
              title: medication.name,
              description: description,
              scheduledTime: scheduledTime,
              notes: medication.notes,
            ),
          );
        }
      }
    }

    return tasks;
  }

  /// Generate time occurrences for the next N days.
  List<DateTime> _generateTimeOccurrences(
    String timeString,
    List<int>? daysOfWeek, {
    required int daysAhead,
  }) {
    final parts = timeString.split(':');
    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);

    final now = _clock.nowLocal();
    final occurrences = <DateTime>[];

    for (int i = 0; i < daysAhead; i++) {
      final date = now.add(Duration(days: i));
      final dayOfWeek = date.weekday % 7; // Convert to Sunday = 0 format

      // Check if this day should be included
      if (daysOfWeek == null || daysOfWeek.contains(dayOfWeek)) {
        final occurrence = DateTime(
          date.year,
          date.month,
          date.day,
          hour,
          minute,
        );

        // Only include future occurrences
        if (occurrence.isAfter(now)) {
          occurrences.add(occurrence);
        }
      }
    }

    return occurrences;
  }

  /// Generate a unique task ID.
  String _generateTaskId(
    String petId,
    String type,
    String time,
    DateTime scheduledTime,
  ) {
    final timeStr = scheduledTime.toIso8601String();
    return '${petId}_${type}_${time}_${timeStr}';
  }

  /// Format time for display (helper method).
  String _formatTimeForDisplay(String timeString) {
    final parts = timeString.split(':');
    final hour = int.parse(parts[0]);
    final minute = parts[1];

    if (hour == 0) return '12:$minute AM';
    if (hour < 12) return '$hour:$minute AM';
    if (hour == 12) return '12:$minute PM';
    return '${hour - 12}:$minute PM';
  }

  /// Get overdue tasks from a list of tasks.
  List<CareTask> getOverdueTasks(List<CareTask> tasks) {
    final now = _clock.nowLocal();
    return tasks
        .where((task) => !task.completed && task.scheduledTime.isBefore(now))
        .toList();
  }

  /// Get tasks due soon (within the next 30 minutes).
  List<CareTask> getTasksDueSoon(List<CareTask> tasks) {
    final now = _clock.nowLocal();
    final thirtyMinutesFromNow = now.add(const Duration(minutes: 30));

    return tasks
        .where(
          (task) =>
              !task.completed &&
              task.scheduledTime.isAfter(now) &&
              task.scheduledTime.isBefore(thirtyMinutesFromNow),
        )
        .toList();
  }

  /// Get tasks for today.
  List<CareTask> getTodayTasks(List<CareTask> tasks) {
    final now = _clock.nowLocal();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));

    return tasks
        .where(
          (task) =>
              !task.completed &&
              task.scheduledTime.isAfter(today) &&
              task.scheduledTime.isBefore(tomorrow),
        )
        .toList();
  }
}

