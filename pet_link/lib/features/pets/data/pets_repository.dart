import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:petfolio/features/pets/domain/pet.dart';

/// PetsRepository centralizes all Firestore and Storage operations
/// for Pets. Keeping data access in one place makes the UI simpler
/// and easier to test.
class PetsRepository {
  PetsRepository({FirebaseFirestore? firestore, FirebaseStorage? storage})
    : _firestore = firestore ?? FirebaseFirestore.instance,
      _storage = storage ?? FirebaseStorage.instance;

  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  /// Stream the authenticated user's pets. The UI can listen to this
  /// and rebuild automatically when the data changes in Firestore.
  Stream<List<Pet>> watchPetsForOwner(String ownerId) {
    return _firestore
        .collection('pets')
        .where('ownerId', isEqualTo: ownerId)
        .snapshots()
        .map(
          (snap) =>
              snap.docs.map((doc) {
                final data = doc.data();
                return Pet(
                  id: doc.id,
                  ownerId: data['ownerId'] ?? '',
                  name: data['name'] ?? '',
                  species: data['species'] ?? 'Unknown',
                  breed: data['breed'],
                  dateOfBirth: data['dateOfBirth']?.toDate(),
                  weightKg: (data['weightKg'] as num?)?.toDouble(),
                  heightCm: (data['heightCm'] as num?)?.toDouble(),
                  photoUrl: data['photoUrl'],
                  isLost: data['isLost'] ?? false,
                  createdAt: data['createdAt']?.toDate(),
                  updatedAt: data['updatedAt']?.toDate(),
                );
              }).toList(),
        );
  }

  /// Create or overwrite a Pet document. If [pet.id] already exists,
  /// the document will be replaced. Use [updatePet] to merge instead.
  Future<void> createPet(Pet pet) async {
    await _firestore.collection('pets').doc(pet.id).set({
      'ownerId': pet.ownerId,
      'name': pet.name,
      'species': pet.species,
      'breed': pet.breed,
      'dateOfBirth': pet.dateOfBirth,
      'weightKg': pet.weightKg,
      'heightCm': pet.heightCm,
      'photoUrl': pet.photoUrl,
      'isLost': pet.isLost,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Update specific fields on a Pet.
  Future<void> updatePet(String petId, Map<String, dynamic> updates) async {
    await _firestore.collection('pets').doc(petId).update({
      ...updates,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Delete a Pet by id.
  Future<void> deletePet(String petId) async {
    await _firestore.collection('pets').doc(petId).delete();
  }

  /// Get a Pet by id.
  /// Returns null if the pet doesn't exist or can't be accessed.
  Future<Pet?> getPetById(String petId) async {
    try {
      final doc = await _firestore.collection('pets').doc(petId).get();
      if (!doc.exists) return null;

      final data = doc.data()!;
      return Pet(
        id: doc.id,
        ownerId: data['ownerId'] ?? '',
        name: data['name'] ?? '',
        species: data['species'] ?? 'Unknown',
        breed: data['breed'],
        dateOfBirth: data['dateOfBirth']?.toDate(),
        weightKg: (data['weightKg'] as num?)?.toDouble(),
        heightCm: (data['heightCm'] as num?)?.toDouble(),
        photoUrl: data['photoUrl'],
        isLost: data['isLost'] ?? false,
        createdAt: data['createdAt']?.toDate(),
        updatedAt: data['updatedAt']?.toDate(),
      );
    } catch (e) {
      return null;
    }
  }

  /// Upload a pet photo to Firebase Storage and return a public download URL.
  ///
  /// Folder structure: users/{ownerId}/pets/{petId}/{filename}
  Future<String> uploadPetPhoto({
    required String ownerId,
    required String petId,
    required XFile file,
  }) async {
    final fileName = file.name;
    final ref = _storage
        .ref()
        .child('users')
        .child(ownerId)
        .child('pets')
        .child(petId)
        .child(fileName);

    // Debug helper: shows the exact storage path and owner we're writing to
    // Helpful when diagnosing Storage rules issues
    // ignore: avoid_print
    print('[Storage] Upload path: ' + ref.fullPath + ' ownerId=' + ownerId);

    // On web we must upload raw bytes; on mobile/desktop we can upload a File
    if (kIsWeb) {
      final bytes = await file.readAsBytes();
      await ref.putData(
        bytes,
        SettableMetadata(contentType: _inferContentType(fileName)),
      );
    } else {
      await ref.putFile(
        File(file.path),
        SettableMetadata(contentType: _inferContentType(fileName)),
      );
    }
    return await ref.getDownloadURL();
  }

  /// Simple helper to guess content type from file extension.
  String _inferContentType(String fileName) {
    final lower = fileName.toLowerCase();
    if (lower.endsWith('.png')) return 'image/png';
    if (lower.endsWith('.jpg') || lower.endsWith('.jpeg')) return 'image/jpeg';
    if (lower.endsWith('.gif')) return 'image/gif';
    return 'application/octet-stream';
  }
}
