import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_link/features/auth/presentation/state/auth_provider.dart';
import 'package:pet_link/features/auth/presentation/pages/login_page.dart';
import 'package:pet_link/features/care_plans/application/notification_setup_provider.dart';

/// Wrapper widget that handles authentication state and redirects accordingly.
class AuthWrapper extends ConsumerStatefulWidget {
  final Widget child;

  const AuthWrapper({super.key, required this.child});

  @override
  ConsumerState<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends ConsumerState<AuthWrapper> {
  bool _notificationsInitialized = false;

  @override
  void initState() {
    super.initState();
    // Initialize notifications on app startup
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeNotifications();
    });
  }

  Future<void> _initializeNotifications() async {
    if (_notificationsInitialized) return;

    try {
      final setupNotifier = ref.read(notificationSetupProvider.notifier);
      await setupNotifier.completeSetup();
      _notificationsInitialized = true;
    } catch (e) {
      // Log error but don't crash the app
      print('Failed to initialize notifications: $e');
    }
  }

  Future<void> _reconcileNotifications() async {
    try {
      // For now, we'll just ensure notifications are initialized
      // In a full implementation, we'd fetch all care plans for the user
      // and reconcile them with the notification system
      if (!_notificationsInitialized) {
        await _initializeNotifications();
      }
    } catch (e) {
      print('Failed to reconcile notifications: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return authState.when(
      data: (user) {
        if (user == null) {
          // User is not authenticated, show login page
          return const LoginPage();
        } else {
          // User is authenticated, reconcile notifications and show the main app
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _reconcileNotifications();
          });
          return widget.child;
        }
      },
      loading: () {
        // Show loading screen while checking authentication
        return const Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.pets, size: 80, color: Colors.blue),
                SizedBox(height: 16),
                Text(
                  'PetLink',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                SizedBox(height: 32),
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Loading...'),
              ],
            ),
          ),
        );
      },
      error: (error, stackTrace) {
        // Show error screen
        return Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 80, color: Colors.red),
                const SizedBox(height: 16),
                const Text(
                  'Authentication Error',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Text(
                  error.toString(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: () {
                    // Retry by invalidating the auth provider
                    ref.invalidate(authProvider);
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
