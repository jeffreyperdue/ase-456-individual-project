import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../pets/domain/pet.dart';
import '../../../care_plans/domain/care_task.dart';
import '../../domain/access_token.dart';
import '../../data/access_token_repository_impl.dart';
import '../widgets/sitter_pet_card.dart';
import '../widgets/sitter_task_list.dart';
import '../../../auth/presentation/state/auth_provider.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;

/// Dashboard for pet sitters to view assigned pets and manage care tasks.
class SitterDashboardPage extends ConsumerStatefulWidget {
  const SitterDashboardPage({super.key});

  @override
  ConsumerState<SitterDashboardPage> createState() =>
      _SitterDashboardPageState();
}

class _SitterDashboardPageState extends ConsumerState<SitterDashboardPage> {
  List<AccessToken> _sitterTokens = [];
  List<Pet> _assignedPets = [];
  List<CareTask> _upcomingTasks = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadSitterData();
  }

  Future<void> _loadSitterData() async {
    try {
      final firebaseUserAsync = ref.read(firebaseUserProvider);
      final firebaseUser = firebaseUserAsync.value;

      if (firebaseUser == null) {
        setState(() {
          _error = 'Please sign in to view your sitter dashboard.';
          _isLoading = false;
        });
        return;
      }

      final repository = AccessTokenRepositoryImpl();

      // Get all active sitter tokens for this user
      final allTokens = await repository.getAccessTokensByUser(
        firebaseUser.uid,
      );
      _sitterTokens =
          allTokens
              .where(
                (token) =>
                    token.isValid &&
                    token.role == AccessRole.sitter &&
                    token.grantedTo == firebaseUser.uid,
              )
              .toList();

      // Load pet data for each token
      await _loadAssignedPets();

      // Load upcoming tasks
      await _loadUpcomingTasks();

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load sitter data: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _loadAssignedPets() async {
    // TODO: Implement pet data loading from repository
    // For now, we'll create mock data to demonstrate the UI

    for (final token in _sitterTokens) {
      // Mock pet data
      final pet = Pet(
        id: token.petId,
        ownerId: token.grantedBy,
        name: 'Buddy',
        species: 'Dog',
        breed: 'Golden Retriever',
        dateOfBirth: DateTime(2020, 3, 15),
        weightKg: 25.5,
        photoUrl: null,
        createdAt: DateTime.now().subtract(const Duration(days: 365)),
      );

      _assignedPets.add(pet);
    }
  }

  Future<void> _loadUpcomingTasks() async {
    // TODO: Implement task loading from repository
    // For now, we'll create mock data to demonstrate the UI

    final now = DateTime.now();
    final tomorrow = now.add(const Duration(days: 1));

    _upcomingTasks = [
      CareTask(
        id: 'task_1',
        petId: _assignedPets.isNotEmpty ? _assignedPets.first.id : '',
        carePlanId: 'plan_1',
        type: CareTaskType.feeding,
        title: 'Morning Feeding',
        description: 'Feed Buddy his morning meal',
        scheduledTime: now.add(const Duration(hours: 2)),
        notes: '1 cup of dry food',
      ),
      CareTask(
        id: 'task_2',
        petId: _assignedPets.isNotEmpty ? _assignedPets.first.id : '',
        carePlanId: 'plan_1',
        type: CareTaskType.medication,
        title: 'Evening Medication',
        description: 'Give Buddy his evening medication',
        scheduledTime: now.add(const Duration(hours: 6)),
        notes: '1 tablet with food',
      ),
      CareTask(
        id: 'task_3',
        petId: _assignedPets.isNotEmpty ? _assignedPets.first.id : '',
        carePlanId: 'plan_1',
        type: CareTaskType.feeding,
        title: 'Evening Feeding',
        description: 'Feed Buddy his evening meal',
        scheduledTime: tomorrow,
        notes: '1 cup of dry food',
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Sitter Dashboard')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Sitter Dashboard')),
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
                  _loadSitterData();
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (_sitterTokens.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Sitter Dashboard')),
        body: Center(
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sitter Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                _isLoading = true;
              });
              _loadSitterData();
            },
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {
            _isLoading = true;
          });
          await _loadSitterData();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome section
              _buildWelcomeSection(context),

              const SizedBox(height: 16),

              // Upcoming tasks
              if (_upcomingTasks.isNotEmpty) ...[
                _buildUpcomingTasks(context),
                const SizedBox(height: 16),
              ],

              // Assigned pets
              _buildAssignedPets(context),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeSection(BuildContext context) {
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
                  'You have ${_assignedPets.length} pet${_assignedPets.length == 1 ? '' : 's'} assigned',
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

  Widget _buildUpcomingTasks(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Upcoming Tasks',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          SitterTaskList(
            tasks: _upcomingTasks,
            onTaskCompleted: _onTaskCompleted,
          ),
        ],
      ),
    );
  }

  Widget _buildAssignedPets(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Assigned Pets',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          ..._assignedPets.map((pet) {
            final token = _sitterTokens.firstWhere(
              (t) => t.petId == pet.id,
              orElse: () => _sitterTokens.first,
            );
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: SitterPetCard(
                pet: pet,
                token: token,
                onViewProfile: () => _viewPetProfile(pet, token),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  void _onTaskCompleted(CareTask task) {
    // TODO: Implement task completion logic
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${task.title} marked as complete'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {
            // TODO: Implement undo functionality
          },
        ),
      ),
    );

    // Remove completed task from the list
    setState(() {
      _upcomingTasks.removeWhere((t) => t.id == task.id);
    });
  }

  void _viewPetProfile(Pet pet, AccessToken token) {
    // TODO: Navigate to public pet profile view
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Viewing profile for ${pet.name}')));
  }
}
