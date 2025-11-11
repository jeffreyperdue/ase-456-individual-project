import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../pets/domain/pet.dart';
import '../../domain/care_plan.dart';
import '../../application/care_plan_provider.dart';
import '../../application/care_task_provider.dart';
import '../widgets/care_task_card.dart';
import 'care_plan_form_page.dart';

/// Page for viewing a care plan and upcoming tasks.
class CarePlanViewPage extends ConsumerWidget {
  final Pet pet;

  const CarePlanViewPage({super.key, required this.pet});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final carePlanAsync = ref.watch(carePlanForPetProvider(pet.id));

    return Scaffold(
      appBar: AppBar(
        title: Text('${pet.name}\'s Care Plan'),
        actions: [
          IconButton(
            onPressed: () => _navigateToEditPage(context),
            icon: const Icon(Icons.edit),
            tooltip: 'Edit care plan',
          ),
        ],
      ),
      body: carePlanAsync.when(
        data: (carePlan) {
          if (carePlan == null) {
            return _buildNoCarePlanState(context);
          }
          return _buildCarePlanContent(context, ref, carePlan);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => _buildErrorState(context, error),
      ),
    );
  }

  Widget _buildNoCarePlanState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.pets,
              size: 80,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 24),
            Text(
              'No Care Plan Yet',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              'Create a care plan for ${pet.name} to set up feeding schedules, medications, and reminders.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: () => _navigateToEditPage(context),
              icon: const Icon(Icons.add),
              label: const Text('Create Care Plan'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCarePlanContent(
    BuildContext context,
    WidgetRef ref,
    CarePlan carePlan,
  ) {
    // Use real-time provider for tasks with completion status
    final tasksWithCompletionAsync = ref.watch(
      careTaskWithCompletionProvider((carePlan: carePlan, petId: pet.id)),
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Care plan summary
          _buildCarePlanSummary(context, carePlan),

          const SizedBox(height: 24),

          // Real-time tasks with completion status
          tasksWithCompletionAsync.when(
            data: (tasksWithCompletion) {
              // Filter tasks into categories
              final overdueTasks = tasksWithCompletion
                  .where((t) => t.task.isOverdue && !t.isCompleted)
                  .toList();
              final dueSoonTasks = tasksWithCompletion
                  .where((t) => t.task.isDueSoon && !t.isCompleted)
                  .toList();
              final todayTasks = tasksWithCompletion
                  .where((t) {
                    final now = DateTime.now();
                    final taskDate = DateTime(
                      t.task.scheduledTime.year,
                      t.task.scheduledTime.month,
                      t.task.scheduledTime.day,
                    );
                    final today = DateTime(now.year, now.month, now.day);
                    return taskDate == today && !t.isCompleted;
                  })
                  .toList();
              final upcomingTasks = tasksWithCompletion
                  .where((t) =>
                      !t.isCompleted &&
                      t.task.scheduledTime.isAfter(DateTime.now()))
                  .take(10)
                  .toList();

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Urgent tasks (overdue + due soon)
                  if (overdueTasks.isNotEmpty || dueSoonTasks.isNotEmpty) ...[
                    _buildUrgentTasksSection(
                      context,
                      overdueTasks,
                      dueSoonTasks,
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Today's tasks
                  if (todayTasks.isNotEmpty) ...[
                    _buildTodayTasksSection(context, todayTasks),
                    const SizedBox(height: 24),
                  ],

                  // All upcoming tasks
                  if (upcomingTasks.isNotEmpty) ...[
                    _buildUpcomingTasksSection(context, upcomingTasks),
                    const SizedBox(height: 24),
                  ],

                  // Care plan details
                  _buildCarePlanDetails(context, carePlan),
                ],
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => _buildErrorState(context, error),
          ),
        ],
      ),
    );
  }

  Widget _buildCarePlanSummary(BuildContext context, CarePlan carePlan) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 25,
                  backgroundImage:
                      pet.photoUrl != null ? NetworkImage(pet.photoUrl!) : null,
                  child:
                      pet.photoUrl == null
                          ? Text(
                            pet.name.isNotEmpty
                                ? pet.name[0].toUpperCase()
                                : '?',
                            style: Theme.of(context).textTheme.titleLarge,
                          )
                          : null,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        pet.name,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        carePlan.summary,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => _navigateToEditPage(context),
                  icon: const Icon(Icons.edit),
                  tooltip: 'Edit care plan',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUrgentTasksSection(
    BuildContext context,
    List<CareTaskWithCompletion> overdueTasks,
    List<CareTaskWithCompletion> dueSoonTasks,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.priority_high,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(width: 8),
            Text(
              'Urgent Tasks',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.error,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        if (overdueTasks.isNotEmpty) ...[
          Text(
            'Overdue',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Theme.of(context).colorScheme.error,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          ...overdueTasks.map(
            (taskWithCompletion) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: CareTaskCard(
                taskWithCompletion: taskWithCompletion,
                isUrgent: true,
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],

        if (dueSoonTasks.isNotEmpty) ...[
          Text(
            'Due Soon',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          ...dueSoonTasks.map(
            (taskWithCompletion) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: CareTaskCard(
                taskWithCompletion: taskWithCompletion,
                isUrgent: true,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildTodayTasksSection(
    BuildContext context,
    List<CareTaskWithCompletion> todayTasks,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.today, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 8),
            Text(
              'Today\'s Tasks',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...todayTasks.map(
          (taskWithCompletion) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: CareTaskCard(taskWithCompletion: taskWithCompletion),
          ),
        ),
      ],
    );
  }

  Widget _buildUpcomingTasksSection(
    BuildContext context,
    List<CareTaskWithCompletion> upcomingTasks,
  ) {
    if (upcomingTasks.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.schedule,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 8),
            Text(
              'Upcoming Tasks',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...upcomingTasks.map(
          (taskWithCompletion) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: CareTaskCard(taskWithCompletion: taskWithCompletion),
          ),
        ),
      ],
    );
  }

  Widget _buildCarePlanDetails(BuildContext context, CarePlan carePlan) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Care Plan Details',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),

            // Diet information
            if (carePlan.dietText.isNotEmpty) ...[
              _buildDetailSection(
                context,
                'Diet Information',
                Icons.restaurant,
                carePlan.dietText,
              ),
              const SizedBox(height: 16),
            ],

            // Feeding schedules
            if (carePlan.feedingSchedules.isNotEmpty) ...[
              _buildDetailSection(
                context,
                'Feeding Schedules',
                Icons.schedule,
                carePlan.feedingSchedules.map((s) => s.description).join('\n'),
              ),
              const SizedBox(height: 16),
            ],

            // Medications
            if (carePlan.medications.isNotEmpty) ...[
              _buildDetailSection(
                context,
                'Medications',
                Icons.medication,
                carePlan.medications.map((m) => m.description).join('\n'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDetailSection(
    BuildContext context,
    String title,
    IconData icon,
    String content,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 8),
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(content, style: Theme.of(context).textTheme.bodyMedium),
      ],
    );
  }

  Widget _buildErrorState(BuildContext context, Object error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 80,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 24),
            Text(
              'Error Loading Care Plan',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              error.toString(),
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: () => _navigateToEditPage(context),
              icon: const Icon(Icons.add),
              label: const Text('Create Care Plan'),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToEditPage(BuildContext context) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => CarePlanFormPage(pet: pet)));
  }
}
