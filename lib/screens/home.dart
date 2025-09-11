import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import '../models/task.dart';
import '../models/calendar_event.dart';
import '../widgets/task_card.dart';
import '../widgets/event_card.dart';
import '../service/calendar_service.dart';
import 'add_event_screen.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  final List<Task> tasks = [];
  final List<CalendarEvent> events = [];
  final GlobalKey<AnimatedListState> _listKey = GlobalKey();
  final GlobalKey<AnimatedListState> _eventsListKey = GlobalKey();
  final Random rand = Random();
  final CalendarService _calendarService = CalendarService();
  Timer? autoTimer;
  late TabController _tabController;

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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (_tabController.index == 1) {
        // Refresh events when switching to events tab
        _loadEvents();
      }
    });
    _startAutoAddTasks();
    _loadEvents();
  }

  /// Loads events for today from the calendar service and updates the UI
  /// Includes debug logging to track event loading and date matching
  Future<void> _loadEvents() async {
    try {
      final today = DateTime.now();
      print('Loading events for today: ${today.toString()}');
      print(
        'Date components: year=${today.year}, month=${today.month}, day=${today.day}',
      );

      final todayEvents = await _calendarService.getEventsForDate(today);
      print('Found ${todayEvents.length} events for today');

      // Debug: Print all events to see what we have
      for (int i = 0; i < todayEvents.length; i++) {
        final event = todayEvents[i];
        print('Event $i: ${event.title} - Date: ${event.date.toString()}');
        print(
          '  Event date components: year=${event.date.year}, month=${event.date.month}, day=${event.date.day}',
        );
        print(
          '  Today date components: year=${today.year}, month=${today.month}, day=${today.day}',
        );
        print(
          '  Date match: ${event.date.year == today.year && event.date.month == today.month && event.date.day == today.day}',
        );
      }

      setState(() {
        events.clear();
        events.addAll(todayEvents);
      });
      print('Events updated in UI: ${events.length}');
    } catch (e) {
      print('Error loading events: $e');
    }
  }

  /// Removes an event from the events list and updates the UI immediately
  /// Used for swipe-to-delete functionality
  void _removeEventFromList(CalendarEvent event) {
    setState(() {
      events.remove(event);
    });
    print('Event removed from list: ${event.title}');
  }

  /// Automatically generates and adds tasks to the list every 500ms
  /// Tasks are randomly selected from sampleTasks array with random priority
  /// Tasks automatically get marked as done after 1-2 seconds
  /// Stops generating when 8 tasks are reached
  void _startAutoAddTasks() {
    autoTimer = Timer.periodic(Duration(milliseconds: 500), (_) {
      if (tasks.length >= 8) {
        autoTimer?.cancel();
        return;
      }
      final name = sampleTasks[rand.nextInt(sampleTasks.length)];
      final priority = ["Low", "Medium", "High"][rand.nextInt(3)];
      final task = Task(name: name, priority: priority);
      tasks.insert(0, task);
      _listKey.currentState?.insertItem(0);

      Future.delayed(Duration(milliseconds: 1000 + rand.nextInt(1000)), () {
        if (mounted && tasks.contains(task)) {
          setState(() {
            task.done = true;
          });
        }
      });
    });
  }

  @override
  void dispose() {
    autoTimer?.cancel();
    _tabController.dispose();
    super.dispose();
  }

  /// Calculates the total number of items to display in the combined tasks/events list
  /// This includes debug section, task headers, tasks, event headers, and events
  int _getCombinedItemCount() {
    int count = 0;

    // Debug section (always shown)
    count += 1;

    // Tasks section header + tasks
    if (tasks.isNotEmpty) {
      count += 1 + tasks.length; // header + tasks
    }

    // Events section header + events
    if (events.isNotEmpty) {
      count += 1 + events.length; // header + events
    }

    return count;
  }

  /// Builds individual items for the combined tasks/events list based on index
  /// Handles debug section, task headers, tasks, event headers, and events
  Widget _buildCombinedItem(BuildContext context, int index) {
    final colorScheme = Theme.of(context).colorScheme;
    int currentIndex = 0;

    // Debug section (always first)
    if (index == currentIndex) {
      return Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: colorScheme.surfaceVariant.withOpacity(0.3),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          'Debug: Events loaded: ${events.length}',
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
        ),
      );
    }
    currentIndex++;

    // Tasks section - displays task header and individual task cards
    if (tasks.isNotEmpty) {
      // Tasks header - shows "Tasks (X)" title
      if (index == currentIndex) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(
            'Tasks (${tasks.length})',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.primary,
            ),
          ),
        );
      }
      currentIndex++;

      // Individual task cards with swipe-to-delete functionality
      if (index < currentIndex + tasks.length) {
        final taskIndex = index - currentIndex;
        final task = tasks[taskIndex];
        return Dismissible(
          key: Key(task.name + taskIndex.toString()),
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
          onDismissed: (_) => setState(() => tasks.removeAt(taskIndex)),
          child: TaskCard(
            task: task,
            onChecked: (val) => setState(() => task.done = val ?? false),
          ),
        );
      }
      currentIndex += tasks.length;
    }

    // Events section - displays event header and individual event cards
    if (events.isNotEmpty) {
      // Events header - shows "Today's Events (X)" title
      if (index == currentIndex) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(
            'Today\'s Events (${events.length})',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.secondary,
            ),
          ),
        );
      }
      currentIndex++;

      // Individual event cards with swipe-to-delete functionality
      if (index < currentIndex + events.length) {
        final eventIndex = index - currentIndex;
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
          onDismissed: (_) => _removeEventFromList(event),
          child: EventCard(
            event: event,
            onTap: () {
              // Show event details
            },
            onEdit: () {
              // Edit event
            },
            onDelete: () {
              // Delete event
              _deleteEvent(event);
            },
          ),
        );
      }
    }

    return const SizedBox.shrink();
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
              // Header section with app title, progress bar, and action buttons
              Container(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: colorScheme.primary,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Icon(
                            Icons.task_alt_rounded,
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
                                "Auto To-Do Demo",
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: colorScheme.onSurface,
                                    ),
                              ),
                              Text(
                                "${tasks.where((t) => t.done).length} of ${tasks.length} completed",
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                              ),
                            ],
                          ),
                        ),
                        // Add Event Button
                        IconButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const AddEventScreen(),
                              ),
                            ).then((_) {
                              // Refresh events when returning from add event screen
                              print(
                                'Returning from add event screen, refreshing events...',
                              );
                              _loadEvents().then((_) {
                                // Force a rebuild to ensure the first tab shows the new events
                                if (mounted) {
                                  setState(() {
                                    // This will trigger a rebuild of the entire widget tree
                                  });
                                }
                              });
                            });
                          },
                          icon: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: colorScheme.secondary,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.event_rounded,
                              color: colorScheme.onSecondary,
                              size: 20,
                            ),
                          ),
                          tooltip: 'Add Event',
                        ),
                        // Refresh Button (for debugging)
                        IconButton(
                          onPressed: () {
                            print('Manual refresh triggered');
                            _loadEvents();
                          },
                          icon: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: colorScheme.tertiary,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.refresh_rounded,
                              color: colorScheme.onTertiary,
                              size: 20,
                            ),
                          ),
                          tooltip: 'Refresh Events',
                        ),
                        // Debug All Events Button
                        IconButton(
                          onPressed: () async {
                            print('Loading ALL events from service...');
                            final allEvents = await _calendarService
                                .getEvents();
                            print(
                              'Total events in service: ${allEvents.length}',
                            );
                            for (int i = 0; i < allEvents.length; i++) {
                              final event = allEvents[i];
                              print(
                                'All Event $i: ${event.title} - Date: ${event.date.toString()}',
                              );
                            }
                          },
                          icon: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.purple,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.list_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                          tooltip: 'Debug All Events',
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    // Progress Bar
                    if (tasks.isNotEmpty)
                      Container(
                        height: 8,
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceVariant,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: FractionallySizedBox(
                          alignment: Alignment.centerLeft,
                          widthFactor: tasks.isEmpty
                              ? 0
                              : tasks.where((t) => t.done).length /
                                    tasks.length,
                          child: Container(
                            decoration: BoxDecoration(
                              color: colorScheme.primary,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              // Main content area with tabbed interface
              Expanded(
                child: Column(
                  children: [
                    // Tab bar for switching between Tasks and Events
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceVariant.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: TabBar(
                        controller: _tabController,
                        indicator: BoxDecoration(
                          color: colorScheme.primary,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        labelColor: colorScheme.onPrimary,
                        unselectedLabelColor: colorScheme.onSurfaceVariant,
                        tabs: [
                          Tab(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.task_alt_rounded, size: 18),
                                const SizedBox(width: 8),
                                Text('Tasks (${tasks.length})'),
                              ],
                            ),
                          ),
                          Tab(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.event_rounded, size: 18),
                                const SizedBox(width: 8),
                                Text('Today\'s Events (${events.length})'),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Tab content area with dynamic list views
                    Expanded(
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          // First tab: Combined view showing both tasks and events
                          (tasks.isEmpty && events.isEmpty)
                              ? Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.task_alt_outlined,
                                        size: 64,
                                        color: colorScheme.onSurfaceVariant
                                            .withOpacity(0.5),
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        "No tasks or events yet",
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleLarge
                                            ?.copyWith(
                                              color:
                                                  colorScheme.onSurfaceVariant,
                                            ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        "Tasks will appear automatically\nTap + to add events",
                                        textAlign: TextAlign.center,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium
                                            ?.copyWith(
                                              color: colorScheme
                                                  .onSurfaceVariant
                                                  .withOpacity(0.7),
                                            ),
                                      ),
                                    ],
                                  ),
                                )
                              : ListView.builder(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                  ),
                                  itemCount: _getCombinedItemCount(),
                                  itemBuilder: (context, index) {
                                    return _buildCombinedItem(context, index);
                                  },
                                ),
                          // Second tab: Dedicated events view with AnimatedList
                          events.isEmpty
                              ? Center(
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
                                        "No events today",
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleLarge
                                            ?.copyWith(
                                              color:
                                                  colorScheme.onSurfaceVariant,
                                            ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        "Tap + to add an event",
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium
                                            ?.copyWith(
                                              color: colorScheme
                                                  .onSurfaceVariant
                                                  .withOpacity(0.7),
                                            ),
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        "Debug: Events loaded: ${events.length}",
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(
                                              color: colorScheme
                                                  .onSurfaceVariant
                                                  .withOpacity(0.5),
                                            ),
                                      ),
                                    ],
                                  ),
                                )
                              : AnimatedList(
                                  key: _eventsListKey,
                                  initialItemCount: events.length,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                  ),
                                  itemBuilder: (context, index, animation) {
                                    final event = events[index];
                                    return SlideTransition(
                                      position: animation.drive(
                                        Tween(
                                          begin: const Offset(1, 0),
                                          end: Offset.zero,
                                        ).chain(
                                          CurveTween(
                                            curve: Curves.easeOutCubic,
                                          ),
                                        ),
                                      ),
                                      child: FadeTransition(
                                        opacity: animation,
                                        child: Dismissible(
                                          key: Key('event_${event.id}'),
                                          background: Container(
                                            margin: const EdgeInsets.symmetric(
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.red.shade400,
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                            ),
                                            alignment: Alignment.centerLeft,
                                            padding: const EdgeInsets.only(
                                              left: 20,
                                            ),
                                            child: const Icon(
                                              Icons.delete_rounded,
                                              color: Colors.white,
                                              size: 28,
                                            ),
                                          ),
                                          onDismissed: (_) =>
                                              _removeEventFromList(event),
                                          child: EventCard(
                                            event: event,
                                            onTap: () {
                                              // Show event details
                                            },
                                            onEdit: () {
                                              // Edit event
                                            },
                                            onDelete: () {
                                              // Delete event
                                              _deleteEvent(event);
                                            },
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Shows confirmation dialog and deletes an event from both UI and storage
  /// Handles both successful deletion and error cases with user feedback
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
                _removeEventFromList(event); // Remove with animation
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
