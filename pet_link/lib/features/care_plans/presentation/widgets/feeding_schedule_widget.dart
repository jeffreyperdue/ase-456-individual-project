import 'package:flutter/material.dart';
import '../../domain/feeding_schedule.dart';
import '../../services/time_utils.dart';
import 'time_picker_widget.dart';
import 'day_selector_widget.dart';

/// A widget for creating and editing feeding schedules.
class FeedingScheduleWidget extends StatefulWidget {
  final FeedingSchedule? initialSchedule;
  final ValueChanged<FeedingSchedule> onScheduleChanged;
  final VoidCallback? onRemove;

  const FeedingScheduleWidget({
    super.key,
    this.initialSchedule,
    required this.onScheduleChanged,
    this.onRemove,
  });

  @override
  State<FeedingScheduleWidget> createState() => _FeedingScheduleWidgetState();
}

class _FeedingScheduleWidgetState extends State<FeedingScheduleWidget> {
  late TextEditingController _labelController;
  late TextEditingController _notesController;
  List<String> _selectedTimes = [];
  List<int>? _selectedDays;

  @override
  void initState() {
    super.initState();
    final schedule = widget.initialSchedule;
    _labelController = TextEditingController(text: schedule?.label ?? '');
    _notesController = TextEditingController(text: schedule?.notes ?? '');
    _selectedTimes = List.from(schedule?.times ?? []);
    _selectedDays = schedule?.daysOfWeek;
  }

  @override
  void dispose() {
    _labelController.dispose();
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
                    _labelController.text.isEmpty
                        ? 'Feeding Schedule'
                        : _labelController.text,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (widget.onRemove != null)
                  IconButton(
                    onPressed: widget.onRemove,
                    icon: const Icon(Icons.delete_outline),
                    tooltip: 'Remove schedule',
                  ),
              ],
            ),

            const SizedBox(height: 16),

            // Label input
            TextFormField(
              controller: _labelController,
              decoration: const InputDecoration(
                labelText: 'Schedule Name (e.g., Breakfast, Dinner)',
                hintText: 'Optional - helps identify this schedule',
              ),
              onChanged: _updateSchedule,
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
                _updateSchedule('');
              },
              label: 'Days',
              required: false,
            ),

            const SizedBox(height: 16),

            // Notes
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Notes (optional)',
                hintText: 'Any special instructions for this feeding...',
              ),
              maxLines: 2,
              onChanged: _updateSchedule,
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
          'Feeding Times',
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
                      _updateSchedule('');
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
              _updateSchedule('');
            }
          },
          label: _selectedTimes.isEmpty ? 'Add First Time' : 'Add Another Time',
          required: _selectedTimes.isEmpty,
        ),
      ],
    );
  }

  void _updateSchedule(String _) {
    final schedule = FeedingSchedule(
      id:
          widget.initialSchedule?.id ??
          DateTime.now().microsecondsSinceEpoch.toString(),
      label:
          _labelController.text.trim().isEmpty
              ? null
              : _labelController.text.trim(),
      times: _selectedTimes,
      daysOfWeek: _selectedDays,
      active: true,
      notes:
          _notesController.text.trim().isEmpty
              ? null
              : _notesController.text.trim(),
    );

    widget.onScheduleChanged(schedule);
  }
}

