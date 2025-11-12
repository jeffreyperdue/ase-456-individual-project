import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:firebase_storage/firebase_storage.dart';

/// Service for uploading poster images to Firebase Storage.
/// Note: Poster generation (widget to image) is handled in the UI layer
/// using RepaintBoundary and RenderRepaintBoundary.toImage(), which requires BuildContext.
class PosterGeneratorService {
  PosterGeneratorService({FirebaseStorage? storage})
      : _storage = storage ?? FirebaseStorage.instance;

  final FirebaseStorage _storage;

  /// Upload poster image bytes to Firebase Storage.
  /// Returns the download URL of the uploaded poster.
  Future<String> uploadPoster({
    required Uint8List imageBytes,
    required String ownerId,
    required String petId,
  }) async {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final fileName = 'poster_$timestamp.png';
    final storagePath = 'users/$ownerId/lost_reports/$petId/$fileName';

    debugPrint('Uploading poster to: $storagePath');
    debugPrint('Image size: ${imageBytes.length} bytes');
    debugPrint('Owner ID: $ownerId');
    debugPrint('Pet ID: $petId');

    final ref = _storage.ref().child(storagePath);

    try {
      if (kIsWeb) {
        debugPrint('Uploading via putData (Web)');
        await ref.putData(
          imageBytes,
          SettableMetadata(contentType: 'image/png'),
        );
      } else {
        debugPrint('Uploading via putFile (Mobile/Desktop)');
        // For mobile/desktop, write to a temporary file first
        final tempFile = File('${Directory.systemTemp.path}/$fileName');
        await tempFile.writeAsBytes(imageBytes);
        debugPrint('Temp file created: ${tempFile.path}');
        
        await ref.putFile(
          tempFile,
          SettableMetadata(contentType: 'image/png'),
        );
        debugPrint('File uploaded successfully');
        
        // Clean up temp file
        await tempFile.delete();
        debugPrint('Temp file deleted');
      }

      final downloadUrl = await ref.getDownloadURL();
      debugPrint('Download URL: $downloadUrl');
      return downloadUrl;
    } catch (e, stackTrace) {
      debugPrint('Upload error: $e');
      debugPrint('Stack trace: $stackTrace');
      
      // Provide more specific error messages
      if (e.toString().contains('unauthorized') || e.toString().contains('permission')) {
        throw Exception(
          'Storage permission denied. Please ensure Firebase Storage rules are deployed. '
          'Path: $storagePath'
        );
      } else if (e.toString().contains('network')) {
        throw Exception('Network error. Please check your internet connection.');
      } else {
        throw Exception('Error uploading poster to storage: $e');
      }
    }
  }
}

