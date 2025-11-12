# PetLink Testing Suite

This directory contains a comprehensive testing suite for the PetLink application, covering unit tests, integration tests, and widget tests for all Sprint 1 features.

## Test Structure

```
test/
├── README.md                           # This file
├── test_config.dart                    # Test configuration and setup
├── widget_test.dart                    # Widget tests for UI components
├── helpers/
│   └── test_helpers.dart               # Test utilities and helpers
├── unit/
│   ├── domain/
│   │   ├── user_test.dart              # User domain model tests
│   │   ├── pet_test.dart               # Pet domain model tests
│   │   ├── care_plan_test.dart         # Care plan domain model tests
│   │   └── access_token_test.dart      # Access token domain model tests
│   └── services/
│       ├── time_utils_test.dart        # Time utilities service tests
│       ├── care_task_generator_test.dart # Care task generator tests
│       └── qr_code_service_test.dart   # QR code service tests
└── integration/
    ├── auth_workflow_test.dart         # Authentication workflow tests
    ├── pet_management_workflow_test.dart # Pet management workflow tests
    └── care_plan_workflow_test.dart    # Care plan workflow tests
```

## Test Categories

### Unit Tests
Unit tests focus on individual components and classes in isolation:

- **Domain Models**: Test data validation, serialization, and business logic
- **Services**: Test utility functions, time calculations, and QR code generation
- **Use Cases**: Test business logic and application layer functionality

### Integration Tests
Integration tests verify that multiple components work together correctly:

- **Authentication Workflow**: End-to-end user authentication flows
- **Pet Management Workflow**: Complete pet CRUD operations
- **Care Plan Workflow**: Care plan creation, task generation, and management

### Widget Tests
Widget tests ensure UI components render and behave correctly:

- **App Initialization**: Verify app starts without errors
- **Navigation**: Test basic navigation flows
- **Provider Integration**: Ensure state management works with UI

## Running Tests

### Run All Tests
```bash
flutter test
```

### Run Specific Test Categories
```bash
# Unit tests only
flutter test test/unit/

# Integration tests only
flutter test test/integration/

# Widget tests only
flutter test test/widget_test.dart
```

### Run Individual Test Files
```bash
flutter test test/unit/domain/user_test.dart
flutter test test/integration/auth_workflow_test.dart
```

### Run Tests with Coverage
```bash
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
```

### Run Tests in Watch Mode
```bash
flutter test --watch
```

## Test Features Covered

### Sprint 1 Features Tested

1. **User Authentication**
   - User signup, login, and logout
   - Password reset functionality
   - User profile management
   - Error handling and validation

2. **Pet Management**
   - Pet creation, reading, updating, and deletion
   - Pet data validation
   - Photo upload handling
   - Owner-pet relationships

3. **Care Plans**
   - Care plan creation and validation
   - Feeding schedule management
   - Medication tracking
   - Task generation and scheduling

4. **Sharing System**
   - Access token creation and management
   - QR code generation and validation
   - Public profile access
   - Permission-based access control

5. **Local Notifications**
   - Notification scheduling
   - Time-based task reminders
   - Timezone handling

6. **Time Utilities**
   - Time parsing and validation
   - Timezone conversions
   - Duration calculations
   - Day-of-week handling

## Test Utilities

### TestDataFactory
Provides factory methods for creating test objects:
```dart
final user = TestDataFactory.createTestUser();
final pet = TestDataFactory.createTestPet();
final carePlan = TestDataFactory.createTestCarePlan();
```

### MockClock
Allows controlling time in tests:
```dart
final mockClock = MockClock();
mockClock.setTime(DateTime(2024, 1, 15, 12, 0));
mockClock.advance(Duration(hours: 2));
```

### TestWidgetWrapper
Wraps widgets with necessary providers for testing:
```dart
await tester.pumpWidget(
  TestWidgetWrapper(
    child: MyWidget(),
    overrides: [myProvider.overrideWithValue(testValue)],
  ),
);
```

## Mock Services

The test suite includes comprehensive mocks for:
- Firebase Authentication
- Firestore Database
- Firebase Storage
- Local Notifications
- Image Picker
- Share Plus
- URL Launcher

## Test Configuration

Tests are configured in `test_config.dart` which:
- Sets up platform channel mocks
- Configures test timeouts
- Handles test environment setup and cleanup

## Best Practices

1. **Test Isolation**: Each test is independent and doesn't rely on other tests
2. **Descriptive Names**: Test names clearly describe what is being tested
3. **Arrange-Act-Assert**: Tests follow the AAA pattern for clarity
4. **Mock External Dependencies**: External services are mocked for reliable testing
5. **Edge Cases**: Tests cover both happy paths and error scenarios
6. **Time Control**: Time-dependent tests use MockClock for deterministic behavior

## Adding New Tests

When adding new features:

1. **Create unit tests** for domain models and services
2. **Add integration tests** for workflow scenarios
3. **Include widget tests** for new UI components
4. **Update test utilities** if new test data factories are needed
5. **Mock new external dependencies** in `test_config.dart`

## Week 9 Lost & Found Tests

The following tests have been created for the Lost & Found feature:

1. **Unit Tests:**
   - `test/unit/domain/lost_report_test.dart` - Tests for LostReport domain model
   - `test/unit/presentation/lost_found_notifier_test.dart` - Tests for LostFoundNotifier

2. **Widget Tests:**
   - `test/widget/lost_pet_poster_widget_test.dart` - Tests for LostPetPosterWidget

3. **Integration Tests:**
   - `test/integration/lost_found_workflow_test.dart` - End-to-end workflow tests

**Note:** Repository tests for `LostReportRepository` are not included as they require complex Firestore mocking. The repository is tested indirectly through integration tests and through the notifier tests. For comprehensive repository testing, consider using Firebase emulator-based integration tests.

## Continuous Integration

The test suite is designed to run in CI environments:
- All tests are deterministic and don't rely on external services
- Platform channels are properly mocked
- Tests complete within reasonable timeouts
- Coverage reports are generated for monitoring

## Troubleshooting

### Common Issues

1. **Platform Channel Errors**: Ensure `test_config.dart` is imported and `setupTestEnvironment()` is called
2. **Provider Errors**: Use `TestWidgetWrapper` with proper provider overrides
3. **Time-dependent Tests**: Use `MockClock` for consistent time-based testing
4. **Async Operations**: Use proper `await` and `Future.delayed()` for async testing

### Debug Tips

- Use `flutter test --verbose` for detailed test output
- Add `print()` statements for debugging test flow
- Use `tester.pumpAndSettle()` to wait for animations to complete
- Check provider state with `container.read(provider)` in tests
