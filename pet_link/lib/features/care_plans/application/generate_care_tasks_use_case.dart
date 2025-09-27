import '../domain/care_plan.dart';
import '../domain/care_task.dart';
import '../services/care_task_generator.dart';

/// Use case for generating care tasks from care plans.
class GenerateCareTasksUseCase {
  final CareTaskGenerator _generator;

  const GenerateCareTasksUseCase(this._generator);

  /// Generate upcoming care tasks for a care plan.
  List<CareTask> execute(CarePlan carePlan) {
    return _generator.generateUpcomingTasks(carePlan);
  }

  /// Get overdue tasks from a list of tasks.
  List<CareTask> getOverdueTasks(List<CareTask> tasks) {
    return _generator.getOverdueTasks(tasks);
  }

  /// Get tasks due soon (within the next 30 minutes).
  List<CareTask> getTasksDueSoon(List<CareTask> tasks) {
    return _generator.getTasksDueSoon(tasks);
  }

  /// Get tasks for today.
  List<CareTask> getTodayTasks(List<CareTask> tasks) {
    return _generator.getTodayTasks(tasks);
  }
}

