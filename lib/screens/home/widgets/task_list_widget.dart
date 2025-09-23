import 'package:flutter/material.dart';
import '../../../models/task.dart';
import '../../../models/calendar_event.dart';

/// Task List Widget
/// Displays combined tasks and events in a unified list
class TaskListWidget extends StatelessWidget {
  final List<Task> tasks;
  final List<CalendarEvent> events;
  final Function(BuildContext, int) buildCombinedItem;
  final int Function() getCombinedItemCount;
  final Function(CalendarEvent) onEditEvent;
  final Function(CalendarEvent) onDeleteEvent;
  final Function(CalendarEvent, bool) onToggleEventCompletion;

  const TaskListWidget({
    super.key,
    required this.tasks,
    required this.events,
    required this.buildCombinedItem,
    required this.getCombinedItemCount,
    required this.onEditEvent,
    required this.onDeleteEvent,
    required this.onToggleEventCompletion,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (tasks.isEmpty && events.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.task_alt_outlined,
              size: 64,
              color: colorScheme.onSurfaceVariant.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              "No tasks or events yet",
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Tasks will appear automatically\nTap + to add events",
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant.withOpacity(0.7),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: getCombinedItemCount(),
      itemBuilder: (context, index) {
        return buildCombinedItem(context, index);
      },
    );
  }
}
