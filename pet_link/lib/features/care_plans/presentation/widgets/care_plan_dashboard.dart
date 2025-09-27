import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../application/pet_with_plan_provider.dart';

/// A dashboard widget showing care plan summaries and urgent tasks.
class CarePlanDashboard extends ConsumerWidget {
  const CarePlanDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allPetsAsync = ref.watch(allPetsWithPlanProvider);
    final petsWithUrgentTasks = ref.watch(petsWithUrgentTasksProvider);

    return allPetsAsync.when(
      data: (allPets) {
        if (allPets.isEmpty) {
          return const SizedBox.shrink();
        }

        return Card(
          margin: const EdgeInsets.all(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.dashboard,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Care Plan Dashboard',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Urgent tasks section
                if (petsWithUrgentTasks.isNotEmpty) ...[
                  _buildUrgentTasksSection(context, petsWithUrgentTasks),
                  const SizedBox(height: 16),
                ],

                // Care plan summary
                _buildCarePlanSummary(context, allPets),
              ],
            ),
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (error, stack) => const SizedBox.shrink(),
    );
  }

  Widget _buildUrgentTasksSection(
    BuildContext context,
    List petsWithUrgentTasks,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.priority_high,
              color: Theme.of(context).colorScheme.error,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              'Urgent Tasks',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.error,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...petsWithUrgentTasks.map((petWithPlan) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 12,
                  backgroundImage:
                      petWithPlan.pet.photoUrl != null
                          ? NetworkImage(petWithPlan.pet.photoUrl!)
                          : null,
                  child:
                      petWithPlan.pet.photoUrl == null
                          ? Text(
                            petWithPlan.pet.name.isNotEmpty
                                ? petWithPlan.pet.name[0].toUpperCase()
                                : '?',
                            style: const TextStyle(fontSize: 12),
                          )
                          : null,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${petWithPlan.pet.name} - ${petWithPlan.taskStats.summary}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.error,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildCarePlanSummary(BuildContext context, List allPets) {
    final petsWithCarePlans =
        allPets.where((pet) => pet.carePlan != null).length;
    final totalTasks = allPets.fold<int>(
      0,
      (sum, pet) => sum + (pet.taskStats.total as int),
    );
    final todayTasks = allPets.fold<int>(
      0,
      (sum, pet) => sum + (pet.taskStats.today as int),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Overview',
          style: Theme.of(
            context,
          ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                context,
                'Pets with Care Plans',
                '$petsWithCarePlans of ${allPets.length}',
                Icons.medical_services,
                Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildStatCard(
                context,
                'Today\'s Tasks',
                '$todayTasks',
                Icons.today,
                Theme.of(context).colorScheme.secondary,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildStatCard(
                context,
                'Total Tasks',
                '$totalTasks',
                Icons.task,
                Theme.of(context).colorScheme.tertiary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
