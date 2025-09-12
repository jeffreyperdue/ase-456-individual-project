/// Domain model for a single pet.
/// Keep this tiny for MVP; we can add more fields later.
class Pet {
  final String id; // Unique identifier (e.g., timestamp string, UUID)
  String name; // Display name
  String species; // e.g., "Dog", "Cat"
  DateTime? birthday; // Optional

  Pet({
    required this.id,
    required this.name,
    required this.species,
    this.birthday,
  });

  // (Nice to have) readable debugging
  @override
  String toString() =>
      'Pet(id: $id, name: $name, species: $species, birthday: $birthday)';
}
