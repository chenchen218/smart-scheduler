import 'package:flutter/material.dart';

/// Home Tab Navigation Widget
/// Displays tab bar for switching between Tasks and Events
class HomeTabNavigation extends StatelessWidget {
  final TabController tabController;
  final int taskCount;
  final int eventCount;

  const HomeTabNavigation({
    super.key,
    required this.tabController,
    required this.taskCount,
    required this.eventCount,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TabBar(
        controller: tabController,
        indicator: BoxDecoration(
          color: colorScheme.primary,
          borderRadius: BorderRadius.circular(12),
        ),
        labelColor: colorScheme.onPrimary,
        unselectedLabelColor: colorScheme.onSurfaceVariant,
        tabs: [
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.task_alt_rounded, size: 18),
                const SizedBox(width: 8),
                Text('Tasks ($taskCount)'),
              ],
            ),
          ),
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.event_rounded, size: 18),
                const SizedBox(width: 8),
                Text('Today\'s Events ($eventCount)'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
