import 'package:flutter/material.dart';
import '../../../models/calendar_event.dart';
import '../../../widgets/event_card.dart';

/// Event List Widget
/// Displays events in an animated list with swipe-to-delete functionality
class EventListWidget extends StatelessWidget {
  final List<CalendarEvent> events;
  final Function(CalendarEvent) onEditEvent;
  final Function(CalendarEvent) onDeleteEvent;
  final Function(CalendarEvent, bool) onToggleEventCompletion;

  const EventListWidget({
    super.key,
    required this.events,
    required this.onEditEvent,
    required this.onDeleteEvent,
    required this.onToggleEventCompletion,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (events.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.event_available_outlined,
              size: 64,
              color: colorScheme.onSurfaceVariant.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              "No events today",
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Tap + to add an event",
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              "Debug: Events loaded: ${events.length}",
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant.withOpacity(0.5),
              ),
            ),
          ],
        ),
      );
    }

    return AnimatedList(
      initialItemCount: events.length,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemBuilder: (context, index, animation) {
        final event = events[index];
        return SlideTransition(
          position: animation.drive(
            Tween<Offset>(
              begin: const Offset(1, 0),
              end: Offset.zero,
            ).chain(CurveTween(curve: Curves.easeOutCubic)),
          ),
          child: FadeTransition(
            opacity: animation,
            child: Dismissible(
              key: Key('event_${event.id}'),
              background: Container(
                margin: const EdgeInsets.symmetric(vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.red.shade400,
                  borderRadius: BorderRadius.circular(16),
                ),
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.only(left: 20),
                child: const Icon(
                  Icons.delete_rounded,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              onDismissed: (_) => onDeleteEvent(event),
              child: EventCard(
                event: event,
                onTap: () {
                  // Show event details
                },
                onEdit: () => onEditEvent(event),
                onDelete: () => onDeleteEvent(event),
                onToggle: (isCompleted) =>
                    onToggleEventCompletion(event, isCompleted),
              ),
            ),
          ),
        );
      },
    );
  }
}
