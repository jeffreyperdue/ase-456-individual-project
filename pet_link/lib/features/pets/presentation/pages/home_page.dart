import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_link/features/pets/presentation/state/pet_list_provider.dart';
import 'package:pet_link/features/auth/presentation/state/auth_provider.dart';
import 'package:pet_link/features/pets/domain/pet.dart';

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
        title: const Text('PetLink'),
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
                    : ListView.builder(
                      itemCount: pets.length,
                      itemBuilder: (context, i) {
                        final Pet pet = pets[i];
                        final imageUrl = pet.photoUrl;
                        final cacheBustedUrl =
                            imageUrl == null
                                ? null
                                : '${imageUrl}${imageUrl.contains('?') ? '&' : '?'}ts=${DateTime.now().millisecondsSinceEpoch}';
                        return ListTile(
                          leading: CircleAvatar(
                            foregroundImage:
                                cacheBustedUrl != null
                                    ? NetworkImage(cacheBustedUrl)
                                    : null,
                            child:
                                cacheBustedUrl == null
                                    ? Text(
                                      pet.name.substring(0, 1).toUpperCase(),
                                    )
                                    : null,
                          ),
                          title: Text(pet.name),
                          subtitle: Text(pet.species),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                tooltip: 'Edit',
                                icon: const Icon(Icons.edit_outlined),
                                onPressed: () {
                                  Navigator.pushNamed(
                                    context,
                                    '/edit',
                                    arguments: {'pet': pet},
                                  );
                                },
                              ),
                              IconButton(
                                tooltip: 'Delete',
                                icon: const Icon(Icons.delete_outline),
                                onPressed: () async {
                                  final confirmed = await showDialog<bool>(
                                    context: context,
                                    builder:
                                        (context) => AlertDialog(
                                          title: const Text('Delete Pet'),
                                          content: Text(
                                            'Are you sure you want to delete ${pet.name}?',
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed:
                                                  () => Navigator.pop(
                                                    context,
                                                    false,
                                                  ),
                                              child: const Text('Cancel'),
                                            ),
                                            FilledButton(
                                              onPressed:
                                                  () => Navigator.pop(
                                                    context,
                                                    true,
                                                  ),
                                              child: const Text('Delete'),
                                            ),
                                          ],
                                        ),
                                  );
                                  if (confirmed == true) {
                                    await ref
                                        .read(petsProvider.notifier)
                                        .remove(pet.id);
                                  }
                                },
                              ),
                            ],
                          ),
                        );
                      },
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
}
