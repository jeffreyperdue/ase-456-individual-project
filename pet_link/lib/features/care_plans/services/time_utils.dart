import 'package:flutter/material.dart';
import 'clock.dart';

/// Utility functions for time-related operations in care plans.
class TimeUtils {
  static const List<String> _timeSuggestions = [
    '06:00',
    '07:00',
    '07:30',
    '08:00',
    '08:30',
    '09:00',
    '12:00',
    '12:30',
    '13:00',
    '17:00',
    '17:30',
    '18:00',
    '18:30',
    '19:00',
    '19:30',
    '20:00',
    '21:00',
    '22:00',
  ];

  static const Map<String, List<String>> _quickAddChips = {
    'Morning': ['07:00', '07:30', '08:00'],
    'Lunch': ['12:00', '12:30', '13:00'],
    'Evening': ['18:00', '18:30', '19:00'],
    'Night': ['20:00', '21:00', '22:00'],
  };

  /// Get suggested times for quick selection.
  static List<String> getSuggestedTimes() => List.from(_timeSuggestions);

  /// Get quick-add chips for common feeding times.
  static Map<String, List<String>> getQuickAddChips() =>
      Map.from(_quickAddChips);

  /// Parse a time string (HH:mm) to TimeOfDay.
  static TimeOfDay? parseTimeOfDay(String timeString) {
    // First validate the format strictly
    if (!isValidTimeFormat(timeString)) {
      return null;
    }

    try {
      final parts = timeString.split(':');
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);

      if (hour >= 0 && hour <= 23 && minute >= 0 && minute <= 59) {
        return TimeOfDay(hour: hour, minute: minute);
      }
    } catch (e) {
      // Invalid format
    }
    return null;
  }

  /// Format TimeOfDay to HH:mm string.
  static String formatTimeOfDay(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  /// Format time string for display (12-hour format with AM/PM).
  static String formatTimeForDisplay(String timeString) {
    final timeOfDay = parseTimeOfDay(timeString);
    if (timeOfDay == null) return timeString;

    return '${timeOfDay.hourOfPeriod == 0 ? 12 : timeOfDay.hourOfPeriod}:${timeOfDay.minute.toString().padLeft(2, '0')} ${timeOfDay.period.name.toUpperCase()}';
  }

  /// Get day names for display.
  static List<String> getDayNames() {
    return [
      'Sunday',
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
    ];
  }

  /// Get short day names for display.
  static List<String> getShortDayNames() {
    return ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
  }

  /// Convert day names to numbers (0-6, Sunday = 0).
  static List<int> dayNamesToNumbers(List<String> dayNames) {
    final fullNames = getDayNames();
    return dayNames
        .map((name) => fullNames.indexOf(name))
        .where((index) => index != -1)
        .toList();
  }

  /// Convert day numbers to names.
  static List<String> dayNumbersToNames(List<int> dayNumbers) {
    final fullNames = getDayNames();
    return dayNumbers
        .where((num) => num >= 0 && num < 7)
        .map((num) => fullNames[num])
        .toList();
  }

  /// Validate time string format (HH:mm).
  static bool isValidTimeFormat(String timeString) {
    final regex = RegExp(r'^([01]?[0-9]|2[0-3]):[0-5][0-9]$');
    return regex.hasMatch(timeString);
  }

  /// Get next occurrence of a time on given days.
  static DateTime? getNextOccurrence(
    String timeString,
    List<int>? daysOfWeek,
    Clock clock,
  ) {
    if (!isValidTimeFormat(timeString)) return null;

    final parts = timeString.split(':');
    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);

    final now = clock.nowLocal();
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

    return null;
  }

  /// Get time until next occurrence.
  static Duration? getTimeUntilNext(
    String timeString,
    List<int>? daysOfWeek,
    Clock clock,
  ) {
    final next = getNextOccurrence(timeString, daysOfWeek, clock);
    if (next == null) return null;

    return next.difference(clock.nowLocal());
  }

  /// Format duration for display.
  static String formatDuration(Duration duration) {
    if (duration.inDays > 0) {
      return '${duration.inDays} day${duration.inDays == 1 ? '' : 's'}';
    } else if (duration.inHours > 0) {
      return '${duration.inHours} hour${duration.inHours == 1 ? '' : 's'}';
    } else if (duration.inMinutes > 0) {
      return '${duration.inMinutes} minute${duration.inMinutes == 1 ? '' : 's'}';
    } else {
      return 'now';
    }
  }
}
