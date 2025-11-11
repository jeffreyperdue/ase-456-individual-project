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

    final ref = _storage.ref().child(storagePath);

    try {
      if (kIsWeb) {
        await ref.putData(
          imageBytes,
          SettableMetadata(contentType: 'image/png'),
        );
      } else {
        // For mobile/desktop, write to a temporary file first
        final tempFile = File('${Directory.systemTemp.path}/$fileName');
        await tempFile.writeAsBytes(imageBytes);
        await ref.putFile(
          tempFile,
          SettableMetadata(contentType: 'image/png'),
        );
        // Clean up temp file
        await tempFile.delete();
      }

      return await ref.getDownloadURL();
    } catch (e) {
      throw Exception('Error uploading poster to storage: $e');
    }
  }
}

