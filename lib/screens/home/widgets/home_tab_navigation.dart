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
    final textTheme = Theme.of(context).textTheme;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.outline.withOpacity(0.2),
          width: 0.5,
        ),
      ),
      child: TabBar(
        controller: tabController,
        indicator: BoxDecoration(
          color: colorScheme.primary,
          borderRadius: BorderRadius.circular(10),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        indicatorPadding: const EdgeInsets.all(4),
        labelColor: Colors.white,
        unselectedLabelColor: colorScheme.onSurface.withOpacity(0.6),
        labelStyle: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
        unselectedLabelStyle: textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.w500,
        ),
        tabs: [
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.check_circle_outline_rounded, size: 16),
                const SizedBox(width: 6),
                Text('Tasks ($taskCount)'),
              ],
            ),
          ),
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.event_outlined, size: 16),
                const SizedBox(width: 6),
                Text('Events ($eventCount)'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
