import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pet_link/features/pets/presentation/state/pet_list_provider.dart';

/// Shows the list of pets and a FAB to add a dummy pet.
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Listen to provider; rebuild when the pets list changes.
    final pets = context.watch<PetListProvider>().pets;

    return Scaffold(
      appBar: AppBar(title: const Text('PetLink')),
      body:
          pets.isEmpty
              ? const Center(child: Text('No pets yet. Tap + to add one.'))
              : ListView.builder(
                itemCount: pets.length,
                itemBuilder: (context, i) {
                  final pet = pets[i];
                  return ListTile(
                    title: Text(pet.name),
                    subtitle: Text(pet.species),
                    trailing: IconButton(
                      tooltip: 'Delete',
                      icon: const Icon(Icons.delete_outline),
                      onPressed:
                          () => context.read<PetListProvider>().remove(pet.id),
                    ),
                  );
                },
              ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Prove the FAB works: check your Debug Console/terminal.
          print('add pet');
          context.read<PetListProvider>().addDummy();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
