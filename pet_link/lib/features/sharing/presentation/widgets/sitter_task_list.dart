import 'package:flutter/material.dart';
import '../../../care_plans/domain/care_task.dart';
import '../../../care_plans/application/care_task_provider.dart';

/// Widget for displaying and managing care tasks in the sitter dashboard.
/// Supports both CareTask and CareTaskWithCompletion for real-time updates.
class SitterTaskList extends StatelessWidget {
  final List<CareTask>? tasks;
  final List<CareTaskWithCompletion>? tasksWithCompletion;
  final Function(CareTask) onTaskCompleted;

  const SitterTaskList({
    super.key,
    this.tasks,
    this.tasksWithCompletion,
    required this.onTaskCompleted,
  }) : assert(
          tasks != null || tasksWithCompletion != null,
          'Either tasks or tasksWithCompletion must be provided',
        );

  List<CareTaskWithCompletion> get _tasksWithCompletion {
    if (tasksWithCompletion != null) {
      return tasksWithCompletion!;
    }
    // Convert CareTask list to CareTaskWithCompletion list
    return tasks!.map((task) => CareTaskWithCompletion(task: task)).toList();
  }

  @override
  Widget build(BuildContext context) {
    final tasksList = _tasksWithCompletion;
    final incompleteTasks = tasksList.where((t) => !t.isCompleted).toList();

    if (incompleteTasks.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Icon(
              Icons.task_alt,
              size: 48,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              'No upcoming tasks',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              tasksList.isEmpty
                  ? 'No tasks assigned'
                  : 'All tasks are completed!',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: incompleteTasks.map((taskWithCompletion) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: SitterTaskCard(
            taskWithCompletion: taskWithCompletion,
            onCompleted: () => onTaskCompleted(taskWithCompletion.task),
          ),
        );
      }).toList(),
    );
  }
}

/// Individual task card for the sitter dashboard.
class SitterTaskCard extends StatelessWidget {
  final CareTask? task;
  final CareTaskWithCompletion? taskWithCompletion;
  final VoidCallback onCompleted;

  const SitterTaskCard({
    super.key,
    this.task,
    this.taskWithCompletion,
    required this.onCompleted,
  }) : assert(
          task != null || taskWithCompletion != null,
          'Either task or taskWithCompletion must be provided',
        );

  CareTask get _task => taskWithCompletion?.task ?? task!;
  bool get _isCompleted => taskWithCompletion?.isCompleted ?? false;

  @override
  Widget build(BuildContext context) {
    final currentTask = _task;
    final isCompleted = _isCompleted;

    return Card(
      elevation: 1,
      color: isCompleted
          ? Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3)
          : null,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Task header
            Row(
              children: [
                // Task icon and type
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _getTaskColor(context).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    currentTask.icon,
                    style: TextStyle(
                      fontSize: 20,
                      color: isCompleted
                          ? Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.6)
                          : null,
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                // Task info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        currentTask.title,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          decoration: isCompleted ? TextDecoration.lineThrough : null,
                          color: isCompleted
                              ? Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.6)
                              : null,
                        ),
                      ),
                      Text(
                        currentTask.description,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: isCompleted
                              ? Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.6)
                              : Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),

                // Completion status or time info
                if (isCompleted)
                  Icon(
                    Icons.check_circle,
                    color: Theme.of(context).colorScheme.primary,
                    size: 24,
                  )
                else
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        _formatTime(currentTask.scheduledTime),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        currentTask.timeUntilDue,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: _getTimeColor(context),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
              ],
            ),

            // Completion status with timestamp
            if (isCompleted && taskWithCompletion?.latestCompletion != null) ...[
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.check_circle,
                      size: 16,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        'Completed ${_formatRelativeTime(taskWithCompletion!.latestCompletion!.completedAt)}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Task notes
            if (currentTask.notes != null && !isCompleted) ...[
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.surfaceVariant.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  currentTask.notes!,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],

            // Action button (only show if not completed)
            if (!isCompleted) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: onCompleted,
                  icon: const Icon(Icons.check_circle_outline),
                  label: const Text('Mark Complete'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _getTaskColor(context),
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatRelativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago';
    } else {
      return 'just now';
    }
  }

  Color _getTaskColor(BuildContext context) {
    if (_task.isOverdue) {
      return Theme.of(context).colorScheme.error;
    } else if (_task.isDueSoon) {
      return Theme.of(context).colorScheme.tertiary;
    } else {
      return Theme.of(context).colorScheme.primary;
    }
  }

  Color _getTimeColor(BuildContext context) {
    if (_task.isOverdue) {
      return Theme.of(context).colorScheme.error;
    } else if (_task.isDueSoon) {
      return Theme.of(context).colorScheme.tertiary;
    } else {
      return Theme.of(context).colorScheme.onSurfaceVariant;
    }
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour;
    final minute = dateTime.minute;
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);

    return '$displayHour:${minute.toString().padLeft(2, '0')} $period';
  }
}
