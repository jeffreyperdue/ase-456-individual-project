import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// Service for handling URLs and deep links for sharing features.
class URLHandler {
  /// Handle a URL that might contain a pet profile access token.
  static Future<void> handleURL(BuildContext context, String url) async {
    try {
      // Check if it's a pet profile URL
      if (url.contains('/public-profile/')) {
        final tokenId = _extractTokenId(url);
        if (tokenId != null) {
          _navigateToPublicProfile(context, tokenId);
          return;
        }
      }

      // If it's not a pet profile URL, try to launch it externally
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        _showError(context, 'Could not open URL: $url');
      }
    } catch (e) {
      _showError(context, 'Error handling URL: $e');
    }
  }

  /// Extract token ID from a pet profile URL.
  static String? _extractTokenId(String url) {
    try {
      final uri = Uri.parse(url);
      final pathSegments = uri.pathSegments;

      // Look for /public-profile/{tokenId} pattern
      final profileIndex = pathSegments.indexOf('public-profile');
      if (profileIndex != -1 && profileIndex + 1 < pathSegments.length) {
        return pathSegments[profileIndex + 1];
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  /// Navigate to public profile page.
  static void _navigateToPublicProfile(BuildContext context, String tokenId) {
    Navigator.pushNamed(
      context,
      '/public-profile',
      arguments: {'tokenId': tokenId},
    );
  }

  /// Show error message.
  static void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
      ),
    );
  }

  /// Generate a shareable URL for a pet profile.
  static String generatePetProfileURL(String tokenId) {
    // In a real app, this would be your app's domain
    return 'https://petfolio.app/public-profile/$tokenId';
  }

  /// Test URL handler with a sample token.
  static void testURLHandler(BuildContext context) {
    const testTokenId = 'test-token-123';
    final testURL = generatePetProfileURL(testTokenId);

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Test URL Handler'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Test URL:'),
                const SizedBox(height: 8),
                SelectableText(testURL),
                const SizedBox(height: 16),
                const Text('This will simulate opening a QR code URL.'),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  handleURL(context, testURL);
                },
                child: const Text('Test'),
              ),
            ],
          ),
    );
  }
}
