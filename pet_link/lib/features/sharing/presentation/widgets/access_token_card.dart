import 'package:flutter/material.dart';
import '../../domain/access_token.dart';

/// Card widget for displaying access token information.
class AccessTokenCard extends StatelessWidget {
  final AccessToken token;
  final VoidCallback? onViewQR;
  final VoidCallback? onManage;
  final VoidCallback? onDelete;

  const AccessTokenCard({
    super.key,
    required this.token,
    this.onViewQR,
    this.onManage,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with role and status
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _getRoleColor(context).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    token.role.icon,
                    style: const TextStyle(fontSize: 20),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        token.role.displayName,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      Text(
                        token.accessDescription,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                _buildStatusIndicator(context),
              ],
            ),

            const SizedBox(height: 12),

            // Expiration info
            Row(
              children: [
                Icon(
                  Icons.schedule,
                  size: 16,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 4),
                Text(
                  'Expires ${token.timeUntilExpiration}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color:
                        token.isExpired
                            ? Theme.of(context).colorScheme.error
                            : Theme.of(context).colorScheme.onSurfaceVariant,
                    fontWeight:
                        token.isExpired ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ],
            ),

            if (token.notes != null) ...[
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.note,
                    size: 16,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      token.notes!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ),
            ],

            if (token.contactInfo != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.contact_phone,
                    size: 16,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      token.contactInfo!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ],

            const SizedBox(height: 16),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onViewQR,
                    icon: const Icon(Icons.qr_code, size: 16),
                    label: const Text('QR Code'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onManage,
                    icon: const Icon(Icons.edit, size: 16),
                    label: const Text('Manage'),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: onDelete,
                  icon: Icon(
                    Icons.delete_outline,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  tooltip: 'Delete handoff',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusIndicator(BuildContext context) {
    Color statusColor;
    IconData statusIcon;
    String statusText;

    if (!token.isActive) {
      statusColor = Theme.of(context).colorScheme.error;
      statusIcon = Icons.block;
      statusText = 'Inactive';
    } else if (token.isExpired) {
      statusColor = Theme.of(context).colorScheme.error;
      statusIcon = Icons.schedule;
      statusText = 'Expired';
    } else {
      statusColor = Theme.of(context).colorScheme.primary;
      statusIcon = Icons.check_circle;
      statusText = 'Active';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: statusColor.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(statusIcon, size: 12, color: statusColor),
          const SizedBox(width: 4),
          Text(
            statusText,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: statusColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Color _getRoleColor(BuildContext context) {
    switch (token.role) {
      case AccessRole.viewer:
        return Theme.of(context).colorScheme.primary;
      case AccessRole.sitter:
        return Theme.of(context).colorScheme.secondary;
      case AccessRole.coCaretaker:
        return Theme.of(context).colorScheme.tertiary;
    }
  }
}
