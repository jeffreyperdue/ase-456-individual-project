import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petfolio/features/care_plans/presentation/widgets/care_plan_dashboard.dart';
import 'package:petfolio/app/navigation_provider.dart';
import 'package:petfolio/features/care_plans/presentation/pages/today_tasks_page.dart';
import 'package:petfolio/features/pets/presentation/state/pet_list_provider.dart';
import 'package:petfolio/features/care_plans/presentation/pages/care_plan_form_page.dart';
import 'package:petfolio/features/care_plans/application/care_plan_provider.dart';

class CareDashboardPage extends ConsumerWidget {
  const CareDashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Stack(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Expanded(child: CarePlanDashboard()),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ActionChip(
                    avatar: const Icon(Icons.edit, size: 18),
                    label: const Text('Add Care Plan'),
                    onPressed: () {
                      _onAddCarePlanPressed(context, ref);
                    },
                  ),
                  ActionChip(
                    avatar: const Icon(Icons.pets, size: 18),
                    label: const Text('Manage Pets'),
                    onPressed: () {
                      ref.read(navIndexProvider.notifier).setIndex(0);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
        Positioned(
          bottom: 16,
          right: 16,
          child: FloatingActionButton.extended(
            icon: const Icon(Icons.today),
            label: const Text("Today's Tasks"),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const TodayTasksPage(),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

Future<void> _onAddCarePlanPressed(BuildContext context, WidgetRef ref) async {
  final petsAsync = ref.read(petsProvider);

  // If pets are still loading or errored, fall back to existing behavior.
  if (petsAsync.isLoading || petsAsync.hasError) {
    Navigator.pushNamed(context, '/edit');
    return;
  }

  final pets = petsAsync.value ?? [];

  if (pets.isEmpty) {
    // No pets yet - prompt user to create one first.
    final createPet = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('No pets found'),
        content: const Text(
          'You need to add a pet before creating a care plan. Would you like to add a pet now?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Add Pet'),
          ),
        ],
      ),
    );

    if (createPet == true) {
      Navigator.pushNamed(context, '/edit');
    }
    return;
  }

  final selectedPet = await showModalBottomSheet<dynamic>(
    context: context,
    showDragHandle: true,
    builder: (context) {
      return SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Select a pet',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: pets.length,
                itemBuilder: (context, index) {
                  final pet = pets[index];
                  return ListTile(
                    leading: CircleAvatar(
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
                    title: Text(pet.name),
                    subtitle: Text(pet.species),
                    onTap: () => Navigator.pop(context, pet),
                  );
                },
              ),
            ),
          ],
        ),
      );
    },
  );

  if (selectedPet != null) {
    final carePlanAsync = ref.read(carePlanForPetProvider(selectedPet.id));

    if (carePlanAsync.hasValue && carePlanAsync.value != null) {
      // Pet already has a care plan – ask whether to edit it.
      final editExisting = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Care plan already exists'),
          content: Text(
            '${selectedPet.name} already has an active care plan. Would you like to edit it?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Edit Care Plan'),
            ),
          ],
        ),
      );

      if (editExisting != true) {
        return;
      }
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CarePlanFormPage(pet: selectedPet),
      ),
    );
  }
}


