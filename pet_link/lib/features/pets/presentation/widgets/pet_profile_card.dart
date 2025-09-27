import 'package:flutter/material.dart';
import '../../domain/pet_profile.dart';

/// Widget for displaying pet profile information in a card format.
class PetProfileCard extends StatelessWidget {
  final PetProfile? profile;
  final VoidCallback? onEdit;
  final VoidCallback? onCreate;

  const PetProfileCard({super.key, this.profile, this.onEdit, this.onCreate});

  @override
  Widget build(BuildContext context) {
    if (profile == null) {
      return _buildEmptyState(context);
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.person_outline,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Enhanced Profile',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                if (onEdit != null)
                  IconButton(
                    onPressed: onEdit,
                    icon: const Icon(Icons.edit),
                    tooltip: 'Edit Profile',
                  ),
              ],
            ),
            const SizedBox(height: 16),

            // Emergency Contact Information
            if (_hasEmergencyInfo(profile!)) ...[
              _buildSection(context, 'Emergency Contact', Icons.emergency, [
                if (profile!.veterinarianContact?.isNotEmpty == true)
                  _buildInfoRow(
                    context,
                    'Veterinarian',
                    profile!.veterinarianContact!,
                  ),
                if (profile!.emergencyContact?.isNotEmpty == true)
                  _buildInfoRow(
                    context,
                    'Emergency Contact',
                    profile!.emergencyContact!,
                  ),
                if (profile!.insuranceInfo?.isNotEmpty == true)
                  _buildInfoRow(context, 'Insurance', profile!.insuranceInfo!),
                if (profile!.microchipId?.isNotEmpty == true)
                  _buildInfoRow(context, 'Microchip ID', profile!.microchipId!),
              ]),
              const SizedBox(height: 16),
            ],

            // Medical Information
            if (_hasMedicalInfo(profile!)) ...[
              _buildSection(
                context,
                'Medical Information',
                Icons.medical_services,
                [
                  if (profile!.allergies?.isNotEmpty == true)
                    _buildInfoRow(context, 'Allergies', profile!.allergies!),
                  if (profile!.chronicConditions?.isNotEmpty == true)
                    _buildInfoRow(
                      context,
                      'Chronic Conditions',
                      profile!.chronicConditions!,
                    ),
                  if (profile!.vaccinationHistory?.isNotEmpty == true)
                    _buildInfoRow(
                      context,
                      'Vaccinations',
                      profile!.vaccinationHistory!,
                    ),
                  if (profile!.lastCheckupDate?.isNotEmpty == true)
                    _buildInfoRow(
                      context,
                      'Last Checkup',
                      profile!.lastCheckupDate!,
                    ),
                  if (profile!.currentMedications?.isNotEmpty == true)
                    _buildInfoRow(
                      context,
                      'Current Medications',
                      profile!.currentMedications!,
                    ),
                ],
              ),
              const SizedBox(height: 16),
            ],

            // General Information
            if (_hasGeneralInfo(profile!)) ...[
              _buildSection(context, 'General Information', Icons.note, [
                if (profile!.generalNotes?.isNotEmpty == true)
                  _buildInfoRow(context, 'Notes', profile!.generalNotes!),
                if (profile!.tags.isNotEmpty)
                  _buildTagsRow(context, 'Tags', profile!.tags),
              ]),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Icon(
              Icons.person_add_outlined,
              size: 48,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              'No Enhanced Profile',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              'Add emergency contacts, medical history, and notes to create a comprehensive profile for sharing.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            if (onCreate != null)
              FilledButton.icon(
                onPressed: onCreate,
                icon: const Icon(Icons.add),
                label: const Text('Create Profile'),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(
    BuildContext context,
    String title,
    IconData icon,
    List<Widget> children,
  ) {
    if (children.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...children,
      ],
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w500,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 2),
          Text(value, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }

  Widget _buildTagsRow(BuildContext context, String label, List<String> tags) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w500,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 4),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children:
                tags.map((tag) {
                  return Chip(
                    label: Text(tag),
                    backgroundColor:
                        Theme.of(context).colorScheme.surfaceVariant,
                    labelStyle: Theme.of(context).textTheme.bodySmall,
                  );
                }).toList(),
          ),
        ],
      ),
    );
  }

  bool _hasEmergencyInfo(PetProfile profile) {
    return profile.veterinarianContact?.isNotEmpty == true ||
        profile.emergencyContact?.isNotEmpty == true ||
        profile.insuranceInfo?.isNotEmpty == true ||
        profile.microchipId?.isNotEmpty == true;
  }

  bool _hasMedicalInfo(PetProfile profile) {
    return profile.allergies?.isNotEmpty == true ||
        profile.chronicConditions?.isNotEmpty == true ||
        profile.vaccinationHistory?.isNotEmpty == true ||
        profile.lastCheckupDate?.isNotEmpty == true ||
        profile.currentMedications?.isNotEmpty == true;
  }

  bool _hasGeneralInfo(PetProfile profile) {
    return profile.generalNotes?.isNotEmpty == true || profile.tags.isNotEmpty;
  }
}
