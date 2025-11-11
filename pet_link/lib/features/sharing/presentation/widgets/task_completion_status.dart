import 'package:flutter/material.dart';
import '../../domain/task_completion.dart';

/// Widget to display task completion status with timestamp and user info.
class TaskCompletionStatus extends StatelessWidget {
  final TaskCompletion? completion;
  final String? completedByDisplayName;

  const TaskCompletionStatus({
    super.key,
    this.completion,
    this.completedByDisplayName,
  });

  @override
  Widget build(BuildContext context) {
    if (completion == null) {
      return const SizedBox.shrink();
    }

    return Row(
      children: [
        Icon(
          Icons.check_circle,
          size: 16,
          color: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            _getCompletionText(context),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }

  String _getCompletionText(BuildContext context) {
    final completedAt = completion!.completedAt;
    final now = DateTime.now();
    final difference = now.difference(completedAt);

    String timeText;
    if (difference.inDays > 0) {
      timeText = '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
    } else if (difference.inHours > 0) {
      timeText = '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
    } else if (difference.inMinutes > 0) {
      timeText = '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago';
    } else {
      timeText = 'just now';
    }

    if (completedByDisplayName != null) {
      return 'Completed by $completedByDisplayName $timeText';
    }

    return 'Completed $timeText';
  }
}

/// Format a DateTime as a relative time string (e.g., "2 hours ago").
String formatRelativeTime(DateTime dateTime) {
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

/// Format a DateTime as a readable string.
String formatDateTime(DateTime dateTime) {
  // Format: "Jan 1, 2024 • 2:30 PM"
  final monthNames = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ];
  final month = monthNames[dateTime.month - 1];
  final day = dateTime.day;
  final year = dateTime.year;
  
  final hour = dateTime.hour;
  final minute = dateTime.minute;
  final period = hour >= 12 ? 'PM' : 'AM';
  final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
  final minuteStr = minute.toString().padLeft(2, '0');
  
  return '$month $day, $year • $displayHour:$minuteStr $period';
}

