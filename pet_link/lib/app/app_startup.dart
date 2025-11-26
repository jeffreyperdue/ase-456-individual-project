import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petfolio/features/auth/presentation/state/auth_provider.dart';
import 'package:petfolio/features/onboarding/welcome_view.dart';
import 'package:petfolio/services/local_storage_provider.dart';
import 'package:petfolio/features/pets/presentation/pages/edit_pet_page.dart';
import 'package:petfolio/features/pets/presentation/state/pet_list_provider.dart';

/// App startup widget that handles initial routing based on authentication and onboarding state.
class AppStartup extends ConsumerWidget {
  final Widget child;
  
  const AppStartup({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final onboardingComplete = ref.watch(onboardingCompleteProvider);
    // We still read hasSeenWelcome in case we want it for future microcopy,
    // but routing for logged-out users now always shows WelcomeView.
    final hasSeenWelcome = ref.watch(hasSeenWelcomeProvider);

    // Debug logging
    print('AppStartup Debug:');
    print('  authState: $authState');
    print('  onboardingComplete: ${onboardingComplete.value}');
    print('  hasSeenWelcome: ${hasSeenWelcome.value}');

    return authState.when(
      data: (user) {
        if (user == null) {
          // User is not authenticated - always show welcome screen.
          // hasSeenWelcome is ignored for routing to keep behavior consistent
          // on cold start and after logout.
          return const WelcomeView();
        } else {
          // User is authenticated - check onboarding completion
          return onboardingComplete.when(
            data: (completed) {
              print('  User authenticated, onboarding completed: $completed');
              if (!completed) {
                // Check if user actually has pets (fallback for existing users)
                final petsAsync = ref.watch(petsProvider);
                return petsAsync.when(
                  data: (pets) {
                    print('  User has ${pets.length} pets');
                    if (pets.isNotEmpty) {
                      // User has pets but onboarding not marked complete - mark it now
                      WidgetsBinding.instance.addPostFrameCallback((_) async {
                        final localStorage = ref.read(localStorageServiceProvider);
                        await localStorage.setOnboardingComplete();
                        print('  Marked onboarding as complete for existing user');
                      });
                      return child; // Show main app
                    } else {
                      // User has no pets - show guided pet creation
                      print('  Showing guided pet creation for new user');
                      return const EditPetPage(isFirstTimeFlow: true);
                    }
                  },
                  loading: () => _buildLoadingScreen(context),
                  error: (error, stack) => _buildErrorScreen(context, ref, error.toString()),
                );
              } else {
                // Show main app
                print('  Showing main app for completed onboarding');
                return child;
              }
            },
            loading: () => _buildLoadingScreen(context),
            error: (error, stack) => _buildErrorScreen(context, ref, error.toString()),
          );
        }
      },
      loading: () => _buildLoadingScreen(context),
      error: (error, stack) => _buildErrorScreen(context, ref, error.toString()),
    );
  }

  Widget _buildLoadingScreen(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.pets,
              size: 80,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              'Petfolio',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 32),
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            const Text('Loading...'),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorScreen(BuildContext context, WidgetRef ref, String error) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 80,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Startup Error',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              error,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                // Retry by invalidating providers
                ref.invalidate(authProvider);
                ref.invalidate(onboardingCompleteProvider);
                ref.invalidate(hasSeenWelcomeProvider);
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

