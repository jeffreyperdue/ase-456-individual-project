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
  const EditPetPage({
    super.key, 
    this.petToEdit,
    this.isFirstTimeFlow = false,
  });

  final Pet? petToEdit; // if provided, we're editing
  final bool isFirstTimeFlow; // if true, show guided onboarding flow

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
  int _currentStep = 1; // for guided flow step tracking

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
          SnackBar(
            content: const Text('You must be signed in to add pets'),
            backgroundColor: Theme.of(context).colorScheme.error,
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
            backgroundColor: Theme.of(context).colorScheme.error,
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

      // 5) Handle success - different flow for first-time vs regular
      if (mounted) {
        if (widget.isFirstTimeFlow) {
          // Navigate to success screen for first-time flow
          Navigator.pushReplacementNamed(
            context, 
            '/onboarding-success',
            arguments: {'petName': pet.name},
          );
        } else {
          // Regular flow - show snackbar and go back
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Pet added')),
          );
          Navigator.pop(context);
        }
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

  // Helper methods for guided flow
  void _nextStep() {
    if (_currentStep < 3) {
      setState(() => _currentStep++);
    }
  }

  void _previousStep() {
    if (_currentStep > 1) {
      setState(() => _currentStep--);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isFirstTimeFlow) {
      return _buildGuidedFlow(context);
    } else {
      return _buildRegularFlow(context);
    }
  }

  Widget _buildRegularFlow(BuildContext context) {
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

  Widget _buildGuidedFlow(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Your First Pet'),
        automaticallyImplyLeading: false, // Disable back button in guided flow
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            // Progress indicator
            _buildStepIndicator(theme),
            
            // Step content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: _buildStepContent(theme),
              ),
            ),
            
            // Navigation buttons
            _buildNavigationButtons(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildStepIndicator(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          _buildStepIndicatorItem(theme, 1, 'Basic Info'),
          Expanded(
            child: Container(
              height: 2,
              color: _currentStep > 1 
                  ? theme.colorScheme.primary 
                  : theme.colorScheme.outline.withValues(alpha: 0.3),
            ),
          ),
          _buildStepIndicatorItem(theme, 2, 'Photo'),
          Expanded(
            child: Container(
              height: 2,
              color: _currentStep > 2 
                  ? theme.colorScheme.primary 
                  : theme.colorScheme.outline.withValues(alpha: 0.3),
            ),
          ),
          _buildStepIndicatorItem(theme, 3, 'Review'),
        ],
      ),
    );
  }

  Widget _buildStepIndicatorItem(ThemeData theme, int step, String label) {
    final isActive = _currentStep == step;
    final isCompleted = _currentStep > step;
    
    return Column(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: isActive || isCompleted 
                ? theme.colorScheme.primary 
                : theme.colorScheme.outline.withValues(alpha: 0.3),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: isCompleted 
                ? Icon(Icons.check, color: theme.colorScheme.onPrimary, size: 18)
                : Text(
                    step.toString(),
                    style: TextStyle(
                      color: isActive || isCompleted 
                          ? theme.colorScheme.onPrimary 
                          : theme.colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: isActive 
                ? theme.colorScheme.primary 
                : theme.colorScheme.onSurfaceVariant,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildStepContent(ThemeData theme) {
    switch (_currentStep) {
      case 1:
        return _buildBasicInfoStep(theme);
      case 2:
        return _buildPhotoStep(theme);
      case 3:
        return _buildReviewStep(theme);
      default:
        return const SizedBox();
    }
  }

  Widget _buildBasicInfoStep(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Let\'s start with the basics',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Tell us about your pet\'s name and species',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 32),
        
        // Pet name
        TextFormField(
          controller: _nameCtrl,
          decoration: InputDecoration(
            labelText: 'Pet\'s Name',
            hintText: 'e.g., Buddy, Luna, Max',
            prefixIcon: const Icon(Icons.pets),
            border: const OutlineInputBorder(),
          ),
          textInputAction: TextInputAction.next,
          onChanged: (value) => setState(() {}), // Trigger rebuild for validation
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter your pet\'s name';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),

        // Species dropdown
        DropdownButtonFormField<String>(
          initialValue: _species,
          decoration: const InputDecoration(
            labelText: 'Species',
            prefixIcon: Icon(Icons.category),
            border: OutlineInputBorder(),
          ),
          items: const [
            DropdownMenuItem(value: 'Dog', child: Text('Dog')),
            DropdownMenuItem(value: 'Cat', child: Text('Cat')),
            DropdownMenuItem(value: 'Bird', child: Text('Bird')),
            DropdownMenuItem(value: 'Other', child: Text('Other')),
          ],
          onChanged: (val) => setState(() => _species = val),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please select your pet\'s species';
            }
            return null;
          },
        ),
        
        const Spacer(),
        
        // Hint text
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(
                Icons.lightbulb_outline,
                color: theme.colorScheme.primary,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Don\'t worry, you can always add more details later!',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPhotoStep(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Add a photo',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'A photo helps others identify your pet',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 32),
        
        // Photo upload area
        Center(
          child: GestureDetector(
            onTap: _pickPhoto,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                border: Border.all(
                  color: _selectedPhoto != null 
                      ? theme.colorScheme.primary 
                      : theme.colorScheme.outline,
                  width: 2,
                  style: BorderStyle.solid,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: _selectedPhoto == null
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add_a_photo,
                            size: 48,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Tap to add photo',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      )
                    : kIsWeb
                        ? (_selectedBytes != null
                            ? Image.memory(_selectedBytes!, fit: BoxFit.cover)
                            : const Icon(Icons.image, size: 48))
                        : Image.file(
                            File(_selectedPhoto!.path),
                            fit: BoxFit.cover,
                          ),
              ),
            ),
          ),
        ),
        
        const Spacer(),
        
        // Hint text
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(
                Icons.camera_alt_outlined,
                color: theme.colorScheme.primary,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'You can always update this photo later from your pet\'s profile',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildReviewStep(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Review your pet',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Everything looks good? Let\'s create your pet profile!',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 32),
        
        // Review card
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: theme.colorScheme.outline.withValues(alpha: 0.2),
            ),
          ),
          child: Column(
            children: [
              // Pet photo or placeholder
              CircleAvatar(
                radius: 40,
                backgroundImage: _selectedPhoto == null
                    ? null
                    : kIsWeb
                        ? (_selectedBytes != null
                            ? MemoryImage(_selectedBytes!)
                            : null)
                        : FileImage(File(_selectedPhoto!.path))
                            as ImageProvider<Object>,
                child: _selectedPhoto == null
                    ? Icon(
                        Icons.pets,
                        size: 40,
                        color: theme.colorScheme.onSurfaceVariant,
                      )
                    : null,
              ),
              const SizedBox(height: 16),
              
              // Pet name
              Text(
                _nameCtrl.text.trim().isEmpty ? 'Your Pet' : _nameCtrl.text.trim(),
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              
              // Species
              Text(
                _species ?? 'Unknown Species',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        
        const Spacer(),
        
        // Success hint
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(
                Icons.check_circle_outline,
                color: theme.colorScheme.primary,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Great! You can add care plans, medical info, and more details after creating your pet.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNavigationButtons(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          // Previous button
          if (_currentStep > 1)
            Expanded(
              child: OutlinedButton(
                onPressed: _previousStep,
                child: const Text('Previous'),
              ),
            ),
          
          if (_currentStep > 1) const SizedBox(width: 16),
          
          // Next/Complete button
          Expanded(
            flex: _currentStep == 1 ? 1 : 1,
            child: FilledButton(
              onPressed: _isSaving ? null : () {
                if (_currentStep < 3) {
                  _nextStep();
                } else {
                  // Final step - save the pet
                  _save();
                }
              },
              child: _isSaving 
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(_currentStep == 3 ? 'Create Pet' : 'Next'),
            ),
          ),
        ],
      ),
    );
  }
}
