import 'package:flutter/material.dart';
import 'package:pet_link/features/pets/domain/pet.dart';

/// Holds the in-memory list of pets and notifies the UI when it changes.
class PetListProvider extends ChangeNotifier {
  final List<Pet> _pets = [];

  List<Pet> get pets => List.unmodifiable(_pets);

  void add(Pet p) {
    _pets.add(p);
    notifyListeners(); // tell listeners (widgets) to rebuild
  }

  void remove(String id) {
    _pets.removeWhere((p) => p.id == id);
    notifyListeners();
  }

  /// Convenience for MVP: create a quick dummy Pet so you can see the UI update.
  void addDummy() {
    final id = DateTime.now().microsecondsSinceEpoch.toString();
    add(Pet(id: id, name: 'New Pet $id', species: 'Unknown'));
  }
}
