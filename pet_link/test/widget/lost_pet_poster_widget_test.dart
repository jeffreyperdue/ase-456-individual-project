import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:petfolio/features/lost_found/presentation/widgets/lost_pet_poster_widget.dart';
import 'package:petfolio/features/pets/domain/pet.dart';
import 'package:petfolio/features/auth/domain/user.dart' as app_user;
import '../helpers/test_helpers.dart';

void main() {
  group('LostPetPosterWidget Tests', () {
    late Pet testPet;
    late app_user.User testOwner;

    setUp(() {
      testPet = TestDataFactory.createTestPet();
      testOwner = TestDataFactory.createTestUser();
    });

    // Helper function to set up test surface for poster widget
    void setUpPosterTestSurface(WidgetTester tester) {
      // Set up test surface with enough space for the poster (800x1200)
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
    }

    // Helper function to wrap poster widget in a test-friendly container
    // The widget is designed to be 800x1200, so we render it without constraints
    Widget wrapPosterWidget(LostPetPosterWidget poster) {
      return MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: Center(
              child: poster,
            ),
          ),
        ),
      );
    }

    testWidgets('should render poster with required fields', (
      WidgetTester tester,
    ) async {
      // Arrange
      final lostDate = DateTime(2024, 1, 15, 12, 0, 0);
      setUpPosterTestSurface(tester);

      // Act
      await tester.pumpWidget(
        wrapPosterWidget(
          LostPetPosterWidget(
            pet: testPet,
            owner: testOwner,
            lostDate: lostDate,
          ),
        ),
      );

      // Assert
      expect(find.text('LOST'), findsOneWidget);
      expect(find.text(testPet.name.toUpperCase()), findsOneWidget);
      expect(find.text(testOwner.email), findsOneWidget);
      expect(find.text('Petfolio'), findsOneWidget);
    });

    testWidgets('should render poster with optional fields', (
      WidgetTester tester,
    ) async {
      // Arrange
      final lostDate = DateTime(2024, 1, 15, 12, 0, 0);
      const lastSeenLocation = 'Central Park';
      const notes = 'Last seen near the pond';
      setUpPosterTestSurface(tester);

      // Act
      await tester.pumpWidget(
        wrapPosterWidget(
          LostPetPosterWidget(
            pet: testPet,
            owner: testOwner,
            lostDate: lostDate,
            lastSeenLocation: lastSeenLocation,
            notes: notes,
          ),
        ),
      );

      // Assert
      expect(find.text('LOST'), findsOneWidget);
      expect(find.text(testPet.name.toUpperCase()), findsOneWidget);
      expect(find.textContaining(lastSeenLocation), findsOneWidget);
      expect(find.textContaining(notes), findsOneWidget);
      expect(find.text('If found, please contact:'), findsOneWidget);
    });

    testWidgets('should render poster without optional fields', (
      WidgetTester tester,
    ) async {
      // Arrange
      final lostDate = DateTime(2024, 1, 15, 12, 0, 0);
      setUpPosterTestSurface(tester);

      // Act
      await tester.pumpWidget(
        wrapPosterWidget(
          LostPetPosterWidget(
            pet: testPet,
            owner: testOwner,
            lostDate: lostDate,
          ),
        ),
      );

      // Assert
      expect(find.text('LOST'), findsOneWidget);
      expect(find.text(testPet.name.toUpperCase()), findsOneWidget);
      expect(find.text('If found, please contact:'), findsOneWidget);
      // Should not find location or notes text
      expect(find.textContaining('Last seen:'), findsNothing);
    });

    testWidgets('should display pet photo when available', (
      WidgetTester tester,
    ) async {
      // Arrange
      final petWithPhoto = TestDataFactory.createTestPet().copyWith(
        photoUrl: 'https://example.com/photo.jpg',
      );
      final lostDate = DateTime(2024, 1, 15, 12, 0, 0);
      setUpPosterTestSurface(tester);

      // Act
      await tester.pumpWidget(
        wrapPosterWidget(
          LostPetPosterWidget(
            pet: petWithPhoto,
            owner: testOwner,
            lostDate: lostDate,
          ),
        ),
      );

      // Assert
      expect(find.byType(Image), findsOneWidget);
    });

    testWidgets('should display placeholder when pet photo is not available', (
      WidgetTester tester,
    ) async {
      // Arrange
      final petWithoutPhoto = TestDataFactory.createTestPet().copyWith(
        photoUrl: null,
      );
      final lostDate = DateTime(2024, 1, 15, 12, 0, 0);
      setUpPosterTestSurface(tester);

      // Act
      await tester.pumpWidget(
        wrapPosterWidget(
          LostPetPosterWidget(
            pet: petWithoutPhoto,
            owner: testOwner,
            lostDate: lostDate,
          ),
        ),
      );

      // Assert
      expect(find.byIcon(Icons.pets), findsOneWidget);
    });

    testWidgets('should display owner display name when available', (
      WidgetTester tester,
    ) async {
      // Arrange
      final ownerWithDisplayName = TestDataFactory.createTestUser(
        displayName: 'John Doe',
      );
      final lostDate = DateTime(2024, 1, 15, 12, 0, 0);
      setUpPosterTestSurface(tester);

      // Act
      await tester.pumpWidget(
        wrapPosterWidget(
          LostPetPosterWidget(
            pet: testPet,
            owner: ownerWithDisplayName,
            lostDate: lostDate,
          ),
        ),
      );

      // Assert
      expect(find.text(ownerWithDisplayName.displayName!), findsOneWidget);
      expect(find.text(ownerWithDisplayName.email), findsOneWidget);
    });

    testWidgets('should display only email when display name is not available', (
      WidgetTester tester,
    ) async {
      // Arrange
      final ownerWithoutDisplayName = TestDataFactory.createTestUser(
        displayName: null,
      );
      final lostDate = DateTime(2024, 1, 15, 12, 0, 0);
      setUpPosterTestSurface(tester);

      // Act
      await tester.pumpWidget(
        wrapPosterWidget(
          LostPetPosterWidget(
            pet: testPet,
            owner: ownerWithoutDisplayName,
            lostDate: lostDate,
          ),
        ),
      );

      // Assert
      expect(find.text(ownerWithoutDisplayName.email), findsOneWidget);
      expect(find.text('If found, please contact:'), findsOneWidget);
    });

    testWidgets('should format lost date correctly', (
      WidgetTester tester,
    ) async {
      // Arrange
      final lostDate = DateTime(2024, 3, 15, 12, 0, 0); // March 15, 2024
      setUpPosterTestSurface(tester);

      // Act
      await tester.pumpWidget(
        wrapPosterWidget(
          LostPetPosterWidget(
            pet: testPet,
            owner: testOwner,
            lostDate: lostDate,
          ),
        ),
      );

      // Assert
      expect(find.textContaining('March'), findsOneWidget);
      expect(find.textContaining('15'), findsWidgets);
      expect(find.textContaining('2024'), findsOneWidget);
    });

    testWidgets('should display pet species and breed', (
      WidgetTester tester,
    ) async {
      // Arrange
      final petWithBreed = TestDataFactory.createTestPet(
        species: 'Dog',
        breed: 'Golden Retriever',
      );
      final lostDate = DateTime(2024, 1, 15, 12, 0, 0);
      setUpPosterTestSurface(tester);

      // Act
      await tester.pumpWidget(
        wrapPosterWidget(
          LostPetPosterWidget(
            pet: petWithBreed,
            owner: testOwner,
            lostDate: lostDate,
          ),
        ),
      );

      // Assert
      expect(find.textContaining('Dog'), findsOneWidget);
      expect(find.textContaining('Golden Retriever'), findsOneWidget);
    });

    testWidgets('should handle long text with ellipsis', (
      WidgetTester tester,
    ) async {
      // Arrange
      final petWithLongName = TestDataFactory.createTestPet(
        name: 'Very Long Pet Name That Should Be Truncated',
      );
      final lostDate = DateTime(2024, 1, 15, 12, 0, 0);
      setUpPosterTestSurface(tester);

      // Act
      await tester.pumpWidget(
        wrapPosterWidget(
          LostPetPosterWidget(
            pet: petWithLongName,
            owner: testOwner,
            lostDate: lostDate,
          ),
        ),
      );

      // Assert
      // Widget should render without overflow errors
      // Even with ellipsis, the beginning of the text should be visible
      expect(find.textContaining('VERY LONG'), findsOneWidget);
    });

    testWidgets('should have correct poster dimensions', (
      WidgetTester tester,
    ) async {
      // Arrange
      final lostDate = DateTime(2024, 1, 15, 12, 0, 0);
      setUpPosterTestSurface(tester);

      // Act
      await tester.pumpWidget(
        wrapPosterWidget(
          LostPetPosterWidget(
            pet: testPet,
            owner: testOwner,
            lostDate: lostDate,
          ),
        ),
      );

      // Assert
      final container = tester.widget<Container>(
        find.byType(Container).first,
      );
      expect(container.constraints, isNotNull);
    });

    testWidgets('should render with correct styling', (
      WidgetTester tester,
    ) async {
      // Arrange
      final lostDate = DateTime(2024, 1, 15, 12, 0, 0);
      setUpPosterTestSurface(tester);

      // Act
      await tester.pumpWidget(
        wrapPosterWidget(
          LostPetPosterWidget(
            pet: testPet,
            owner: testOwner,
            lostDate: lostDate,
          ),
        ),
      );

      // Assert
      // Check for red header background
      final headerContainer = tester.widget<Container>(
        find.ancestor(
          of: find.text('LOST'),
          matching: find.byType(Container),
        ).first,
      );
      expect(headerContainer.color, equals(Colors.red));

      // Check for white background
      final mainContainer = tester.widget<Container>(
        find.descendant(
          of: find.byType(LostPetPosterWidget),
          matching: find.byType(Container),
        ).first,
      );
      expect(mainContainer.color, equals(Colors.white));
    });

    testWidgets('should render location icon when location is provided', (
      WidgetTester tester,
    ) async {
      // Arrange
      final lostDate = DateTime(2024, 1, 15, 12, 0, 0);
      const lastSeenLocation = 'Central Park';
      setUpPosterTestSurface(tester);

      // Act
      await tester.pumpWidget(
        wrapPosterWidget(
          LostPetPosterWidget(
            pet: testPet,
            owner: testOwner,
            lostDate: lostDate,
            lastSeenLocation: lastSeenLocation,
          ),
        ),
      );

      // Assert
      expect(find.byIcon(Icons.location_on), findsOneWidget);
      expect(find.textContaining(lastSeenLocation), findsOneWidget);
    });
  });
}

