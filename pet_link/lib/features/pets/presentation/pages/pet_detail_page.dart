import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/pet.dart';
import '../../../care_plans/presentation/pages/care_plan_view_page.dart';
import '../../../care_plans/presentation/pages/care_plan_form_page.dart';
import '../../application/pet_with_details_provider.dart';
import '../../application/pet_profile_providers.dart';
import '../widgets/pet_profile_card.dart';
import 'pet_profile_form_page.dart';
import '../../../lost_found/presentation/state/lost_found_provider.dart';
import '../../../lost_found/presentation/pages/lost_pet_poster_page.dart';
import '../../../auth/presentation/state/auth_provider.dart';

/// Page for viewing detailed pet information and care plan.
class PetDetailPage extends ConsumerWidget {
  final Pet pet;

  const PetDetailPage({super.key, required this.pet});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final petWithDetailsAsync = ref.watch(petWithDetailsProvider(pet.id));
    final profileAsync = ref.watch(petProfileForPetProvider(pet.id));

    return Scaffold(
      appBar: AppBar(
        title: Text(pet.name),
        actions: [
          IconButton(
            onPressed: () => _navigateToEditPet(context),
            icon: const Icon(Icons.edit),
            tooltip: 'Edit Pet',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Pet info card
            _buildPetInfoCard(context),

            const SizedBox(height: 24),

            // Enhanced Pet Profile section
            _buildProfileSection(context, ref, profileAsync),

            const SizedBox(height: 24),

            // Care plan section
            _buildCarePlanSection(context, ref, petWithDetailsAsync),

            const SizedBox(height: 24),

            // Lost & Found section
            _buildLostFoundSection(context, ref),

            const SizedBox(height: 24),

            // Quick actions
            _buildQuickActions(context, ref, petWithDetailsAsync),
          ],
        ),
      ),
    );
  }

  Widget _buildPetInfoCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Pet photo and basic info
            Row(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundImage:
                      pet.photoUrl != null ? NetworkImage(pet.photoUrl!) : null,
                  child:
                      pet.photoUrl == null
                          ? Text(
                            pet.name.isNotEmpty
                                ? pet.name[0].toUpperCase()
                                : '?',
                            style: Theme.of(context).textTheme.headlineMedium,
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
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        pet.species,
                        style: Theme.of(
                          context,
                        ).textTheme.titleMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                      if (pet.breed != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          pet.breed!,
                          style: Theme.of(
                            context,
                          ).textTheme.bodyMedium?.copyWith(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileSection(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<dynamic> profileAsync,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.person_outline,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 8),
            Text(
              'Enhanced Profile',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
            ),
          ],
        ),
        const SizedBox(height: 16),

        profileAsync.when(
          data: (profile) {
            return PetProfileCard(
              profile: profile,
              onEdit: () => _navigateToEditProfile(context, profile),
              onCreate: () => _navigateToCreateProfile(context),
            );
          },
          loading:
              () => const Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(child: CircularProgressIndicator()),
                ),
              ),
          error:
              (error, stack) => Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Icon(
                        Icons.error_outline,
                        color: Theme.of(context).colorScheme.error,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Failed to load profile: $error',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
        ),
      ],
    );
  }

  Widget _buildCarePlanSection(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<dynamic> petWithDetailsAsync,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.medical_services,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 8),
            Text(
              'Care Plan',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
            ),
          ],
        ),
        const SizedBox(height: 16),

        petWithDetailsAsync.when(
          data: (petWithDetails) {
            if (petWithDetails.carePlan == null) {
              return _buildNoCarePlanCard(context);
            }
            return _buildCarePlanCard(context, petWithDetails.carePlan!);
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => _buildCarePlanErrorCard(context, error),
        ),
      ],
    );
  }

  Widget _buildNoCarePlanCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Icon(
              Icons.medical_services_outlined,
              size: 48,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              'No Care Plan Yet',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              'Create a care plan to track ${pet.name}\'s feeding schedules, medications, and health reminders.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: () => _navigateToCreateCarePlan(context),
              icon: const Icon(Icons.add),
              label: const Text('Create Care Plan'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCarePlanCard(BuildContext context, carePlan) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Care Plan Active',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        carePlan.summary ??
                            'Feeding and medication schedules configured',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => _navigateToCarePlanView(context),
                  icon: const Icon(Icons.arrow_forward),
                  tooltip: 'View Care Plan',
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _navigateToCarePlanView(context),
                    icon: const Icon(Icons.visibility),
                    label: const Text('View'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () => _navigateToEditCarePlan(context),
                    icon: const Icon(Icons.edit),
                    label: const Text('Edit'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCarePlanErrorCard(BuildContext context, Object error) {
    return Card(
      color: Theme.of(context).colorScheme.errorContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              Icons.error_outline,
              color: Theme.of(context).colorScheme.onErrorContainer,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Error Loading Care Plan',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: Theme.of(context).colorScheme.onErrorContainer,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    error.toString(),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onErrorContainer,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions(
    BuildContext context,
    WidgetRef ref,
    AsyncValue petWithPlanAsync,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 16),

        petWithPlanAsync.when(
          data: (petWithPlan) {
            return Row(
              children: [
                Expanded(
                  child: Card(
                    child: InkWell(
                      onTap: () => _navigateToCarePlanView(context),
                      borderRadius: BorderRadius.circular(12),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Icon(
                              Icons.schedule,
                              size: 32,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'View Tasks',
                              style: Theme.of(context).textTheme.titleSmall
                                  ?.copyWith(fontWeight: FontWeight.w600),
                            ),
                            Text(
                              petWithPlan.taskStats.summary,
                              style: Theme.of(
                                context,
                              ).textTheme.bodySmall?.copyWith(
                                color:
                                    Theme.of(
                                      context,
                                    ).colorScheme.onSurfaceVariant,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Card(
                    child: InkWell(
                      onTap: () => _navigateToEditCarePlan(context),
                      borderRadius: BorderRadius.circular(12),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Icon(
                              Icons.medical_services,
                              size: 32,
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Care Plan',
                              style: Theme.of(context).textTheme.titleSmall
                                  ?.copyWith(fontWeight: FontWeight.w600),
                            ),
                            Text(
                              petWithPlan.carePlan != null ? 'Edit' : 'Create',
                              style: Theme.of(
                                context,
                              ).textTheme.bodySmall?.copyWith(
                                color:
                                    Theme.of(
                                      context,
                                    ).colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => const SizedBox.shrink(),
        ),
      ],
    );
  }

  void _navigateToEditPet(BuildContext context) {
    Navigator.pushNamed(context, '/edit', arguments: {'pet': pet});
  }

  void _navigateToCarePlanView(BuildContext context) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => CarePlanViewPage(pet: pet)));
  }

  void _navigateToCreateCarePlan(BuildContext context) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => CarePlanFormPage(pet: pet)));
  }

  void _navigateToEditCarePlan(BuildContext context) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => CarePlanFormPage(pet: pet)));
  }

  void _navigateToEditProfile(BuildContext context, dynamic profile) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder:
            (context) => PetProfileFormPage(pet: pet, existingProfile: profile),
      ),
    );
  }

  void _navigateToCreateProfile(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => PetProfileFormPage(pet: pet)),
    );
  }

  Widget _buildLostFoundSection(BuildContext context, WidgetRef ref) {
    final lostReportAsync = ref.watch(lostReportProvider(pet.id));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.warning_amber_rounded,
              color: pet.isLost
                  ? Colors.red
                  : Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 8),
            Text(
              'Lost & Found',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (pet.isLost)
          Card(
            color: Colors.red[50],
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.error_outline,
                        color: Colors.red[700],
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'This pet is marked as LOST',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.red[900],
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  lostReportAsync.when(
                    data: (lostReport) {
                      if (lostReport == null) {
                        return const SizedBox.shrink();
                      }
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (lostReport.lastSeenLocation != null) ...[
                            Text(
                              'Last seen: ${lostReport.lastSeenLocation}',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            const SizedBox(height: 8),
                          ],
                          if (lostReport.notes != null &&
                              lostReport.notes!.isNotEmpty) ...[
                            Text(
                              'Notes: ${lostReport.notes}',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            const SizedBox(height: 16),
                          ],
                        ],
                      );
                    },
                    loading: () => const CircularProgressIndicator(),
                    error: (_, __) => const SizedBox.shrink(),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: () => _viewPoster(context, ref),
                          icon: const Icon(Icons.image),
                          label: const Text('View Poster'),
                          style: FilledButton.styleFrom(
                            backgroundColor: Colors.red[700],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _markAsFound(context, ref),
                          icon: const Icon(Icons.check_circle),
                          label: const Text('Mark as Found'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          )
        else
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Has your pet gone missing?',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Mark your pet as lost to generate a shareable poster.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color:
                              Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: () => _markAsLost(context, ref),
                    icon: const Icon(Icons.warning_amber),
                    label: const Text('Mark as Lost'),
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Future<void> _markAsLost(BuildContext context, WidgetRef ref) async {
    final currentUser = ref.read(currentUserDataProvider);
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You must be logged in to mark a pet as lost')),
      );
      return;
    }

    final lastSeenController = TextEditingController();
    final notesController = TextEditingController();

    final result = await showDialog<Map<String, String?>>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Mark Pet as Lost'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Please provide the following information (optional):',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: lastSeenController,
                decoration: const InputDecoration(
                  labelText: 'Last seen location',
                  hintText: 'e.g., Near Central Park',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: notesController,
                decoration: const InputDecoration(
                  labelText: 'Additional notes',
                  hintText: 'Any additional information',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(
              context,
              {
                'lastSeenLocation': lastSeenController.text.trim().isEmpty
                    ? null
                    : lastSeenController.text.trim(),
                'notes': notesController.text.trim().isEmpty
                    ? null
                    : notesController.text.trim(),
              },
            ),
            child: const Text('Mark as Lost'),
          ),
        ],
      ),
    );

    if (result != null) {
      try {
        final notifier = ref.read(lostFoundNotifierProvider.notifier);
        await notifier.markPetAsLost(
          pet: pet,
          owner: currentUser,
          lastSeenLocation: result['lastSeenLocation'],
          notes: result['notes'],
        );

        // Show success message
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${pet.name} has been marked as lost'),
              backgroundColor: Colors.green,
            ),
          );
        }

        // Wait a moment for Firestore to sync, then navigate to poster
        await Future.delayed(const Duration(milliseconds: 800));

        if (context.mounted) {
          try {
            final lostReport = await ref.read(lostReportRepositoryProvider)
                .getLostReportByPetId(pet.id);
            if (lostReport != null && context.mounted) {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => LostPetPosterPage(
                    pet: pet,
                    owner: currentUser,
                    lostReport: lostReport,
                  ),
                ),
              );
            } else if (context.mounted) {
              // Report was created but couldn't be retrieved immediately
              // User can still view it from the pet detail page
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Pet marked as lost. You can view the poster from the Lost & Found section.'),
                  backgroundColor: Colors.blue,
                ),
              );
            }
          } catch (e) {
            // Error retrieving lost report, but marking as lost succeeded
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Pet marked as lost, but could not load poster: $e'),
                  backgroundColor: Colors.orange,
                ),
              );
            }
          }
        }
      } catch (e) {
        if (context.mounted) {
          // Parse error message for better user feedback
          String errorMessage = 'Error marking pet as lost: $e';
          if (e.toString().contains('permission-denied')) {
            errorMessage = 'Permission denied. Please check Firestore security rules are deployed.';
          } else if (e.toString().contains('network')) {
            errorMessage = 'Network error. Please check your internet connection and try again.';
          }
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMessage),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 5),
            ),
          );
        }
      }
    }
  }

  Future<void> _viewPoster(BuildContext context, WidgetRef ref) async {
    final currentUser = ref.read(currentUserDataProvider);
    if (currentUser == null) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('You must be logged in to view the poster'),
          ),
        );
      }
      return;
    }

    try {
      // Get the lost report from repository directly
      final repository = ref.read(lostReportRepositoryProvider);
      final lostReport = await repository.getLostReportByPetId(pet.id);
      
      if (lostReport == null) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Lost report not found. Please mark the pet as lost again.'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
      }

      if (context.mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => LostPetPosterPage(
              pet: pet,
              owner: currentUser,
              lostReport: lostReport,
            ),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading poster: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _markAsFound(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Mark as Found'),
        content: Text('Are you sure ${pet.name} has been found?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Mark as Found'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        // Get the lost report from repository directly
        final repository = ref.read(lostReportRepositoryProvider);
        final lostReport = await repository.getLostReportByPetId(pet.id);

        final notifier = ref.read(lostFoundNotifierProvider.notifier);
        await notifier.markPetAsFound(
          pet: pet,
          lostReport: lostReport,
        );

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${pet.name} has been marked as found!'),
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error marking pet as found: $e'),
            ),
          );
        }
      }
    }
  }
}
