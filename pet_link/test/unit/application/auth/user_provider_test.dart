import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'package:petfolio/features/auth/application/user_provider.dart';
import 'package:petfolio/features/auth/domain/user.dart' as app_user;
import 'package:petfolio/features/auth/presentation/state/auth_provider.dart';

import '../../../integration/auth_workflow_test.mocks.dart';

void main() {
  group('user_provider application layer', () {
    late ProviderContainer container;
    late MockAuthService mockAuthService;

    setUp(() {
      mockAuthService = MockAuthService();
      container = ProviderContainer(
        overrides: [
          authServiceProvider.overrideWithValue(mockAuthService),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('userByIdProvider returns user from AuthService', () async {
      // Arrange
      const userId = 'user1';
      final user = app_user.User(
        id: userId,
        email: 'user1@example.com',
        displayName: 'User One',
        createdAt: DateTime(2024, 1, 1),
      );

      when(mockAuthService.getUserById(userId)).thenAnswer((_) async => user);

      // Act
      final result = await container.read(userByIdProvider(userId).future);

      // Assert
      expect(result, equals(user));
      verify(mockAuthService.getUserById(userId)).called(1);
    });

    test('usersByIdsProvider returns map of users from AuthService', () async {
      // Arrange
      final userIds = ['user1', 'user2'];
      final users = {
        'user1': app_user.User(
          id: 'user1',
          email: 'user1@example.com',
          displayName: 'User One',
          createdAt: DateTime(2024, 1, 1),
        ),
        'user2': app_user.User(
          id: 'user2',
          email: 'user2@example.com',
          displayName: null,
          createdAt: DateTime(2024, 1, 2),
        ),
      };

      when(mockAuthService.getUsersByIds(userIds)).thenAnswer((_) async => users);

      // Act
      final result = await container.read(usersByIdsProvider(userIds).future);

      // Assert
      expect(result, equals(users));
      verify(mockAuthService.getUsersByIds(userIds)).called(1);
    });

    test('userDisplayNameProvider prefers displayName then email', () async {
      // Arrange
      const userWithNameId = 'user1';
      const userWithoutNameId = 'user2';

      final userWithName = app_user.User(
        id: userWithNameId,
        email: 'named@example.com',
        displayName: 'Named User',
        createdAt: DateTime(2024, 1, 1),
      );
      final userWithoutName = app_user.User(
        id: userWithoutNameId,
        email: 'noname@example.com',
        displayName: null,
        createdAt: DateTime(2024, 1, 1),
      );

      when(mockAuthService.getUserById(userWithNameId))
          .thenAnswer((_) async => userWithName);
      when(mockAuthService.getUserById(userWithoutNameId))
          .thenAnswer((_) async => userWithoutName);

      // Act
      final name1 =
          await container.read(userDisplayNameProvider(userWithNameId).future);
      final name2 =
          await container.read(userDisplayNameProvider(userWithoutNameId).future);

      // Assert
      expect(name1, 'Named User');
      expect(name2, 'noname@example.com');
    });

    test('userDisplayNamesProvider returns map of display names', () async {
      // Arrange
      final userIds = ['user1', 'user2'];
      final users = {
        'user1': app_user.User(
          id: 'user1',
          email: 'user1@example.com',
          displayName: 'User One',
          createdAt: DateTime(2024, 1, 1),
        ),
        'user2': app_user.User(
          id: 'user2',
          email: 'user2@example.com',
          displayName: null,
          createdAt: DateTime(2024, 1, 2),
        ),
      };

      when(mockAuthService.getUsersByIds(userIds)).thenAnswer((_) async => users);

      // Act
      final displayNames =
          await container.read(userDisplayNamesProvider(userIds).future);

      // Assert
      expect(displayNames['user1'], 'User One');
      expect(displayNames['user2'], 'user2@example.com');
    });
  });
}


