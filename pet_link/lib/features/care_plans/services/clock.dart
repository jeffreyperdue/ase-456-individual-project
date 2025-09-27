/// Clock abstraction for testable time operations.
///
/// This allows us to:
/// - Test time-dependent logic with fixed times
/// - Handle timezone conversions consistently
/// - Mock time operations in unit tests
/// - Prepare for future timezone/daylight saving time handling
abstract class Clock {
  /// Get the current date and time in UTC.
  DateTime nowUtc();

  /// Get the current date and time in the local timezone.
  DateTime nowLocal();

  /// Parse a time string (HH:mm) and return a DateTime for today in local timezone.
  DateTime todayAtTime(String timeString);

  /// Convert a local DateTime to UTC.
  DateTime toUtc(DateTime localTime);

  /// Convert a UTC DateTime to local time.
  DateTime toLocal(DateTime utcTime);
}

/// Default implementation using the system clock.
class SystemClock implements Clock {
  @override
  DateTime nowUtc() => DateTime.now().toUtc();

  @override
  DateTime nowLocal() => DateTime.now();

  @override
  DateTime todayAtTime(String timeString) {
    final parts = timeString.split(':');
    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);

    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day, hour, minute);
  }

  @override
  DateTime toUtc(DateTime localTime) => localTime.toUtc();

  @override
  DateTime toLocal(DateTime utcTime) => utcTime.toLocal();
}

/// Fixed clock for testing - always returns the same time.
class FixedClock implements Clock {
  final DateTime _fixedTime;

  const FixedClock(this._fixedTime);

  @override
  DateTime nowUtc() => _fixedTime.toUtc();

  @override
  DateTime nowLocal() => _fixedTime;

  @override
  DateTime todayAtTime(String timeString) {
    final parts = timeString.split(':');
    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);

    return DateTime(
      _fixedTime.year,
      _fixedTime.month,
      _fixedTime.day,
      hour,
      minute,
    );
  }

  @override
  DateTime toUtc(DateTime localTime) => localTime.toUtc();

  @override
  DateTime toLocal(DateTime utcTime) => utcTime.toLocal();
}
