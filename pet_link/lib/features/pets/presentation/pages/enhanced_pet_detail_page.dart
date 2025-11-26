import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/pet.dart';
import '../../../care_plans/presentation/pages/care_plan_view_page.dart';
import '../../../care_plans/presentation/pages/care_plan_form_page.dart';
import '../../application/pet_with_details_provider.dart';
import '../../application/pet_profile_providers.dart';
import '../../../care_plans/application/pet_with_plan_provider.dart';
import '../../presentation/state/pet_list_provider.dart';
import '../widgets/pet_profile_card.dart';
import 'pet_profile_form_page.dart';
import '../../../lost_found/presentation/state/lost_found_provider.dart';
import '../../../lost_found/presentation/pages/lost_pet_poster_page.dart';
import '../../../auth/presentation/state/auth_provider.dart';
import '../../../sharing/presentation/pages/share_pet_page.dart';
import '../../../../app/utils/animation_utils.dart';

/// Enhanced pet detail page with tabbed interface and collapsible app bar
class EnhancedPetDetailPage extends ConsumerStatefulWidget {
  final Pet pet;

  const EnhancedPetDetailPage({
    super.key,
    required this.pet,
  });

  @override
  ConsumerState<EnhancedPetDetailPage> createState() =>
      _EnhancedPetDetailPageState();
}

class _EnhancedPetDetailPageState
    extends ConsumerState<EnhancedPetDetailPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          _buildSliverAppBar(context, innerBoxIsScrolled),
        ],
        body: Column(
          children: [
            // Tab Bar
            TabBar(
              controller: _tabController,
              tabs: const [
                Tab(icon: Icon(Icons.info_outline), text: 'Overview'),
                Tab(icon: Icon(Icons.medical_services), text: 'Care Plan'),
                Tab(icon: Icon(Icons.history), text: 'History'),
                Tab(icon: Icon(Icons.settings), text: 'Settings'),
              ],
            ),

            // Tab Views
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildOverviewTab(context),
                  _buildCarePlanTab(context),
                  _buildHistoryTab(context),
                  _buildSettingsTab(context),
                ],
              ),
            ),
          ],
        ),
      ),

      // Floating Action Button for Quick Actions
      floatingActionButton: _buildQuickActionFAB(context),
    );
  }

  Widget _buildSliverAppBar(BuildContext context, bool innerBoxIsScrolled) {
    return SliverAppBar(
      expandedHeight: 300,
      floating: false,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        background: _buildHeroImage(context),
        title: Text(
          widget.pet.name,
          style: TextStyle(
            color: Colors.white,
            shadows: [
              Shadow(
                color: Colors.black.withOpacity(0.5),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
        ),
        centerTitle: true,
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.share),
          onPressed: () => _sharePet(context),
          tooltip: 'Share Pet',
        ),
        PopupMenuButton(
          itemBuilder: (context) => [
            PopupMenuItem(
              child: const ListTile(
                leading: Icon(Icons.edit),
                title: Text('Edit Pet'),
                contentPadding: EdgeInsets.zero,
              ),
              onTap: () {
                Future.microtask(() => _navigateToEditPet(context));
              },
            ),
            PopupMenuItem(
              child: ListTile(
                leading: Icon(Icons.delete, color: Theme.of(context).colorScheme.error),
                title: Text(
                  'Delete Pet',
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
                contentPadding: EdgeInsets.zero,
              ),
              onTap: () {
                Future.microtask(() => _showDeleteDialog(context));
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildHeroImage(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        widget.pet.photoUrl != null
            ? Image.network(
                widget.pet.photoUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _buildPlaceholder(context),
              )
            : _buildPlaceholder(context),
        // Gradient overlay for better text readability
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent,
                Colors.black.withOpacity(0.3),
              ],
            ),
          ),
        ),
        // Lost badge overlay
        if (widget.pet.isLost)
          Positioned(
            top: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
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
            ),
          ),
      ],
    );
  }

  Widget _buildPlaceholder(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).colorScheme.primary.withOpacity(0.3),
            Theme.of(context).colorScheme.secondary.withOpacity(0.3),
          ],
        ),
      ),
      child: Center(
        child: Icon(
          Icons.pets,
          size: 100,
          color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
        ),
      ),
    );
  }

  Widget _buildOverviewTab(BuildContext context) {
    final profileAsync = ref.watch(petProfileForPetProvider(widget.pet.id));
    final petWithPlanAsync = ref.watch(petWithPlanProvider(widget.pet.id));

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Quick Stats Grid
          _buildQuickStatsGrid(context, petWithPlanAsync),

          const SizedBox(height: 24),

          // Basic Information Card
          _buildBasicInfoCard(context),

          const SizedBox(height: 24),

          // Profile Information
          _buildProfileSection(context, ref, profileAsync),

          const SizedBox(height: 24),

          // Upcoming Tasks (if any)
          _buildUpcomingTasks(context, petWithPlanAsync),

          const SizedBox(height: 24),

          // Lost & Found Status
          _buildLostFoundCard(context, ref),
        ],
      ),
    );
  }

  Widget _buildQuickStatsGrid(
      BuildContext context, AsyncValue petWithPlanAsync) {
    return petWithPlanAsync.when(
      data: (petWithPlan) {
        final stats = petWithPlan.taskStats;
        return GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.5,
          children: [
            _buildStatCard(
              context,
              'Today\'s Tasks',
              stats.todayCount.toString(),
              Icons.today,
              Theme.of(context).colorScheme.primary,
            ),
            _buildStatCard(
              context,
              'Total Tasks',
              stats.totalCount.toString(),
              Icons.assignment,
              Theme.of(context).colorScheme.secondary,
            ),
            _buildStatCard(
              context,
              'Completed',
              stats.completedCount.toString(),
              Icons.check_circle,
              Theme.of(context).colorScheme.primary,
            ),
            _buildStatCard(
              context,
              'Pending',
              stats.pendingCount.toString(),
              Icons.pending,
              Theme.of(context).colorScheme.error,
            ),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBasicInfoCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Basic Information',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoRow(context, 'Species', widget.pet.species),
            if (widget.pet.breed != null)
              _buildInfoRow(context, 'Breed', widget.pet.breed!),
            if (widget.pet.dateOfBirth != null)
              _buildInfoRow(
                context,
                'Age',
                _calculateAge(widget.pet.dateOfBirth!),
              ),
            if (widget.pet.weightKg != null)
              _buildInfoRow(
                context,
                'Weight',
                '${widget.pet.weightKg!.toStringAsFixed(1)} kg',
              ),
            if (widget.pet.heightCm != null)
              _buildInfoRow(
                context,
                'Height',
                '${widget.pet.heightCm!.toStringAsFixed(1)} cm',
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  String _calculateAge(DateTime dateOfBirth) {
    final now = DateTime.now();
    final age = now.difference(dateOfBirth);
    final years = age.inDays ~/ 365;
    final months = (age.inDays % 365) ~/ 30;

    if (years > 0) {
      return months > 0 ? '$years years, $months months' : '$years years';
    } else {
      return '$months months';
    }
  }

  Widget _buildProfileSection(
    BuildContext context,
    WidgetRef ref,
    AsyncValue profileAsync,
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
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
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
          loading: () => const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            ),
          ),
          error: (error, stack) => Card(
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
                    child: Text(
                      'Failed to load profile: $error',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onErrorContainer,
                      ),
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

  Widget _buildUpcomingTasks(BuildContext context, AsyncValue petWithPlanAsync) {
    return petWithPlanAsync.when(
      data: (petWithPlan) {
        if (petWithPlan.carePlan == null || petWithPlan.taskStats.todayCount == 0) {
          return const SizedBox.shrink();
        }

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.schedule,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Today\'s Tasks',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  '${petWithPlan.taskStats.todayCount} task${petWithPlan.taskStats.todayCount != 1 ? 's' : ''} scheduled for today',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 12),
                FilledButton.icon(
                  onPressed: () => _navigateToCarePlanView(context),
                  icon: const Icon(Icons.visibility),
                  label: const Text('View Tasks'),
                ),
              ],
            ),
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _buildLostFoundCard(BuildContext context, WidgetRef ref) {
    final lostReportAsync = ref.watch(lostReportProvider(widget.pet.id));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.warning_amber_rounded,
              color: widget.pet.isLost
                  ? Colors.red
                  : Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 8),
            Text(
              'Lost & Found',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (widget.pet.isLost)
          Card(
            color: Colors.red[50],
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.error_outline, color: Colors.red[700]),
                      const SizedBox(width: 8),
                      Text(
                        'This pet is marked as LOST',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.red[900],
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  lostReportAsync.when(
                    data: (lostReport) {
                      if (lostReport == null) {
                        return const SizedBox.shrink();
                      }
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (lostReport.lastSeenLocation != null) ...[
                            Text(
                              'Last seen: ${lostReport.lastSeenLocation}',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            const SizedBox(height: 8),
                          ],
                        ],
                      );
                    },
                    loading: () => const CircularProgressIndicator(),
                    error: (_, __) => const SizedBox.shrink(),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: () => _viewPoster(context, ref),
                          icon: const Icon(Icons.image),
                          label: const Text('View Poster'),
                          style: FilledButton.styleFrom(
                            backgroundColor: Colors.red[700],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _markAsFound(context, ref),
                          icon: const Icon(Icons.check_circle),
                          label: const Text('Mark as Found'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          )
        else
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Has your pet gone missing?',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Mark your pet as lost to generate a shareable poster.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: () => _markAsLost(context, ref),
                    icon: const Icon(Icons.warning_amber),
                    label: const Text('Mark as Lost'),
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildCarePlanTab(BuildContext context) {
    final petWithDetailsAsync = ref.watch(petWithDetailsProvider(widget.pet.id));

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: petWithDetailsAsync.when(
        data: (petWithDetails) {
          if (petWithDetails.carePlan == null) {
            return _buildNoCarePlanCard(context);
          }
          return _buildCarePlanContent(context, petWithDetails.carePlan!);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => _buildCarePlanErrorCard(context, error),
      ),
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
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Create a care plan to track ${widget.pet.name}\'s feeding schedules, medications, and health reminders.',
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

  Widget _buildCarePlanContent(BuildContext context, carePlan) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Card(
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
                  ],
                ),
                const SizedBox(height: 16),
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
        ),
      ],
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

  Widget _buildHistoryTab(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history,
            size: 64,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 16),
          Text(
            'History',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Task completion history and activity logs will appear here.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTab(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.share),
                  title: const Text('Share Pet'),
                  subtitle: const Text('Generate QR code or share link'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _sharePet(context),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.edit),
                  title: const Text('Edit Pet'),
                  subtitle: const Text('Update pet information'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _navigateToEditPet(context),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: Icon(Icons.delete, color: Theme.of(context).colorScheme.error),
                  title: Text(
                    'Delete Pet',
                    style: TextStyle(color: Theme.of(context).colorScheme.error),
                  ),
                  subtitle: Text(
                    'Permanently remove this pet',
                    style: TextStyle(color: Theme.of(context).colorScheme.error),
                  ),
                  trailing: Icon(Icons.chevron_right, color: Theme.of(context).colorScheme.error),
                  onTap: () => _showDeleteDialog(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionFAB(BuildContext context) {
    final petWithPlanAsync = ref.watch(petWithPlanProvider(widget.pet.id));

    return petWithPlanAsync.when(
      data: (petWithPlan) {
        if (petWithPlan.carePlan == null) {
          return FloatingActionButton.extended(
            onPressed: () => _navigateToCreateCarePlan(context),
            icon: const Icon(Icons.add),
            label: const Text('Create Care Plan'),
          );
        }
        return FloatingActionButton(
          onPressed: () => _navigateToCarePlanView(context),
          child: const Icon(Icons.schedule),
          tooltip: 'View Tasks',
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  // Navigation methods
  void _navigateToEditPet(BuildContext context) {
    Navigator.pushNamed(context, '/edit', arguments: {'pet': widget.pet});
  }

  void _navigateToCarePlanView(BuildContext context) {
    Navigator.of(context).push(
      AnimationUtils.createPageRoute(
        CarePlanViewPage(pet: widget.pet),
      ),
    );
  }

  void _navigateToCreateCarePlan(BuildContext context) {
    Navigator.of(context).push(
      AnimationUtils.createPageRoute(
        CarePlanFormPage(pet: widget.pet),
      ),
    );
  }

  void _navigateToEditCarePlan(BuildContext context) {
    Navigator.of(context).push(
      AnimationUtils.createPageRoute(
        CarePlanFormPage(pet: widget.pet),
      ),
    );
  }

  void _navigateToEditProfile(BuildContext context, dynamic profile) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => PetProfileFormPage(
          pet: widget.pet,
          existingProfile: profile,
        ),
      ),
    );
  }

  void _navigateToCreateProfile(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => PetProfileFormPage(pet: widget.pet),
      ),
    );
  }

  void _sharePet(BuildContext context) {
    Navigator.of(context).push(
      AnimationUtils.createPageRoute(
        SharePetPage(pet: widget.pet),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Pet'),
        content: Text('Are you sure you want to delete ${widget.pet.name}? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(context);
              await ref.read(petsProvider.notifier).remove(widget.pet.id);
              if (context.mounted) {
                Navigator.pop(context); // Go back to home page
              }
            },
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _markAsLost(BuildContext context, WidgetRef ref) async {
    final currentUser = ref.read(currentUserDataProvider);
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You must be logged in to mark a pet as lost')),
      );
      return;
    }

    final lastSeenController = TextEditingController();
    final notesController = TextEditingController();

    final result = await showDialog<Map<String, String?>>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Mark Pet as Lost'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Please provide the following information (optional):',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: lastSeenController,
                decoration: const InputDecoration(
                  labelText: 'Last seen location',
                  hintText: 'e.g., Near Central Park',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: notesController,
                decoration: const InputDecoration(
                  labelText: 'Additional notes',
                  hintText: 'Any additional information',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(
              context,
              {
                'lastSeenLocation': lastSeenController.text.trim().isEmpty
                    ? null
                    : lastSeenController.text.trim(),
                'notes': notesController.text.trim().isEmpty
                    ? null
                    : notesController.text.trim(),
              },
            ),
            child: const Text('Mark as Lost'),
          ),
        ],
      ),
    );

    if (result != null) {
      try {
        final notifier = ref.read(lostFoundNotifierProvider.notifier);
        await notifier.markPetAsLost(
          pet: widget.pet,
          owner: currentUser,
          lastSeenLocation: result['lastSeenLocation'],
          notes: result['notes'],
        );

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${widget.pet.name} has been marked as lost'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error marking pet as lost: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _viewPoster(BuildContext context, WidgetRef ref) async {
    final currentUser = ref.read(currentUserDataProvider);
    if (currentUser == null) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('You must be logged in to view the poster'),
          ),
        );
      }
      return;
    }

    try {
      final repository = ref.read(lostReportRepositoryProvider);
      final lostReport = await repository.getLostReportByPetId(widget.pet.id);

      if (lostReport == null) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Lost report not found. Please mark the pet as lost again.'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
      }

      if (context.mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => LostPetPosterPage(
              pet: widget.pet,
              owner: currentUser,
              lostReport: lostReport,
            ),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading poster: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _markAsFound(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Mark as Found'),
        content: Text('Are you sure ${widget.pet.name} has been found?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Mark as Found'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final repository = ref.read(lostReportRepositoryProvider);
        final lostReport = await repository.getLostReportByPetId(widget.pet.id);

        final notifier = ref.read(lostFoundNotifierProvider.notifier);
        await notifier.markPetAsFound(
          pet: widget.pet,
          lostReport: lostReport,
        );

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${widget.pet.name} has been marked as found!'),
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error marking pet as found: $e'),
            ),
          );
        }
      }
    }
  }
}

