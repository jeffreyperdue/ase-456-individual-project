import 'package:flutter_test/flutter_test.dart';
import 'package:petfolio/features/care_plans/services/clock.dart';
import '../../helpers/test_helpers.dart';

void main() {
  group('SystemClock', () {
    final clock = SystemClock();

    test('nowUtc and nowLocal return times close to DateTime.now', () {
      final before = DateTime.now();
      final nowLocal = clock.nowLocal();
      final nowUtc = clock.nowUtc();
      final after = DateTime.now();

      expect(nowLocal.isAfter(before) || nowLocal.isAtSameMomentAs(before), isTrue);
      expect(nowLocal.isBefore(after) || nowLocal.isAtSameMomentAs(after), isTrue);
      expect(nowUtc.timeZoneOffset, equals(Duration.zero));
    });

    test('todayAtTime returns today with given HH:mm', () {
      final result = clock.todayAtTime('13:45');
      final now = DateTime.now();

      expect(result.year, now.year);
      expect(result.month, now.month);
      expect(result.day, now.day);
      expect(result.hour, 13);
      expect(result.minute, 45);
    });

    test('toUtc and toLocal round trip correctly', () {
      final local = DateTime.now();
      final utc = clock.toUtc(local);
      final backToLocal = clock.toLocal(utc);

      expect(utc.isUtc, isTrue);
      // Allow for potential minor differences in some platforms
      expect(backToLocal.difference(local).inSeconds.abs(), lessThanOrEqualTo(1));
    });
  });

  group('FixedClock', () {
    test('always returns fixed time', () {
      final fixed = DateTime(2024, 1, 15, 12, 0);
      final clock = FixedClock(fixed);

      expect(clock.nowLocal(), fixed);
      expect(clock.nowUtc(), fixed.toUtc());
    });

    test('todayAtTime uses fixed date with provided time', () {
      final fixed = DateTime(2024, 1, 15, 12, 0);
      final clock = FixedClock(fixed);

      final result = clock.todayAtTime('08:30');

      expect(result.year, fixed.year);
      expect(result.month, fixed.month);
      expect(result.day, fixed.day);
      expect(result.hour, 8);
      expect(result.minute, 30);
    });

    test('toUtc and toLocal delegate to DateTime conversions', () {
      final fixed = DateTime(2024, 1, 15, 12, 0);
      final clock = FixedClock(fixed);

      final utc = clock.toUtc(fixed);
      final local = clock.toLocal(utc);

      expect(utc.isUtc, isTrue);
      expect(local.isUtc, isFalse);
    });

    test('MockClock from test_helpers behaves like Clock', () {
      final mockClock = MockClock();

      final original = mockClock.nowLocal();
      mockClock.advanceHours(2);
      final advanced = mockClock.nowLocal();

      expect(advanced.difference(original), equals(const Duration(hours: 2)));
    });
  });
}


