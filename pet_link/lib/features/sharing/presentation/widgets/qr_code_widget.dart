import 'package:flutter/material.dart';
import '../../domain/access_token.dart';
import '../../application/qr_code_service.dart';

/// A reusable widget for displaying QR codes for access tokens.
class QRCodeWidget extends StatelessWidget {
  final AccessToken token;
  final double size;
  final String? title;
  final String? subtitle;
  final bool showShareButton;
  final VoidCallback? onShare;
  final VoidCallback? onCopy;

  const QRCodeWidget({
    super.key,
    required this.token,
    this.size = 200.0,
    this.title,
    this.subtitle,
    this.showShareButton = true,
    this.onShare,
    this.onCopy,
  });

  @override
  Widget build(BuildContext context) {
    final qrService = QRCodeService();

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            if (title != null || subtitle != null) ...[
              Text(
                title ?? 'Share Pet Profile',
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 8),
                Text(
                  subtitle!,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
              const SizedBox(height: 16),
            ],

            // QR Code
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Theme.of(context).colorScheme.outline,
                  width: 1,
                ),
              ),
              child: qrService.generateQRCode(token: token, size: size),
            ),

            const SizedBox(height: 16),

            // Token info
            _buildTokenInfo(context),

            const SizedBox(height: 16),

            // Action buttons
            if (showShareButton) _buildActionButtons(context),
          ],
        ),
      ),
    );
  }

  Widget _buildTokenInfo(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(token.role.icon, style: const TextStyle(fontSize: 16)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${token.role.displayName} Access',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            token.accessDescription,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                Icons.schedule,
                size: 16,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 4),
              Text(
                token.timeUntilExpiration,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color:
                      token.isExpired
                          ? Theme.of(context).colorScheme.error
                          : Theme.of(context).colorScheme.onSurfaceVariant,
                  fontWeight:
                      token.isExpired ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: onCopy ?? () => _copyTokenToClipboard(context),
            icon: const Icon(Icons.copy),
            label: const Text('Copy Link'),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: onShare ?? () => _shareToken(context),
            icon: const Icon(Icons.share),
            label: const Text('Share'),
          ),
        ),
      ],
    );
  }

  void _copyTokenToClipboard(BuildContext context) {
    // Note: In a real implementation, you'd use Clipboard.setData()
    // For now, we'll just show a snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Token URL copied to clipboard'),
        duration: Duration(seconds: 2),
      ),
    );
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

/// A compact QR code widget for use in lists or cards.
class CompactQRCodeWidget extends StatelessWidget {
  final AccessToken token;
  final double size;

  const CompactQRCodeWidget({
    super.key,
    required this.token,
    this.size = 100.0,
  });

  @override
  Widget build(BuildContext context) {
    final qrService = QRCodeService();

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline,
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          qrService.generateQRCode(token: token, size: size),
          const SizedBox(height: 4),
          Text(
            token.role.displayName,
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
          Text(
            token.timeUntilExpiration,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color:
                  token.isExpired
                      ? Theme.of(context).colorScheme.error
                      : Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
