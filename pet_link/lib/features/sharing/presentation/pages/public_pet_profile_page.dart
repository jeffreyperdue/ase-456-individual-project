import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../pets/domain/pet.dart';
import '../../../pets/domain/pet_profile.dart';
import '../../../care_plans/domain/care_task.dart';
import '../../../care_plans/application/care_plan_provider.dart';
import '../../../care_plans/application/care_task_provider.dart';
import '../../../auth/domain/user.dart';
import '../../../auth/presentation/state/auth_provider.dart';
import '../../domain/access_token.dart';
import '../../application/get_access_token_use_case.dart';
import '../../application/task_completion_provider.dart';
import '../../data/access_token_repository_impl.dart';
import '../../../pets/data/pets_repository.dart';
import '../widgets/public_profile_header.dart';
import '../widgets/read_only_pet_info.dart';
import '../widgets/read_only_care_plan.dart';
import '../widgets/sitter_task_list.dart';

/// Screen for displaying pet profiles to non-authenticated users via access tokens.
class PublicPetProfilePage extends ConsumerStatefulWidget {
  final String tokenId;

  const PublicPetProfilePage({super.key, required this.tokenId});

  @override
  ConsumerState<PublicPetProfilePage> createState() =>
      _PublicPetProfilePageState();
}

class _PublicPetProfilePageState extends ConsumerState<PublicPetProfilePage> {
  AccessToken? _accessToken;
  Pet? _pet;
  PetProfile? _petProfile;
  User? _owner;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadPetProfile();
  }

  Future<void> _loadPetProfile() async {
    try {
      final repository = AccessTokenRepositoryImpl();
      final getTokenUseCase = GetAccessTokenUseCase(repository);

      // Get and validate the access token
      final token = await getTokenUseCase.getValidToken(widget.tokenId);
      if (token == null) {
        setState(() {
          _error = 'Invalid or expired access token';
          _isLoading = false;
        });
        return;
      }

      setState(() {
        _accessToken = token;
      });

      // Load pet data
      await _loadPetData(token.petId);
    } catch (e) {
      setState(() {
        _error = 'Failed to load pet profile: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _loadPetData(String petId) async {
    try {
      // Load real pet data from repository
      final repository = PetsRepository();
      final pet = await repository.getPetById(petId);

      if (pet == null) {
        setState(() {
          _error = 'Pet not found';
          _isLoading = false;
        });
        return;
      }

      // Mock pet profile for now (TODO: implement pet profile repository)
      final petProfile = PetProfile(
        id: 'profile_$petId',
        petId: petId,
        ownerId: _accessToken!.grantedBy,
        veterinarianContact: null,
        emergencyContact: null,
        allergies: null,
        chronicConditions: null,
        vaccinationHistory: null,
        generalNotes: null,
        tags: [],
        createdAt: DateTime.now(),
      );

      // Mock owner for now (TODO: load from user repository)
      final owner = User(
        id: _accessToken!.grantedBy,
        email: 'owner@example.com',
        displayName: 'Pet Owner',
        createdAt: DateTime.now(),
      );

      setState(() {
        _pet = pet;
        _petProfile = petProfile;
        _owner = owner;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load pet data: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Loading Pet Profile...')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: Center(
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
                _error!,
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _isLoading = true;
                    _error = null;
                  });
                  _loadPetProfile();
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (_accessToken == null || _pet == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Invalid Access')),
        body: const Center(child: Text('Invalid access token')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_pet!.name),
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Public profile header
            PublicProfileHeader(
              pet: _pet!,
              owner: _owner!,
              accessToken: _accessToken!,
            ),

            const SizedBox(height: 16),

            // Pet information
            ReadOnlyPetInfo(pet: _pet!, petProfile: _petProfile),

            const SizedBox(height: 16),

            // Care plan and tasks (if sitter access)
            if (_accessToken!.role == AccessRole.sitter) ...[
              _buildSitterContent(context, ref),
              const SizedBox(height: 16),
            ],

            // Access info footer
            _buildAccessInfoFooter(context),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSitterContent(BuildContext context, WidgetRef ref) {
    // Watch care plan for this pet
    final carePlanAsync = ref.watch(carePlanForPetProvider(_pet!.id));
    
    // Watch tasks with completion status
    final tasksAsync = carePlanAsync.when(
      data: (carePlan) {
        if (carePlan == null) {
          return const AsyncValue.data(<CareTaskWithCompletion>[]);
        }
        return ref.watch(
          careTaskWithCompletionProvider((carePlan: carePlan, petId: _pet!.id)),
        );
      },
      loading: () => const AsyncValue.loading(),
      error: (error, stack) => AsyncValue.error(error, stack),
    );

    return Column(
      children: [
        // Care plan details
        ReadOnlyCarePlan(pet: _pet!, carePlan: carePlanAsync.valueOrNull),

        const SizedBox(height: 16),

        // Tasks section
        tasksAsync.when(
          data: (tasksWithCompletion) {
            // Filter to show incomplete tasks and recently completed
            final incompleteTasks = tasksWithCompletion
                .where((t) => !t.isCompleted)
                .where((t) => t.task.scheduledTime.isAfter(
                      DateTime.now().subtract(const Duration(days: 1)),
                    ))
                .toList();

            if (incompleteTasks.isEmpty && tasksWithCompletion.isEmpty) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(16),
                child: Text(
                  'No tasks available for this pet',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
              );
            }

            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.task_alt,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Care Tasks',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      if (incompleteTasks.isEmpty)
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text(
                            'All tasks are completed!',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        )
                      else
                        _buildTasksList(context, ref, incompleteTasks),
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
          error: (error, stack) => Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(16),
            child: Text(
              'Error loading tasks: $error',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTasksList(
    BuildContext context,
    WidgetRef ref,
    List<CareTaskWithCompletion> tasks,
  ) {
    // Get current user ID for task completion
    final firebaseUserAsync = ref.watch(firebaseUserProvider);
    final firebaseUser = firebaseUserAsync.value;
    
    if (firebaseUser == null) {
      return Text(
        'Please sign in to complete tasks',
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: Theme.of(context).colorScheme.error,
        ),
      );
    }

    return SitterTaskList(
      tasksWithCompletion: tasks,
      onTaskCompleted: (task) => _onTaskCompleted(context, ref, task, firebaseUser.uid),
    );
  }

  Future<void> _onTaskCompleted(
    BuildContext context,
    WidgetRef ref,
    CareTask task,
    String sitterUserId,
  ) async {
    if (_accessToken == null || _pet == null) return;

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
        petId: _pet!.id,
        careTaskId: task.id,
        completedBy: sitterUserId,
        notes: null,
      );

      // Invalidate providers to refresh tasks
      ref.invalidate(carePlanForPetProvider(_pet!.id));

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

  Widget _buildAccessInfoFooter(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                _accessToken!.role.icon,
                style: const TextStyle(fontSize: 20),
              ),
              const SizedBox(width: 8),
              Text(
                '${_accessToken!.role.displayName} Access',
                style: Theme.of(
                  context,
                ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _accessToken!.accessDescription,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                Icons.schedule,
                size: 16,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 4),
              Text(
                'Expires ${_accessToken!.timeUntilExpiration}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color:
                      _accessToken!.isExpired
                          ? Theme.of(context).colorScheme.error
                          : Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          if (_accessToken!.notes != null) ...[
            const SizedBox(height: 8),
            Text(
              'Note: ${_accessToken!.notes}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontStyle: FontStyle.italic,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
