import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../models/calendar_event.dart';

/// Day View Widget
/// Displays a single day with hourly timeline
class DayView extends StatelessWidget {
  final DateTime date;
  final List<CalendarEvent> events;
  final Function(CalendarEvent) onEventTap;
  final Function(DateTime) onTimeSlotTap;

  const DayView({
    super.key,
    required this.date,
    required this.events,
    required this.onEventTap,
    required this.onTimeSlotTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final now = DateTime.now();
    final isToday =
        date.year == now.year && date.month == now.month && date.day == now.day;
    final currentHour = now.hour;

    // Group events by hour
    final eventsByHour = <int, List<CalendarEvent>>{};
    for (final event in events) {
      final eventDate = event.startDate ?? event.date;
      if (eventDate.year == date.year &&
          eventDate.month == date.month &&
          eventDate.day == date.day) {
        final hour = event.startTime?.hour ?? eventDate.hour;
        eventsByHour.putIfAbsent(hour, () => []).add(event);
      }
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Date header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isToday
                  ? colorScheme.primaryContainer
                  : colorScheme.surfaceVariant,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      DateFormat('EEEE').format(date),
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isToday
                            ? colorScheme.onPrimaryContainer
                            : colorScheme.onSurfaceVariant,
                      ),
                    ),
                    Text(
                      DateFormat('MMMM d, y').format(date),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: isToday
                            ? colorScheme.onPrimaryContainer.withOpacity(0.7)
                            : colorScheme.onSurfaceVariant.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
                if (isToday)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: colorScheme.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Today',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: colorScheme.onPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          // Timeline
          Expanded(
            child: ListView.builder(
              itemCount: 24,
              itemBuilder: (context, index) {
                final hour = index;
                final hourEvents = eventsByHour[hour] ?? [];
                final isCurrentHour = isToday && hour == currentHour;

                return _buildHourRow(
                  context,
                  hour: hour,
                  events: hourEvents,
                  isCurrentHour: isCurrentHour,
                  colorScheme: colorScheme,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHourRow(
    BuildContext context, {
    required int hour,
    required List<CalendarEvent> events,
    required bool isCurrentHour,
    required ColorScheme colorScheme,
  }) {
    final hourText = hour == 0
        ? '12 AM'
        : hour < 12
        ? '$hour AM'
        : hour == 12
        ? '12 PM'
        : '${hour - 12} PM';

    return InkWell(
      onTap: () {
        final timeSlot = DateTime(date.year, date.month, date.day, hour);
        onTimeSlotTap(timeSlot);
      },
      child: Container(
        height: 80,
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: colorScheme.outline.withOpacity(0.1),
              width: 0.5,
            ),
          ),
          color: isCurrentHour
              ? colorScheme.primaryContainer.withOpacity(0.1)
              : null,
        ),
        child: Row(
          children: [
            // Hour label
            Container(
              width: 80,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Text(
                hourText,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: isCurrentHour
                      ? colorScheme.primary
                      : colorScheme.onSurfaceVariant,
                  fontWeight: isCurrentHour
                      ? FontWeight.bold
                      : FontWeight.normal,
                ),
              ),
            ),
            // Events
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: events.isEmpty
                    ? const SizedBox()
                    : ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: events.length,
                        itemBuilder: (context, index) {
                          final event = events[index];
                          return _buildEventChip(context, event, colorScheme);
                        },
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEventChip(
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

    return GestureDetector(
      onTap: () => onEventTap(event),
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        constraints: const BoxConstraints(minWidth: 120),
        decoration: BoxDecoration(
          color: event.color.withOpacity(0.2),
          border: Border.all(color: event.color, width: 2),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              event.title,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: event.color,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            if (timeText.isNotEmpty)
              Text(
                timeText,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: event.color.withOpacity(0.8),
                ),
              ),
          ],
        ),
      ),
    );
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
