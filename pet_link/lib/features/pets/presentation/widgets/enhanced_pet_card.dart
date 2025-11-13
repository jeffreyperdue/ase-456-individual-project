import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petfolio/features/pets/domain/pet.dart';
import 'package:petfolio/features/pets/presentation/pages/enhanced_pet_detail_page.dart';
import 'package:petfolio/features/pets/presentation/state/pet_list_provider.dart';
import 'package:petfolio/features/sharing/presentation/pages/share_pet_page.dart';
import 'package:petfolio/features/care_plans/application/pet_with_plan_provider.dart';
import 'package:petfolio/app/utils/animation_utils.dart';

/// Enhanced pet card with hero image, progressive disclosure, and modern design
class EnhancedPetCard extends ConsumerWidget {
  final Pet pet;
  final String? cacheBustedUrl;
  final int index;

  const EnhancedPetCard({
    super.key,
    required this.pet,
    this.cacheBustedUrl,
    this.index = 0,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AnimationUtils.buildStaggeredItem(
      index: index,
      child: Card(
        elevation: pet.isLost ? 8 : 2,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: pet.isLost
              ? const BorderSide(color: Colors.red, width: 3)
              : BorderSide(
                  color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                  width: 1,
                ),
        ),
        child: InkWell(
          onTap: () => _navigateToDetail(context),
          borderRadius: BorderRadius.circular(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hero Section with Photo
              _buildHeroSection(context),

              // Content Section
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name and Status
                    _buildHeader(context),

                    const SizedBox(height: 12),

                    // Quick Stats
                    _buildQuickStats(context, ref),

                    const SizedBox(height: 16),

                    // Primary Actions (Max 2-3)
                    _buildPrimaryActions(context, ref),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeroSection(BuildContext context) {
    return Stack(
      children: [
        Container(
          height: 200, // Increased height to show more of the image
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Theme.of(context).colorScheme.primary.withOpacity(0.1),
                Theme.of(context).colorScheme.secondary.withOpacity(0.1),
              ],
            ),
          ),
          child: cacheBustedUrl != null
              ? ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(20)),
                  child: Image.network(
                    cacheBustedUrl!,
                    fit: BoxFit.contain, // Changed from cover to contain to show full image
                    alignment: Alignment.center,
                    errorBuilder: (_, __, ___) => _buildPlaceholder(context),
                  ),
                )
              : _buildPlaceholder(context),
        ),

        // Status Badge (Lost/Found)
        if (pet.isLost)
          Positioned(
            top: 12,
            right: 12,
            child: _buildStatusBadge(context),
          ),
      ],
    );
  }

  Widget _buildPlaceholder(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius:
            const BorderRadius.vertical(top: Radius.circular(20)),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).colorScheme.primary.withOpacity(0.2),
            Theme.of(context).colorScheme.secondary.withOpacity(0.2),
          ],
        ),
      ),
      child: Center(
        child: Icon(
          Icons.pets,
          size: 64,
          color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.red,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.warning_amber_rounded, color: Colors.white, size: 16),
          SizedBox(width: 4),
          Text(
            'LOST',
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }

  // Removed duplicate menu button - using the one in primary actions instead

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                pet.name,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                pet.species,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuickStats(BuildContext context, WidgetRef ref) {
    final petWithPlanAsync = ref.watch(petWithPlanProvider(pet.id));

    return petWithPlanAsync.when(
      data: (petWithPlan) {
        if (petWithPlan.carePlan == null) {
          return Row(
            children: [
              Icon(
                Icons.medical_services_outlined,
                size: 16,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 8),
              Text(
                'No care plan',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            ],
          );
        }

        final hasUrgentTasks = petWithPlan.taskStats.hasUrgentTasks;
        return Row(
          children: [
            Icon(
              hasUrgentTasks ? Icons.priority_high : Icons.medical_services,
              size: 16,
              color: hasUrgentTasks
                  ? Theme.of(context).colorScheme.error
                  : Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                petWithPlan.taskStats.summary,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: hasUrgentTasks
                          ? Theme.of(context).colorScheme.error
                          : Theme.of(context).colorScheme.onSurfaceVariant,
                      fontWeight: hasUrgentTasks ? FontWeight.w600 : null,
                    ),
              ),
            ),
          ],
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _buildPrimaryActions(BuildContext context, WidgetRef ref) {
    return Row(
      children: [
        // Primary: View Details (most common action)
        Expanded(
          child: FilledButton.icon(
            onPressed: () => _navigateToDetail(context),
            icon: const Icon(Icons.visibility, size: 18),
            label: const Text('View Details'),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),

        const SizedBox(width: 8),

        // Secondary: More Options (progressive disclosure)
        OutlinedButton(
          onPressed: () => _showMoreOptions(context),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.all(12),
            minimumSize: const Size(56, 48), // Meets 44x44pt accessibility requirement
          ),
          child: const Icon(Icons.more_vert),
        ),
      ],
    );
  }

  void _navigateToDetail(BuildContext context) {
    Navigator.of(context).push(
      AnimationUtils.createPageRoute(
        EnhancedPetDetailPage(pet: pet),
      ),
    );
  }

  void _showMoreOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _buildOptionsSheet(context),
    );
  }

  Widget _buildOptionsSheet(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          const SizedBox(height: 16),

          // Options
          ListTile(
            leading: const Icon(Icons.share),
            title: const Text('Share Pet'),
            onTap: () {
              Navigator.pop(context);
              _navigateToShare(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.edit),
            title: const Text('Edit Pet'),
            onTap: () {
              Navigator.pop(context);
              _navigateToEdit(context);
            },
          ),
          ListTile(
            leading: Icon(Icons.delete, color: Theme.of(context).colorScheme.error),
            title: Text(
              'Delete Pet',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
            onTap: () {
              Navigator.pop(context);
              _showDeleteDialog(context);
            },
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }

  void _navigateToShare(BuildContext context) {
    Navigator.of(context).push(
      AnimationUtils.createPageRoute(
        SharePetPage(pet: pet),
      ),
    );
  }

  void _navigateToEdit(BuildContext context) {
    Navigator.pushNamed(context, '/edit', arguments: {'pet': pet});
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => Consumer(
        builder: (context, ref, _) => AlertDialog(
          title: const Text('Delete Pet'),
          content: Text('Are you sure you want to delete ${pet.name}? This action cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () async {
                Navigator.pop(dialogContext);
                // Delete through provider
                await ref.read(petsProvider.notifier).remove(pet.id);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${pet.name} has been deleted'),
                    ),
                  );
                }
              },
              style: FilledButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
              child: const Text('Delete'),
            ),
          ],
        ),
      ),
    );
  }
}

