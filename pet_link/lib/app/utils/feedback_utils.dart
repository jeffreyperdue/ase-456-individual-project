import 'package:flutter/material.dart';
import 'package:petfolio/services/error_handler.dart';

/// Utility functions for user feedback (success, error, info messages)
class FeedbackUtils {
  /// Show success message
  static void showSuccess(BuildContext context, String message) {
    ErrorHandler.showSuccess(context, message);
  }

  /// Show error message
  static void showError(BuildContext context, Object error, {String? customMessage}) {
    ErrorHandler.handleError(context, error, customMessage: customMessage);
  }

  /// Show info message
  static void showInfo(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.secondary,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  /// Show error with retry action
  static void showErrorWithRetry(
    BuildContext context,
    Object error,
    VoidCallback onRetry, {
    String? customMessage,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(customMessage ?? ErrorHandler.mapErrorToMessage(error)),
        backgroundColor: Theme.of(context).colorScheme.error,
        action: SnackBarAction(
          label: 'Retry',
          textColor: Colors.white,
          onPressed: onRetry,
        ),
        duration: const Duration(seconds: 5),
      ),
    );
  }
}


