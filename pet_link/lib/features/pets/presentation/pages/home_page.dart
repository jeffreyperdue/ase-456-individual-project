import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petfolio/features/pets/presentation/state/pet_list_provider.dart';
import 'package:petfolio/features/auth/presentation/state/auth_provider.dart';
import 'package:petfolio/features/pets/domain/pet.dart';
import 'package:petfolio/features/care_plans/presentation/widgets/care_plan_dashboard.dart';
import 'package:petfolio/features/pets/presentation/widgets/enhanced_pet_card.dart';
import 'package:petfolio/app/utils/empty_states.dart';

/// Shows the list of pets and a FAB to add a dummy pet.
class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // TEMPORARY: Toggle to show/hide Care Plan Dashboard for visual assessment
    // Set to false to hide the dashboard, true to show it
    const bool showCarePlanDashboard = false;

    // Listen to Riverpod provider; rebuild when the pets list changes.
    final petsAsync = ref.watch(petsProvider);
    // Keep provider subscription for rebuilds on user changes
    ref.watch(currentUserDataProvider);

    return Stack(
      children: [
        petsAsync.when(
          loading: () => const EnhancedLoadingState(message: 'Loading your pets...'),
          error: (error, stack) => EnhancedErrorState(
            error: error.toString(),
            onRetry: () => ref.invalidate(petsProvider),
          ),
          data: (pets) => pets.isEmpty
              ? EnhancedEmptyState(
                  title: 'No pets yet',
                  description: 'Start by adding your first pet to track their care, schedule reminders, and share with family or sitters.',
                  icon: Icons.pets,
                  actionLabel: 'Add Your First Pet',
                  onAction: () => Navigator.pushNamed(context, '/edit'),
                )
              : Column(
                  children: [
                    // Care Plan Dashboard - Temporarily hidden for visual assessment
                    if (showCarePlanDashboard) const CarePlanDashboard(),

                    // Pets List with Enhanced Cards
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        itemCount: pets.length,
                        itemBuilder: (context, i) {
                          final Pet pet = pets[i];
                          final imageUrl = pet.photoUrl;
                          final cacheBustedUrl = imageUrl == null
                              ? null
                              : '${imageUrl}${imageUrl.contains('?') ? '&' : '?'}ts=${DateTime.now().millisecondsSinceEpoch}';
                          return EnhancedPetCard(
                            pet: pet,
                            cacheBustedUrl: cacheBustedUrl,
                            index: i,
                          );
                        },
                      ),
                    ),
                  ],
                ),
        ),
        // Floating Action Button for adding pets
        Positioned(
          bottom: 16,
          right: 16,
          child: FloatingActionButton(
            onPressed: () => Navigator.pushNamed(context, '/edit'),
            child: const Icon(Icons.add),
          ),
        ),
      ],
    );
  }
}
