import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petfolio/features/pets/presentation/state/pet_list_provider.dart';
import 'package:petfolio/features/care_plans/application/care_plan_provider.dart';
import 'package:petfolio/features/care_plans/application/care_task_provider.dart';
import 'package:petfolio/features/care_plans/presentation/widgets/care_task_card.dart';

/// Page that aggregates today's and overdue care tasks across all pets.
class TodayTasksPage extends ConsumerWidget {
  const TodayTasksPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final petsAsync = ref.watch(petsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Today's Tasks"),
      ),
      body: petsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Failed to load pets: $error',
              textAlign: TextAlign.center,
            ),
          ),
        ),
        data: (pets) {
          if (pets.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Text(
                  'No pets yet. Add a pet to start tracking care tasks.',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: pets.length,
            itemBuilder: (context, index) {
              final pet = pets[index];
              final carePlanAsync = ref.watch(carePlanForPetProvider(pet.id));

              return carePlanAsync.when(
                loading: () => const SizedBox.shrink(),
                error: (error, stack) => const SizedBox.shrink(),
                data: (carePlan) {
                  if (carePlan == null) {
                    return const SizedBox.shrink();
                  }

                  final tasksWithCompletionAsync = ref.watch(
                    careTaskWithCompletionProvider(
                      (carePlan: carePlan, petId: pet.id),
                    ),
                  );

                  return tasksWithCompletionAsync.when(
                    loading: () => const SizedBox.shrink(),
                    error: (error, stack) => const SizedBox.shrink(),
                    data: (tasksWithCompletion) {
                      final now = DateTime.now();
                      final todayDate =
                          DateTime(now.year, now.month, now.day);

                      // Overdue tasks (incomplete and isOverdue)
                      final overdueTasks = tasksWithCompletion
                          .where(
                            (t) =>
                                t.task.isOverdue && !t.isCompleted,
                          )
                          .toList();

                      // Today's tasks (incomplete and scheduled for today)
                      final todayTasks = tasksWithCompletion.where((t) {
                        if (t.isCompleted) return false;
                        final scheduled = t.task.scheduledTime;
                        final taskDate = DateTime(
                          scheduled.year,
                          scheduled.month,
                          scheduled.day,
                        );
                        return taskDate == todayDate;
                      }).toList();

                      if (overdueTasks.isEmpty && todayTasks.isEmpty) {
                        return const SizedBox.shrink();
                      }

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    radius: 20,
                                    backgroundImage: pet.photoUrl != null
                                        ? NetworkImage(pet.photoUrl!)
                                        : null,
                                    child: pet.photoUrl == null
                                        ? Text(
                                            pet.name.isNotEmpty
                                                ? pet.name[0].toUpperCase()
                                                : '?',
                                          )
                                        : null,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      pet.name,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.w600,
                                          ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              if (overdueTasks.isNotEmpty) ...[
                                Row(
                                  children: [
                                    Icon(
                                      Icons.priority_high,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .error,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Overdue',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleSmall
                                          ?.copyWith(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .error,
                                            fontWeight: FontWeight.w600,
                                          ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                ...overdueTasks.map(
                                  (taskWithCompletion) => Padding(
                                    padding:
                                        const EdgeInsets.only(bottom: 8.0),
                                    child: CareTaskCard(
                                      taskWithCompletion: taskWithCompletion,
                                      isUrgent: true,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 12),
                              ],
                              if (todayTasks.isNotEmpty) ...[
                                Row(
                                  children: [
                                    Icon(
                                      Icons.today,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .primary,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      "Today's Tasks",
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleSmall
                                          ?.copyWith(
                                            fontWeight: FontWeight.w600,
                                          ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                ...todayTasks.map(
                                  (taskWithCompletion) => Padding(
                                    padding:
                                        const EdgeInsets.only(bottom: 8.0),
                                    child: CareTaskCard(
                                      taskWithCompletion: taskWithCompletion,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}



