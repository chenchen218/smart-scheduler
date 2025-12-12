import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../models/calendar_event.dart';

/// Agenda View Widget
/// Displays a chronological list of events
class AgendaView extends StatelessWidget {
  final List<CalendarEvent> events;
  final Function(CalendarEvent) onEventTap;

  const AgendaView({super.key, required this.events, required this.onEventTap});

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
              'No upcoming events',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    // Group events by date
    final eventsByDate = <DateTime, List<CalendarEvent>>{};
    for (final event in events) {
      final eventDate = event.startDate ?? event.date;
      final dayKey = DateTime(eventDate.year, eventDate.month, eventDate.day);
      eventsByDate.putIfAbsent(dayKey, () => []).add(event);
    }

    final sortedDates = eventsByDate.keys.toList()
      ..sort((a, b) => a.compareTo(b));

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: sortedDates.length,
      itemBuilder: (context, index) {
        final date = sortedDates[index];
        final dateEvents = eventsByDate[date]!;
        final isToday = _isToday(date);
        final isTomorrow = _isTomorrow(date);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date header
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              margin: EdgeInsets.only(top: index > 0 ? 16 : 0),
              decoration: BoxDecoration(
                color: isToday
                    ? colorScheme.primaryContainer
                    : colorScheme.surfaceVariant,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getDateLabel(date, isToday, isTomorrow),
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: isToday
                                  ? colorScheme.onPrimaryContainer
                                  : colorScheme.onSurfaceVariant,
                            ),
                      ),
                      Text(
                        DateFormat('EEEE, MMMM d').format(date),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: isToday
                              ? colorScheme.onPrimaryContainer.withOpacity(0.7)
                              : colorScheme.onSurfaceVariant.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: isToday
                          ? colorScheme.primary
                          : colorScheme.surface,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${dateEvents.length}',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: isToday
                            ? colorScheme.onPrimary
                            : colorScheme.onSurface,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            // Events for this date
            ...dateEvents.map((event) {
              return _buildEventCard(context, event, colorScheme);
            }),
          ],
        );
      },
    );
  }

  Widget _buildEventCard(
    BuildContext context,
    CalendarEvent event,
    ColorScheme colorScheme,
  ) {
    final startTime = event.startTime;
    final endTime = event.endTime;
    String timeText = '';
    if (startTime != null) {
      if (endTime != null) {
        timeText = '${_formatTime(startTime)} - ${_formatTime(endTime)}';
      } else {
        timeText = _formatTime(startTime);
      }
    } else if (event.isAllDay) {
      timeText = 'All Day';
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: event.color.withOpacity(0.3), width: 1),
      ),
      child: InkWell(
        onTap: () => onEventTap(event),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Color indicator
              Container(
                width: 4,
                height: 60,
                decoration: BoxDecoration(
                  color: event.color,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 16),
              // Event details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            event.title,
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  decoration: event.isCompleted
                                      ? TextDecoration.lineThrough
                                      : null,
                                ),
                          ),
                        ),
                        if (event.priority == 'High')
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'High',
                              style: Theme.of(context).textTheme.labelSmall
                                  ?.copyWith(
                                    color: Colors.red,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ),
                      ],
                    ),
                    if (timeText.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            size: 14,
                            color: colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            timeText,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: colorScheme.onSurfaceVariant),
                          ),
                        ],
                      ),
                    ],
                    if (event.location != null &&
                        event.location!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            size: 14,
                            color: colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              event.location!,
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                    if (event.tags.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 4,
                        runSpacing: 4,
                        children: event.tags.map((tag) {
                          return Chip(
                            label: Text(tag),
                            backgroundColor: event.color.withOpacity(0.1),
                            labelStyle: TextStyle(
                              color: event.color,
                              fontSize: 10,
                            ),
                            padding: EdgeInsets.zero,
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                            visualDensity: VisualDensity.compact,
                          );
                        }).toList(),
                      ),
                    ],
                  ],
                ),
              ),
              // Completion indicator
              if (event.isCompleted)
                Icon(Icons.check_circle, color: colorScheme.primary),
            ],
          ),
        ),
      ),
    );
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  bool _isTomorrow(DateTime date) {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return date.year == tomorrow.year &&
        date.month == tomorrow.month &&
        date.day == tomorrow.day;
  }

  String _getDateLabel(DateTime date, bool isToday, bool isTomorrow) {
    if (isToday) return 'Today';
    if (isTomorrow) return 'Tomorrow';
    return DateFormat('MMMM d').format(date);
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hour == 0
        ? 12
        : time.hour > 12
        ? time.hour - 12
        : time.hour;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.hour < 12 ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }
}
