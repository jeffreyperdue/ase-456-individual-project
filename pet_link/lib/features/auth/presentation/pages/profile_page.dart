import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petfolio/features/auth/presentation/state/auth_provider.dart';
import 'package:petfolio/services/error_handler.dart';
import 'package:petfolio/app/utils/feedback_utils.dart';
import 'package:petfolio/app/widgets/loading_widgets.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(authProvider);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: userAsync.when(
        data: (user) {
          final displayName = user?.displayName ?? 'User';
          final email = user?.email ?? '';
          final photoUrl = user?.photoUrl;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundImage: photoUrl != null ? NetworkImage(photoUrl) : null,
                    child: photoUrl == null
                        ? Text(
                            (displayName.isNotEmpty ? displayName : email)
                                .substring(0, 1)
                                .toUpperCase(),
                          )
                        : null,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(displayName, style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 4),
                        Text(email, style: Theme.of(context).textTheme.bodySmall),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 12),
              ListTile(
                leading: const Icon(Icons.logout),
                title: const Text('Sign Out'),
                onTap: () async {
                  try {
                    await ref.read(authProvider.notifier).signOut();
                    if (context.mounted) {
                      FeedbackUtils.showSuccess(context, 'Signed out successfully');
                      Navigator.pushNamedAndRemoveUntil(context, '/', (_) => false);
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ErrorHandler.handleError(context, e);
                    }
                  }
                },
              ),
            ],
          );
        },
        loading: () => LoadingWidgets.circularProgress(),
        error: (e, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Failed to load profile: ${ErrorHandler.mapErrorToMessage(e)}'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.invalidate(authProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


