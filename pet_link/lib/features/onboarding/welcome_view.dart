import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petfolio/services/local_storage_provider.dart';

/// Welcome screen shown to first-time users.
/// Introduces Petfolio and provides a clear path to get started.
class WelcomeView extends ConsumerWidget {
  const WelcomeView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                // Top spacing
                const SizedBox(height: 32),
                
                // App Logo and Title
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.pets,
                    size: 80,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 24),
                
                Text(
                  'Welcome to Petfolio',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                
                Text(
                  'Your shared hub for pet care',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                
                // Value Proposition Cards
                _buildValueCard(
                  context,
                  icon: Icons.sync,
                  title: 'Real-time Sync',
                  description: 'Keep all caregivers in sync with shared care plans and reminders',
                ),
                const SizedBox(height: 16),
                
                _buildValueCard(
                  context,
                  icon: Icons.people,
                  title: 'Easy Handoffs',
                  description: 'Generate secure QR codes for sitters and temporary caregivers',
                ),
                const SizedBox(height: 16),
                
                _buildValueCard(
                  context,
                  icon: Icons.search,
                  title: 'Lost & Found',
                  description: 'Quick alerts and poster generation if your pet goes missing',
                ),
                
                const SizedBox(height: 48),
                
                // Get Started Button
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () => _navigateToAuth(context, ref),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text(
                      'Get Started',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Sign In Link
                TextButton(
                  onPressed: () => _navigateToLogin(context, ref),
                  child: const Text('Already have an account? Sign In'),
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

  Widget _buildValueCard(
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

  void _navigateToAuth(BuildContext context, WidgetRef ref) async {
    // Mark that user has seen welcome screen
    final localStorage = ref.read(localStorageServiceProvider);
    await localStorage.setHasSeenWelcome();
    
    if (context.mounted) {
      Navigator.pushReplacementNamed(context, '/signup');
    }
  }

  void _navigateToLogin(BuildContext context, WidgetRef ref) async {
    // Mark that user has seen welcome screen
    final localStorage = ref.read(localStorageServiceProvider);
    await localStorage.setHasSeenWelcome();
    
    if (context.mounted) {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }
}
