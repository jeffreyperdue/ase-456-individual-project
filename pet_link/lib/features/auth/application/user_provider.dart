import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/user.dart' as app_user;
import '../presentation/state/auth_provider.dart';

/// Provider for getting a user by ID.
final userByIdProvider = FutureProvider.family<app_user.User?, String>((ref, userId) async {
  final authService = ref.watch(authServiceProvider);
  return await authService.getUserById(userId);
});

/// Provider for getting multiple users by their IDs.
/// Returns a map of userId -> User.
final usersByIdsProvider = FutureProvider.family<Map<String, app_user.User>, List<String>>((ref, userIds) async {
  if (userIds.isEmpty) return {};
  final authService = ref.watch(authServiceProvider);
  return await authService.getUsersByIds(userIds);
});

/// Provider for getting a user's display name by ID.
/// Returns the display name, or email if display name is not available, or null if user not found.
final userDisplayNameProvider =
    FutureProvider.family<String?, String>((ref, userId) async {
  final user = await ref.watch(userByIdProvider(userId).future);
  if (user == null) return null;
  return user.displayName ?? user.email;
});

/// Provider for getting display names for multiple users.
/// Returns a map of userId -> displayName (or email if no display name).
final userDisplayNamesProvider =
    FutureProvider.family<Map<String, String>, List<String>>(
        (ref, userIds) async {
  if (userIds.isEmpty) return {};
  final users = await ref.watch(usersByIdsProvider(userIds).future);
  final Map<String, String> displayNames = {};
  for (final entry in users.entries) {
    displayNames[entry.key] = entry.value.displayName ?? entry.value.email;
  }
  return displayNames;
});

