import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petfolio/app/navigation_provider.dart';
import 'package:petfolio/features/auth/presentation/state/auth_provider.dart';

class UserAvatarAction extends ConsumerWidget {
  const UserAvatarAction({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(currentUserDataProvider);

    return IconButton(
      tooltip: 'Profile',
      onPressed: () {
        ref.read(navIndexProvider.notifier).setIndex(2);
      },
      icon: const Icon(Icons.person),
    );
  }
}


