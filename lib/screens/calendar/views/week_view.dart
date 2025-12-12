import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../models/calendar_event.dart';

/// Week View Widget
/// Displays a 7-day grid with events
class WeekView extends StatelessWidget {
  final DateTime startOfWeek;
  final List<CalendarEvent> events;
  final Function(CalendarEvent) onEventTap;
  final Function(DateTime) onDayTap;

  const WeekView({
    super.key,
    required this.startOfWeek,
    required this.events,
    required this.onEventTap,
    required this.onDayTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Generate list of days in the week
    final days = List.generate(7, (index) {
      return startOfWeek.add(Duration(days: index));
    });

    // Group events by day
    final eventsByDay = <DateTime, List<CalendarEvent>>{};
    for (final event in events) {
      final eventDate = event.startDate ?? event.date;
      final dayKey = DateTime(eventDate.year, eventDate.month, eventDate.day);
      eventsByDay.putIfAbsent(dayKey, () => []).add(event);
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
          // Week header with day names
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: colorScheme.surfaceVariant,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                // Time column header
                SizedBox(
                  width: 60,
                  child: Center(
                    child: Text(
                      'Time',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ),
                // Day headers
                ...days.map((day) {
                  final isToday =
                      day.year == today.year &&
                      day.month == today.month &&
                      day.day == today.day;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => onDayTap(day),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: isToday
                              ? colorScheme.primaryContainer
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          children: [
                            Text(
                              DateFormat('E').format(day),
                              style: Theme.of(context).textTheme.labelSmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: isToday
                                        ? colorScheme.onPrimaryContainer
                                        : colorScheme.onSurfaceVariant,
                                  ),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: isToday
                                    ? colorScheme.primary
                                    : Colors.transparent,
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  '${day.day}',
                                  style: Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(
                                        fontWeight: isToday
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                        color: isToday
                                            ? colorScheme.onPrimary
                                            : colorScheme.onSurface,
                                      ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
          // Week grid with hourly rows
          Expanded(
            child: ListView.builder(
              itemCount: 24,
              itemBuilder: (context, hourIndex) {
                final hour = hourIndex;
                return _buildHourRow(
                  context,
                  hour: hour,
                  days: days,
                  eventsByDay: eventsByDay,
                  today: today,
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
    required List<DateTime> days,
    required Map<DateTime, List<CalendarEvent>> eventsByDay,
    required DateTime today,
    required ColorScheme colorScheme,
  }) {
    final hourText = hour == 0
        ? '12 AM'
        : hour < 12
        ? '$hour AM'
        : hour == 12
        ? '12 PM'
        : '${hour - 12} PM';

    return Container(
      height: 60,
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: colorScheme.outline.withOpacity(0.1),
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        children: [
          // Hour label
          SizedBox(
            width: 60,
            child: Center(
              child: Text(
                hourText,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ),
          // Day columns
          ...days.map((day) {
            final dayKey = DateTime(day.year, day.month, day.day);
            final dayEvents = eventsByDay[dayKey] ?? [];
            final hourEvents = dayEvents.where((event) {
              final eventDate = event.startDate ?? event.date;
              final eventHour = event.startTime?.hour ?? eventDate.hour;
              return eventHour == hour;
            }).toList();

            return Expanded(
              child: Container(
                decoration: BoxDecoration(
                  border: Border(
                    right: BorderSide(
                      color: colorScheme.outline.withOpacity(0.1),
                      width: 0.5,
                    ),
                  ),
                ),
                child: hourEvents.isEmpty
                    ? const SizedBox()
                    : ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: hourEvents.length,
                        itemBuilder: (context, index) {
                          final event = hourEvents[index];
                          return GestureDetector(
                            onTap: () => onEventTap(event),
                            child: Container(
                              margin: const EdgeInsets.all(2),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4,
                                vertical: 2,
                              ),
                              constraints: const BoxConstraints(minWidth: 40),
                              decoration: BoxDecoration(
                                color: event.color.withOpacity(0.3),
                                border: Border.all(
                                  color: event.color,
                                  width: 1,
                                ),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Center(
                                child: Text(
                                  event.title,
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(
                                        color: event.color,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
