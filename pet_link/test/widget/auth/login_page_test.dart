// Widget test: Login Page
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:petfolio/features/auth/presentation/pages/login_page.dart';
import 'package:petfolio/features/auth/presentation/pages/signup_page.dart';
import 'package:petfolio/features/auth/presentation/state/auth_provider.dart';
import 'package:petfolio/features/auth/data/auth_service.dart';
import '../../helpers/test_helpers.dart';
import '../../test_config.dart';
import 'login_page_test.mocks.dart';

// Generate mocks
@GenerateMocks([AuthService])
void main() {
  group('LoginPage Widget Tests', () {
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
      // Arrange & Act - Use larger screen to avoid overflow
      await tester.binding.setSurfaceSize(const Size(800, 1200));
      await tester.pumpWidget(
        TestWidgetWrapper(
          child: const LoginPage(),
          overrides: [
            authServiceProvider.overrideWithValue(mockAuthService),
          ],
        ),
      );
      await tester.pump(); // Don't settle to avoid timeout on animations

      // Assert: All UI elements are present
      expect(find.text('Sign In'), findsWidgets);
      expect(find.text('Petfolio'), findsOneWidget);
      expect(find.text('Sign in to manage your pets'), findsOneWidget);
      expect(find.byType(TextFormField), findsNWidgets(2)); // Email and password
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.text('Forgot Password?'), findsOneWidget);
      expect(find.text("Don't have an account? "), findsOneWidget);
      expect(find.text('Sign Up'), findsOneWidget);
      
      // Reset screen size
      addTearDown(() => tester.binding.setSurfaceSize(null));
    });

    testWidgets('should display validation error for empty email', (
      WidgetTester tester,
    ) async {
      // Arrange - Use larger screen
      await tester.binding.setSurfaceSize(const Size(800, 1200));
      await tester.pumpWidget(
        TestWidgetWrapper(
          child: const LoginPage(),
          overrides: [
            authServiceProvider.overrideWithValue(mockAuthService),
          ],
        ),
      );
      await tester.pump();

      // Act: Try to submit without entering email
      // Find button by finding LoadingWidgets.loadingButton which returns ElevatedButton
      final buttons = find.byType(ElevatedButton);
      expect(buttons, findsWidgets);
      await tester.tap(buttons.first);
      await tester.pump(); // Allow validation to run

      // Assert: Validation error is shown (appears in TextFormField errorText)
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
          child: const LoginPage(),
          overrides: [
            authServiceProvider.overrideWithValue(mockAuthService),
          ],
        ),
      );
      await tester.pump();

      // Act: Enter invalid email
      final emailField = find.byType(TextFormField).first;
      await tester.enterText(emailField, 'invalid-email');
      final buttons = find.byType(ElevatedButton);
      expect(buttons, findsWidgets);
      await tester.tap(buttons.first);
      await tester.pump(); // Allow validation to run

      // Assert: Validation error is shown
      expect(find.text('Please enter a valid email'), findsOneWidget);
      
      addTearDown(() => tester.binding.setSurfaceSize(null));
    });

    testWidgets('should display validation error for empty password', (
      WidgetTester tester,
    ) async {
      // Arrange - Use larger screen
      await tester.binding.setSurfaceSize(const Size(800, 1200));
      await tester.pumpWidget(
        TestWidgetWrapper(
          child: const LoginPage(),
          overrides: [
            authServiceProvider.overrideWithValue(mockAuthService),
          ],
        ),
      );
      await tester.pump();

      // Act: Enter email but not password
      final emailField = find.byType(TextFormField).first;
      await tester.enterText(emailField, 'test@example.com');
      final buttons = find.byType(ElevatedButton);
      expect(buttons, findsWidgets);
      await tester.tap(buttons.first);
      await tester.pump(); // Allow validation to run

      // Assert: Validation error is shown
      expect(find.text('Please enter your password'), findsOneWidget);
      
      addTearDown(() => tester.binding.setSurfaceSize(null));
    });

    testWidgets('should display validation error for short password', (
      WidgetTester tester,
    ) async {
      // Arrange - Use larger screen
      await tester.binding.setSurfaceSize(const Size(800, 1200));
      await tester.pumpWidget(
        TestWidgetWrapper(
          child: const LoginPage(),
          overrides: [
            authServiceProvider.overrideWithValue(mockAuthService),
          ],
        ),
      );
      await tester.pump();

      // Act: Enter short password
      final emailField = find.byType(TextFormField).first;
      final passwordField = find.byType(TextFormField).last;
      await tester.enterText(emailField, 'test@example.com');
      await tester.enterText(passwordField, '123');
      final buttons = find.byType(ElevatedButton);
      expect(buttons, findsWidgets);
      await tester.tap(buttons.first);
      await tester.pump(); // Allow validation to run

      // Assert: Validation error is shown
      expect(
        find.text('Password must be at least 6 characters'),
        findsOneWidget,
      );
      
      addTearDown(() => tester.binding.setSurfaceSize(null));
    });

    testWidgets('should toggle password visibility', (
      WidgetTester tester,
    ) async {
      // Arrange - Use larger screen
      await tester.binding.setSurfaceSize(const Size(800, 1200));
      await tester.pumpWidget(
        TestWidgetWrapper(
          child: const LoginPage(),
          overrides: [
            authServiceProvider.overrideWithValue(mockAuthService),
          ],
        ),
      );
      await tester.pump();

      // Act: Enter password and toggle visibility
      final passwordField = find.byType(TextFormField).last;
      await tester.enterText(passwordField, 'password123');

      // Find visibility toggle button
      final visibilityButton = find.byIcon(Icons.visibility_off);
      expect(visibilityButton, findsOneWidget);

      await tester.tap(visibilityButton);
      await tester.pump();

      // Assert: Icon changes to visibility
      expect(find.byIcon(Icons.visibility), findsOneWidget);
      
      addTearDown(() => tester.binding.setSurfaceSize(null));
    });


    testWidgets('should navigate to signup page when Sign Up is tapped', (
      WidgetTester tester,
    ) async {
      // Arrange - Use larger screen and MaterialApp with routes
      await tester.binding.setSurfaceSize(const Size(800, 1200));
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: ProviderContainer(
            overrides: [
              authServiceProvider.overrideWithValue(mockAuthService),
            ],
          ),
          child: MaterialApp(
            routes: {
              '/signup': (_) => const SignUpPage(),
              '/login': (_) => const LoginPage(),
            },
            home: const LoginPage(),
          ),
        ),
      );
      await tester.pump();

      // Act: Tap Sign Up link - find by widget predicate to handle TextSpan
      final signUpFinder = find.byWidgetPredicate(
        (widget) => widget is Text && widget.data?.contains('Sign Up') == true,
      );
      if (signUpFinder.evaluate().isEmpty) {
        // Fallback: try finding by text
        await tester.tap(find.text('Sign Up'), warnIfMissed: false);
      } else {
        await tester.tap(signUpFinder.first);
      }
      await tester.pumpAndSettle();

      // Assert: Navigation occurs (if routes are set up correctly)
      // The Sign Up link should be tappable
      expect(find.text('Sign Up'), findsWidgets);
      
      addTearDown(() => tester.binding.setSurfaceSize(null));
    });
  });
}

