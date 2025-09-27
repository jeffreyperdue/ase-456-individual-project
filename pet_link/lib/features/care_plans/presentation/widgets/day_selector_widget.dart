import 'package:flutter/material.dart';
import '../../services/time_utils.dart';

/// A widget for selecting days of the week for schedules.
class DaySelectorWidget extends StatefulWidget {
  final List<int>? initialDays;
  final ValueChanged<List<int>?> onDaysChanged;
  final String label;
  final bool required;

  const DaySelectorWidget({
    super.key,
    this.initialDays,
    required this.onDaysChanged,
    required this.label,
    this.required = false,
  });

  @override
  State<DaySelectorWidget> createState() => _DaySelectorWidgetState();
}

class _DaySelectorWidgetState extends State<DaySelectorWidget> {
  List<int>? _selectedDays;

  @override
  void initState() {
    super.initState();
    _selectedDays = widget.initialDays;
  }

  @override
  Widget build(BuildContext context) {
    final dayNames = TimeUtils.getShortDayNames();

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

        // Quick selection buttons
        _buildQuickSelectionButtons(),

        const SizedBox(height: 12),

        // Individual day selection
        _buildDayChips(dayNames),

        // Validation error (if any)
        if (widget.required && _selectedDays == null) ...[
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

  Widget _buildQuickSelectionButtons() {
    return Row(
      children: [
        _buildQuickButton('Daily', null),
        const SizedBox(width: 8),
        _buildQuickButton('Weekdays', [1, 2, 3, 4, 5]), // Mon-Fri
        const SizedBox(width: 8),
        _buildQuickButton('Weekends', [0, 6]), // Sun, Sat
      ],
    );
  }

  Widget _buildQuickButton(String label, List<int>? days) {
    final isSelected = _selectedDays == days;

    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedDays = selected ? days : null;
        });
        widget.onDaysChanged(_selectedDays);
      },
      selectedColor: Theme.of(context).colorScheme.secondaryContainer,
      checkmarkColor: Theme.of(context).colorScheme.onSecondaryContainer,
    );
  }

  Widget _buildDayChips(List<String> dayNames) {
    return Wrap(
      spacing: 8,
      children: List.generate(7, (index) {
        final isSelected = _selectedDays?.contains(index) ?? false;

        return FilterChip(
          label: Text(dayNames[index]),
          selected: isSelected,
          onSelected: (selected) {
            setState(() {
              if (_selectedDays == null) {
                _selectedDays = [];
              }

              if (selected) {
                _selectedDays = [..._selectedDays!, index];
              } else {
                _selectedDays =
                    _selectedDays!.where((day) => day != index).toList();
                if (_selectedDays!.isEmpty) {
                  _selectedDays = null;
                }
              }
            });
            widget.onDaysChanged(_selectedDays);
          },
          selectedColor: Theme.of(context).colorScheme.primaryContainer,
          checkmarkColor: Theme.of(context).colorScheme.onPrimaryContainer,
        );
      }),
    );
  }
}

