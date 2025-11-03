import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petfolio/app/navigation_provider.dart';
import 'package:petfolio/features/pets/presentation/pages/home_page.dart';
import 'package:petfolio/features/care_plans/presentation/pages/care_dashboard_page.dart';
import 'package:petfolio/features/auth/presentation/pages/profile_page.dart';
import 'package:petfolio/app/widgets/user_avatar_action.dart';

class MainScaffold extends ConsumerWidget {
  const MainScaffold({super.key});

  static final List<Widget> _pages = [
    const HomePage(),
    const CareDashboardPage(),
    const ProfilePage(),
  ];

  static final List<_PageConfig> _pageConfigs = [
    const _PageConfig(title: 'Petfolio', showUserAvatar: true),
    const _PageConfig(title: 'Care', showUserAvatar: true),
    const _PageConfig(title: 'Profile', showUserAvatar: false),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(navIndexProvider);
    final pageConfig = _pageConfigs[currentIndex];

    return Scaffold(
      appBar: AppBar(
        title: Text(pageConfig.title),
        actions: pageConfig.showUserAvatar ? const [UserAvatarAction()] : null,
      ),
      body: SafeArea(
        child: IndexedStack(
          index: currentIndex,
          children: _pages,
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: (i) => ref.read(navIndexProvider.notifier).setIndex(i),
        destinations: [
          const NavigationDestination(icon: Icon(Icons.pets), label: 'Pets'),
          NavigationDestination(
            icon: Stack(
              clipBehavior: Clip.none,
              children: [
                const Icon(Icons.favorite),
                Positioned(
                  right: -2,
                  top: -2,
                  child: const _CareBadge(count: 0),
                ),
              ],
            ),
            label: 'Care',
          ),
          const NavigationDestination(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}

class _PageConfig {
  final String title;
  final bool showUserAvatar;

  const _PageConfig({
    required this.title,
    required this.showUserAvatar,
  });
}

class _CareBadge extends StatelessWidget {
  final int count;
  const _CareBadge({required this.count});

  @override
  Widget build(BuildContext context) {
    if (count <= 0) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.all(1.5),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.error,
        shape: BoxShape.circle,
      ),
      constraints: const BoxConstraints(minWidth: 12, minHeight: 12),
      child: Center(
        child: Text(
          count > 9 ? '9+' : '$count',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 8,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}


