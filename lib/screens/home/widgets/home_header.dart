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
    final textTheme = Theme.of(context).textTheme;
    final completedTasks = tasks.where((t) => t.done).length;
    final totalTasks = tasks.length;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      child: Column(
        children: [
          // Top row with title and action buttons
          Row(
            children: [
              // App icon and title
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: colorScheme.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.check_circle_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "SmartScheduler",
                        style: textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onBackground,
                        ),
                      ),
                      Text(
                        "$completedTasks of $totalTasks completed",
                        style: textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onBackground.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const Spacer(),
              // Action buttons
              Row(
                children: [
                  _buildActionButton(
                    context,
                    icon: Icons.add_rounded,
                    onPressed: onAddEvent,
                    tooltip: 'Add Event',
                  ),
                  const SizedBox(width: 8),
                  _buildActionButton(
                    context,
                    icon: Icons.refresh_rounded,
                    onPressed: onRefresh,
                    tooltip: 'Refresh',
                  ),
                  const SizedBox(width: 8),
                  _buildActionButton(
                    context,
                    icon: Icons.list_rounded,
                    onPressed: onDebugAllEvents,
                    tooltip: 'Debug',
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Progress indicator
          if (tasks.isNotEmpty) ...[
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 6,
                    decoration: BoxDecoration(
                      color: colorScheme.outline.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(3),
                    ),
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: completedTasks / totalTasks,
                      child: Container(
                        decoration: BoxDecoration(
                          color: colorScheme.primary,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '${((completedTasks / totalTasks) * 100).round()}%',
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onBackground.withOpacity(0.6),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required VoidCallback onPressed,
    required String tooltip,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: colorScheme.outline.withOpacity(0.2),
          width: 0.5,
        ),
      ),
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(icon, size: 18, color: colorScheme.onSurface),
        tooltip: tooltip,
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(),
      ),
    );
  }
}
