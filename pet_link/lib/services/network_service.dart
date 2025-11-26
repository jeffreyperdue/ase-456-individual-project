import 'dart:io';

/// Basic network connectivity service
class NetworkService {
  /// Check if device has network connectivity
  static Future<bool> hasConnection() async {
    try {
      final result = await InternetAddress.lookup('google.com')
          .timeout(const Duration(seconds: 5));
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  /// Get user-friendly network error message
  static String getNetworkErrorMessage() {
    return "No internet connection. Please check your network and try again.";
  }
}


