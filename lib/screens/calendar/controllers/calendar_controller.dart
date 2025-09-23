import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../../../models/calendar_event.dart';
import '../../../service/calendar_service.dart';
import '../../add_event/add_event_screen.dart';

/// Calendar Controller
/// Manages state and business logic for the calendar screen
class CalendarController extends ChangeNotifier {
  final CalendarService _calendarService = CalendarService();
  final ValueNotifier<List<CalendarEvent>> _selectedEvents = ValueNotifier([]);

  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  RangeSelectionMode _rangeSelectionMode = RangeSelectionMode.toggledOff;
  DateTime? _rangeStart;
  DateTime? _rangeEnd;

  // Getters
  DateTime get focusedDay => _focusedDay;
  DateTime? get selectedDay => _selectedDay;
  CalendarFormat get calendarFormat => _calendarFormat;
  RangeSelectionMode get rangeSelectionMode => _rangeSelectionMode;
  DateTime? get rangeStart => _rangeStart;
  DateTime? get rangeEnd => _rangeEnd;
  ValueNotifier<List<CalendarEvent>> get selectedEvents => _selectedEvents;

  /// Initialize the calendar
  Future<void> initialize() async {
    _selectedDay = _focusedDay;
    await _loadEvents();
  }

  /// Load events for the selected day
  Future<void> _loadEvents() async {
    try {
      final events = await _loadEventsForDay(_selectedDay!);
      _selectedEvents.value = events;
    } catch (e) {
      print('Error loading events: $e');
    }
  }

  /// Get events for a specific day (synchronous for TableCalendar)
  List<CalendarEvent> getEventsForDay(DateTime day) {
    // This is used by TableCalendar which expects a synchronous function
    // We'll load events asynchronously in initialize and onDaySelected
    return [];
  }

  /// Load events for a specific day (asynchronous)
  Future<List<CalendarEvent>> _loadEventsForDay(DateTime day) async {
    try {
      return await _calendarService.getEventsForDate(day);
    } catch (e) {
      print('Error loading events for day: $e');
      return [];
    }
  }

  /// Handle day selection
  void onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(_selectedDay, selectedDay)) {
      _selectedDay = selectedDay;
      _focusedDay = focusedDay;
      _rangeStart = null;
      _rangeEnd = null;
      _rangeSelectionMode = RangeSelectionMode.toggledOff;
      notifyListeners();

      _loadEventsForSelectedDay(selectedDay);
    }
  }

  /// Load events for the selected day
  Future<void> _loadEventsForSelectedDay(DateTime day) async {
    try {
      final events = await _loadEventsForDay(day);
      _selectedEvents.value = events;
    } catch (e) {
      print('Error loading events for selected day: $e');
    }
  }

  /// Handle range selection
  void onRangeSelected(DateTime? start, DateTime? end, DateTime focusedDay) {
    _selectedDay = null;
    _focusedDay = focusedDay;
    _rangeStart = start;
    _rangeEnd = end;
    _rangeSelectionMode = RangeSelectionMode.toggledOn;
    notifyListeners();
  }

  /// Handle calendar format change
  void onFormatChanged(CalendarFormat format) {
    if (_calendarFormat != format) {
      _calendarFormat = format;
      notifyListeners();
    }
  }

  /// Handle page change
  void onPageChanged(DateTime focusedDay) {
    _focusedDay = focusedDay;
    notifyListeners();
  }

  /// Refresh events
  Future<void> refreshEvents() async {
    await _loadEvents();
  }

  /// Get formatted selected date
  String getFormattedSelectedDate() {
    if (_selectedDay != null) {
      return DateFormat('EEEE, MMMM d, y').format(_selectedDay!);
    }
    return "Select a date";
  }

  /// Show event details dialog
  void showEventDetails(BuildContext context, CalendarEvent event) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(event.title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (event.description.isNotEmpty) ...[
              Text(
                'Description:',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              Text(event.description),
              const SizedBox(height: 8),
            ],
            Text('Date:', style: Theme.of(context).textTheme.titleSmall),
            Text(DateFormat('EEEE, MMMM d, y').format(event.date)),
            const SizedBox(height: 8),
            if (event.formattedTime.isNotEmpty) ...[
              Text('Time:', style: Theme.of(context).textTheme.titleSmall),
              Text(event.formattedTime),
              const SizedBox(height: 8),
            ],
            if (event.location != null && event.location!.isNotEmpty) ...[
              Text('Location:', style: Theme.of(context).textTheme.titleSmall),
              Text(event.location!),
              const SizedBox(height: 8),
            ],
            if (event.tags.isNotEmpty) ...[
              Text('Tags:', style: Theme.of(context).textTheme.titleSmall),
              Wrap(
                children: event.tags
                    .map(
                      (tag) => Chip(
                        label: Text(tag),
                        backgroundColor: event.color.withOpacity(0.1),
                      ),
                    )
                    .toList(),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              editEvent(context, event);
            },
            child: const Text('Edit'),
          ),
        ],
      ),
    );
  }

  /// Edit event
  void editEvent(BuildContext context, CalendarEvent event) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddEventScreen(eventToEdit: event),
      ),
    ).then((_) {
      // Refresh events when returning from edit screen
      refreshEvents();
    });
  }

  /// Delete event
  void deleteEvent(BuildContext context, CalendarEvent event) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Event'),
        content: Text('Are you sure you want to delete "${event.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              try {
                await _calendarService.deleteEvent(event.id);
                Navigator.pop(context);
                await refreshEvents(); // Refresh the events list
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Event "${event.title}" deleted'),
                      backgroundColor: Theme.of(context).colorScheme.primary,
                    ),
                  );
                }
              } catch (e) {
                Navigator.pop(context);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error deleting event: $e'),
                      backgroundColor: Theme.of(context).colorScheme.error,
                    ),
                  );
                }
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _selectedEvents.dispose();
    super.dispose();
  }
}
