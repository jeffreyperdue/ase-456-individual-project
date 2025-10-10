import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/access_token.dart';
import '../../application/qr_code_service.dart';
import '../widgets/qr_code_widget.dart';

/// Screen for displaying and sharing QR codes for access tokens.
class QRCodeDisplayPage extends ConsumerWidget {
  final AccessToken token;

  const QRCodeDisplayPage({super.key, required this.token});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Share Pet Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () => _shareToken(context),
            tooltip: 'Share QR Code',
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Main QR Code Widget
            QRCodeWidget(
              token: token,
              size: 250,
              title: 'Pet Profile Access',
              subtitle:
                  'Scan this QR code to access ${token.role.displayName.toLowerCase()} information',
              onShare: () => _shareToken(context),
            ),

            const SizedBox(height: 16),

            // Token Details
            _buildTokenDetails(context),

            const SizedBox(height: 16),

            // Instructions
            _buildInstructions(context),
          ],
        ),
      ),
    );
  }

  Widget _buildTokenDetails(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Access Details',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),

            _buildDetailRow(
              context,
              'Access Level',
              '${token.role.icon} ${token.role.displayName}',
            ),

            _buildDetailRow(context, 'Description', token.accessDescription),

            _buildDetailRow(
              context,
              'Expires',
              _formatDateTime(token.expiresAt),
            ),

            _buildDetailRow(
              context,
              'Time Remaining',
              token.timeUntilExpiration,
              valueColor:
                  token.isExpired ? Theme.of(context).colorScheme.error : null,
            ),

            if (token.notes != null) ...[
              _buildDetailRow(context, 'Notes', token.notes!),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    BuildContext context,
    String label,
    String value, {
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: valueColor),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInstructions(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('How to Use', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),

            const InstructionStep(
              icon: Icons.qr_code_scanner,
              title: 'Scan QR Code',
              description: 'Use any QR code scanner app to scan the code above',
            ),

            const InstructionStep(
              icon: Icons.share,
              title: 'Share Link',
              description:
                  'Tap the Share button to send the access link via message or email',
            ),

            const InstructionStep(
              icon: Icons.schedule,
              title: 'Time Limited',
              description: 'Access expires automatically at the specified time',
            ),
          ],
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} at ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  void _shareToken(BuildContext context) {
    final qrService = QRCodeService();

    qrService
        .shareURL(
          token: token,
          subject: 'Pet Profile Access',
          text: 'Access ${token.role.displayName} information for this pet',
        )
        .catchError((error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to share: $error'),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        });
  }
}

/// Widget for displaying instruction steps.
class InstructionStep extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const InstructionStep({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: Theme.of(context).colorScheme.onPrimaryContainer,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
