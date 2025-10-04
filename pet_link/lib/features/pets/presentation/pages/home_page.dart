import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petfolio/features/pets/presentation/state/pet_list_provider.dart';
import 'package:petfolio/features/auth/presentation/state/auth_provider.dart';
import 'package:petfolio/features/pets/domain/pet.dart';
import 'package:petfolio/features/pets/presentation/pages/pet_detail_page.dart';
import 'package:petfolio/features/care_plans/application/pet_with_plan_provider.dart';
import 'package:petfolio/features/care_plans/application/care_plan_provider.dart';
import 'package:petfolio/features/care_plans/application/care_task_provider.dart';
import 'package:petfolio/features/care_plans/presentation/widgets/care_plan_dashboard.dart';

/// Shows the list of pets and a FAB to add a dummy pet.
class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Listen to Riverpod provider; rebuild when the pets list changes.
    final petsAsync = ref.watch(petsProvider);
    final currentUser = ref.watch(currentUserDataProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Petfolio'),
        actions: [
          // User info and sign out
          PopupMenuButton<String>(
            onSelected: (value) async {
              if (value == 'signout') {
                try {
                  await ref.read(authProvider.notifier).signOut();
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Sign out failed: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              }
            },
            itemBuilder:
                (context) => [
                  PopupMenuItem(
                    enabled: false,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          currentUser?.displayName ?? 'User',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          currentUser?.email ?? '',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'signout',
                    child: Row(
                      children: [
                        Icon(Icons.logout),
                        SizedBox(width: 8),
                        Text('Sign Out'),
                      ],
                    ),
                  ),
                ],
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: CircleAvatar(
                backgroundImage:
                    currentUser?.photoUrl != null
                        ? NetworkImage(currentUser!.photoUrl!)
                        : null,
                child:
                    currentUser?.photoUrl == null
                        ? Text(
                          (currentUser?.displayName ??
                                  currentUser?.email ??
                                  'U')
                              .substring(0, 1)
                              .toUpperCase(),
                        )
                        : null,
              ),
            ),
          ),
        ],
      ),
      body: petsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error:
            (error, stack) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error: $error'),
                  ElevatedButton(
                    onPressed: () => ref.invalidate(petsProvider),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
        data:
            (pets) =>
                pets.isEmpty
                    ? const Center(
                      child: Text('No pets yet. Tap + to add one.'),
                    )
                    : Column(
                      children: [
                        // Care Plan Dashboard
                        const CarePlanDashboard(),

                        // Pets List
                        Expanded(
                          child: ListView.builder(
                            itemCount: pets.length,
                            itemBuilder: (context, i) {
                              final Pet pet = pets[i];
                              final imageUrl = pet.photoUrl;
                              final cacheBustedUrl =
                                  imageUrl == null
                                      ? null
                                      : '${imageUrl}${imageUrl.contains('?') ? '&' : '?'}ts=${DateTime.now().millisecondsSinceEpoch}';
                              return _buildPetTile(
                                context,
                                ref,
                                pet,
                                cacheBustedUrl,
                              );
                            },
                          ),
                        ),
                      ],
                    ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Open the Add Pet form instead of adding a dummy
          Navigator.pushNamed(context, '/edit');
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildPetTile(
    BuildContext context,
    WidgetRef ref,
    Pet pet,
    String? cacheBustedUrl,
  ) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          radius: 30,
          foregroundImage:
              cacheBustedUrl != null ? NetworkImage(cacheBustedUrl) : null,
          child:
              cacheBustedUrl == null
                  ? Text(pet.name.substring(0, 1).toUpperCase())
                  : null,
        ),
        title: Text(
          pet.name,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(pet.species),
            const SizedBox(height: 4),
            _buildCarePlanStatus(context, ref, pet),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              tooltip: 'View Details',
              icon: const Icon(Icons.info_outline),
              onPressed: () => _navigateToPetDetail(context, pet),
            ),
            IconButton(
              tooltip: 'Edit',
              icon: const Icon(Icons.edit_outlined),
              onPressed: () => _navigateToEditPet(context, pet),
            ),
            IconButton(
              tooltip: 'Delete',
              icon: const Icon(Icons.delete_outline),
              onPressed: () => _showDeleteDialog(context, ref, pet),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCarePlanStatus(BuildContext context, WidgetRef ref, Pet pet) {
    final petWithPlanAsync = ref.watch(petWithPlanProvider(pet.id));

    return petWithPlanAsync.when(
      data: (petWithPlan) {
        if (petWithPlan.carePlan == null) {
          return Row(
            children: [
              Icon(
                Icons.medical_services_outlined,
                size: 16,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 4),
              Text(
                'No care plan',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          );
        }

        final hasUrgentTasks = petWithPlan.taskStats.hasUrgentTasks;
        return Row(
          children: [
            Icon(
              hasUrgentTasks ? Icons.priority_high : Icons.medical_services,
              size: 16,
              color:
                  hasUrgentTasks
                      ? Theme.of(context).colorScheme.error
                      : Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 4),
            Text(
              petWithPlan.taskStats.summary,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color:
                    hasUrgentTasks
                        ? Theme.of(context).colorScheme.error
                        : Theme.of(context).colorScheme.onSurfaceVariant,
                fontWeight: hasUrgentTasks ? FontWeight.w600 : null,
              ),
            ),
          ],
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (error, stack) => const SizedBox.shrink(),
    );
  }

  void _navigateToPetDetail(BuildContext context, Pet pet) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => PetDetailPage(pet: pet)));
  }

  void _navigateToEditPet(BuildContext context, Pet pet) {
    Navigator.pushNamed(context, '/edit', arguments: {'pet': pet});
  }

  Future<void> _showDeleteDialog(
    BuildContext context,
    WidgetRef ref,
    Pet pet,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Pet'),
            content: Text('Are you sure you want to delete ${pet.name}?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Delete'),
              ),
            ],
          ),
    );

    if (confirmed == true) {
      await ref.read(petsProvider.notifier).remove(pet.id);
    }
  }
}
