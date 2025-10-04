import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:petfolio/features/pets/domain/pet.dart';
import 'package:petfolio/features/pets/presentation/state/pet_list_provider.dart';
import 'package:petfolio/features/auth/presentation/state/auth_provider.dart';
import 'package:petfolio/features/care_plans/presentation/pages/care_plan_form_page.dart';
import 'package:petfolio/features/pets/presentation/pages/pet_profile_form_page.dart';

class EditPetPage extends ConsumerStatefulWidget {
  const EditPetPage({super.key, this.petToEdit});

  final Pet? petToEdit; // if provided, we're editing

  @override
  ConsumerState<EditPetPage> createState() => _EditPetPageState();
}

class _EditPetPageState extends ConsumerState<EditPetPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  String? _species; // simple dropdown for MVP
  XFile? _selectedPhoto; // holds selected image file before upload
  bool _isSaving = false;
  Uint8List? _selectedBytes; // used for Flutter Web preview

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    // Prefill when editing
    final pet = widget.petToEdit;
    if (pet != null) {
      _nameCtrl.text = pet.name;
      _species = pet.species;
    }
  }

  Future<void> _pickPhoto() async {
    // Beginner note: ImagePicker opens the device gallery/camera based on source
    final picker = ImagePicker();
    final result = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1600,
    );
    if (result != null) {
      if (kIsWeb) {
        final bytes = await result.readAsBytes();
        setState(() {
          _selectedPhoto = result;
          _selectedBytes = bytes;
        });
      } else {
        setState(() => _selectedPhoto = result);
      }
    }
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

    setState(() => _isSaving = true);

    // 3) Determine id (new vs edit)
    final existing = widget.petToEdit;
    final id = existing?.id ?? DateTime.now().microsecondsSinceEpoch.toString();
    String? photoUrl;

    // 3a) If a photo is selected, upload it first so we can store its URL
    try {
      if (_selectedPhoto != null) {
        final repo = ref.read(petsRepositoryProvider);
        photoUrl = await repo.uploadPetPhoto(
          ownerId: currentUser.id,
          petId: id,
          file: _selectedPhoto!,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Photo upload failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }

    final pet = Pet(
      id: id,
      ownerId: currentUser.id,
      name: _nameCtrl.text.trim(),
      species: _species ?? 'Unknown',
      photoUrl: photoUrl ?? existing?.photoUrl,
    );

    // 4) Add via Riverpod provider
    try {
      if (existing == null) {
        await ref.read(petsProvider.notifier).add(pet);
      } else {
        await ref.read(petsProvider.notifier).update(id, {
          'name': pet.name,
          'species': pet.species,
          if (photoUrl != null) 'photoUrl': photoUrl,
        });
      }

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
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _navigateToCarePlan(BuildContext context) {
    if (widget.petToEdit != null) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => CarePlanFormPage(pet: widget.petToEdit!),
        ),
      );
    }
  }

  void _navigateToProfile(BuildContext context) {
    if (widget.petToEdit != null) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => PetProfileFormPage(pet: widget.petToEdit!),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.petToEdit == null ? 'Add Pet' : 'Edit Pet'),
        actions: [
          if (widget.petToEdit != null) ...[
            IconButton(
              onPressed: () => _navigateToProfile(context),
              icon: const Icon(Icons.person_outline),
              tooltip: 'Pet Profile',
            ),
            IconButton(
              onPressed: () => _navigateToCarePlan(context),
              icon: const Icon(Icons.medical_services),
              tooltip: 'Care Plan',
            ),
          ],
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Photo preview + pick button
              GestureDetector(
                onTap: _pickPhoto,
                child: CircleAvatar(
                  radius: 44,
                  backgroundImage:
                      _selectedPhoto == null
                          ? null
                          : kIsWeb
                          ? (_selectedBytes != null
                              ? MemoryImage(_selectedBytes!)
                              : null)
                          : FileImage(File(_selectedPhoto!.path))
                              as ImageProvider<Object>,
                  child:
                      _selectedPhoto == null
                          ? const Icon(Icons.add_a_photo, size: 28)
                          : null,
                ),
              ),
              const SizedBox(height: 12),

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
                  onPressed: _isSaving ? null : _save,
                  label:
                      _isSaving ? const Text('Saving...') : const Text('Save'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
