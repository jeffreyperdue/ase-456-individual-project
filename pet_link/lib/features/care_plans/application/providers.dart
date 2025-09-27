import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../data/care_plan_repository_impl.dart';
import '../domain/care_plan_repository.dart';
import '../services/clock.dart';
import '../services/care_scheduler.dart';
import '../services/care_task_generator.dart';
import 'save_care_plan_use_case.dart';
import 'get_care_plan_use_case.dart';
import 'schedule_reminders_use_case.dart';
import 'generate_care_tasks_use_case.dart';

/// Core dependency providers for CarePlan feature.

/// Clock provider - can be overridden for testing
final clockProvider = Provider<Clock>((ref) => SystemClock());

/// Flutter Local Notifications plugin
final flutterLocalNotificationsProvider =
    Provider<FlutterLocalNotificationsPlugin>((ref) {
      return FlutterLocalNotificationsPlugin();
    });

/// CarePlan Repository
final carePlanRepositoryProvider = Provider<CarePlanRepository>((ref) {
  return CarePlanRepositoryImpl();
});

/// Care Scheduler Service
final careSchedulerProvider = Provider<CareScheduler>((ref) {
  return CareScheduler(
    notifications: ref.read(flutterLocalNotificationsProvider),
    clock: ref.read(clockProvider),
  );
});

/// Care Task Generator Service
final careTaskGeneratorProvider = Provider<CareTaskGenerator>((ref) {
  return CareTaskGenerator(clock: ref.read(clockProvider));
});

/// Use Cases
final saveCarePlanUseCaseProvider = Provider<SaveCarePlanUseCase>((ref) {
  return SaveCarePlanUseCase(ref.read(carePlanRepositoryProvider));
});

final getCarePlanUseCaseProvider = Provider<GetCarePlanUseCase>((ref) {
  return GetCarePlanUseCase(ref.read(carePlanRepositoryProvider));
});

final scheduleRemindersUseCaseProvider = Provider<ScheduleRemindersUseCase>((
  ref,
) {
  return ScheduleRemindersUseCase(ref.read(careSchedulerProvider));
});

final generateCareTasksUseCaseProvider = Provider<GenerateCareTasksUseCase>((
  ref,
) {
  return GenerateCareTasksUseCase(ref.read(careTaskGeneratorProvider));
});

/// Feature flag for notifications (allows shipping core CRUD even if notifications are still stabilizing)
final notificationsEnabledProvider = StateProvider<bool>((ref) => true);

/// Notification permissions state
final notificationPermissionsProvider = StateProvider<bool>((ref) => false);
