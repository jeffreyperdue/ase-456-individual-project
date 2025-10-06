import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/foundation.dart';
import '../../application/notification_setup_provider.dart';
import '../../application/providers.dart';
import 'notification_permission_dialog.dart';

/// Widget that displays notification status and allows users to manage permissions.
class NotificationStatusWidget extends ConsumerWidget {
  const NotificationStatusWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final setupState = ref.watch(notificationSetupProvider);
    final notificationsEnabled = ref.watch(notificationsEnabledProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.notifications,
                  color: _getStatusColor(context, setupState, notificationsEnabled),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Notifications',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Switch(
                  value: notificationsEnabled,
                  onChanged: (enabled) => _toggleNotifications(ref, enabled),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _buildStatusText(context, setupState, notificationsEnabled),
            if (notificationsEnabled && !setupState.hasPermissions) ...[
              const SizedBox(height: 12),
              _buildPermissionRequestButton(context),
            ],
            if (notificationsEnabled && setupState.hasPermissions) ...[
              const SizedBox(height: 12),
              _buildTestNotificationButton(context, ref),
            ],
            if (setupState.error != null) ...[
              const SizedBox(height: 8),
              _buildErrorText(context, setupState.error!),
            ],
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(
    BuildContext context,
    NotificationSetupState setupState,
    bool notificationsEnabled,
  ) {
    if (!notificationsEnabled) {
      return Theme.of(context).colorScheme.onSurfaceVariant;
    }

    if (setupState.hasPermissions) {
      return Theme.of(context).colorScheme.primary;
    } else if (setupState.error != null) {
      return Theme.of(context).colorScheme.error;
    } else {
      return Theme.of(context).colorScheme.secondary;
    }
  }

  Widget _buildStatusText(
    BuildContext context,
    NotificationSetupState setupState,
    bool notificationsEnabled,
  ) {
    if (!notificationsEnabled) {
      return Text(
        'Notifications are disabled. You won\'t receive reminders for feeding or medication times.',
        style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant),
      );
    }

    if (setupState.hasPermissions) {
      return Text(
        'You\'ll receive reminders for feeding and medication times.',
        style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.primary),
      );
    } else if (setupState.error != null) {
      return Text(
        'Error: ${setupState.error}',
        style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.error),
      );
    } else {
      return Text(
        'Notifications are enabled but permissions are needed.',
        style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.secondary),
      );
    }
  }

  Widget _buildPermissionRequestButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () => _showPermissionDialog(context),
        icon: const Icon(Icons.notifications_active, size: 16),
        label: const Text('Enable Notifications'),
      ),
    );
  }

  Widget _buildTestNotificationButton(BuildContext context, WidgetRef ref) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () => _sendTestNotification(context, ref),
        icon: const Icon(Icons.send, size: 16),
        label: const Text('Send Test Notification'),
      ),
    );
  }

  Widget _buildErrorText(BuildContext context, String error) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.error.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Theme.of(context).colorScheme.error.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, size: 16, color: Theme.of(context).colorScheme.error),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              error,
              style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.error),
            ),
          ),
        ],
      ),
    );
  }

  void _toggleNotifications(WidgetRef ref, bool enabled) {
    ref.read(notificationsEnabledProvider.notifier).state = enabled;

    // If enabling notifications and permissions aren't granted, show permission dialog
    if (enabled) {
      final setupState = ref.read(notificationSetupProvider);
      if (!setupState.hasPermissions) {
        // We'll need to show the dialog from the parent widget
        // For now, just update the state
      }
    }
  }

  void _showPermissionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const NotificationPermissionDialog(),
    );
  }

  Future<void> _sendTestNotification(
    BuildContext context,
    WidgetRef ref,
  ) async {
    try {
      if (kIsWeb) {
        // Web doesn't support local notifications, show a mock dialog instead
        _showMockNotificationDialog(context);
        return;
      }

      final notifications = ref.read(flutterLocalNotificationsProvider);

      await notifications.show(
        999, // Test notification ID
        'Petfolio Test',
        'This is a test notification to verify your settings are working correctly.',
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'care_plans_feeding',
            'Pet Feeding Reminders',
            channelDescription: 'Reminders for pet feeding times',
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
      );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'Test notification sent! Check your notification area.',
            ),
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to send test notification: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  void _showMockNotificationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Row(
              children: [
                Icon(Icons.notifications, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                const Text('Mock Notification'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Petfolio Test',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  'This is a test notification to verify your settings are working correctly.',
                ),
                const SizedBox(height: 16),
                Text(
                  'Note: This is a mock notification for web testing. On mobile devices, you would receive an actual system notification.',
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
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
}
