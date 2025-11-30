// Widget test: Welcome View
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:petfolio/features/onboarding/welcome_view.dart';
import 'package:petfolio/services/local_storage_service.dart';
import 'package:petfolio/services/local_storage_provider.dart';
import '../../helpers/test_helpers.dart';
import '../../test_config.dart';
import 'welcome_view_test.mocks.dart';

// Generate mocks
@GenerateMocks([LocalStorageService])
void main() {
  group('WelcomeView Widget Tests', () {
    late MockLocalStorageService mockLocalStorageService;

    setUp(() {
      setupTestEnvironment();
      mockLocalStorageService = MockLocalStorageService();
      when(mockLocalStorageService.hasSeenWelcome())
          .thenAnswer((_) async => false);
      when(mockLocalStorageService.setHasSeenWelcome())
          .thenAnswer((_) async => {});
    });

    tearDown(() {
      cleanupTestEnvironment();
    });

    testWidgets('should render welcome screen correctly', (
      WidgetTester tester,
    ) async {
      // Act
      await tester.pumpWidget(
        TestWidgetWrapper(
          child: const WelcomeView(),
          overrides: [
            localStorageServiceProvider.overrideWithValue(mockLocalStorageService),
          ],
        ),
      );
      await tester.pumpAndSettle();

      // Assert: Welcome content is displayed
      expect(find.text('Welcome to Petfolio'), findsOneWidget);
      expect(find.text('Your shared hub for pet care'), findsOneWidget);
      expect(find.text('Get Started'), findsOneWidget);
    });

    testWidgets('should display value proposition cards', (
      WidgetTester tester,
    ) async {
      // Act
      await tester.pumpWidget(
        TestWidgetWrapper(
          child: const WelcomeView(),
          overrides: [
            localStorageServiceProvider.overrideWithValue(mockLocalStorageService),
          ],
        ),
      );
      await tester.pumpAndSettle();

      // Assert: Value cards are displayed
      expect(find.text('Real-time Sync'), findsOneWidget);
      expect(find.text('Easy Handoffs'), findsOneWidget);
      expect(find.text('Lost & Found'), findsOneWidget);
    });
  });
}

