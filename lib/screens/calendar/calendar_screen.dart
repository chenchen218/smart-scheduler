import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/calendar_event.dart';
import '../../../models/calendar_view_type.dart';
import 'controllers/calendar_controller.dart';
import 'widgets/calendar_header.dart';
import 'widgets/calendar_widget.dart';
import 'widgets/events_list_widget.dart';
import 'widgets/view_switcher.dart';
import 'views/day_view.dart';
import 'views/week_view.dart';
import 'views/agenda_view.dart';
import 'views/year_view.dart';
import '../add_event/add_event_screen.dart';

/// Calendar Screen - Modularized Version
/// Main screen for displaying calendar and events
class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  late CalendarController _controller;

  @override
  void initState() {
    super.initState();
    _controller = CalendarController();
    _controller.initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onAddEvent() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddEventScreen()),
    ).then((_) {
      // Refresh events when returning from add event screen
      _controller.refreshEvents();
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ChangeNotifierProvider.value(
      value: _controller,
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                colorScheme.primaryContainer.withOpacity(0.3),
                colorScheme.secondaryContainer.withOpacity(0.2),
              ],
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                // Header section with title, navigation, and add button
                CalendarHeader(
                  selectedDateText: _controller.getFormattedSelectedDate(),
                  onAddEvent: _onAddEvent,
                  onPrevious: _controller.navigatePrevious,
                  onNext: _controller.navigateNext,
                  onToday: _controller.navigateToToday,
                ),
                // View switcher
                ViewSwitcher(
                  currentView: _controller.currentView,
                  onViewChanged: (view) {
                    _controller.changeView(view);
                  },
                ),
                // Calendar view content
                Expanded(
                  child: ValueListenableBuilder<List<CalendarEvent>>(
                    valueListenable: _controller.selectedEvents,
                    builder: (context, events, _) {
                      return _buildView(context, events);
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildView(BuildContext context, List<CalendarEvent> events) {
    switch (_controller.currentView) {
      case CalendarViewType.day:
        return DayView(
          date: _controller.selectedDay ?? _controller.focusedDay,
          events: events,
          onEventTap: (event) => _controller.showEventDetails(context, event),
          onTimeSlotTap: (dateTime) {
            // Navigate to add event screen with pre-filled time
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AddEventScreen()),
            ).then((_) {
              _controller.refreshEvents();
            });
          },
        );
      case CalendarViewType.week:
        final startOfWeek = _getStartOfWeek(_controller.focusedDay);
        return WeekView(
          startOfWeek: startOfWeek,
          events: events,
          onEventTap: (event) => _controller.showEventDetails(context, event),
          onDayTap: (day) {
            _controller.onDaySelected(day, day);
          },
        );
      case CalendarViewType.month:
        return Column(
          children: [
            // Calendar widget
            CalendarWidget(
              focusedDay: _controller.focusedDay,
              selectedDay: _controller.selectedDay,
              calendarFormat: _controller.calendarFormat,
              rangeSelectionMode: _controller.rangeSelectionMode,
              rangeStart: _controller.rangeStart,
              rangeEnd: _controller.rangeEnd,
              eventLoader: _controller.getEventsForDay,
              onDaySelected: _controller.onDaySelected,
              onRangeSelected: _controller.onRangeSelected,
              onFormatChanged: _controller.onFormatChanged,
              onPageChanged: _controller.onPageChanged,
            ),
            const SizedBox(height: 16),
            // Events list
            Expanded(
              child: EventsListWidget(
                events: events,
                onEventTap: (event) =>
                    _controller.showEventDetails(context, event),
                onEditEvent: (event) => _controller.editEvent(context, event),
                onDeleteEvent: (event) =>
                    _controller.deleteEvent(context, event),
              ),
            ),
          ],
        );
      case CalendarViewType.agenda:
        return AgendaView(
          events: events,
          onEventTap: (event) => _controller.showEventDetails(context, event),
        );
      case CalendarViewType.year:
        return YearView(
          year: _controller.focusedDay.year,
          events: events,
          onMonthTap: (monthDate) {
            _controller.onDaySelected(monthDate, monthDate);
            _controller.changeView(CalendarViewType.month);
          },
          onEventTap: (event) => _controller.showEventDetails(context, event),
        );
    }
  }

  DateTime _getStartOfWeek(DateTime date) {
    final weekday = date.weekday;
    return date.subtract(Duration(days: weekday - 1));
  }
}
