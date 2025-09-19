import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pet_link/features/pets/domain/pet.dart';

/// Holds the in-memory list of pets and notifies the UI when it changes.
/// Now syncs with Firestore for persistence.
class PetListProvider extends ChangeNotifier {
  final List<Pet> _pets = [];
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late StreamSubscription<QuerySnapshot<Map<String, dynamic>>>
  _petsSubscription;

  List<Pet> get pets => List.unmodifiable(_pets);

  PetListProvider() {
    _loadPets();
  }

  void _loadPets() {
    // Listen to Firestore changes and update local list
    _petsSubscription = _firestore.collection('pets').snapshots().listen((
      snapshot,
    ) {
      _pets.clear();
      for (var doc in snapshot.docs) {
        final data = doc.data();
        _pets.add(
          Pet(
            id: doc.id,
            name: data['name'] ?? '',
            species: data['species'] ?? 'Unknown',
          ),
        );
      }
      notifyListeners();
    });
  }

  Future<void> add(Pet p) async {
    try {
      // Save to Firestore - this will trigger the listener above
      await _firestore.collection('pets').doc(p.id).set({
        'name': p.name,
        'species': p.species,
        'createdAt': FieldValue.serverTimestamp(),
      });
      print('✅ Pet saved to Firestore: ${p.name}');
    } catch (e) {
      print('❌ Error saving pet: $e');
      // Fallback: add to local list if Firestore fails
      _pets.add(p);
      notifyListeners();
    }
  }

  Future<void> remove(String id) async {
    try {
      await _firestore.collection('pets').doc(id).delete();
      print('✅ Pet deleted from Firestore: $id');
    } catch (e) {
      print('❌ Error deleting pet: $e');
      // Fallback: remove from local list
      _pets.removeWhere((p) => p.id == id);
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _petsSubscription.cancel();
    super.dispose();
  }

  /// Convenience for MVP: create a quick dummy Pet so you can see the UI update.
  void addDummy() {
    final id = DateTime.now().microsecondsSinceEpoch.toString();
    add(Pet(id: id, name: 'New Pet $id', species: 'Unknown'));
  }
}
