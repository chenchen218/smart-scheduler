import 'package:flutter/material.dart';
import '../../../models/calendar_event.dart';
import 'widgets/home_header.dart';
import 'widgets/home_tab_navigation.dart';
import 'widgets/task_list_widget.dart';
import 'widgets/event_list_widget.dart';
import 'controllers/home_controller.dart';
import '../add_event/add_event_screen.dart';
import '../search/search_screen.dart';

/// Home Screen - Modularized Version
/// Main screen for displaying tasks and events
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late HomeController _controller;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _controller = HomeController();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (_tabController.index == 1) {
        // Refresh events when switching to events tab
        _controller.loadEvents();
      }
    });
    _controller.startAutoAddTasks();
    _controller.loadEvents();
    _controller.addListener(_onControllerUpdate);
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerUpdate);
    _controller.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _onControllerUpdate() {
    if (mounted) {
      setState(() {});
    }
  }

  void _onAddEvent() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddEventScreen()),
    ).then((_) {
      // Refresh events when returning from add event screen
      print('Returning from add event screen, refreshing events...');
      _controller.loadEvents().then((_) {
        // Force a rebuild to ensure the first tab shows the new events
        if (mounted) {
          setState(() {
            // This will trigger a rebuild of the entire widget tree
          });
        }
      });
    });
  }

  void _onSearch() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SearchScreen()),
    );
  }

  void _onRefresh() {
    print('Manual refresh triggered');
    _controller.loadEvents();
  }

  void _onDebugAllEvents() {
    _controller.debugAllEvents();
  }

  void _onEditEvent(CalendarEvent event) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddEventScreen(eventToEdit: event),
      ),
    ).then((_) {
      // Refresh events when returning from edit screen
      _controller.loadEvents();
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header section with app title, progress bar, and action buttons
            HomeHeader(
              onSearch: _onSearch,
              tasks: _controller.tasks,
              onAddEvent: _onAddEvent,
              onRefresh: _onRefresh,
              onDebugAllEvents: _onDebugAllEvents,
            ),
            // Main content area with tabbed interface
            Expanded(
              child: Column(
                children: [
                  // Tab bar for switching between Tasks and Events
                  HomeTabNavigation(
                    tabController: _tabController,
                    taskCount: _controller.tasks.length,
                    eventCount: _controller.events.length,
                  ),
                  const SizedBox(height: 8),
                  // Tab content area with dynamic list views
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        // First tab: Combined view showing both tasks and events
                        TaskListWidget(
                          tasks: _controller.tasks,
                          events: _controller.events,
                          buildCombinedItem: _controller.buildCombinedItem,
                          getCombinedItemCount:
                              _controller.getCombinedItemCount,
                          onEditEvent: _onEditEvent,
                          onDeleteEvent: _controller.deleteEvent,
                          onToggleEventCompletion:
                              _controller.toggleEventCompletion,
                        ),
                        // Second tab: Dedicated events view with AnimatedList
                        EventListWidget(
                          events: _controller.events,
                          onEditEvent: _onEditEvent,
                          onDeleteEvent: _controller.deleteEvent,
                          onToggleEventCompletion:
                              _controller.toggleEventCompletion,
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
    );
  }
}
