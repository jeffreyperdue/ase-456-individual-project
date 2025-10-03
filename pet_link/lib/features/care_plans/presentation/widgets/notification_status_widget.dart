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
                  color: _getStatusColor(setupState, notificationsEnabled),
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
    NotificationSetupState setupState,
    bool notificationsEnabled,
  ) {
    if (!notificationsEnabled) {
      return Colors.grey;
    }

    if (setupState.hasPermissions) {
      return Colors.green;
    } else if (setupState.error != null) {
      return Colors.red;
    } else {
      return Colors.orange;
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
        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
      );
    }

    if (setupState.hasPermissions) {
      return Text(
        'You\'ll receive reminders for feeding and medication times.',
        style: TextStyle(fontSize: 12, color: Colors.green[700]),
      );
    } else if (setupState.error != null) {
      return Text(
        'Error: ${setupState.error}',
        style: const TextStyle(fontSize: 12, color: Colors.red),
      );
    } else {
      return Text(
        'Notifications are enabled but permissions are needed.',
        style: TextStyle(fontSize: 12, color: Colors.orange[700]),
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
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.red[200]!),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, size: 16, color: Colors.red[700]),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              error,
              style: TextStyle(fontSize: 12, color: Colors.red[700]),
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
        'PetLink Test',
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
          const SnackBar(
            content: Text(
              'Test notification sent! Check your notification area.',
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to send test notification: $e'),
            backgroundColor: Colors.red,
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
            title: const Row(
              children: [
                Icon(Icons.notifications, color: Colors.blue),
                SizedBox(width: 8),
                Text('Mock Notification'),
              ],
            ),
            content: const Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'PetLink Test',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text(
                  'This is a test notification to verify your settings are working correctly.',
                ),
                SizedBox(height: 16),
                Text(
                  'Note: This is a mock notification for web testing. On mobile devices, you would receive an actual system notification.',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
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
