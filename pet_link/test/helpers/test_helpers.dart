import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockito/mockito.dart';
import 'package:fake_async/fake_async.dart';
import 'package:petfolio/features/care_plans/services/clock.dart';

import 'package:petfolio/features/auth/domain/user.dart';
import 'package:petfolio/features/pets/domain/pet.dart';
import 'package:petfolio/features/care_plans/domain/care_plan.dart';
import 'package:petfolio/features/care_plans/domain/feeding_schedule.dart';
import 'package:petfolio/features/care_plans/domain/medication.dart';
import 'package:petfolio/features/sharing/domain/access_token.dart';
import 'package:petfolio/features/lost_found/domain/lost_report.dart';

/// Test helpers and utilities for PetLink testing suite.

/// Mock clock for time-based testing
class MockClock implements Clock {
  DateTime _now = DateTime(2024, 1, 15, 12, 0, 0); // Monday noon

  @override
  DateTime nowUtc() => _now.toUtc();

  @override
  DateTime nowLocal() => _now;

  @override
  DateTime todayAtTime(String timeString) {
    final parts = timeString.split(':');
    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);

    return DateTime(_now.year, _now.month, _now.day, hour, minute);
  }

  @override
  DateTime toUtc(DateTime localTime) => localTime.toUtc();

  @override
  DateTime toLocal(DateTime utcTime) => utcTime.toLocal();

  void setTime(DateTime time) {
    _now = time;
  }

  void advance(Duration duration) {
    _now = _now.add(duration);
  }

  void advanceDays(int days) {
    _now = _now.add(Duration(days: days));
  }

  void advanceHours(int hours) {
    _now = _now.add(Duration(hours: hours));
  }
}

/// Test data factories for creating test objects
class TestDataFactory {
  static User createTestUser({String? id, String? email, String? displayName}) {
    return User(
      id: id ?? 'test_user_id',
      email: email ?? 'test@example.com',
      displayName: displayName ?? 'Test User',
      createdAt: DateTime(2024, 1, 1),
    );
  }

  static Pet createTestPet({
    String? id,
    String? ownerId,
    String? name,
    String? species,
    String? breed,
  }) {
    return Pet(
      id: id ?? 'test_pet_id',
      ownerId: ownerId ?? 'test_user_id',
      name: name ?? 'Test Pet',
      species: species ?? 'Dog',
      breed: breed ?? 'Golden Retriever',
      dateOfBirth: DateTime(2020, 1, 1),
      weightKg: 25.0,
      heightCm: 60.0,
      createdAt: DateTime(2024, 1, 1),
    );
  }

  static FeedingSchedule createTestFeedingSchedule({
    String? label,
    List<String>? times,
    List<int>? daysOfWeek,
    bool active = true,
  }) {
    return FeedingSchedule(
      id: 'test_feeding_id',
      label: label ?? 'Morning Feeding',
      times: times ?? ['07:00', '19:00'],
      daysOfWeek: daysOfWeek,
      active: active,
      notes: 'Test feeding notes',
    );
  }

  static Medication createTestMedication({
    String? name,
    String? dosage,
    List<String>? times,
    List<int>? daysOfWeek,
    bool active = true,
    bool withFood = true,
  }) {
    return Medication(
      id: 'test_medication_id',
      name: name ?? 'Test Medication',
      dosage: dosage ?? '1 tablet',
      times: times ?? ['08:00'],
      daysOfWeek: daysOfWeek,
      active: active,
      withFood: withFood,
      notes: 'Test medication notes',
    );
  }

  static CarePlan createTestCarePlan({
    String? id,
    String? petId,
    String? ownerId,
    String? dietText,
    List<FeedingSchedule>? feedingSchedules,
    List<Medication>? medications,
  }) {
    return CarePlan(
      id: id ?? 'test_care_plan_id',
      petId: petId ?? 'test_pet_id',
      ownerId: ownerId ?? 'test_user_id',
      dietText: dietText ?? 'High-quality dry food twice daily',
      feedingSchedules: feedingSchedules ?? [createTestFeedingSchedule()],
      medications: medications ?? [createTestMedication()],
      createdAt: TestConstants.testDate,
      timezone: 'America/New_York',
    );
  }

  static AccessToken createTestAccessToken({
    String? id,
    String? petId,
    String? grantedBy,
    AccessRole? role,
    DateTime? expiresAt,
  }) {
    return AccessToken(
      id: id ?? 'test_token_id',
      petId: petId ?? 'test_pet_id',
      grantedBy: grantedBy ?? 'test_user_id',
      role: role ?? AccessRole.viewer,
      expiresAt: expiresAt ?? DateTime(2024, 1, 22, 12, 0, 0),
      createdAt: DateTime(2024, 1, 15, 12, 0, 0),
      notes: 'Test access token',
    );
  }

  static LostReport createTestLostReport({
    String? id,
    String? petId,
    String? ownerId,
    DateTime? createdAt,
    String? lastSeenLocation,
    String? notes,
    String? posterUrl,
  }) {
    return LostReport(
      id: id ?? 'test_lost_report_id',
      petId: petId ?? 'test_pet_id',
      ownerId: ownerId ?? 'test_user_id',
      createdAt: createdAt ?? DateTime(2024, 1, 15, 12, 0, 0),
      lastSeenLocation: lastSeenLocation,
      notes: notes,
      posterUrl: posterUrl,
    );
  }
}

/// Widget test helper for testing with Riverpod
class TestWidgetWrapper extends StatelessWidget {
  final Widget child;
  final List<Override> overrides;

  const TestWidgetWrapper({
    super.key,
    required this.child,
    this.overrides = const [],
  });

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      overrides: overrides,
      child: MaterialApp(home: Scaffold(body: child)),
    );
  }
}

/// Helper for testing async operations with fake time
class AsyncTestHelper {
  static void runWithFakeTime(
    VoidCallback testFunction, {
    DateTime? startTime,
  }) {
    final clock = startTime ?? DateTime(2024, 1, 15, 12, 0, 0);

    FakeAsync().run((fakeAsync) {
      fakeAsync.elapse(Duration.zero); // Initialize
      testFunction();
    });
  }
}

/// Mock providers for testing
class MockProviders {
  static List<Override> createOverrides({required List<Override> overrides}) {
    return overrides;
  }
}

/// Test matchers for common assertions
class TestMatchers {
  /// Matcher for valid time format (HH:mm)
  static Matcher isValidTimeFormat() {
    return predicate<String>(
      (time) => RegExp(r'^([01]?[0-9]|2[0-3]):[0-5][0-9]$').hasMatch(time),
      'is a valid time format (HH:mm)',
    );
  }

  /// Matcher for valid email format
  static Matcher isValidEmail() {
    return predicate<String>(
      (email) => RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email),
      'is a valid email format',
    );
  }

  /// Matcher for non-empty string
  static Matcher isNonEmptyString() {
    return predicate<String>(
      (str) => str.trim().isNotEmpty,
      'is a non-empty string',
    );
  }

  /// Matcher for valid day of week (0-6)
  static Matcher isValidDayOfWeek() {
    return predicate<int>(
      (day) => day >= 0 && day <= 6,
      'is a valid day of week (0-6)',
    );
  }
}

/// Common test constants
class TestConstants {
  static const String testUserId = 'test_user_id';
  static const String testPetId = 'test_pet_id';
  static const String testCarePlanId = 'test_care_plan_id';
  static const String testAccessTokenId = 'test_token_id';
  static const String testLostReportId = 'test_lost_report_id';

  static const String testEmail = 'test@example.com';
  static const String testPassword = 'testpassword123';
  static const String testDisplayName = 'Test User';

  static const String testPetName = 'Test Pet';
  static const String testSpecies = 'Dog';
  static const String testBreed = 'Golden Retriever';

  static final DateTime testDate = DateTime(2024, 1, 15, 12, 0, 0);
  static final DateTime testExpirationDate = DateTime(2024, 1, 22, 12, 0, 0);

  static const List<String> testFeedingTimes = ['07:00', '19:00'];
  static const List<String> testMedicationTimes = ['08:00'];
  static const List<int> testDaysOfWeek = [1, 2, 3, 4, 5]; // Monday to Friday
}
