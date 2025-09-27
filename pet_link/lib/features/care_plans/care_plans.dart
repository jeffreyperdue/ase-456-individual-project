// Care Plans Feature - Main Export File
// This file provides easy access to all care plan components

// Domain
export 'domain/care_plan.dart';
export 'domain/feeding_schedule.dart';
export 'domain/medication.dart';
export 'domain/care_task.dart';
export 'domain/care_plan_repository.dart';

// Application Layer
export 'application/providers.dart';
export 'application/care_plan_provider.dart';
export 'application/care_task_provider.dart';
export 'application/pet_with_plan_provider.dart';
export 'application/notification_setup_provider.dart';
export 'application/care_plan_form_provider.dart';

// Use Cases
export 'application/save_care_plan_use_case.dart';
export 'application/get_care_plan_use_case.dart';
export 'application/schedule_reminders_use_case.dart';
export 'application/generate_care_tasks_use_case.dart';

// Data Layer
export 'data/care_plan_repository_impl.dart';

// Services
export 'services/clock.dart';
export 'services/care_scheduler.dart';
export 'services/time_utils.dart';
export 'services/care_task_generator.dart';

// Presentation Layer
export 'presentation/pages/care_plan_form_page.dart';
export 'presentation/pages/care_plan_view_page.dart';
export 'presentation/widgets/time_picker_widget.dart';
export 'presentation/widgets/day_selector_widget.dart';
export 'presentation/widgets/feeding_schedule_widget.dart';
export 'presentation/widgets/medication_widget.dart';
export 'presentation/widgets/care_task_card.dart';

