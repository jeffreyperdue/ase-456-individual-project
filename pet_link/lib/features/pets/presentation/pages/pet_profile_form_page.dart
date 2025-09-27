import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/pet.dart';
import '../../domain/pet_profile.dart';
import '../../application/pet_profile_form_provider.dart';
import '../../application/pet_profile_providers.dart';
import '../../../auth/presentation/state/auth_provider.dart';

/// Page for creating and editing pet profiles.
class PetProfileFormPage extends ConsumerStatefulWidget {
  final Pet pet;
  final PetProfile? existingProfile;

  const PetProfileFormPage({
    super.key,
    required this.pet,
    this.existingProfile,
  });

  @override
  ConsumerState<PetProfileFormPage> createState() => _PetProfileFormPageState();
}

class _PetProfileFormPageState extends ConsumerState<PetProfileFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _veterinarianController = TextEditingController();
  final _emergencyController = TextEditingController();
  final _insuranceController = TextEditingController();
  final _microchipController = TextEditingController();
  final _allergiesController = TextEditingController();
  final _conditionsController = TextEditingController();
  final _vaccinationsController = TextEditingController();
  final _checkupController = TextEditingController();
  final _medicationsController = TextEditingController();
  final _notesController = TextEditingController();
  final _tagController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializeForm();
  }

  void _initializeForm() {
    final formNotifier = ref.read(petProfileFormProvider.notifier);
    formNotifier.initializeWithProfile(widget.existingProfile);

    // Populate controllers with existing data
    if (widget.existingProfile != null) {
      final profile = widget.existingProfile!;
      _veterinarianController.text = profile.veterinarianContact ?? '';
      _emergencyController.text = profile.emergencyContact ?? '';
      _insuranceController.text = profile.insuranceInfo ?? '';
      _microchipController.text = profile.microchipId ?? '';
      _allergiesController.text = profile.allergies ?? '';
      _conditionsController.text = profile.chronicConditions ?? '';
      _vaccinationsController.text = profile.vaccinationHistory ?? '';
      _checkupController.text = profile.lastCheckupDate ?? '';
      _medicationsController.text = profile.currentMedications ?? '';
      _notesController.text = profile.generalNotes ?? '';
    }
  }

  @override
  void dispose() {
    _veterinarianController.dispose();
    _emergencyController.dispose();
    _insuranceController.dispose();
    _microchipController.dispose();
    _allergiesController.dispose();
    _conditionsController.dispose();
    _vaccinationsController.dispose();
    _checkupController.dispose();
    _medicationsController.dispose();
    _notesController.dispose();
    _tagController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(petProfileFormProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${widget.existingProfile == null ? 'Create' : 'Edit'} Pet Profile',
        ),
        actions: [
          if (widget.existingProfile != null)
            IconButton(
              onPressed: _showDeleteDialog,
              icon: const Icon(Icons.delete),
              tooltip: 'Delete Profile',
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Pet info header
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundImage:
                            widget.pet.photoUrl != null
                                ? NetworkImage(widget.pet.photoUrl!)
                                : null,
                        child:
                            widget.pet.photoUrl == null
                                ? Text(
                                  widget.pet.name.substring(0, 1).toUpperCase(),
                                )
                                : null,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.pet.name,
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.w600),
                            ),
                            Text(
                              '${widget.pet.species}${widget.pet.breed != null ? ' • ${widget.pet.breed}' : ''}',
                              style: Theme.of(
                                context,
                              ).textTheme.bodyMedium?.copyWith(
                                color:
                                    Theme.of(
                                      context,
                                    ).colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Emergency Contact Information
              _buildSectionHeader('Emergency Contact Information'),
              const SizedBox(height: 12),
              _buildTextField(
                controller: _veterinarianController,
                label: 'Veterinarian Contact',
                hint: 'Dr. Smith, Animal Hospital, (555) 123-4567',
                icon: Icons.local_hospital,
                onChanged:
                    ref
                        .read(petProfileFormProvider.notifier)
                        .setVeterinarianContact,
              ),
              const SizedBox(height: 12),
              _buildTextField(
                controller: _emergencyController,
                label: 'Emergency Contact',
                hint: 'Emergency vet or after-hours contact',
                icon: Icons.emergency,
                onChanged:
                    ref
                        .read(petProfileFormProvider.notifier)
                        .setEmergencyContact,
              ),
              const SizedBox(height: 12),
              _buildTextField(
                controller: _insuranceController,
                label: 'Insurance Information',
                hint: 'Pet insurance provider and policy number',
                icon: Icons.security,
                onChanged:
                    ref.read(petProfileFormProvider.notifier).setInsuranceInfo,
              ),
              const SizedBox(height: 12),
              _buildTextField(
                controller: _microchipController,
                label: 'Microchip ID',
                hint: '15-digit microchip number',
                icon: Icons.nfc,
                onChanged:
                    ref.read(petProfileFormProvider.notifier).setMicrochipId,
              ),

              const SizedBox(height: 24),

              // Medical Information
              _buildSectionHeader('Medical Information'),
              const SizedBox(height: 12),
              _buildTextField(
                controller: _allergiesController,
                label: 'Known Allergies',
                hint: 'List any known allergies or sensitivities',
                icon: Icons.warning,
                maxLines: 2,
                onChanged:
                    ref.read(petProfileFormProvider.notifier).setAllergies,
              ),
              const SizedBox(height: 12),
              _buildTextField(
                controller: _conditionsController,
                label: 'Chronic Conditions',
                hint: 'Any ongoing health conditions or diseases',
                icon: Icons.medical_services,
                maxLines: 2,
                onChanged:
                    ref
                        .read(petProfileFormProvider.notifier)
                        .setChronicConditions,
              ),
              const SizedBox(height: 12),
              _buildTextField(
                controller: _vaccinationsController,
                label: 'Vaccination History',
                hint: 'Recent vaccinations and due dates',
                icon: Icons.vaccines,
                maxLines: 3,
                onChanged:
                    ref
                        .read(petProfileFormProvider.notifier)
                        .setVaccinationHistory,
              ),
              const SizedBox(height: 12),
              _buildTextField(
                controller: _checkupController,
                label: 'Last Checkup',
                hint: 'Date and details of last veterinary visit',
                icon: Icons.calendar_today,
                onChanged:
                    ref
                        .read(petProfileFormProvider.notifier)
                        .setLastCheckupDate,
              ),
              const SizedBox(height: 12),
              _buildTextField(
                controller: _medicationsController,
                label: 'Current Medications',
                hint: 'Medications not covered in care plan',
                icon: Icons.medication,
                maxLines: 2,
                onChanged:
                    ref
                        .read(petProfileFormProvider.notifier)
                        .setCurrentMedications,
              ),

              const SizedBox(height: 24),

              // General Information
              _buildSectionHeader('General Information'),
              const SizedBox(height: 12),
              _buildTextField(
                controller: _notesController,
                label: 'General Notes',
                hint:
                    'Behavioral notes, special instructions, or other important information',
                icon: Icons.note,
                maxLines: 4,
                onChanged:
                    ref.read(petProfileFormProvider.notifier).setGeneralNotes,
              ),
              const SizedBox(height: 12),

              // Tags section
              _buildTagsSection(),

              const SizedBox(height: 32),

              // Error message
              if (formState.errorMessage != null)
                Card(
                  color: Theme.of(context).colorScheme.errorContainer,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        Icon(
                          Icons.error,
                          color: Theme.of(context).colorScheme.onErrorContainer,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            formState.errorMessage!,
                            style: TextStyle(
                              color:
                                  Theme.of(
                                    context,
                                  ).colorScheme.onErrorContainer,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed:
                              () =>
                                  ref
                                      .read(petProfileFormProvider.notifier)
                                      .clearError(),
                          icon: const Icon(Icons.close),
                          color: Theme.of(context).colorScheme.onErrorContainer,
                        ),
                      ],
                    ),
                  ),
                ),

              const SizedBox(height: 16),

              // Save button
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: formState.isSubmitting ? null : _saveProfile,
                  child:
                      formState.isSubmitting
                          ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                          : Text(
                            widget.existingProfile == null
                                ? 'Create Profile'
                                : 'Update Profile',
                          ),
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.w600,
        color: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required Function(String?) onChanged,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon),
        border: const OutlineInputBorder(),
      ),
      onChanged: onChanged,
    );
  }

  Widget _buildTagsSection() {
    final formState = ref.watch(petProfileFormProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tags',
          style: Theme.of(
            context,
          ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),

        // Add tag input
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _tagController,
                decoration: const InputDecoration(
                  labelText: 'Add tag',
                  hintText: 'e.g., senior, special needs',
                  prefixIcon: Icon(Icons.tag),
                  border: OutlineInputBorder(),
                ),
                onSubmitted: (value) {
                  if (value.trim().isNotEmpty) {
                    ref.read(petProfileFormProvider.notifier).addTag(value);
                    _tagController.clear();
                  }
                },
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: () {
                if (_tagController.text.trim().isNotEmpty) {
                  ref
                      .read(petProfileFormProvider.notifier)
                      .addTag(_tagController.text);
                  _tagController.clear();
                }
              },
              icon: const Icon(Icons.add),
            ),
          ],
        ),

        const SizedBox(height: 8),

        // Display tags
        if (formState.tags.isNotEmpty)
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children:
                formState.tags.map((tag) {
                  return Chip(
                    label: Text(tag),
                    onDeleted:
                        () => ref
                            .read(petProfileFormProvider.notifier)
                            .removeTag(tag),
                    deleteIcon: const Icon(Icons.close, size: 18),
                  );
                }).toList(),
          ),
      ],
    );
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    final formNotifier = ref.read(petProfileFormProvider.notifier);
    final profileNotifier = ref.read(
      petProfileForPetProvider(widget.pet.id).notifier,
    );
    final currentUser = ref.read(currentUserDataProvider);

    if (currentUser == null) {
      _showErrorSnackBar('You must be signed in to save pet profiles');
      return;
    }

    formNotifier.setSubmitting(true);
    formNotifier.clearError();

    try {
      final formState = ref.read(petProfileFormProvider);
      final profile = formState.toPetProfile(
        id: widget.existingProfile?.id ?? '${widget.pet.id}_profile',
        petId: widget.pet.id,
        ownerId: currentUser.id,
      );

      if (widget.existingProfile != null) {
        await profileNotifier.updatePetProfile(profile);
        _showSuccessSnackBar('Pet profile updated successfully!');
      } else {
        await profileNotifier.createPetProfile(profile);
        _showSuccessSnackBar('Pet profile created successfully!');
      }

      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      formNotifier.setError('Failed to save pet profile: $e');
    } finally {
      formNotifier.setSubmitting(false);
    }
  }

  Future<void> _showDeleteDialog() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Pet Profile'),
            content: const Text(
              'Are you sure you want to delete this pet profile? This action cannot be undone.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Delete'),
              ),
            ],
          ),
    );

    if (confirmed == true) {
      try {
        final profileNotifier = ref.read(
          petProfileForPetProvider(widget.pet.id).notifier,
        );
        await profileNotifier.deletePetProfile();
        _showSuccessSnackBar('Pet profile deleted successfully!');

        if (mounted) {
          Navigator.of(context).pop();
        }
      } catch (e) {
        _showErrorSnackBar('Failed to delete pet profile: $e');
      }
    }
  }

  void _showSuccessSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Theme.of(context).colorScheme.primary,
        ),
      );
    }
  }

  void _showErrorSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }
}
