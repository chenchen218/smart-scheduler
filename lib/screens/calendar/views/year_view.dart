import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../models/calendar_event.dart';

/// Year View Widget
/// Displays a 12-month overview
class YearView extends StatelessWidget {
  final int year;
  final List<CalendarEvent> events;
  final Function(DateTime) onMonthTap;
  final Function(CalendarEvent) onEventTap;

  const YearView({
    super.key,
    required this.year,
    required this.events,
    required this.onMonthTap,
    required this.onEventTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final now = DateTime.now();
    final currentYear = now.year;

    // Group events by month
    final eventsByMonth = <int, List<CalendarEvent>>{};
    for (final event in events) {
      final eventDate = event.startDate ?? event.date;
      if (eventDate.year == year) {
        eventsByMonth.putIfAbsent(eventDate.month, () => []).add(event);
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
          // Year header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: year == currentYear
                  ? colorScheme.primaryContainer
                  : colorScheme.surfaceVariant,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '$year',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: year == currentYear
                        ? colorScheme.onPrimaryContainer
                        : colorScheme.onSurfaceVariant,
                  ),
                ),
                if (year == currentYear) ...[
                  const SizedBox(width: 12),
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
                      'Current Year',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: colorScheme.onPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          // Months grid
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.2,
              ),
              itemCount: 12,
              itemBuilder: (context, index) {
                final month = index + 1;
                final monthEvents = eventsByMonth[month] ?? [];
                final isCurrentMonth =
                    year == currentYear && month == now.month;

                return _buildMonthCard(
                  context,
                  year: year,
                  month: month,
                  events: monthEvents,
                  isCurrentMonth: isCurrentMonth,
                  colorScheme: colorScheme,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthCard(
    BuildContext context, {
    required int year,
    required int month,
    required List<CalendarEvent> events,
    required bool isCurrentMonth,
    required ColorScheme colorScheme,
  }) {
    final monthDate = DateTime(year, month, 1);
    final monthName = DateFormat('MMMM').format(monthDate);
    final daysInMonth = DateTime(year, month + 1, 0).day;
    final firstDayOfWeek = monthDate.weekday;

    return Card(
      elevation: isCurrentMonth ? 4 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isCurrentMonth
            ? BorderSide(color: colorScheme.primary, width: 2)
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: () => onMonthTap(monthDate),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isCurrentMonth
                ? colorScheme.primaryContainer.withOpacity(0.3)
                : colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Month name
              Text(
                monthName,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isCurrentMonth
                      ? colorScheme.primary
                      : colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              // Mini calendar grid
              Expanded(
                child: GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 7,
                    crossAxisSpacing: 2,
                    mainAxisSpacing: 2,
                  ),
                  itemCount: firstDayOfWeek - 1 + daysInMonth,
                  itemBuilder: (context, index) {
                    if (index < firstDayOfWeek - 1) {
                      return const SizedBox();
                    }
                    final day = index - (firstDayOfWeek - 1) + 1;
                    final hasEvents = events.any((event) {
                      final eventDate = event.startDate ?? event.date;
                      return eventDate.year == year &&
                          eventDate.month == month &&
                          eventDate.day == day;
                    });
                    final isToday = isCurrentMonth && day == DateTime.now().day;

                    return Container(
                      decoration: BoxDecoration(
                        color: isToday
                            ? colorScheme.primary
                            : hasEvents
                            ? colorScheme.secondary.withOpacity(0.3)
                            : null,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '$day',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: isToday
                                    ? colorScheme.onPrimary
                                    : hasEvents
                                    ? colorScheme.onSurface
                                    : colorScheme.onSurfaceVariant,
                                fontWeight: isToday || hasEvents
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                fontSize: 10,
                              ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              // Event count
              if (events.isNotEmpty)
                Container(
                  margin: const EdgeInsets.only(top: 4),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.secondaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${events.length} ${events.length == 1 ? 'event' : 'events'}',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: colorScheme.onSecondaryContainer,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
