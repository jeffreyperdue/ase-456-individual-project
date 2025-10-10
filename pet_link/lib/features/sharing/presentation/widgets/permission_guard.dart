import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../application/permission_provider.dart';
import '../../application/permission_service.dart';

/// Widget that conditionally renders child widgets based on user permissions.
class PermissionGuard extends ConsumerWidget {
  final String petId;
  final String userId;
  final AccessLevel requiredLevel;
  final Widget child;
  final Widget? fallback;
  final bool showError;

  const PermissionGuard({
    super.key,
    required this.petId,
    required this.userId,
    required this.requiredLevel,
    required this.child,
    this.fallback,
    this.showError = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accessRequest = PetAccessRequest(petId: petId, userId: userId);
    final accessLevelAsync = ref.watch(userAccessLevelProvider(accessRequest));

    return accessLevelAsync.when(
      data: (accessLevel) {
        if (_hasRequiredAccess(accessLevel, requiredLevel)) {
          return child;
        } else if (fallback != null) {
          return fallback!;
        } else if (showError) {
          return _buildErrorWidget(context, accessLevel);
        } else {
          return const SizedBox.shrink();
        }
      },
      loading: () => _buildLoadingWidget(context),
      error: (error, stack) => _buildErrorWidget(context, AccessLevel.none),
    );
  }

  bool _hasRequiredAccess(AccessLevel userLevel, AccessLevel requiredLevel) {
    switch (requiredLevel) {
      case AccessLevel.none:
        return true; // Always allow
      case AccessLevel.viewer:
        return userLevel.canRead;
      case AccessLevel.sitter:
        return userLevel.canCompleteTasks;
      case AccessLevel.coCaretaker:
        return userLevel.canModify;
      case AccessLevel.owner:
        return userLevel == AccessLevel.owner;
    }
  }

  Widget _buildLoadingWidget(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: const Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildErrorWidget(BuildContext context, AccessLevel userLevel) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.errorContainer.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).colorScheme.error.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.block, color: Theme.of(context).colorScheme.error),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Insufficient permissions. Required: ${requiredLevel.displayName}, Current: ${userLevel.displayName}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Widget that shows different content based on user access level.
class AccessLevelBuilder extends ConsumerWidget {
  final String petId;
  final String userId;
  final Widget Function(AccessLevel accessLevel) builder;

  const AccessLevelBuilder({
    super.key,
    required this.petId,
    required this.userId,
    required this.builder,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accessRequest = PetAccessRequest(petId: petId, userId: userId);
    final accessLevelAsync = ref.watch(userAccessLevelProvider(accessRequest));

    return accessLevelAsync.when(
      data: (accessLevel) => builder(accessLevel),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => builder(AccessLevel.none),
    );
  }
}

/// Widget that shows an access level indicator.
class AccessLevelIndicator extends StatelessWidget {
  final AccessLevel accessLevel;
  final bool showDescription;

  const AccessLevelIndicator({
    super.key,
    required this.accessLevel,
    this.showDescription = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _getAccessLevelColor(context).withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _getAccessLevelColor(context).withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(accessLevel.icon, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                accessLevel.displayName,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: _getAccessLevelColor(context),
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (showDescription)
                Text(
                  accessLevel.description,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: _getAccessLevelColor(context),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getAccessLevelColor(BuildContext context) {
    switch (accessLevel) {
      case AccessLevel.none:
        return Theme.of(context).colorScheme.error;
      case AccessLevel.viewer:
        return Theme.of(context).colorScheme.primary;
      case AccessLevel.sitter:
        return Theme.of(context).colorScheme.secondary;
      case AccessLevel.coCaretaker:
        return Theme.of(context).colorScheme.tertiary;
      case AccessLevel.owner:
        return Theme.of(context).colorScheme.primary;
    }
  }
}

/// Widget that shows permission requirements for an action.
class PermissionRequirements extends StatelessWidget {
  final AccessLevel requiredLevel;
  final String action;

  const PermissionRequirements({
    super.key,
    required this.requiredLevel,
    required this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            size: 16,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Requires ${requiredLevel.displayName} access to $action',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
