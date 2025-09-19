import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_link/features/pets/domain/pet.dart';
import 'package:pet_link/features/pets/presentation/state/pet_list_provider.dart';
import 'package:pet_link/features/auth/presentation/state/auth_provider.dart';

class EditPetPage extends ConsumerStatefulWidget {
  const EditPetPage({super.key});

  @override
  ConsumerState<EditPetPage> createState() => _EditPetPageState();
}

class _EditPetPageState extends ConsumerState<EditPetPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  String? _species; // simple dropdown for MVP

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    // 1) Validate
    if (!(_formKey.currentState?.validate() ?? false)) return;

    // 2) Get current user
    final currentUser = ref.read(currentUserDataProvider);
    if (currentUser == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('You must be signed in to add pets'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    // 3) Build Pet
    final id = DateTime.now().microsecondsSinceEpoch.toString();
    final pet = Pet(
      id: id,
      ownerId: currentUser.id,
      name: _nameCtrl.text.trim(),
      species: _species ?? 'Unknown',
    );

    // 4) Add via Riverpod provider
    try {
      await ref.read(petsProvider.notifier).add(pet);

      // 5) Give feedback and go back
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Pet added')));
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Pet')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Pet name
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(labelText: 'Name'),
                textInputAction: TextInputAction.next,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),

              // Species dropdown (keep it simple)
              DropdownButtonFormField<String>(
                value: _species,
                decoration: const InputDecoration(labelText: 'Species'),
                items: const [
                  DropdownMenuItem(value: 'Dog', child: Text('Dog')),
                  DropdownMenuItem(value: 'Cat', child: Text('Cat')),
                  DropdownMenuItem(value: 'Bird', child: Text('Bird')),
                  DropdownMenuItem(value: 'Other', child: Text('Other')),
                ],
                onChanged: (val) => setState(() => _species = val),
              ),

              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  icon: const Icon(Icons.save),
                  onPressed: _save,
                  label: const Text('Save'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
