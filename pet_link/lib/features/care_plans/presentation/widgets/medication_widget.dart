import 'package:flutter/material.dart';
import '../../domain/medication.dart';
import '../../services/time_utils.dart';
import 'time_picker_widget.dart';
import 'day_selector_widget.dart';

/// A widget for creating and editing medications.
class MedicationWidget extends StatefulWidget {
  final Medication? initialMedication;
  final ValueChanged<Medication> onMedicationChanged;
  final VoidCallback? onRemove;

  const MedicationWidget({
    super.key,
    this.initialMedication,
    required this.onMedicationChanged,
    this.onRemove,
  });

  @override
  State<MedicationWidget> createState() => _MedicationWidgetState();
}

class _MedicationWidgetState extends State<MedicationWidget> {
  late TextEditingController _nameController;
  late TextEditingController _dosageController;
  late TextEditingController _notesController;
  List<String> _selectedTimes = [];
  List<int>? _selectedDays;
  bool _withFood = false;

  @override
  void initState() {
    super.initState();
    final medication = widget.initialMedication;
    _nameController = TextEditingController(text: medication?.name ?? '');
    _dosageController = TextEditingController(text: medication?.dosage ?? '');
    _notesController = TextEditingController(text: medication?.notes ?? '');
    _selectedTimes = List.from(medication?.times ?? []);
    _selectedDays = medication?.daysOfWeek;
    _withFood = medication?.withFood ?? false;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dosageController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with remove button
            Row(
              children: [
                Expanded(
                  child: Text(
                    _nameController.text.isEmpty
                        ? 'Medication'
                        : _nameController.text,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (widget.onRemove != null)
                  IconButton(
                    onPressed: widget.onRemove,
                    icon: const Icon(Icons.delete_outline),
                    tooltip: 'Remove medication',
                  ),
              ],
            ),

            const SizedBox(height: 16),

            // Name and dosage
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Medication Name',
                      hintText: 'e.g., Heart medication',
                    ),
                    onChanged: _updateMedication,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _dosageController,
                    decoration: const InputDecoration(
                      labelText: 'Dosage',
                      hintText: 'e.g., 5mg, 1 tablet',
                    ),
                    onChanged: _updateMedication,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Time selection
            _buildTimeSelection(),

            const SizedBox(height: 16),

            // Day selection
            DaySelectorWidget(
              initialDays: _selectedDays,
              onDaysChanged: (days) {
                setState(() {
                  _selectedDays = days;
                });
                _updateMedication('');
              },
              label: 'Days',
              required: false,
            ),

            const SizedBox(height: 16),

            // With food checkbox
            CheckboxListTile(
              title: const Text('Give with food'),
              subtitle: const Text(
                'Check if medication should be given with meals',
              ),
              value: _withFood,
              onChanged: (value) {
                setState(() {
                  _withFood = value ?? false;
                });
                _updateMedication('');
              },
              contentPadding: EdgeInsets.zero,
            ),

            const SizedBox(height: 16),

            // Notes
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Notes (optional)',
                hintText: 'Any special instructions for this medication...',
              ),
              maxLines: 2,
              onChanged: _updateMedication,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Medication Times',
          style: Theme.of(
            context,
          ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),

        // Selected times
        if (_selectedTimes.isNotEmpty) ...[
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children:
                _selectedTimes.map((time) {
                  return Chip(
                    label: Text(TimeUtils.formatTimeForDisplay(time)),
                    deleteIcon: const Icon(Icons.close, size: 18),
                    onDeleted: () {
                      setState(() {
                        _selectedTimes.remove(time);
                      });
                      _updateMedication('');
                    },
                  );
                }).toList(),
          ),
          const SizedBox(height: 12),
        ],

        // Add time button
        TimePickerWidget(
          onTimeChanged: (time) {
            if (time != null && !_selectedTimes.contains(time)) {
              setState(() {
                _selectedTimes.add(time);
              });
              _updateMedication('');
            }
          },
          label: _selectedTimes.isEmpty ? 'Add First Time' : 'Add Another Time',
          required: _selectedTimes.isEmpty,
        ),
      ],
    );
  }

  void _updateMedication(String _) {
    final medication = Medication(
      id:
          widget.initialMedication?.id ??
          DateTime.now().microsecondsSinceEpoch.toString(),
      name: _nameController.text.trim(),
      dosage: _dosageController.text.trim(),
      times: _selectedTimes,
      daysOfWeek: _selectedDays,
      withFood: _withFood,
      notes:
          _notesController.text.trim().isEmpty
              ? null
              : _notesController.text.trim(),
      active: true,
    );

    widget.onMedicationChanged(medication);
  }
}

