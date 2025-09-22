import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../models/calendar_event.dart';
import '../service/calendar_service.dart';
import '../widgets/event_card.dart';
import 'add_event/add_event_screen.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  final CalendarService _calendarService = CalendarService();
  late final ValueNotifier<List<CalendarEvent>> _selectedEvents;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  RangeSelectionMode _rangeSelectionMode = RangeSelectionMode.toggledOff;
  DateTime? _rangeStart;
  DateTime? _rangeEnd;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _selectedEvents = ValueNotifier([]);
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    try {
      final events = await _loadEventsForDay(_selectedDay!);
      _selectedEvents.value = events;
    } catch (e) {
      print('Error loading events: $e');
    }
  }

  @override
  void dispose() {
    _selectedEvents.dispose();
    super.dispose();
  }

  List<CalendarEvent> _getEventsForDay(DateTime day) {
    // This is used by TableCalendar which expects a synchronous function
    // We'll load events asynchronously in initState and onDaySelected
    return [];
  }

  Future<List<CalendarEvent>> _loadEventsForDay(DateTime day) async {
    try {
      return await _calendarService.getEventsForDate(day);
    } catch (e) {
      print('Error loading events for day: $e');
      return [];
    }
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        _selectedDay = selectedDay;
        _focusedDay = focusedDay;
        _rangeStart = null;
        _rangeEnd = null;
        _rangeSelectionMode = RangeSelectionMode.toggledOff;
      });

      _loadEventsForSelectedDay(selectedDay);
    }
  }

  Future<void> _loadEventsForSelectedDay(DateTime day) async {
    try {
      final events = await _loadEventsForDay(day);
      _selectedEvents.value = events;
    } catch (e) {
      print('Error loading events for selected day: $e');
    }
  }

  void _onRangeSelected(DateTime? start, DateTime? end, DateTime focusedDay) {
    setState(() {
      _selectedDay = null;
      _focusedDay = focusedDay;
      _rangeStart = start;
      _rangeEnd = end;
      _rangeSelectionMode = RangeSelectionMode.toggledOn;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
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
              // Header
              Container(
                padding: const EdgeInsets.all(24),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: colorScheme.primary,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        Icons.calendar_month_rounded,
                        color: colorScheme.onPrimary,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Calendar",
                            style: Theme.of(context).textTheme.headlineMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.onSurface,
                                ),
                          ),
                          Text(
                            _selectedDay != null
                                ? DateFormat(
                                    'EEEE, MMMM d, y',
                                  ).format(_selectedDay!)
                                : "Select a date",
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(color: colorScheme.onSurfaceVariant),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AddEventScreen(),
                          ),
                        ).then((_) {
                          // Refresh events when returning from add event screen
                          _loadEvents();
                        });
                      },
                      icon: Icon(Icons.add_rounded, color: colorScheme.primary),
                    ),
                  ],
                ),
              ),
              // Calendar
              Container(
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
                  focusedDay: _focusedDay,
                  calendarFormat: _calendarFormat,
                  eventLoader: _getEventsForDay,
                  startingDayOfWeek: StartingDayOfWeek.monday,
                  calendarStyle: CalendarStyle(
                    outsideDaysVisible: false,
                    weekendTextStyle: TextStyle(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                    defaultTextStyle: TextStyle(color: colorScheme.onSurface),
                    selectedTextStyle: TextStyle(
                      color: colorScheme.onPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                    todayTextStyle: TextStyle(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                    selectedDecoration: BoxDecoration(
                      color: colorScheme.primary,
                      shape: BoxShape.circle,
                    ),
                    todayDecoration: BoxDecoration(
                      color: colorScheme.primary.withOpacity(0.3),
                      shape: BoxShape.circle,
                    ),
                    markerDecoration: BoxDecoration(
                      color: colorScheme.secondary,
                      shape: BoxShape.circle,
                    ),
                    markersMaxCount: 3,
                    markerSize: 6,
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
                  onDaySelected: _onDaySelected,
                  onRangeSelected: _onRangeSelected,
                  rangeSelectionMode: _rangeSelectionMode,
                  onFormatChanged: (format) {
                    if (_calendarFormat != format) {
                      setState(() {
                        _calendarFormat = format;
                      });
                    }
                  },
                  onPageChanged: (focusedDay) {
                    _focusedDay = focusedDay;
                  },
                ),
              ),
              const SizedBox(height: 16),
              // Events List
              Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  child: ValueListenableBuilder<List<CalendarEvent>>(
                    valueListenable: _selectedEvents,
                    builder: (context, value, _) {
                      if (value.isEmpty) {
                        return SingleChildScrollView(
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.all(32.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.event_available_outlined,
                                    size: 64,
                                    color: colorScheme.onSurfaceVariant
                                        .withOpacity(0.5),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    "No events",
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleLarge
                                        ?.copyWith(
                                          color: colorScheme.onSurfaceVariant,
                                        ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    "Tap + to add an event",
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          color: colorScheme.onSurfaceVariant
                                              .withOpacity(0.7),
                                        ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }

                      return ListView.builder(
                        itemCount: value.length,
                        itemBuilder: (context, index) {
                          return EventCard(
                            event: value[index],
                            onTap: () {
                              // Navigate to event details
                              _showEventDetails(value[index]);
                            },
                            onEdit: () {
                              // Navigate to edit event
                              _editEvent(value[index]);
                            },
                            onDelete: () {
                              // Delete event
                              _deleteEvent(value[index]);
                            },
                          );
                        },
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showEventDetails(CalendarEvent event) {
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
              _editEvent(event);
            },
            child: const Text('Edit'),
          ),
        ],
      ),
    );
  }

  void _editEvent(CalendarEvent event) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddEventScreen(eventToEdit: event),
      ),
    ).then((_) {
      // Refresh events when returning from edit screen
      _loadEvents();
    });
  }

  void _deleteEvent(CalendarEvent event) {
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
                _loadEvents(); // Refresh the events list
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Event "${event.title}" deleted'),
                    backgroundColor: Theme.of(context).colorScheme.primary,
                  ),
                );
              } catch (e) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error deleting event: $e'),
                    backgroundColor: Theme.of(context).colorScheme.error,
                  ),
                );
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
