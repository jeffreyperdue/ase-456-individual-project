import 'package:flutter/material.dart';

/// Standardized loading widgets for consistent UI
class LoadingWidgets {
  /// Standard circular progress indicator
  static Widget circularProgress({Color? color}) {
    return Center(
      child: CircularProgressIndicator(
        color: color,
      ),
    );
  }

  /// Full-screen loading overlay
  static Widget fullScreenLoading({String? message}) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            if (message != null) ...[
              const SizedBox(height: 16),
              Text(
                message,
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Inline loading indicator (small)
  static Widget inlineLoading({double? size}) {
    return SizedBox(
      width: size ?? 20,
      height: size ?? 20,
      child: const CircularProgressIndicator(strokeWidth: 2),
    );
  }

  /// Button with loading state
  static Widget loadingButton({
    required String text,
    required VoidCallback? onPressed,
    required bool isLoading,
    Widget? child,
  }) {
    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      child: isLoading
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          : (child ?? Text(text)),
    );
  }
}


