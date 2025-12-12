import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../../../models/calendar_event.dart';
import '../../../models/calendar_view_type.dart';
import '../../../service/calendar_service.dart';
import '../../add_event/add_event_screen.dart';

/// Calendar Controller
/// Manages state and business logic for the calendar screen
class CalendarController extends ChangeNotifier {
  final CalendarService _calendarService = CalendarService();
  final ValueNotifier<List<CalendarEvent>> _selectedEvents = ValueNotifier([]);

  // Cache for events to provide synchronous access for visual indicators
  final Map<String, List<CalendarEvent>> _eventsCache = {};

  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  RangeSelectionMode _rangeSelectionMode = RangeSelectionMode.toggledOff;
  DateTime? _rangeStart;
  DateTime? _rangeEnd;
  CalendarViewType _currentView = CalendarViewType.month;

  // Getters
  DateTime get focusedDay => _focusedDay;
  DateTime? get selectedDay => _selectedDay;
  CalendarFormat get calendarFormat => _calendarFormat;
  RangeSelectionMode get rangeSelectionMode => _rangeSelectionMode;
  DateTime? get rangeStart => _rangeStart;
  DateTime? get rangeEnd => _rangeEnd;
  CalendarViewType get currentView => _currentView;
  ValueNotifier<List<CalendarEvent>> get selectedEvents => _selectedEvents;

  /// Get all events for a date range
  Future<List<CalendarEvent>> getEventsForDateRange(
    DateTime start,
    DateTime end,
  ) async {
    try {
      final allEvents = await _calendarService.getEvents();
      return allEvents.where((event) {
        final eventDate = event.startDate ?? event.date;
        return eventDate.isAfter(start.subtract(const Duration(days: 1))) &&
            eventDate.isBefore(end.add(const Duration(days: 1)));
      }).toList();
    } catch (e) {
      print('Error loading events for date range: $e');
      return [];
    }
  }

  /// Change calendar view
  void changeView(CalendarViewType view) {
    if (_currentView != view) {
      _currentView = view;
      notifyListeners();
    }
  }

  /// Navigate to previous period
  void navigatePrevious() {
    switch (_currentView) {
      case CalendarViewType.day:
        _focusedDay = _focusedDay.subtract(const Duration(days: 1));
        break;
      case CalendarViewType.week:
        _focusedDay = _focusedDay.subtract(const Duration(days: 7));
        break;
      case CalendarViewType.month:
        _focusedDay = DateTime(_focusedDay.year, _focusedDay.month - 1, 1);
        break;
      case CalendarViewType.year:
        _focusedDay = DateTime(_focusedDay.year - 1, _focusedDay.month, 1);
        break;
      case CalendarViewType.agenda:
        // Agenda doesn't need navigation
        break;
    }
    notifyListeners();
    _loadEventsForCurrentView();
  }

  /// Navigate to next period
  void navigateNext() {
    switch (_currentView) {
      case CalendarViewType.day:
        _focusedDay = _focusedDay.add(const Duration(days: 1));
        break;
      case CalendarViewType.week:
        _focusedDay = _focusedDay.add(const Duration(days: 7));
        break;
      case CalendarViewType.month:
        _focusedDay = DateTime(_focusedDay.year, _focusedDay.month + 1, 1);
        break;
      case CalendarViewType.year:
        _focusedDay = DateTime(_focusedDay.year + 1, _focusedDay.month, 1);
        break;
      case CalendarViewType.agenda:
        // Agenda doesn't need navigation
        break;
    }
    notifyListeners();
    _loadEventsForCurrentView();
  }

  /// Navigate to today
  void navigateToToday() {
    _focusedDay = DateTime.now();
    _selectedDay = DateTime.now();
    notifyListeners();
    _loadEventsForCurrentView();
  }

  /// Load events for current view
  Future<void> _loadEventsForCurrentView() async {
    switch (_currentView) {
      case CalendarViewType.day:
        if (_selectedDay != null) {
          await _loadEventsForSelectedDay(_selectedDay!);
        }
        break;
      case CalendarViewType.week:
        final startOfWeek = _getStartOfWeek(_focusedDay);
        final endOfWeek = startOfWeek.add(const Duration(days: 7));
        final events = await getEventsForDateRange(startOfWeek, endOfWeek);
        _selectedEvents.value = events;
        break;
      case CalendarViewType.month:
        await _preloadMonthEvents(_focusedDay);
        if (_selectedDay != null) {
          await _loadEventsForSelectedDay(_selectedDay!);
        }
        break;
      case CalendarViewType.agenda:
        // Load all upcoming events
        final now = DateTime.now();
        final futureEvents = await getEventsForDateRange(
          now,
          now.add(const Duration(days: 365)),
        );
        _selectedEvents.value = futureEvents
          ..sort(
            (a, b) => (a.startDate ?? a.date).compareTo(b.startDate ?? b.date),
          );
        break;
      case CalendarViewType.year:
        // Load events for the year
        final startOfYear = DateTime(_focusedDay.year, 1, 1);
        final endOfYear = DateTime(_focusedDay.year + 1, 1, 1);
        final events = await getEventsForDateRange(startOfYear, endOfYear);
        _selectedEvents.value = events;
        break;
    }
  }

  /// Get start of week (Monday)
  DateTime _getStartOfWeek(DateTime date) {
    final weekday = date.weekday;
    return date.subtract(Duration(days: weekday - 1));
  }

  /// Initialize the calendar
  Future<void> initialize() async {
    _selectedDay = _focusedDay;
    await _loadEvents();
    await _loadEventsForCurrentView();
  }

  /// Preload events for the current month to show visual indicators
  Future<void> _preloadMonthEvents(DateTime month) async {
    try {
      final endOfMonth = DateTime(month.year, month.month + 1, 0);

      // Load events for the entire month
      for (int day = 1; day <= endOfMonth.day; day++) {
        final date = DateTime(month.year, month.month, day);
        await _loadEventsForDay(date);
      }
    } catch (e) {
      print('Error preloading month events: $e');
    }
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
    // Use cached events for visual indicators
    final dayKey = _getDayKey(day);
    return _eventsCache[dayKey] ?? [];
  }

  /// Get a unique key for a day
  String _getDayKey(DateTime day) {
    return '${day.year}-${day.month}-${day.day}';
  }

  /// Load events for a specific day (asynchronous)
  Future<List<CalendarEvent>> _loadEventsForDay(DateTime day) async {
    try {
      final events = await _calendarService.getEventsForDate(day);
      // Cache the events for synchronous access
      final dayKey = _getDayKey(day);
      _eventsCache[dayKey] = events;
      return events;
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
    // Preload events for the new month
    _preloadMonthEvents(focusedDay);
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
