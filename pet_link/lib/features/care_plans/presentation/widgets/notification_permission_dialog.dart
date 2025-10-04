import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../application/notification_setup_provider.dart';

/// Dialog for requesting notification permissions from the user.
class NotificationPermissionDialog extends ConsumerWidget {
  const NotificationPermissionDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.notifications, color: Colors.blue),
          SizedBox(width: 12),
          Text('Enable Notifications'),
        ],
      ),
      content: const Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Petfolio would like to send you reminders for:',
            style: TextStyle(fontWeight: FontWeight.w500),
          ),
          SizedBox(height: 16),
          _PermissionItem(
            icon: Icons.restaurant,
            title: 'Feeding Times',
            description: 'Get reminded when it\'s time to feed your pets',
          ),
          SizedBox(height: 12),
          _PermissionItem(
            icon: Icons.medication,
            title: 'Medication Times',
            description: 'Never miss giving your pets their medications',
          ),
          SizedBox(height: 16),
          Text(
            'You can change these settings anytime in your device settings.',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Not Now'),
        ),
        FilledButton(
          onPressed: () => _requestPermissions(context, ref),
          child: const Text('Enable Notifications'),
        ),
      ],
    );
  }

  Future<void> _requestPermissions(BuildContext context, WidgetRef ref) async {
    try {
      final setupNotifier = ref.read(notificationSetupProvider.notifier);
      await setupNotifier.requestPermissions();

      if (context.mounted) {
        Navigator.of(context).pop(true);
        _showPermissionResult(context, ref);
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.of(context).pop(false);
        _showErrorDialog(context, e.toString());
      }
    }
  }

  void _showPermissionResult(BuildContext context, WidgetRef ref) {
    final setupState = ref.read(notificationSetupProvider);

    if (setupState.hasPermissions) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Notifications enabled! You\'ll receive reminders for your pets.',
          ),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      _showPermissionDeniedDialog(context);
    }
  }

  void _showPermissionDeniedDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Notifications Disabled'),
            content: const Text(
              'To receive pet care reminders, please enable notifications in your device settings.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
    );
  }

  void _showErrorDialog(BuildContext context, String error) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Error'),
            content: Text('Failed to request notification permissions: $error'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
    );
  }
}

class _PermissionItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _PermissionItem({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
              Text(
                description,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
