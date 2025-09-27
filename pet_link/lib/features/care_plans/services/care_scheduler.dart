import 'dart:async';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import '../domain/care_plan.dart';
import '../domain/feeding_schedule.dart';
import '../domain/medication.dart';
import 'clock.dart';

/// Service for scheduling care plan notifications.
///
/// Handles the scheduling, cancellation, and reconciliation of
/// local notifications based on care plans.
class CareScheduler {
  final FlutterLocalNotificationsPlugin _notifications;
  final Clock _clock;
  final Map<String, List<int>> _scheduledNotificationIds = {};

  CareScheduler({
    required FlutterLocalNotificationsPlugin notifications,
    required Clock clock,
  }) : _notifications = notifications,
       _clock = clock;

  /// Schedule notifications for a care plan.
  /// This will cancel any existing notifications for the pet and schedule new ones.
  Future<void> scheduleNotificationsForCarePlan(CarePlan carePlan) async {
    final petId = carePlan.petId;

    // Cancel existing notifications for this pet
    await cancelNotificationsForPet(petId);

    final scheduledIds = <int>[];

    // Schedule feeding notifications
    for (final schedule in carePlan.activeFeedingSchedules) {
      for (final time in schedule.times) {
        final notificationId = await _scheduleFeedingNotification(
          carePlan,
          schedule,
          time,
        );
        if (notificationId != null) {
          scheduledIds.add(notificationId);
        }
      }
    }

    // Schedule medication notifications
    for (final medication in carePlan.activeMedications) {
      for (final time in medication.times) {
        final notificationId = await _scheduleMedicationNotification(
          carePlan,
          medication,
          time,
        );
        if (notificationId != null) {
          scheduledIds.add(notificationId);
        }
      }
    }

    // Store the scheduled notification IDs for this pet
    _scheduledNotificationIds[petId] = scheduledIds;
  }

  /// Cancel all notifications for a specific pet.
  Future<void> cancelNotificationsForPet(String petId) async {
    final ids = _scheduledNotificationIds[petId];
    if (ids != null && ids.isNotEmpty) {
      for (final id in ids) {
        await _notifications.cancel(id);
      }
      _scheduledNotificationIds.remove(petId);
    }
  }

  /// Cancel all scheduled notifications.
  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
    _scheduledNotificationIds.clear();
  }

  /// Reconcile all notifications (cancel all and reschedule from latest data).
  /// This should be called on app startup to prevent notification drift.
  Future<void> reconcileNotifications(List<CarePlan> carePlans) async {
    await cancelAllNotifications();

    for (final carePlan in carePlans) {
      if (carePlan.hasActiveSchedules) {
        await scheduleNotificationsForCarePlan(carePlan);
      }
    }
  }

  /// Schedule a single feeding notification.
  Future<int?> _scheduleFeedingNotification(
    CarePlan carePlan,
    FeedingSchedule schedule,
    String timeString,
  ) async {
    try {
      // Calculate next occurrence time
      final nextTime = _calculateNextOccurrence(
        timeString,
        schedule.daysOfWeek,
      );

      if (nextTime == null) return null;

      final notificationId = _generateNotificationId(
        carePlan.petId,
        'feeding',
        timeString,
      );

      await _notifications.zonedSchedule(
        notificationId,
        '${schedule.label ?? 'Feeding'} Time',
        'Time to feed your pet!',
        tz.TZDateTime.from(nextTime, tz.local),
        NotificationDetails(
          android: AndroidNotificationDetails(
            'care_plans_feeding',
            'Pet Feeding Reminders',
            channelDescription: 'Reminders for pet feeding times',
            importance: Importance.high,
            priority: Priority.high,
            icon: 'ic_notification',
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: _getDateTimeComponents(schedule.daysOfWeek),
      );

      return notificationId;
    } catch (e) {
      print('Failed to schedule feeding notification: $e');
      return null;
    }
  }

  /// Schedule a single medication notification.
  Future<int?> _scheduleMedicationNotification(
    CarePlan carePlan,
    Medication medication,
    String timeString,
  ) async {
    try {
      // Calculate next occurrence time
      final nextTime = _calculateNextOccurrence(
        timeString,
        medication.daysOfWeek,
      );

      if (nextTime == null) return null;

      final notificationId = _generateNotificationId(
        carePlan.petId,
        'medication',
        timeString,
      );

      final title = '${medication.name} - Medication Time';
      final body =
          'Time to give ${medication.dosage}${medication.withFood ? ' with food' : ''}';

      await _notifications.zonedSchedule(
        notificationId,
        title,
        body,
        tz.TZDateTime.from(nextTime, tz.local),
        NotificationDetails(
          android: AndroidNotificationDetails(
            'care_plans_medication',
            'Pet Medication Reminders',
            channelDescription: 'Reminders for pet medication times',
            importance: Importance.high,
            priority: Priority.high,
            icon: 'ic_notification',
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: _getDateTimeComponents(medication.daysOfWeek),
      );

      return notificationId;
    } catch (e) {
      print('Failed to schedule medication notification: $e');
      return null;
    }
  }

  /// Calculate the next occurrence of a scheduled time.
  DateTime? _calculateNextOccurrence(String timeString, List<int>? daysOfWeek) {
    final parts = timeString.split(':');
    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);

    final now = _clock.nowLocal();
    final today = DateTime(now.year, now.month, now.day, hour, minute);

    // If it's a daily schedule or today is included
    if (daysOfWeek == null || daysOfWeek.contains(now.weekday % 7)) {
      if (today.isAfter(now)) {
        return today;
      }
    }

    // Find the next occurrence
    for (int i = 1; i <= 7; i++) {
      final nextDay = now.add(Duration(days: i));
      final nextOccurrence = DateTime(
        nextDay.year,
        nextDay.month,
        nextDay.day,
        hour,
        minute,
      );

      if (daysOfWeek == null || daysOfWeek.contains(nextDay.weekday % 7)) {
        return nextOccurrence;
      }
    }

    return null; // Should never happen
  }

  /// Generate a unique notification ID for a scheduled item.
  int _generateNotificationId(String petId, String type, String time) {
    final combined = '${petId}_${type}_$time';
    return combined.hashCode.abs();
  }

  /// Get DateTimeComponents for notification scheduling.
  DateTimeComponents _getDateTimeComponents(List<int>? daysOfWeek) {
    if (daysOfWeek == null) {
      return DateTimeComponents.time; // Daily
    }

    if (daysOfWeek.length == 7) {
      return DateTimeComponents.time; // Daily (all days)
    }

    return DateTimeComponents.dayOfWeekAndTime; // Specific days
  }
}
