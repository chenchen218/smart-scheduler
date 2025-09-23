import 'package:flutter/material.dart';
import '../../../models/task.dart';

/// Home Header Widget
/// Displays app title, progress bar, and action buttons
class HomeHeader extends StatelessWidget {
  final List<Task> tasks;
  final VoidCallback onAddEvent;
  final VoidCallback onRefresh;
  final VoidCallback onDebugAllEvents;

  const HomeHeader({
    super.key,
    required this.tasks,
    required this.onAddEvent,
    required this.onRefresh,
    required this.onDebugAllEvents,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final completedTasks = tasks.where((t) => t.done).length;
    final totalTasks = tasks.length;

    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colorScheme.primary,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  Icons.task_alt_rounded,
                  color: colorScheme.onPrimary,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Auto To-Do Demo",
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                          ),
                    ),
                    Text(
                      "$completedTasks of $totalTasks completed",
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              // Add Event Button
              IconButton(
                onPressed: onAddEvent,
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: colorScheme.secondary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.event_rounded,
                    color: colorScheme.onSecondary,
                    size: 20,
                  ),
                ),
                tooltip: 'Add Event',
              ),
              // Refresh Button (for debugging)
              IconButton(
                onPressed: onRefresh,
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: colorScheme.tertiary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.refresh_rounded,
                    color: colorScheme.onTertiary,
                    size: 20,
                  ),
                ),
                tooltip: 'Refresh Events',
              ),
              // Debug All Events Button
              IconButton(
                onPressed: onDebugAllEvents,
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.purple,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.list_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                tooltip: 'Debug All Events',
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Progress Bar
          if (tasks.isNotEmpty)
            Container(
              height: 8,
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(4),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: tasks.isEmpty ? 0 : completedTasks / totalTasks,
                child: Container(
                  decoration: BoxDecoration(
                    color: colorScheme.primary,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
