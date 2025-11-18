import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import '../../../models/task.dart';
import '../../../models/calendar_event.dart';
import '../../../models/filter_options.dart';
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

  // Filter and sort state
  FilterOptions _currentFilters = const FilterOptions();
  SortOptions _currentSort = const SortOptions();

  // Get all tasks and events (unfiltered)
  List<Task> get allTasks => tasks;
  List<CalendarEvent> get allEvents => events;

  // Get filtered and sorted tasks
  List<Task> get filteredTasks {
    var filtered = List<Task>.from(tasks);

    // Apply filters
    filtered = _applyTaskFilters(filtered);

    // Apply sorting
    filtered = _applyTaskSorting(filtered);

    return filtered;
  }

  // Get filtered and sorted events
  List<CalendarEvent> get filteredEvents {
    var filtered = List<CalendarEvent>.from(events);

    // Apply filters
    filtered = _applyEventFilters(filtered);

    // Apply sorting
    filtered = _applyEventSorting(filtered);

    return filtered;
  }

  FilterOptions get currentFilters => _currentFilters;
  SortOptions get currentSort => _currentSort;

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
      id: DateTime.now().millisecondsSinceEpoch.toString(),
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
        id: task.id,
        name: task.name,
        priority: task.priority,
        done: !task.done,
        deadline: task.deadline,
        createdAt: task.createdAt,
        updatedAt: DateTime.now(),
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

  /// Update filters
  void updateFilters(FilterOptions filters) {
    _currentFilters = filters;
    notifyListeners();
  }

  /// Update sort options
  void updateSort(SortOptions sort) {
    _currentSort = sort;
    notifyListeners();
  }

  /// Clear all filters
  void clearFilters() {
    _currentFilters = const FilterOptions();
    notifyListeners();
  }

  /// Apply filters to tasks
  List<Task> _applyTaskFilters(List<Task> taskList) {
    var filtered = taskList;

    // Priority filter
    if (_currentFilters.priorities != null &&
        _currentFilters.priorities!.isNotEmpty) {
      filtered = filtered.where((task) {
        return _currentFilters.priorities!.contains(task.priority);
      }).toList();
    }

    // Date range filter
    if (_currentFilters.startDate != null || _currentFilters.endDate != null) {
      filtered = filtered.where((task) {
        if (task.deadline == null) return false;
        final deadline = task.deadline!;
        if (_currentFilters.startDate != null &&
            deadline.isBefore(_currentFilters.startDate!)) {
          return false;
        }
        if (_currentFilters.endDate != null &&
            deadline.isAfter(_currentFilters.endDate!)) {
          return false;
        }
        return true;
      }).toList();
    }

    // Completion filter
    if (_currentFilters.isCompleted != null) {
      filtered = filtered.where((task) {
        return task.done == _currentFilters.isCompleted;
      }).toList();
    }

    // Quick filters
    if (_currentFilters.quickFilter != null) {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      switch (_currentFilters.quickFilter) {
        case 'today':
          filtered = filtered.where((task) {
            if (task.deadline == null) return false;
            final deadline = task.deadline!;
            return deadline.year == today.year &&
                deadline.month == today.month &&
                deadline.day == today.day;
          }).toList();
          break;
        case 'this_week':
          final startOfWeek = today.subtract(Duration(days: today.weekday - 1));
          final endOfWeek = startOfWeek.add(const Duration(days: 7));
          filtered = filtered.where((task) {
            if (task.deadline == null) return false;
            final deadline = task.deadline!;
            return deadline.isAfter(
                  startOfWeek.subtract(const Duration(days: 1)),
                ) &&
                deadline.isBefore(endOfWeek);
          }).toList();
          break;
        case 'overdue':
          filtered = filtered.where((task) {
            if (task.deadline == null || task.done) return false;
            final deadline = task.deadline!;
            return deadline.isBefore(today);
          }).toList();
          break;
        case 'high_priority':
          filtered = filtered.where((task) {
            return task.priority == 'High';
          }).toList();
          break;
      }
    }

    return filtered;
  }

  /// Apply filters to events
  List<CalendarEvent> _applyEventFilters(List<CalendarEvent> eventList) {
    var filtered = eventList;

    // Priority filter
    if (_currentFilters.priorities != null &&
        _currentFilters.priorities!.isNotEmpty) {
      filtered = filtered.where((event) {
        return _currentFilters.priorities!.contains(event.priority);
      }).toList();
    }

    // Tags filter
    if (_currentFilters.tags != null && _currentFilters.tags!.isNotEmpty) {
      filtered = filtered.where((event) {
        return _currentFilters.tags!.any((tag) => event.tags.contains(tag));
      }).toList();
    }

    // Date range filter
    if (_currentFilters.startDate != null || _currentFilters.endDate != null) {
      filtered = filtered.where((event) {
        final eventDate = event.startDate ?? event.date;
        if (_currentFilters.startDate != null &&
            eventDate.isBefore(_currentFilters.startDate!)) {
          return false;
        }
        if (_currentFilters.endDate != null &&
            eventDate.isAfter(_currentFilters.endDate!)) {
          return false;
        }
        return true;
      }).toList();
    }

    // Source filter
    if (_currentFilters.sources != null &&
        _currentFilters.sources!.isNotEmpty) {
      filtered = filtered.where((event) {
        return event.source != null &&
            _currentFilters.sources!.contains(event.source);
      }).toList();
    }

    // Completion filter
    if (_currentFilters.isCompleted != null) {
      filtered = filtered.where((event) {
        return event.isCompleted == _currentFilters.isCompleted;
      }).toList();
    }

    // Quick filters
    if (_currentFilters.quickFilter != null) {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      switch (_currentFilters.quickFilter) {
        case 'today':
          filtered = filtered.where((event) {
            final eventDate = event.startDate ?? event.date;
            return eventDate.year == today.year &&
                eventDate.month == today.month &&
                eventDate.day == today.day;
          }).toList();
          break;
        case 'this_week':
          final startOfWeek = today.subtract(Duration(days: today.weekday - 1));
          final endOfWeek = startOfWeek.add(const Duration(days: 7));
          filtered = filtered.where((event) {
            final eventDate = event.startDate ?? event.date;
            return eventDate.isAfter(
                  startOfWeek.subtract(const Duration(days: 1)),
                ) &&
                eventDate.isBefore(endOfWeek);
          }).toList();
          break;
        case 'overdue':
          filtered = filtered.where((event) {
            if (event.isCompleted) return false;
            final eventDate = event.startDate ?? event.date;
            return eventDate.isBefore(today);
          }).toList();
          break;
        case 'high_priority':
          filtered = filtered.where((event) {
            return event.priority == 'High';
          }).toList();
          break;
      }
    }

    return filtered;
  }

  /// Apply sorting to tasks
  List<Task> _applyTaskSorting(List<Task> taskList) {
    final sorted = List<Task>.from(taskList);

    sorted.sort((a, b) {
      int comparison = 0;

      switch (_currentSort.field) {
        case SortField.date:
          final aDate = a.deadline ?? DateTime(0);
          final bDate = b.deadline ?? DateTime(0);
          comparison = aDate.compareTo(bDate);
          break;
        case SortField.priority:
          final priorityOrder = {'High': 3, 'Medium': 2, 'Low': 1};
          final aPriority = priorityOrder[a.priority] ?? 0;
          final bPriority = priorityOrder[b.priority] ?? 0;
          comparison = aPriority.compareTo(bPriority);
          break;
        case SortField.title:
          comparison = a.name.compareTo(b.name);
          break;
      }

      return _currentSort.order == SortOrder.ascending
          ? comparison
          : -comparison;
    });

    return sorted;
  }

  /// Apply sorting to events
  List<CalendarEvent> _applyEventSorting(List<CalendarEvent> eventList) {
    final sorted = List<CalendarEvent>.from(eventList);

    sorted.sort((a, b) {
      int comparison = 0;

      switch (_currentSort.field) {
        case SortField.date:
          final aDate = a.startDate ?? a.date;
          final bDate = b.startDate ?? b.date;
          comparison = aDate.compareTo(bDate);
          break;
        case SortField.priority:
          final priorityOrder = {'High': 3, 'Medium': 2, 'Low': 1};
          final aPriority = priorityOrder[a.priority] ?? 0;
          final bPriority = priorityOrder[b.priority] ?? 0;
          comparison = aPriority.compareTo(bPriority);
          break;
        case SortField.title:
          comparison = a.title.compareTo(b.title);
          break;
      }

      return _currentSort.order == SortOrder.ascending
          ? comparison
          : -comparison;
    });

    return sorted;
  }

  /// Get combined item count for the unified list (filtered)
  int getCombinedItemCount() {
    return filteredTasks.length + filteredEvents.length;
  }

  /// Build combined item for the unified list (filtered)
  Widget buildCombinedItem(BuildContext context, int index) {
    final filteredTasksList = filteredTasks;
    final filteredEventsList = filteredEvents;

    if (index < filteredTasksList.length) {
      // This is a task
      final task = filteredTasksList[index];
      return TaskCard(task: task, onChecked: (bool? value) => toggleTask(task));
    } else {
      // This is an event
      final eventIndex = index - filteredTasksList.length;
      final event = filteredEventsList[eventIndex];
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
