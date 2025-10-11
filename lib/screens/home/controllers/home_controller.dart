import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import '../../../models/task.dart';
import '../../../models/calendar_event.dart';
import '../../../service/calendar_service.dart';
import '../../../services/calendar_integration_service.dart';
import '../../../widgets/task_card.dart';
import '../../../widgets/event_card.dart';

/// Home Controller
/// Manages state and business logic for the home screen
class HomeController extends ChangeNotifier {
  final List<Task> tasks = [];
  final List<CalendarEvent> events = [];
  final GlobalKey<AnimatedListState> listKey = GlobalKey();
  final GlobalKey<AnimatedListState> eventsListKey = GlobalKey();
  final Random rand = Random();
  final CalendarService calendarService = CalendarService();
  final CalendarIntegrationService calendarIntegrationService =
      CalendarIntegrationService();
  Timer? autoTimer;
  Timer? _debounceTimer;

  final List<String> sampleTasks = [
    "Buy groceries",
    "Read Flutter docs",
    "Walk the dog",
    "Check emails",
    "Call Alice",
    "Fix bug #23",
    "Push new commit",
    "Prepare slides",
  ];

  /// Start automatic task generation
  void startAutoAddTasks() {
    autoTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (tasks.length < 8) {
        _addRandomTask();
      } else {
        timer.cancel();
      }
    });
  }

  /// Add a random task to the list
  void _addRandomTask() {
    final task = Task(
      name: sampleTasks[rand.nextInt(sampleTasks.length)],
      priority: ["Low", "Medium", "High"][rand.nextInt(3)],
      done: false,
    );

    tasks.add(task);

    // Animate the addition first, then notify
    if (listKey.currentState != null) {
      listKey.currentState!.insertItem(tasks.length - 1);
    }

    // Debounced notification to reduce rebuilds
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 16), () {
      notifyListeners();
    });
  }

  /// Toggle task completion status
  void toggleTask(Task task) {
    final index = tasks.indexOf(task);
    if (index != -1) {
      tasks[index] = Task(
        name: task.name,
        priority: task.priority,
        done: !task.done,
      );
      // Don't notify listeners for simple toggles - let the UI handle it
    }
  }

  /// Delete a task from the list
  void deleteTask(Task task) {
    final index = tasks.indexOf(task);
    if (index != -1) {
      // Animate the removal first
      if (listKey.currentState != null) {
        listKey.currentState!.removeItem(
          index,
          (context, animation) =>
              SizeTransition(sizeFactor: animation, child: Container()),
        );
      }

      // Remove from list after animation starts
      tasks.removeAt(index);

      // Debounced notification
      _debounceTimer?.cancel();
      _debounceTimer = Timer(const Duration(milliseconds: 16), () {
        notifyListeners();
      });
    }
  }

  /// Load events from the app store and Google Calendar (if available)
  Future<void> loadEvents() async {
    try {
      print('Loading events for today: ${DateTime.now()}');
      final today = DateTime.now();
      final start = DateTime(today.year, today.month, today.day);
      final end = DateTime(today.year, today.month, today.day + 7);
      print(
        'Date components: year=${today.year}, month=${today.month}, day=${today.day}',
      );

      // 1) App/Firestore events
      final allEvents = await calendarService.getEvents();
      print('Found ${allEvents.length} total events in storage');
      print(
        'All events: ${allEvents.map((e) => '${e.title} (${e.date})').join(', ')}',
      );

      // Filter app events for today..next 7 days
      final localWindow = allEvents.where((event) {
        final eventDate = event.date;
        print(
          'Event ${allEvents.indexOf(event)}: ${event.title} - Date: ${event.date}',
        );
        print(
          '  Event date components: year=${eventDate.year}, month=${eventDate.month}, day=${eventDate.day}',
        );
        print(
          '  Today date components: year=${today.year}, month=${today.month}, day=${today.day}',
        );

        // Check if event is within the next 7 days
        final daysDifference = eventDate.difference(start).inDays;
        final isWithinNextWeek = daysDifference >= 0 && eventDate.isBefore(end);

        print(
          '  Days difference: $daysDifference, Within next week: $isWithinNextWeek',
        );
        return isWithinNextWeek;
      }).toList();

      // 2) Google Calendar events (best-effort)
      List<CalendarEvent> googleEvents = [];
      try {
        await calendarIntegrationService.initialize();
        googleEvents = await calendarIntegrationService.getEventsForDateRange(
          startDate: start,
          endDate: end,
        );
        print('Loaded ${googleEvents.length} Google events');
        if (googleEvents.isEmpty) {
          print('Google events list is empty in selected window.');
        } else {
          print(
            'Google events detail: ${googleEvents.map((e) => "${e.title} @ ${(e.startDate ?? e.date).toIso8601String()}").join(', ')}',
          );
        }
      } catch (e) {
        print('Google events unavailable (not connected or error): $e');
      }

      // 3) Merge + sort
      final merged = [...localWindow, ...googleEvents];
      merged.sort(
        (a, b) => (a.startDate ?? a.date).compareTo(b.startDate ?? b.date),
      );

      events
        ..clear()
        ..addAll(merged);
      print('Events updated in UI: ${events.length}');
      notifyListeners();
    } catch (e) {
      print('Error loading events: $e');
    }
  }

  /// Remove event from the events list
  void removeEventFromList(CalendarEvent event) {
    final index = events.indexOf(event);
    if (index != -1) {
      print('Event removed from list: ${event.title}');

      // Animate the removal first
      if (eventsListKey.currentState != null) {
        eventsListKey.currentState!.removeItem(
          index,
          (context, animation) =>
              SizeTransition(sizeFactor: animation, child: Container()),
        );
      }

      // Remove from list after animation starts
      events.removeAt(index);

      // Debounced notification
      _debounceTimer?.cancel();
      _debounceTimer = Timer(const Duration(milliseconds: 16), () {
        notifyListeners();
      });
    }
  }

  /// Delete an event from the calendar service
  Future<void> deleteEvent(CalendarEvent event) async {
    try {
      await calendarService.deleteEvent(event.id);
      removeEventFromList(event);
    } catch (e) {
      print('Error deleting event: $e');
    }
  }

  /// Toggle event completion status
  Future<void> toggleEventCompletion(
    CalendarEvent event,
    bool isCompleted,
  ) async {
    try {
      final updatedEvent = event.copyWith(isCompleted: isCompleted);
      await calendarService.updateEvent(updatedEvent);

      final index = events.indexOf(event);
      if (index != -1) {
        events[index] = updatedEvent;
        notifyListeners();
      }
    } catch (e) {
      print('Error toggling event completion: $e');
    }
  }

  /// Get combined item count for the unified list
  int getCombinedItemCount() {
    return tasks.length + events.length;
  }

  /// Build combined item for the unified list
  Widget buildCombinedItem(BuildContext context, int index) {
    if (index < tasks.length) {
      // This is a task
      final task = tasks[index];
      return TaskCard(task: task, onChecked: (bool? value) => toggleTask(task));
    } else {
      // This is an event
      final eventIndex = index - tasks.length;
      final event = events[eventIndex];
      return Dismissible(
        key: Key('event_${event.id}'),
        background: Container(
          margin: const EdgeInsets.symmetric(vertical: 4),
          decoration: BoxDecoration(
            color: Colors.red.shade400,
            borderRadius: BorderRadius.circular(16),
          ),
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.only(left: 20),
          child: const Icon(
            Icons.delete_rounded,
            color: Colors.white,
            size: 28,
          ),
        ),
        onDismissed: (_) => removeEventFromList(event),
        child: EventCard(
          event: event,
          onTap: () {
            // Show event details
          },
          onEdit: () {
            // Edit event - this will be handled by the parent
          },
          onDelete: () => deleteEvent(event),
          onToggle: (isCompleted) => toggleEventCompletion(event, isCompleted),
        ),
      );
    }
  }

  /// Debug method to load all events
  Future<void> debugAllEvents() async {
    try {
      print('Loading ALL events from service...');
      final allEvents = await calendarService.getEvents();
      print('Total events in service: ${allEvents.length}');
      for (int i = 0; i < allEvents.length; i++) {
        final event = allEvents[i];
        print('All Event $i: ${event.title} - Date: ${event.date.toString()}');
      }
    } catch (e) {
      print('Error loading all events: $e');
    }
  }

  @override
  void dispose() {
    autoTimer?.cancel();
    _debounceTimer?.cancel();
    super.dispose();
  }
}
