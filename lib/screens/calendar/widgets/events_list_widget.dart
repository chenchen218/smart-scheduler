import 'package:flutter/material.dart';
import '../../../models/calendar_event.dart';
import '../../../widgets/event_card.dart';

/// Events List Widget
/// Displays the list of events for the selected day
class EventsListWidget extends StatelessWidget {
  final List<CalendarEvent> events;
  final Function(CalendarEvent) onEventTap;
  final Function(CalendarEvent) onEditEvent;
  final Function(CalendarEvent) onDeleteEvent;

  const EventsListWidget({
    super.key,
    required this.events,
    required this.onEventTap,
    required this.onEditEvent,
    required this.onDeleteEvent,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: events.isEmpty
          ? SingleChildScrollView(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
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
                        "No events",
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
                    ],
                  ),
                ),
              ),
            )
          : ListView.builder(
              itemCount: events.length,
              itemBuilder: (context, index) {
                return EventCard(
                  event: events[index],
                  onTap: () => onEventTap(events[index]),
                  onEdit: () => onEditEvent(events[index]),
                  onDelete: () => onDeleteEvent(events[index]),
                );
              },
            ),
    );
  }
}
