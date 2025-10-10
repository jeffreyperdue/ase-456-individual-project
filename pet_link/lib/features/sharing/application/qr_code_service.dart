import 'dart:typed_data';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:crypto/crypto.dart';

import '../domain/access_token.dart';

/// Service for generating and managing QR codes for pet sharing.
class QRCodeService {
  /// Generate a QR code widget for an access token.
  ///
  /// [token] - The access token to encode
  /// [size] - Size of the QR code (default: 200)
  /// [errorCorrectionLevel] - Error correction level for the QR code
  Widget generateQRCode({
    required AccessToken token,
    double size = 200.0,
    int errorCorrectionLevel = QrErrorCorrectLevel.M,
  }) {
    final data = _generateShareableURL(token);

    return QrImageView(
      data: data,
      version: QrVersions.auto,
      size: size,
      errorCorrectionLevel: errorCorrectionLevel,
      backgroundColor: Colors.white,
      foregroundColor: Colors.black,
    );
  }

  /// Generate QR code data as bytes for saving as image.
  Future<Uint8List?> generateQRCodeBytes({
    required AccessToken token,
    double size = 200.0,
    int errorCorrectionLevel = QrErrorCorrectLevel.M,
  }) async {
    try {
      final data = _generateShareableURL(token);
      final qrValidationResult = QrValidator.validate(
        data: data,
        version: QrVersions.auto,
        errorCorrectionLevel: errorCorrectionLevel,
      );

      if (qrValidationResult.status == QrValidationStatus.valid) {
        final qrCode = qrValidationResult.qrCode!;
        final painter = QrPainter.withQr(
          qr: qrCode,
          color: Colors.black,
          emptyColor: Colors.white,
          gapless: false,
        );

        final picData = await painter.toImageData(size);
        return picData?.buffer.asUint8List();
      }
    } catch (e) {
      // Handle QR code generation errors
      print('Error generating QR code bytes: $e');
    }
    return null;
  }

  /// Share the QR code as an image.
  Future<void> shareQRCode({
    required AccessToken token,
    double size = 200.0,
    String? subject,
    String? text,
  }) async {
    try {
      final qrBytes = await generateQRCodeBytes(token: token, size: size);
      if (qrBytes == null) {
        throw QRCodeException('Failed to generate QR code');
      }

      // For now, we'll share the URL directly since file sharing is complex
      // In a real app, you'd save the bytes to a file and share it
      await shareURL(
        token: token,
        subject: subject ?? 'Pet Profile Access',
        text:
            text ?? 'Access ${token.role.displayName} information for this pet',
      );
    } catch (e) {
      throw QRCodeException('Failed to share QR code: $e');
    }
  }

  /// Share the access URL directly.
  Future<void> shareURL({
    required AccessToken token,
    String? subject,
    String? text,
  }) async {
    try {
      final url = _generateShareableURL(token);
      final shareText =
          text ?? 'Access ${token.role.displayName} information for this pet';

      await Share.share(
        '$shareText\n\n$url',
        subject: subject ?? 'Pet Profile Access',
      );
    } catch (e) {
      throw QRCodeException('Failed to share URL: $e');
    }
  }

  /// Open the sharing URL in the default browser.
  Future<void> openURL(AccessToken token) async {
    try {
      final url = _generateShareableURL(token);
      final uri = Uri.parse(url);

      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        throw QRCodeException('Could not launch URL: $url');
      }
    } catch (e) {
      throw QRCodeException('Failed to open URL: $e');
    }
  }

  /// Generate a shareable URL for the access token.
  ///
  /// This creates a URL that can be used to access the pet profile
  /// using the access token. The URL format will be:
  /// https://yourapp.com/shared-pet?token=TOKEN_ID
  String _generateShareableURL(AccessToken token) {
    // For now, we'll use a placeholder URL structure
    // In a real app, this would be your actual domain
    const baseUrl = 'https://petfolio.app/shared-pet';
    return '$baseUrl?token=${token.id}';
  }

  /// Validate if a URL contains a valid token format.
  bool isValidTokenURL(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.host.contains('petfolio.app') &&
          uri.pathSegments.contains('shared-pet') &&
          uri.queryParameters.containsKey('token');
    } catch (e) {
      return false;
    }
  }

  /// Extract token ID from a shareable URL.
  String? extractTokenFromURL(String url) {
    try {
      final uri = Uri.parse(url);
      if (isValidTokenURL(url)) {
        return uri.queryParameters['token'];
      }
    } catch (e) {
      // Invalid URL format
    }
    return null;
  }

  /// Generate a secure token ID using crypto.
  String generateSecureTokenId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    final random = DateTime.now().microsecondsSinceEpoch.toString();
    final data = '$timestamp$random';

    final bytes = utf8.encode(data);
    final digest = sha256.convert(bytes);

    return 'token_${digest.toString().substring(0, 16)}';
  }
}

/// Exception for QR code operations.
class QRCodeException implements Exception {
  final String message;
  QRCodeException(this.message);

  @override
  String toString() => 'QRCodeException: $message';
}
