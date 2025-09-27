import '../domain/care_plan.dart';
import '../services/care_scheduler.dart';

/// Use case for scheduling reminders for a care plan.
class ScheduleRemindersUseCase {
  final CareScheduler _scheduler;

  const ScheduleRemindersUseCase(this._scheduler);

  /// Schedule reminders for a care plan.
  /// This will cancel existing reminders and schedule new ones.
  Future<void> execute(CarePlan carePlan) async {
    await _scheduler.scheduleNotificationsForCarePlan(carePlan);
  }

  /// Cancel reminders for a specific pet.
  Future<void> cancelForPet(String petId) async {
    await _scheduler.cancelNotificationsForPet(petId);
  }

  /// Reconcile all reminders (cancel all and reschedule from latest data).
  Future<void> reconcileAll(List<CarePlan> carePlans) async {
    await _scheduler.reconcileNotifications(carePlans);
  }
}

