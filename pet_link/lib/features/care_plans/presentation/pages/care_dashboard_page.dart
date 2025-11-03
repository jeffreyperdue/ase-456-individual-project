import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petfolio/features/care_plans/presentation/widgets/care_plan_dashboard.dart';
import 'package:petfolio/app/navigation_provider.dart';

class CareDashboardPage extends ConsumerWidget {
  const CareDashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Stack(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Expanded(child: CarePlanDashboard()),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ActionChip(
                    avatar: const Icon(Icons.today, size: 18),
                    label: const Text("Today's Tasks"),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Today's Tasks coming in Week 8 (real-time sync).")),
                      );
                    },
                  ),
                  ActionChip(
                    avatar: const Icon(Icons.edit, size: 18),
                    label: const Text('Add Care Plan'),
                    onPressed: () {
                      Navigator.pushNamed(context, '/edit');
                    },
                  ),
                  ActionChip(
                    avatar: const Icon(Icons.pets, size: 18),
                    label: const Text('Manage Pets'),
                    onPressed: () {
                      ref.read(navIndexProvider.notifier).setIndex(0);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
        Positioned(
          bottom: 16,
          right: 16,
          child: FloatingActionButton.extended(
            icon: const Icon(Icons.today),
            label: const Text("Today's Tasks"),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Today's Tasks coming in Week 8 (real-time sync).")),
              );
            },
          ),
        ),
      ],
    );
  }
}


