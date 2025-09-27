import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/pet.dart';
import '../../../care_plans/presentation/pages/care_plan_view_page.dart';
import '../../../care_plans/presentation/pages/care_plan_form_page.dart';
import '../../application/pet_with_details_provider.dart';
import '../../application/pet_profile_providers.dart';
import '../widgets/pet_profile_card.dart';
import 'pet_profile_form_page.dart';

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
}
