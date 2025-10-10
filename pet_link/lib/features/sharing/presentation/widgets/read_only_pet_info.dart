import 'package:flutter/material.dart';
import '../../../pets/domain/pet.dart';
import '../../../pets/domain/pet_profile.dart';

/// Widget for displaying read-only pet information.
class ReadOnlyPetInfo extends StatelessWidget {
  final Pet pet;
  final PetProfile? petProfile;

  const ReadOnlyPetInfo({super.key, required this.pet, this.petProfile});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Pet Information',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),

            // Basic Information
            _buildInfoSection(context, 'Basic Information', [
              _buildInfoRow(context, 'Name', pet.name),
              _buildInfoRow(context, 'Species', pet.species),
              if (pet.breed != null)
                _buildInfoRow(context, 'Breed', pet.breed!),
              if (pet.dateOfBirth != null)
                _buildInfoRow(
                  context,
                  'Date of Birth',
                  _formatDate(pet.dateOfBirth!),
                ),
              if (pet.weightKg != null)
                _buildInfoRow(context, 'Weight', '${pet.weightKg} kg'),
              if (pet.heightCm != null)
                _buildInfoRow(context, 'Height', '${pet.heightCm} cm'),
            ]),

            if (petProfile != null) ...[
              const SizedBox(height: 16),

              // Health Information
              if (petProfile!.allergies != null ||
                  petProfile!.chronicConditions != null ||
                  petProfile!.currentMedications != null)
                _buildInfoSection(context, 'Health Information', [
                  if (petProfile!.allergies != null)
                    _buildInfoRow(context, 'Allergies', petProfile!.allergies!),
                  if (petProfile!.chronicConditions != null)
                    _buildInfoRow(
                      context,
                      'Chronic Conditions',
                      petProfile!.chronicConditions!,
                    ),
                  if (petProfile!.currentMedications != null)
                    _buildInfoRow(
                      context,
                      'Current Medications',
                      petProfile!.currentMedications!,
                    ),
                ]),

              const SizedBox(height: 16),

              // Contact Information
              if (petProfile!.veterinarianContact != null ||
                  petProfile!.emergencyContact != null)
                _buildInfoSection(context, 'Emergency Contacts', [
                  if (petProfile!.veterinarianContact != null)
                    _buildContactRow(
                      context,
                      'Veterinarian',
                      petProfile!.veterinarianContact!,
                    ),
                  if (petProfile!.emergencyContact != null)
                    _buildContactRow(
                      context,
                      'Emergency Contact',
                      petProfile!.emergencyContact!,
                    ),
                ]),

              const SizedBox(height: 16),

              // General Notes
              if (petProfile!.generalNotes != null)
                _buildInfoSection(context, 'Notes', [
                  _buildInfoRow(
                    context,
                    'General Notes',
                    petProfile!.generalNotes!,
                  ),
                ]),

              // Tags
              if (petProfile!.tags.isNotEmpty) ...[
                const SizedBox(height: 16),
                _buildTagsSection(context),
              ],
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection(
    BuildContext context,
    String title,
    List<Widget> children,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(height: 8),
        ...children,
      ],
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: Text(value, style: Theme.of(context).textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }

  Widget _buildContactRow(BuildContext context, String label, String contact) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: Text(contact, style: Theme.of(context).textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }

  Widget _buildTagsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tags',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children:
              petProfile!.tags.map((tag) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.secondaryContainer,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    tag,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSecondaryContainer,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              }).toList(),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
