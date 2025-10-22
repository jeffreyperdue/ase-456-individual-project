import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petfolio/services/local_storage_provider.dart';

/// Success screen shown after completing the first-time pet creation flow.
class SuccessView extends ConsumerWidget {
  const SuccessView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final petName = ModalRoute.of(context)?.settings.arguments is Map
        ? (ModalRoute.of(context)?.settings.arguments as Map)['petName'] as String?
        : 'your pet';

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                // Top spacing
                const SizedBox(height: 32),
                
                // Success animation/icon
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check_circle,
                    size: 80,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 32),
                
                // Success message
                Text(
                  'Congratulations!',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                
                Text(
                  '$petName has been added to Petfolio!',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: theme.colorScheme.onSurface,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                
                Text(
                  'Your pet profile is now ready. You can add care plans, medical information, and share access with family members or pet sitters.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                
                // Next steps cards
                _buildNextStepCard(
                  context,
                  icon: Icons.medical_services,
                  title: 'Add Care Plan',
                  description: 'Set up feeding schedules, medications, and daily routines',
                ),
                const SizedBox(height: 12),
                
                _buildNextStepCard(
                  context,
                  icon: Icons.people,
                  title: 'Share Access',
                  description: 'Generate QR codes for family members and pet sitters',
                ),
                const SizedBox(height: 12),
                
                _buildNextStepCard(
                  context,
                  icon: Icons.notifications,
                  title: 'Set Reminders',
                  description: 'Get notifications for feeding times and medication',
                ),
                
                const SizedBox(height: 48),
                
                // Go to Dashboard button
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () => _goToDashboard(context, ref),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text(
                      'Go to Dashboard',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                
                // Bottom spacing to prevent overflow
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNextStepCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
  }) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: theme.colorScheme.primary,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _goToDashboard(BuildContext context, WidgetRef ref) async {
    // Mark onboarding as complete
    final localStorage = ref.read(localStorageServiceProvider);
    await localStorage.setOnboardingComplete();
    
    // Navigate to dashboard
    if (context.mounted) {
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/',
        (route) => false, // Remove all previous routes
      );
    }
  }
}
