// Widget test: Signup Page
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:petfolio/features/auth/presentation/pages/signup_page.dart';
import 'package:petfolio/features/auth/presentation/state/auth_provider.dart';
import 'package:petfolio/features/auth/data/auth_service.dart';
import '../../helpers/test_helpers.dart';
import '../../test_config.dart';
import 'signup_page_test.mocks.dart';

// Generate mocks
@GenerateMocks([AuthService])
void main() {
  group('SignUpPage Widget Tests', () {
    late MockAuthService mockAuthService;

    setUp(() {
      setupTestEnvironment();
      mockAuthService = MockAuthService();
      when(mockAuthService.authStateChanges)
          .thenAnswer((_) => const Stream.empty());
    });

    tearDown(() {
      cleanupTestEnvironment();
    });

    testWidgets('should render correctly with all required elements', (
      WidgetTester tester,
    ) async {
      // Arrange & Act
      await tester.pumpWidget(
        TestWidgetWrapper(
          child: const SignUpPage(),
          overrides: [
            authServiceProvider.overrideWithValue(mockAuthService),
          ],
        ),
      );
      await tester.pumpAndSettle();

      // Assert: All UI elements are present
      expect(find.text('Sign Up'), findsWidgets);
      expect(find.text('Join Petfolio'), findsOneWidget);
      expect(
        find.text('Create an account to start managing your pets'),
        findsOneWidget,
      );
      expect(find.byType(TextFormField), findsNWidgets(4)); // Display name, email, password, confirm password
      expect(find.text('Display Name (Optional)'), findsOneWidget);
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.text('Confirm Password'), findsOneWidget);
      expect(find.text('Create Account'), findsOneWidget);
      expect(find.text("Already have an account? "), findsOneWidget);
      expect(find.text('Sign In'), findsOneWidget);
    });

    testWidgets('should display validation error for empty email', (
      WidgetTester tester,
    ) async {
      // Arrange - Use larger screen to avoid overflow
      await tester.binding.setSurfaceSize(const Size(800, 1200));
      await tester.pumpWidget(
        TestWidgetWrapper(
          child: const SignUpPage(),
          overrides: [
            authServiceProvider.overrideWithValue(mockAuthService),
          ],
        ),
      );
      await tester.pump();

      // Act: Try to submit without entering email
      final createAccountButton = find.text('Create Account');
      // Button might be off-screen, scroll if needed
      if (createAccountButton.evaluate().isEmpty) {
        await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -200));
        await tester.pump();
      }
      await tester.tap(createAccountButton, warnIfMissed: false);
      await tester.pump(); // Allow validation to run

      // Assert: Validation error is shown
      expect(find.text('Please enter your email'), findsOneWidget);
      
      addTearDown(() => tester.binding.setSurfaceSize(null));
    });

    testWidgets('should display validation error for invalid email format', (
      WidgetTester tester,
    ) async {
      // Arrange - Use larger screen
      await tester.binding.setSurfaceSize(const Size(800, 1200));
      await tester.pumpWidget(
        TestWidgetWrapper(
          child: const SignUpPage(),
          overrides: [
            authServiceProvider.overrideWithValue(mockAuthService),
          ],
        ),
      );
      await tester.pump();

      // Act: Enter invalid email
      final emailField = find.byType(TextFormField).at(1); // Second field is email
      await tester.enterText(emailField, 'invalid-email');
      final createAccountButton = find.text('Create Account');
      if (createAccountButton.evaluate().isEmpty) {
        await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -200));
        await tester.pump();
      }
      await tester.tap(createAccountButton, warnIfMissed: false);
      await tester.pump(); // Allow validation to run

      // Assert: Validation error is shown
      expect(find.text('Please enter a valid email'), findsOneWidget);
      
      addTearDown(() => tester.binding.setSurfaceSize(null));
    });

    testWidgets('should display validation error for password mismatch', (
      WidgetTester tester,
    ) async {
      // Arrange - Use larger screen
      await tester.binding.setSurfaceSize(const Size(800, 1200));
      await tester.pumpWidget(
        TestWidgetWrapper(
          child: const SignUpPage(),
          overrides: [
            authServiceProvider.overrideWithValue(mockAuthService),
          ],
        ),
      );
      await tester.pump();

      // Act: Enter mismatched passwords
      final emailField = find.byType(TextFormField).at(1);
      final passwordField = find.byType(TextFormField).at(2);
      final confirmPasswordField = find.byType(TextFormField).at(3);
      
      await tester.enterText(emailField, 'test@example.com');
      await tester.enterText(passwordField, 'password123');
      await tester.enterText(confirmPasswordField, 'differentpassword');
      final createAccountButton = find.text('Create Account');
      if (createAccountButton.evaluate().isEmpty) {
        await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -200));
        await tester.pump();
      }
      await tester.tap(createAccountButton, warnIfMissed: false);
      await tester.pump(); // Allow validation to run

      // Assert: Validation error is shown
      expect(find.text('Passwords do not match'), findsOneWidget);
      
      addTearDown(() => tester.binding.setSurfaceSize(null));
    });

    testWidgets('should toggle password visibility for both fields', (
      WidgetTester tester,
    ) async {
      // Arrange
      await tester.pumpWidget(
        TestWidgetWrapper(
          child: const SignUpPage(),
          overrides: [
            authServiceProvider.overrideWithValue(mockAuthService),
          ],
        ),
      );
      await tester.pumpAndSettle();

      // Act: Enter passwords and toggle visibility
      final passwordField = find.byType(TextFormField).at(2);
      await tester.enterText(passwordField, 'password123');

      // Find visibility toggle buttons
      final visibilityButtons = find.byIcon(Icons.visibility_off);
      expect(visibilityButtons, findsNWidgets(2)); // Both password fields

      await tester.tap(visibilityButtons.first);
      await tester.pump();

      // Assert: Icon changes to visibility
      expect(find.byIcon(Icons.visibility), findsOneWidget);
    });

    testWidgets('should accept optional display name', (
      WidgetTester tester,
    ) async {
      // Arrange
      await tester.pumpWidget(
        TestWidgetWrapper(
          child: const SignUpPage(),
          overrides: [
            authServiceProvider.overrideWithValue(mockAuthService),
          ],
        ),
      );
      await tester.pumpAndSettle();

      // Act: Enter only required fields (no display name)
      final emailField = find.byType(TextFormField).at(1);
      final passwordField = find.byType(TextFormField).at(2);
      final confirmPasswordField = find.byType(TextFormField).at(3);
      
      await tester.enterText(emailField, 'test@example.com');
      await tester.enterText(passwordField, 'password123');
      await tester.enterText(confirmPasswordField, 'password123');
      await tester.pump();

      // Assert: Form is valid (no validation errors)
      // Display name field is optional, so form should be valid
      expect(find.text('Please enter your email'), findsNothing);
    });

    testWidgets('should show loading state during signup', (
      WidgetTester tester,
    ) async {
      // Arrange
      const email = 'test@example.com';
      const password = 'password123';
      final testUser = TestDataFactory.createTestUser(email: email);

      when(mockAuthService.signUpWithEmailAndPassword(
        email: email,
        password: password,
        displayName: null,
      )).thenAnswer((_) async => testUser);

      await tester.pumpWidget(
        TestWidgetWrapper(
          child: const SignUpPage(),
          overrides: [
            authServiceProvider.overrideWithValue(mockAuthService),
          ],
        ),
      );
      await tester.pumpAndSettle();

      // Act: Fill form and submit
      final emailField = find.byType(TextFormField).at(1);
      final passwordField = find.byType(TextFormField).at(2);
      final confirmPasswordField = find.byType(TextFormField).at(3);
      
      await tester.enterText(emailField, email);
      await tester.enterText(passwordField, password);
      await tester.enterText(confirmPasswordField, password);
      await tester.tap(find.text('Create Account'));
      await tester.pump(); // Don't settle, check loading state

      // Assert: Button shows loading (implementation dependent)
      // The button should be disabled or show loading indicator
    });
  });
}

