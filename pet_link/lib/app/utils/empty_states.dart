import 'package:flutter/material.dart';
import 'package:petfolio/app/utils/animation_utils.dart';

/// Enhanced empty state widget with animations and helpful messaging
class EnhancedEmptyState extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final String? actionLabel;
  final VoidCallback? onAction;
  final Widget? customIcon;

  const EnhancedEmptyState({
    super.key,
    required this.title,
    required this.description,
    this.icon = Icons.pets,
    this.actionLabel,
    this.onAction,
    this.customIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animated Icon
            AnimationUtils.scaleIn(
              child: customIcon ??
                  Icon(
                    icon,
                    size: 80,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),

            const SizedBox(height: 24),

            // Title
            AnimationUtils.fadeIn(
              duration: const Duration(milliseconds: 400),
              child: Text(
                title,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                textAlign: TextAlign.center,
              ),
            ),

            const SizedBox(height: 8),

            // Description
            AnimationUtils.fadeIn(
              duration: const Duration(milliseconds: 500),
              child: Text(
                description,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                textAlign: TextAlign.center,
              ),
            ),

            // Action Button
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 24),
              AnimationUtils.fadeIn(
                duration: const Duration(milliseconds: 600),
                child: FilledButton.icon(
                  onPressed: onAction,
                  icon: const Icon(Icons.add),
                  label: Text(actionLabel!),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Enhanced error state widget with user-friendly messages
class EnhancedErrorState extends StatelessWidget {
  final String error;
  final VoidCallback? onRetry;
  final String? customTitle;
  final String? customMessage;

  const EnhancedErrorState({
    super.key,
    required this.error,
    this.onRetry,
    this.customTitle,
    this.customMessage,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimationUtils.scaleIn(
              child: Icon(
                Icons.error_outline,
                size: 64,
                color: Theme.of(context).colorScheme.error,
              ),
            ),

            const SizedBox(height: 16),

            AnimationUtils.fadeIn(
              duration: const Duration(milliseconds: 300),
              child: Text(
                customTitle ?? 'Something went wrong',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),

            const SizedBox(height: 8),

            AnimationUtils.fadeIn(
              duration: const Duration(milliseconds: 400),
              child: Text(
                customMessage ?? _getUserFriendlyMessage(error),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                textAlign: TextAlign.center,
              ),
            ),

            if (onRetry != null) ...[
              const SizedBox(height: 24),
              AnimationUtils.fadeIn(
                duration: const Duration(milliseconds: 500),
                child: FilledButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Try Again'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _getUserFriendlyMessage(String error) {
    final errorLower = error.toLowerCase();
    if (errorLower.contains('network') || errorLower.contains('internet')) {
      return 'Please check your internet connection and try again.';
    } else if (errorLower.contains('permission')) {
      return 'We need permission to access this feature. Please check your settings.';
    } else if (errorLower.contains('not-found')) {
      return 'The requested information could not be found.';
    } else if (errorLower.contains('unauthorized') || errorLower.contains('auth')) {
      return 'Please sign in to continue.';
    }
    return 'An unexpected error occurred. Please try again.';
  }
}

/// Enhanced loading state with context
class EnhancedLoadingState extends StatelessWidget {
  final String? message;

  const EnhancedLoadingState({
    super.key,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(
              message!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ],
        ],
      ),
    );
  }
}



