import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../pets/domain/pet.dart';
import '../../domain/access_token.dart';
import '../../application/qr_code_provider.dart';
import '../../application/create_access_token_use_case.dart';
import '../../application/manage_access_token_use_case.dart';
import '../../data/access_token_repository_impl.dart';
import '../widgets/handoff_form.dart';
import '../widgets/access_token_card.dart';
import '../pages/qr_code_display_page.dart';
import '../../../auth/presentation/state/auth_provider.dart';

/// Screen for creating and managing pet handoffs (access tokens).
class SharePetPage extends ConsumerStatefulWidget {
  final Pet pet;

  const SharePetPage({super.key, required this.pet});

  @override
  ConsumerState<SharePetPage> createState() => _SharePetPageState();
}

class _SharePetPageState extends ConsumerState<SharePetPage> {
  final _formKey = GlobalKey<FormState>();
  AccessRole _selectedRole = AccessRole.viewer;
  DateTime _expirationDate = DateTime.now().add(const Duration(days: 7));
  String _notes = '';
  String _contactInfo = '';
  String _recipientUserId = '';
  bool _isCreating = false;

  @override
  Widget build(BuildContext context) {
    final accessTokensAsync = ref.watch(petAccessTokensProvider(widget.pet.id));

    return Scaffold(
      appBar: AppBar(
        title: Text('Share ${widget.pet.name}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code),
            onPressed: () => _showQRCode(context),
            tooltip: 'Show QR Code',
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Pet info header
            _buildPetHeader(context),

            const SizedBox(height: 16),

            // Create new handoff form
            _buildCreateHandoffForm(context),

            const SizedBox(height: 16),

            // Existing access tokens
            _buildExistingTokens(context, accessTokensAsync),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildPetHeader(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Theme.of(context).colorScheme.surfaceVariant,
            ),
            child:
                widget.pet.photoUrl != null
                    ? ClipOval(
                      child: Image.network(
                        widget.pet.photoUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(
                            Icons.pets,
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          );
                        },
                      ),
                    )
                    : Icon(
                      Icons.pets,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.pet.name,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                Text(
                  '${widget.pet.breed ?? widget.pet.species}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
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

  Widget _buildCreateHandoffForm(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Create New Handoff',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),

            HandoffForm(
              formKey: _formKey,
              selectedRole: _selectedRole,
              expirationDate: _expirationDate,
              notes: _notes,
              contactInfo: _contactInfo,
              recipientUserId: _recipientUserId,
              onRoleChanged: (role) => setState(() => _selectedRole = role),
              onExpirationChanged:
                  (date) => setState(() => _expirationDate = date),
              onNotesChanged: (notes) => setState(() => _notes = notes),
              onContactInfoChanged:
                  (contact) => setState(() => _contactInfo = contact),
              onRecipientUserIdChanged:
                  (userId) => setState(() => _recipientUserId = userId),
            ),

            const SizedBox(height: 16),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isCreating ? null : _createHandoff,
                icon:
                    _isCreating
                        ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                        : const Icon(Icons.share),
                label: Text(_isCreating ? 'Creating...' : 'Create Handoff'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExistingTokens(
    BuildContext context,
    AsyncValue<List<AccessToken>> accessTokensAsync,
  ) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Active Handoffs',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),

            accessTokensAsync.when(
              data: (tokens) {
                if (tokens.isEmpty) {
                  return Container(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      children: [
                        Icon(
                          Icons.share_outlined,
                          size: 48,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No active handoffs',
                          style: Theme.of(
                            context,
                          ).textTheme.titleMedium?.copyWith(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Create a handoff to share access to ${widget.pet.name}\'s profile.',
                          style: Theme.of(
                            context,
                          ).textTheme.bodyMedium?.copyWith(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }

                return Column(
                  children:
                      tokens.map((token) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: AccessTokenCard(
                            token: token,
                            onViewQR: () => _showTokenQRCode(context, token),
                            onManage: () => _manageToken(context, token),
                            onDelete: () => _deleteToken(context, token),
                          ),
                        );
                      }).toList(),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error:
                  (error, stack) => Container(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      'Error loading tokens: $error',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _createHandoff() async {
    if (!_formKey.currentState!.validate()) return;

    final firebaseUserAsync = ref.read(firebaseUserProvider);
    final firebaseUser = firebaseUserAsync.value;

    if (firebaseUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please sign in to create handoffs')),
      );
      return;
    }

    setState(() => _isCreating = true);

    try {
      final repository = AccessTokenRepositoryImpl();
      final createUseCase = CreateAccessTokenUseCase(repository);

      final token = await createUseCase.execute(
        petId: widget.pet.id,
        grantedBy: firebaseUser.uid,
        role: _selectedRole,
        expiresAt: _expirationDate,
        notes: _notes.isEmpty ? null : _notes,
        grantedTo: _recipientUserId.isEmpty ? null : _recipientUserId,
        contactInfo: _contactInfo.isEmpty ? null : _contactInfo,
      );

      // Refresh the tokens list
      ref.invalidate(petAccessTokensProvider(widget.pet.id));

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Handoff created successfully'),
            action: SnackBarAction(
              label: 'View QR',
              onPressed: () => _showTokenQRCode(context, token),
            ),
          ),
        );
      }

      // Reset form
      setState(() {
        _selectedRole = AccessRole.viewer;
        _expirationDate = DateTime.now().add(const Duration(days: 7));
        _notes = '';
        _contactInfo = '';
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to create handoff: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isCreating = false);
      }
    }
  }

  void _showQRCode(BuildContext context) {
    // Create a temporary viewer token for QR display
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('QR Code'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Generate a QR code to share ${widget.pet.name}\'s profile',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _createQuickQRToken();
                  },
                  child: const Text('Generate QR Code'),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
            ],
          ),
    );
  }

  Future<void> _createQuickQRToken() async {
    try {
      final repository = AccessTokenRepositoryImpl();
      final createUseCase = CreateAccessTokenUseCase(repository);

      final token = await createUseCase.execute(
        petId: widget.pet.id,
        grantedBy: widget.pet.ownerId,
        role: AccessRole.viewer,
        expiresAt: DateTime.now().add(const Duration(days: 7)),
        notes: 'QR Code sharing access',
      );

      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => QRCodeDisplayPage(token: token),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to generate QR code: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  void _showTokenQRCode(BuildContext context, AccessToken token) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => QRCodeDisplayPage(token: token)),
    );
  }

  void _manageToken(BuildContext context, AccessToken token) {
    // TODO: Implement token management dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Token management coming soon')),
    );
  }

  Future<void> _deleteToken(BuildContext context, AccessToken token) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Handoff'),
            content: Text(
              'Are you sure you want to delete this ${token.role.displayName.toLowerCase()} handoff? This will revoke access immediately.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                style: TextButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.error,
                ),
                child: const Text('Delete'),
              ),
            ],
          ),
    );

    if (confirmed == true) {
      try {
        final repository = AccessTokenRepositoryImpl();
        final manageUseCase = ManageAccessTokenUseCase(repository);

        await manageUseCase.deleteToken(token.id);

        // Refresh the tokens list
        ref.invalidate(petAccessTokensProvider(widget.pet.id));

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Handoff deleted successfully')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to delete handoff: $e'),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      }
    }
  }
}
