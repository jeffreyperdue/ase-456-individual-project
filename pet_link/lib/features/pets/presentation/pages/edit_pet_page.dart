import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pet_link/features/pets/domain/pet.dart';
import 'package:pet_link/features/pets/presentation/state/pet_list_provider.dart';

class EditPetPage extends StatefulWidget {
  const EditPetPage({super.key});

  @override
  State<EditPetPage> createState() => _EditPetPageState();
}

class _EditPetPageState extends State<EditPetPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  String? _species; // simple dropdown for MVP

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  void _save() {
    // 1) Validate
    if (!(_formKey.currentState?.validate() ?? false)) return;

    // 2) Build Pet
    final id = DateTime.now().microsecondsSinceEpoch.toString();
    final pet = Pet(
      id: id,
      name: _nameCtrl.text.trim(),
      species: _species ?? 'Unknown',
    );

    // 3) Add via provider
    context.read<PetListProvider>().add(pet);

    // 4) Give feedback and go back
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Pet added')));
    Navigator.pop(context);
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
