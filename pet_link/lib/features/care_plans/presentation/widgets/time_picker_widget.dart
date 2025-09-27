import 'package:flutter/material.dart';
import '../../services/time_utils.dart';

/// A reusable time picker widget with quick-add chips.
class TimePickerWidget extends StatefulWidget {
  final String? initialTime;
  final ValueChanged<String?> onTimeChanged;
  final String label;
  final bool required;

  const TimePickerWidget({
    super.key,
    this.initialTime,
    required this.onTimeChanged,
    required this.label,
    this.required = false,
  });

  @override
  State<TimePickerWidget> createState() => _TimePickerWidgetState();
}

class _TimePickerWidgetState extends State<TimePickerWidget> {
  String? _selectedTime;

  @override
  void initState() {
    super.initState();
    _selectedTime = widget.initialTime;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        Text(
          widget.label,
          style: Theme.of(
            context,
          ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),

        // Quick-add chips
        _buildQuickAddChips(),

        const SizedBox(height: 12),

        // Selected time display and picker
        _buildTimePicker(),

        // Validation error (if any)
        if (widget.required && _selectedTime == null) ...[
          const SizedBox(height: 4),
          Text(
            '${widget.label} is required',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.error,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildQuickAddChips() {
    final quickAddChips = TimeUtils.getQuickAddChips();

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children:
          quickAddChips.entries.map((entry) {
            return _buildChipGroup(entry.key, entry.value);
          }).toList(),
    );
  }

  Widget _buildChipGroup(String label, List<String> times) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 4),
        Wrap(
          spacing: 6,
          children: times.map((time) => _buildTimeChip(time)).toList(),
        ),
      ],
    );
  }

  Widget _buildTimeChip(String time) {
    final isSelected = _selectedTime == time;

    return FilterChip(
      label: Text(TimeUtils.formatTimeForDisplay(time)),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedTime = selected ? time : null;
        });
        widget.onTimeChanged(_selectedTime);
      },
      selectedColor: Theme.of(context).colorScheme.secondaryContainer,
      checkmarkColor: Theme.of(context).colorScheme.onSecondaryContainer,
    );
  }

  Widget _buildTimePicker() {
    return InkWell(
      onTap: _showTimePicker,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
            color:
                _selectedTime != null
                    ? Theme.of(context).colorScheme.outline
                    : Theme.of(context).colorScheme.outline.withOpacity(0.5),
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              Icons.access_time,
              color:
                  _selectedTime != null
                      ? Theme.of(context).colorScheme.onSurface
                      : Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _selectedTime != null
                    ? TimeUtils.formatTimeForDisplay(_selectedTime!)
                    : 'Select time',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color:
                      _selectedTime != null
                          ? Theme.of(context).colorScheme.onSurface
                          : Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            if (_selectedTime != null)
              IconButton(
                onPressed: () {
                  setState(() {
                    _selectedTime = null;
                  });
                  widget.onTimeChanged(null);
                },
                icon: const Icon(Icons.clear),
                iconSize: 20,
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _showTimePicker() async {
    final timeOfDay = await showTimePicker(
      context: context,
      initialTime:
          _selectedTime != null
              ? TimeUtils.parseTimeOfDay(_selectedTime!) ?? TimeOfDay.now()
              : TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: Theme.of(context).colorScheme.primary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (timeOfDay != null) {
      final timeString = TimeUtils.formatTimeOfDay(timeOfDay);
      setState(() {
        _selectedTime = timeString;
      });
      widget.onTimeChanged(timeString);
    }
  }
}

