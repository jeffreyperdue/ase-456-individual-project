import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../pets/domain/pet.dart';
import '../../../pets/domain/pet_profile.dart';
import '../../../care_plans/domain/care_plan.dart';
import '../../../auth/domain/user.dart';
import '../../domain/access_token.dart';
import '../../application/get_access_token_use_case.dart';
import '../../data/access_token_repository_impl.dart';
import '../widgets/public_profile_header.dart';
import '../widgets/read_only_pet_info.dart';
import '../widgets/read_only_care_plan.dart';

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
  CarePlan? _carePlan;
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
      // TODO: Implement pet data loading from repository
      // For now, we'll create mock data to demonstrate the UI

      // Mock pet data
      final pet = Pet(
        id: petId,
        ownerId: _accessToken!.grantedBy,
        name: 'Buddy',
        species: 'Dog',
        breed: 'Golden Retriever',
        dateOfBirth: DateTime(2020, 3, 15),
        weightKg: 25.5,
        heightCm: 55.0,
        photoUrl: null,
        createdAt: DateTime.now().subtract(const Duration(days: 365)),
      );

      // Mock pet profile
      final petProfile = PetProfile(
        id: 'profile_$petId',
        petId: petId,
        ownerId: _accessToken!.grantedBy,
        veterinarianContact: 'Dr. Smith - (555) 123-4567',
        emergencyContact: 'Emergency Vet - (555) 987-6543',
        allergies: 'Chicken, Pollen',
        chronicConditions: 'None',
        vaccinationHistory: 'Up to date - last updated 2024-01-15',
        generalNotes: 'Friendly dog, loves walks and treats',
        tags: ['friendly', 'active', 'vaccinated'],
        createdAt: DateTime.now().subtract(const Duration(days: 365)),
      );

      // Mock owner
      final owner = User(
        id: _accessToken!.grantedBy,
        email: 'owner@example.com',
        displayName: 'Pet Owner',
        createdAt: DateTime.now().subtract(const Duration(days: 400)),
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

            // Care plan (if sitter access)
            if (_accessToken!.role == AccessRole.sitter) ...[
              ReadOnlyCarePlan(pet: _pet!, carePlan: _carePlan),
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
