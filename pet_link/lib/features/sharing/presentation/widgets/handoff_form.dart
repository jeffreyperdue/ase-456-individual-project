import 'package:flutter/material.dart';
import '../../domain/access_token.dart';

/// Form widget for creating handoffs (access tokens).
class HandoffForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final AccessRole selectedRole;
  final DateTime expirationDate;
  final String notes;
  final String contactInfo;
  final String recipientUserId;
  final ValueChanged<AccessRole> onRoleChanged;
  final ValueChanged<DateTime> onExpirationChanged;
  final ValueChanged<String> onNotesChanged;
  final ValueChanged<String> onContactInfoChanged;
  final ValueChanged<String> onRecipientUserIdChanged;

  const HandoffForm({
    super.key,
    required this.formKey,
    required this.selectedRole,
    required this.expirationDate,
    required this.notes,
    required this.contactInfo,
    required this.recipientUserId,
    required this.onRoleChanged,
    required this.onExpirationChanged,
    required this.onNotesChanged,
    required this.onContactInfoChanged,
    required this.onRecipientUserIdChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Access Role Selection
          _buildRoleSelection(context),

          const SizedBox(height: 16),

          // Expiration Date
          _buildExpirationDate(context),

          const SizedBox(height: 16),

          // Recipient User ID
          _buildRecipientUserId(context),

          const SizedBox(height: 16),

          // Contact Information
          _buildContactInfo(context),

          const SizedBox(height: 16),

          // Notes
          _buildNotes(context),
        ],
      ),
    );
  }

  Widget _buildRoleSelection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Access Level',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        ...AccessRole.values.map((role) {
          return RadioListTile<AccessRole>(
            title: Row(
              children: [
                Text(role.icon, style: const TextStyle(fontSize: 20)),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(role.displayName),
                      Text(
                        role.description,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            value: role,
            groupValue: selectedRole,
            onChanged: (AccessRole? value) {
              if (value != null) {
                onRoleChanged(value);
              }
            },
            contentPadding: EdgeInsets.zero,
          );
        }).toList(),
      ],
    );
  }

  Widget _buildExpirationDate(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Expiration Date',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () => _selectExpirationDate(context),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(color: Theme.of(context).colorScheme.outline),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _formatDate(expirationDate),
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
                Icon(
                  Icons.arrow_drop_down,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Access will expire automatically on this date',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildRecipientUserId(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recipient User ID (Optional)',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        TextFormField(
          initialValue: recipientUserId,
          onChanged: onRecipientUserIdChanged,
          decoration: const InputDecoration(
            hintText: 'Enter user ID (leave empty for general sharing)',
            prefixIcon: Icon(Icons.person),
            border: OutlineInputBorder(),
          ),
          validator: (value) {
            // Optional field, no validation required
            return null;
          },
        ),
        const SizedBox(height: 4),
        Text(
          'Enter the user ID of the person who should receive access. Leave empty for general sharing via QR code.',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildContactInfo(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Contact Information (Optional)',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        TextFormField(
          initialValue: contactInfo,
          onChanged: onContactInfoChanged,
          decoration: const InputDecoration(
            hintText: 'Phone number or email address',
            prefixIcon: Icon(Icons.contact_phone),
            border: OutlineInputBorder(),
          ),
          validator: (value) {
            // Optional field, no validation required
            return null;
          },
        ),
        const SizedBox(height: 4),
        Text(
          'Add contact info for the person receiving access',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildNotes(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Notes (Optional)',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        TextFormField(
          initialValue: notes,
          onChanged: onNotesChanged,
          maxLines: 3,
          decoration: const InputDecoration(
            hintText: 'Add any special instructions or notes...',
            prefixIcon: Icon(Icons.note),
            border: OutlineInputBorder(),
          ),
          validator: (value) {
            // Optional field, no validation required
            return null;
          },
        ),
        const SizedBox(height: 4),
        Text(
          'Include any special instructions or context for this handoff',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Future<void> _selectExpirationDate(BuildContext context) async {
    final now = DateTime.now();
    final minimumDate = now.add(const Duration(hours: 1));
    final maximumDate = now.add(const Duration(days: 30));

    final selectedDate = await showDatePicker(
      context: context,
      initialDate: expirationDate,
      firstDate: minimumDate,
      lastDate: maximumDate,
      helpText: 'Select expiration date',
    );

    if (selectedDate != null) {
      final selectedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(expirationDate),
        helpText: 'Select expiration time',
      );

      if (selectedTime != null) {
        final newDateTime = DateTime(
          selectedDate.year,
          selectedDate.month,
          selectedDate.day,
          selectedTime.hour,
          selectedTime.minute,
        );

        // Ensure the selected date is in the future
        if (newDateTime.isAfter(now)) {
          onExpirationChanged(newDateTime);
        }
      }
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} at ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}
