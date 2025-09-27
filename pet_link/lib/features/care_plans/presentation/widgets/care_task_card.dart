import 'package:flutter/material.dart';
import '../../domain/care_task.dart';

/// A card widget for displaying care tasks.
class CareTaskCard extends StatelessWidget {
  final CareTask task;
  final bool isUrgent;
  final VoidCallback? onTap;

  const CareTaskCard({
    super.key,
    required this.task,
    this.isUrgent = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color:
          isUrgent
              ? Theme.of(context).colorScheme.errorContainer.withOpacity(0.1)
              : null,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Task icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: _getIconBackgroundColor(context),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Center(
                  child: Text(task.icon, style: const TextStyle(fontSize: 24)),
                ),
              ),

              const SizedBox(width: 16),

              // Task details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      task.title,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color:
                            isUrgent
                                ? Theme.of(context).colorScheme.error
                                : null,
                      ),
                    ),

                    const SizedBox(height: 4),

                    // Description
                    Text(
                      task.description,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Time and status
                    Row(
                      children: [
                        // Time until due
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _getTimeBadgeColor(context),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            task.timeUntilDue,
                            style: Theme.of(
                              context,
                            ).textTheme.bodySmall?.copyWith(
                              color: _getTimeBadgeTextColor(context),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),

                        const SizedBox(width: 8),

                        // Status indicator
                        if (task.isOverdue)
                          Icon(
                            Icons.priority_high,
                            size: 16,
                            color: Theme.of(context).colorScheme.error,
                          )
                        else if (task.isDueSoon)
                          Icon(
                            Icons.access_time,
                            size: 16,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                      ],
                    ),
                  ],
                ),
              ),

              // Completion status
              if (task.completed)
                Icon(
                  Icons.check_circle,
                  color: Theme.of(context).colorScheme.primary,
                )
              else
                Icon(
                  Icons.radio_button_unchecked,
                  color: Theme.of(context).colorScheme.outline,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getIconBackgroundColor(BuildContext context) {
    switch (task.type) {
      case CareTaskType.feeding:
        return Theme.of(context).colorScheme.secondaryContainer;
      case CareTaskType.medication:
        return Theme.of(context).colorScheme.tertiaryContainer;
      case CareTaskType.exercise:
        return Theme.of(context).colorScheme.primaryContainer;
      case CareTaskType.grooming:
        return Theme.of(context).colorScheme.surfaceVariant;
      case CareTaskType.vet:
        return Theme.of(context).colorScheme.errorContainer;
      case CareTaskType.other:
        return Theme.of(context).colorScheme.outline;
    }
  }

  Color _getTimeBadgeColor(BuildContext context) {
    if (task.isOverdue) {
      return Theme.of(context).colorScheme.error;
    } else if (task.isDueSoon) {
      return Theme.of(context).colorScheme.primary;
    } else {
      return Theme.of(context).colorScheme.surfaceVariant;
    }
  }

  Color _getTimeBadgeTextColor(BuildContext context) {
    if (task.isOverdue) {
      return Theme.of(context).colorScheme.onError;
    } else if (task.isDueSoon) {
      return Theme.of(context).colorScheme.onPrimary;
    } else {
      return Theme.of(context).colorScheme.onSurfaceVariant;
    }
  }
}

