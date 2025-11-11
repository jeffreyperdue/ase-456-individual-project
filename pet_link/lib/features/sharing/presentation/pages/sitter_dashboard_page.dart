import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../pets/domain/pet.dart';
import '../../../care_plans/domain/care_task.dart';
import '../../../care_plans/application/care_plan_provider.dart';
import '../../../care_plans/application/care_task_provider.dart';
import '../../domain/access_token.dart';
import '../../data/access_token_repository_impl.dart';
import '../../application/task_completion_provider.dart';
import '../widgets/sitter_task_list.dart';
import '../../../auth/presentation/state/auth_provider.dart';
import '../../../pets/data/pets_repository.dart';
import 'public_pet_profile_page.dart';

/// Provider for sitter's access tokens.
final sitterTokensProvider = FutureProvider<List<AccessToken>>((ref) async {
  final firebaseUserAsync = ref.watch(firebaseUserProvider);
  final firebaseUser = firebaseUserAsync.value;
  
  if (firebaseUser == null) {
    return [];
  }

  final repository = AccessTokenRepositoryImpl();
  final allTokens = await repository.getAccessTokensByUser(firebaseUser.uid);
  
  return allTokens
      .where(
        (token) =>
            token.isValid &&
            token.role == AccessRole.sitter &&
            token.grantedTo == firebaseUser.uid,
      )
      .toList();
});

/// Provider for a pet by ID (for sitters to view shared pets).
final petByIdProvider = FutureProvider.family<Pet?, String>((ref, petId) async {
  try {
    final repository = PetsRepository();
    return await repository.getPetById(petId);
  } catch (e) {
    return null;
  }
});

/// Provider for all assigned pets for a sitter.
final sitterAssignedPetsProvider = FutureProvider<List<Pet>>((ref) async {
  final tokensAsync = ref.watch(sitterTokensProvider);
  
  return tokensAsync.when(
    data: (tokens) async {
      if (tokens.isEmpty) return [];
      
      final repository = PetsRepository();
      final pets = <Pet>[];
      
      // Get pets for each token's petId
      for (final token in tokens) {
        try {
          final pet = await repository.getPetById(token.petId);
          if (pet != null) {
            pets.add(pet);
          }
        } catch (e) {
          // Skip pets that can't be accessed
          continue;
        }
      }
      
      return pets;
    },
    loading: () => [],
    error: (_, __) => [],
  );
});

/// Dashboard for pet sitters to view assigned pets and manage care tasks.
class SitterDashboardPage extends ConsumerWidget {
  const SitterDashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokensAsync = ref.watch(sitterTokensProvider);
    final firebaseUserAsync = ref.watch(firebaseUserProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sitter Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.invalidate(sitterTokensProvider);
            },
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: tokensAsync.when(
        data: (tokens) {
          if (tokens.isEmpty) {
            return _buildNoAssignments(context);
          }

          final firebaseUser = firebaseUserAsync.value;
          if (firebaseUser == null) {
            return _buildError(context, 'Please sign in to view your sitter dashboard.');
          }

          return _buildDashboard(context, ref, tokens, firebaseUser.uid);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => _buildError(context, 'Failed to load sitter data: $error'),
      ),
    );
  }

  Widget _buildDashboard(
    BuildContext context,
    WidgetRef ref,
    List<AccessToken> tokens,
    String sitterUserId,
  ) {
    // Group tasks by pet for display
    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(sitterTokensProvider);
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome section
            _buildWelcomeSection(context, tokens.length),

            const SizedBox(height: 16),

            // Show pets and their tasks
            ...tokens.map((token) {
              return _buildPetSection(context, ref, token, sitterUserId);
            }).toList(),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildPetSection(
    BuildContext context,
    WidgetRef ref,
    AccessToken token,
    String sitterUserId,
  ) {
    // Get pet data
    final petAsync = ref.watch(petByIdProvider(token.petId));
    
    // Watch care plan for this pet
    final carePlanAsync = ref.watch(carePlanForPetProvider(token.petId));
    
    // Watch tasks with completion status
    final tasksAsync = carePlanAsync.when(
      data: (carePlan) {
        if (carePlan == null) {
          return const AsyncValue.data(<CareTaskWithCompletion>[]);
        }
        return ref.watch(
          careTaskWithCompletionProvider((carePlan: carePlan, petId: token.petId)),
        );
      },
      loading: () => const AsyncValue.loading(),
      error: (error, stack) => AsyncValue.error(error, stack),
    );

    return petAsync.when(
      data: (pet) {
        return tasksAsync.when(
          data: (tasksWithCompletion) {
            // Filter to show only incomplete tasks or recently completed
            final incompleteTasks = tasksWithCompletion
                .where((t) => !t.isCompleted)
                .where((t) => t.task.scheduledTime.isAfter(
                      DateTime.now().subtract(const Duration(days: 1)),
                    ))
                .toList();

            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Pet header
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 24,
                            backgroundImage: pet?.photoUrl != null
                                ? NetworkImage(pet!.photoUrl!)
                                : null,
                            child: pet?.photoUrl == null
                                ? Text(
                                    pet?.name.isNotEmpty == true
                                        ? pet!.name[0].toUpperCase()
                                        : 'P',
                                    style: Theme.of(context).textTheme.titleLarge,
                                  )
                                : null,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  pet?.name ?? 'Pet ${token.petId.substring(0, 8)}...',
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  pet != null
                                      ? '${pet.species}${pet.breed != null ? ' • ${pet.breed}' : ''}'
                                      : 'Access expires ${token.timeUntilExpiration}',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.visibility),
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => PublicPetProfilePage(tokenId: token.id),
                                ),
                              );
                            },
                            tooltip: 'View Pet Profile',
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Tasks for this pet
                      if (incompleteTasks.isEmpty)
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text(
                            'No upcoming tasks for this pet',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        )
                      else
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Tasks',
                              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            SitterTaskList(
                              tasksWithCompletion: incompleteTasks,
                              onTaskCompleted: (task) => _onTaskCompleted(
                                context,
                                ref,
                                token,
                                task,
                                sitterUserId,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
            );
          },
          loading: () => const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (error, stack) => Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Error loading tasks: $error',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
          ),
        );
      },
      loading: () => const Padding(
        padding: EdgeInsets.all(16),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => Padding(
        padding: const EdgeInsets.all(16),
        child: Text(
          'Error loading pet: $error',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.error,
          ),
        ),
      ),
    );
  }

  Future<void> _onTaskCompleted(
    BuildContext context,
    WidgetRef ref,
    AccessToken token,
    CareTask task,
    String sitterUserId,
  ) async {
    try {
      final completeTaskUseCase = ref.read(completeTaskUseCaseProvider);
      
      // Show loading indicator
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                SizedBox(width: 12),
                Text('Completing task...'),
              ],
            ),
            duration: Duration(seconds: 2),
          ),
        );
      }

      // Complete the task
      await completeTaskUseCase.execute(
        petId: token.petId,
        careTaskId: task.id,
        completedBy: sitterUserId,
        notes: null,
      );

      // Invalidate providers to refresh tasks
      ref.invalidate(carePlanForPetProvider(token.petId));
      // The careTaskWithCompletionProvider will automatically update via the stream

      if (context.mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${task.title} marked as complete'),
            backgroundColor: Theme.of(context).colorScheme.primary,
            action: SnackBarAction(
              label: 'OK',
              textColor: Colors.white,
              onPressed: () {},
            ),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to complete task: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  Widget _buildWelcomeSection(BuildContext context, int petCount) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primaryContainer,
            Theme.of(context).colorScheme.secondaryContainer,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.pets, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome, Pet Sitter!',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'You have $petCount pet${petCount == 1 ? '' : 's'} assigned',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoAssignments(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.pets_outlined,
              size: 64,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              'No assigned pets',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'You don\'t have any active pet sitting assignments.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildError(BuildContext context, String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
