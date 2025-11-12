import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:petfolio/app/main_scaffold.dart';
import 'package:petfolio/features/auth/presentation/state/auth_provider.dart';
import 'package:petfolio/features/auth/data/auth_service.dart';
import 'package:petfolio/features/pets/presentation/state/pet_list_provider.dart';
import 'package:petfolio/features/pets/data/pets_repository.dart';
import 'package:petfolio/features/care_plans/application/providers.dart';
import 'package:petfolio/features/care_plans/data/care_plan_repository_impl.dart';
import 'package:petfolio/features/sharing/application/task_completion_provider.dart';
import 'package:petfolio/features/sharing/data/task_completion_repository_impl.dart';
import '../test_config.dart';
import 'main_scaffold_test.mocks.dart';

// Generate mocks
@GenerateMocks([
  AuthService,
  PetsRepository,
  CarePlanRepositoryImpl,
  TaskCompletionRepositoryImpl,
])
void main() {
  setUp(() {
    setupTestEnvironment();
  });

  tearDown(() {
    cleanupTestEnvironment();
  });

  testWidgets('MainScaffold shows three destinations and switches tabs', (tester) async {
    // Set up test surface with reasonable size to avoid overflow
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    // Create mock services
    final mockAuthService = MockAuthService();
    final mockPetsRepository = MockPetsRepository();
    final mockCarePlanRepository = MockCarePlanRepositoryImpl();
    final mockTaskCompletionRepository = MockTaskCompletionRepositoryImpl();

    // Stub authStateChanges to return an empty stream
    // This is needed because AuthNotifier subscribes to it during initialization
    when(mockAuthService.authStateChanges)
        .thenAnswer((_) => const Stream.empty());
    
    // Stub getCurrentAppUser to return null (no authenticated user)
    when(mockAuthService.getCurrentAppUser())
        .thenAnswer((_) async => null);

    // Stub petsRepository to return empty stream
    // This prevents HomePage from trying to access Firestore
    when(mockPetsRepository.watchPetsForOwner(any))
        .thenAnswer((_) => const Stream.empty());
    
    // Stub carePlanRepository to return empty stream (null care plan)
    // This prevents CarePlanDashboard from trying to access Firestore
    when(mockCarePlanRepository.watchCarePlanForPet(any))
        .thenAnswer((_) => Stream.value(null));
    
    // Stub taskCompletionRepository to return empty stream
    // This prevents care task providers from trying to access Firestore
    when(mockTaskCompletionRepository.watchTaskCompletionsForPet(any))
        .thenAnswer((_) => const Stream.empty());

    await tester.pumpWidget(
      ProviderScope(
        // Override all Firebase-dependent providers to avoid Firebase initialization
        overrides: [
          // Override authServiceProvider to return mock auth service
          authServiceProvider.overrideWithValue(mockAuthService),
          // Override petsRepositoryProvider to return mock repository
          petsRepositoryProvider.overrideWithValue(mockPetsRepository),
          // Override carePlanRepositoryProvider to return mock repository
          carePlanRepositoryProvider.overrideWithValue(mockCarePlanRepository),
          // Override taskCompletionRepositoryProvider to return mock repository
          taskCompletionRepositoryProvider.overrideWithValue(mockTaskCompletionRepository),
        ],
        child: MaterialApp(
          home: Builder(
            builder: (context) {
              // Wrap with MediaQuery to ensure proper layout
              return MediaQuery(
                data: MediaQuery.of(context).copyWith(
                  size: const Size(800, 1200),
                ),
                child: const MainScaffold(),
              );
            },
          ),
        ),
      ),
    );

    // Allow navigation provider and auth providers to initialize
    // Use pumpFrames to allow async initialization without settling
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    // Don't use pumpAndSettle as it waits for all animations to complete
    // which might cause issues with async providers

    // Three destinations exist in navigation bar
    expect(find.byType(NavigationBar), findsOneWidget);
    
    // Find all navigation destinations
    final navBar = tester.widget<NavigationBar>(find.byType(NavigationBar));
    expect(navBar.destinations.length, equals(3));

    // Verify destinations by checking NavigationDestination widgets
    // Note: Labels may not be visible in test environment, so we check the structure
    final destinations = navBar.destinations;
    expect(destinations.length, equals(3));
    
    // Verify icons exist in the NavigationBar
    // Note: Icons.person might appear in both NavigationBar and UserAvatarAction,
    // so we check only within the NavigationBar context
    final navBarIcons = find.descendant(
      of: find.byType(NavigationBar),
      matching: find.byIcon(Icons.pets),
    );
    expect(navBarIcons, findsOneWidget);
    
    final careIcons = find.descendant(
      of: find.byType(NavigationBar),
      matching: find.byIcon(Icons.favorite),
    );
    expect(careIcons, findsOneWidget);
    
    final profileIcons = find.descendant(
      of: find.byType(NavigationBar),
      matching: find.byIcon(Icons.person),
    );
    expect(profileIcons, findsOneWidget);

    // Verify initial selected index is 0 (Pets)
    expect(navBar.selectedIndex, equals(0));

    // Tap Care destination (index 1) in navigation bar
    // Find the NavigationBar and tap on the second destination area
    final careIcon = find.descendant(
      of: find.byType(NavigationBar),
      matching: find.byIcon(Icons.favorite),
    );
    expect(careIcon, findsOneWidget);
    
    await tester.tap(careIcon);
    // Use pump instead of pumpAndSettle to avoid waiting for all animations
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    // After tapping, verify the NavigationBar selected index is 1
    final updatedNavBar = tester.widget<NavigationBar>(find.byType(NavigationBar));
    expect(updatedNavBar.selectedIndex, equals(1));
    
    // Verify the AppBar title shows "Care"
    // The AppBar title should update based on the selected index
    expect(find.text('Care'), findsWidgets); // May appear in AppBar title and possibly navigation label
  });
}


