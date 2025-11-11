import 'package:flutter/material.dart';
import '../../domain/care_task.dart';
import '../../application/care_task_provider.dart';
import '../../../sharing/domain/task_completion.dart';
import '../../../sharing/presentation/widgets/task_completion_status.dart';

/// A card widget for displaying care tasks.
/// Can display either a CareTask or CareTaskWithCompletion for real-time updates.
class CareTaskCard extends StatelessWidget {
  final CareTask? task;
  final CareTaskWithCompletion? taskWithCompletion;
  final bool isUrgent;
  final VoidCallback? onTap;
  final String? completedByDisplayName;

  const CareTaskCard({
    super.key,
    this.task,
    this.taskWithCompletion,
    this.isUrgent = false,
    this.onTap,
    this.completedByDisplayName,
  }) : assert(
          task != null || taskWithCompletion != null,
          'Either task or taskWithCompletion must be provided',
        );

  /// Get the underlying CareTask.
  CareTask get _task => taskWithCompletion?.task ?? task!;

  /// Check if the task is completed.
  bool get _isCompleted {
    if (taskWithCompletion != null) {
      return taskWithCompletion!.isCompleted;
    }
    return task?.completed ?? false;
  }

  /// Get completion information.
  TaskCompletion? get _completion => taskWithCompletion?.latestCompletion;

  @override
  Widget build(BuildContext context) {
    final currentTask = _task;
    final isCompleted = _isCompleted;

    return Card(
      color: isCompleted
          ? Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3)
          : (isUrgent
              ? Theme.of(context).colorScheme.errorContainer.withOpacity(0.1)
              : null),
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
                  child: Text(
                    currentTask.icon,
                    style: TextStyle(
                      fontSize: 24,
                      color: isCompleted
                          ? Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.6)
                          : null,
                    ),
                  ),
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
                      currentTask.title,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: isCompleted
                            ? Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.6)
                            : (isUrgent
                                ? Theme.of(context).colorScheme.error
                                : null),
                        decoration: isCompleted ? TextDecoration.lineThrough : null,
                      ),
                    ),

                    const SizedBox(height: 4),

                    // Description
                    Text(
                      currentTask.description,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: isCompleted
                            ? Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.6)
                            : Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Completion status or time until due
                    if (isCompleted && _completion != null)
                      TaskCompletionStatus(
                        completion: _completion,
                        completedByDisplayName: completedByDisplayName,
                      )
                    else
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
                              currentTask.timeUntilDue,
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
                          if (currentTask.isOverdue)
                            Icon(
                              Icons.priority_high,
                              size: 16,
                              color: Theme.of(context).colorScheme.error,
                            )
                          else if (currentTask.isDueSoon)
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

              // Completion status icon
              if (isCompleted)
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
    switch (_task.type) {
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
    if (_task.isOverdue) {
      return Theme.of(context).colorScheme.error;
    } else if (_task.isDueSoon) {
      return Theme.of(context).colorScheme.primary;
    } else {
      return Theme.of(context).colorScheme.surfaceVariant;
    }
  }

  Color _getTimeBadgeTextColor(BuildContext context) {
    if (_task.isOverdue) {
      return Theme.of(context).colorScheme.onError;
    } else if (_task.isDueSoon) {
      return Theme.of(context).colorScheme.onPrimary;
    } else {
      return Theme.of(context).colorScheme.onSurfaceVariant;
    }
  }
}

