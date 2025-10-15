import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../models/calendar_event.dart';

/// Calendar Widget
/// Displays the TableCalendar with custom styling
class CalendarWidget extends StatelessWidget {
  final DateTime focusedDay;
  final DateTime? selectedDay;
  final CalendarFormat calendarFormat;
  final RangeSelectionMode rangeSelectionMode;
  final DateTime? rangeStart;
  final DateTime? rangeEnd;
  final List<CalendarEvent> Function(DateTime) eventLoader;
  final Function(DateTime, DateTime) onDaySelected;
  final Function(DateTime?, DateTime?, DateTime) onRangeSelected;
  final Function(CalendarFormat) onFormatChanged;
  final Function(DateTime) onPageChanged;

  const CalendarWidget({
    super.key,
    required this.focusedDay,
    required this.selectedDay,
    required this.calendarFormat,
    required this.rangeSelectionMode,
    required this.rangeStart,
    required this.rangeEnd,
    required this.eventLoader,
    required this.onDaySelected,
    required this.onRangeSelected,
    required this.onFormatChanged,
    required this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

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
      child: TableCalendar<CalendarEvent>(
        firstDay: DateTime.utc(2020, 1, 1),
        lastDay: DateTime.utc(2030, 12, 31),
        focusedDay: focusedDay,
        calendarFormat: calendarFormat,
        eventLoader: eventLoader,
        startingDayOfWeek: StartingDayOfWeek.monday,
        calendarStyle: CalendarStyle(
          outsideDaysVisible: false,
          weekendTextStyle: TextStyle(
            color: colorScheme.primary,
            fontWeight: FontWeight.w600,
          ),
          defaultTextStyle: TextStyle(
            color: colorScheme.onSurface,
            fontSize: 16,
          ),
          selectedTextStyle: TextStyle(
            color: colorScheme.onPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
          todayTextStyle: TextStyle(
            color: colorScheme.primary,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
          // Enhanced selected date styling with multiple effects
          selectedDecoration: BoxDecoration(
            color: colorScheme.primary,
            shape: BoxShape.circle,
            border: Border.all(color: colorScheme.primary, width: 3),
            boxShadow: [
              BoxShadow(
                color: colorScheme.primary.withOpacity(0.5),
                blurRadius: 12,
                offset: const Offset(0, 4),
                spreadRadius: 2,
              ),
            ],
          ),
          // Today's date styling
          todayDecoration: BoxDecoration(
            color: colorScheme.primary.withOpacity(0.3),
            shape: BoxShape.circle,
            border: Border.all(color: colorScheme.primary, width: 2),
            boxShadow: [
              BoxShadow(
                color: colorScheme.primary.withOpacity(0.3),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          // Event markers with better visibility
          markerDecoration: BoxDecoration(
            color: colorScheme.secondary,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: colorScheme.secondary.withOpacity(0.3),
                blurRadius: 4,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          markersMaxCount: 3,
          markerSize: 8,
          // Hover/selection effects
          cellMargin: const EdgeInsets.all(4),
          cellPadding: const EdgeInsets.all(8),
        ),
        headerStyle: HeaderStyle(
          formatButtonVisible: true,
          titleCentered: true,
          formatButtonShowsNext: false,
          formatButtonDecoration: BoxDecoration(
            color: colorScheme.primary,
            borderRadius: BorderRadius.circular(12),
          ),
          formatButtonTextStyle: TextStyle(
            color: colorScheme.onPrimary,
            fontWeight: FontWeight.w600,
          ),
          leftChevronIcon: Icon(
            Icons.chevron_left_rounded,
            color: colorScheme.primary,
          ),
          rightChevronIcon: Icon(
            Icons.chevron_right_rounded,
            color: colorScheme.primary,
          ),
        ),
        onDaySelected: (selectedDay, focusedDay) {
          // Add haptic feedback for better user experience
          HapticFeedback.lightImpact();
          onDaySelected(selectedDay, focusedDay);
        },
        onRangeSelected: onRangeSelected,
        rangeSelectionMode: rangeSelectionMode,
        onFormatChanged: onFormatChanged,
        onPageChanged: onPageChanged,
        // Add custom styling for better visual feedback
        availableCalendarFormats: const {
          CalendarFormat.month: 'Month',
          CalendarFormat.twoWeeks: '2 Weeks',
          CalendarFormat.week: 'Week',
        },
        // Enhanced calendar builders for custom date cells
        calendarBuilders: CalendarBuilders<CalendarEvent>(
          defaultBuilder: (context, day, focusedDay) {
            return _buildDateCell(context, day, focusedDay, false, false);
          },
          selectedBuilder: (context, day, focusedDay) {
            return _buildDateCell(context, day, focusedDay, true, false);
          },
          todayBuilder: (context, day, focusedDay) {
            final isSelected = isSameDay(selectedDay, day);
            return _buildDateCell(context, day, focusedDay, isSelected, true);
          },
        ),
      ),
    );
  }

  /// Build custom date cell with enhanced visual feedback
  Widget _buildDateCell(
    BuildContext context,
    DateTime day,
    DateTime focusedDay,
    bool isSelected,
    bool isToday,
  ) {
    final colorScheme = Theme.of(context).colorScheme;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      margin: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: _getBackgroundColor(colorScheme, isSelected, isToday),
        shape: BoxShape.circle,
        border: _getBorder(colorScheme, isSelected, isToday),
        boxShadow: _getBoxShadow(colorScheme, isSelected, isToday),
      ),
      child: Stack(
        children: [
          // Main date text with scale animation
          Center(
            child: AnimatedScale(
              scale: isSelected ? 1.1 : 1.0,
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              child: Text(
                '${day.day}',
                style: TextStyle(
                  color: _getTextColor(colorScheme, isSelected, isToday),
                  fontWeight: isSelected || isToday
                      ? FontWeight.bold
                      : FontWeight.normal,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          // Event indicators are handled by TableCalendar's built-in markers
        ],
      ),
    );
  }

  Color _getBackgroundColor(
    ColorScheme colorScheme,
    bool isSelected,
    bool isToday,
  ) {
    if (isSelected) {
      return colorScheme.primary;
    } else if (isToday) {
      return colorScheme.primary.withOpacity(0.3);
    }
    return Colors.transparent;
  }

  Border? _getBorder(ColorScheme colorScheme, bool isSelected, bool isToday) {
    if (isSelected) {
      return Border.all(color: colorScheme.primary, width: 3);
    } else if (isToday) {
      return Border.all(color: colorScheme.primary, width: 2);
    }
    return null;
  }

  List<BoxShadow>? _getBoxShadow(
    ColorScheme colorScheme,
    bool isSelected,
    bool isToday,
  ) {
    if (isSelected) {
      return [
        BoxShadow(
          color: colorScheme.primary.withOpacity(0.5),
          blurRadius: 12,
          offset: const Offset(0, 4),
          spreadRadius: 2,
        ),
      ];
    } else if (isToday) {
      return [
        BoxShadow(
          color: colorScheme.primary.withOpacity(0.3),
          blurRadius: 6,
          offset: const Offset(0, 2),
        ),
      ];
    }
    return null;
  }

  Color _getTextColor(ColorScheme colorScheme, bool isSelected, bool isToday) {
    if (isSelected) {
      return colorScheme.onPrimary;
    } else if (isToday) {
      return colorScheme.primary;
    }
    return colorScheme.onSurface;
  }
}
