import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../../services/calendar_integration_service.dart';
import '../../models/calendar_event.dart';

/// Calendar Integration Screen
/// Shows external calendar events and allows basic management
class CalendarIntegrationScreen extends StatefulWidget {
  const CalendarIntegrationScreen({super.key});

  @override
  State<CalendarIntegrationScreen> createState() =>
      _CalendarIntegrationScreenState();
}

class _CalendarIntegrationScreenState extends State<CalendarIntegrationScreen> {
  final CalendarIntegrationService _calendarService =
      CalendarIntegrationService();
  List<CalendarEvent> _externalEvents = [];
  bool _isLoading = false;
  String? _error;
  bool _hasPermission = false;

  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    // On web, check Google Calendar authentication
    if (kIsWeb) {
      try {
        await _calendarService.initialize();
        final isAuthenticated = _calendarService.isAuthenticated;
        setState(() {
          _hasPermission = isAuthenticated;
          _error = null;
        });

        if (isAuthenticated) {
          _loadExternalEvents();
        }
      } catch (e) {
        setState(() {
          _hasPermission = false;
          _error = null;
        });
      }
      return;
    }

    final hasPermission = await _calendarService.hasPermission();
    setState(() {
      _hasPermission = hasPermission;
    });

    if (hasPermission) {
      _loadExternalEvents();
    }
  }

  Future<void> _requestPermissions() async {
    print('CalendarIntegrationScreen: _requestPermissions called');

    // On web, use Google Calendar authentication
    if (kIsWeb) {
      print(
        'CalendarIntegrationScreen: Running on web, authenticating with Google Calendar',
      );
      setState(() {
        _isLoading = true;
        _error = null;
      });

      try {
        // Initialize Google Calendar service
        await _calendarService.initialize();

        // Authenticate with Google Calendar
        final success = await _calendarService.authenticate();

        setState(() {
          _hasPermission = success;
          _isLoading = false;
          if (success) {
            _loadExternalEvents();
          } else {
            _error =
                'Failed to authenticate with Google Calendar. Please try again.';
          }
        });
      } catch (e) {
        setState(() {
          _hasPermission = false;
          _isLoading = false;
          _error = 'Google Calendar authentication failed: $e';
        });
      }
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final hasPermission = await _calendarService.hasPermission();
      setState(() {
        _hasPermission = hasPermission;
        _isLoading = false;
      });

      if (hasPermission) {
        _loadExternalEvents();
      } else {
        setState(() {
          _error = 'Calendar permission is required to access your events';
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Failed to request permissions: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _loadExternalEvents() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      print('CalendarIntegrationScreen: Loading external events...');
      final events = await _calendarService.getTodaysEvents();
      print('CalendarIntegrationScreen: Found ${events.length} events');
      for (int i = 0; i < events.length; i++) {
        print('Event $i: ${events[i].title} - ${events[i].date}');
      }
      setState(() {
        _externalEvents = events;
        _isLoading = false;
      });
    } catch (e) {
      print('CalendarIntegrationScreen: Error loading events: $e');
      setState(() {
        _error = 'Failed to load calendar events: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _loadAllEvents() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      print('CalendarIntegrationScreen: Loading all events for date range...');
      final now = DateTime.now();
      final startDate = DateTime(now.year, now.month, now.day - 7);
      final endDate = DateTime(now.year, now.month, now.day + 7);
      print('CalendarIntegrationScreen: Date range: $startDate to $endDate');

      final events = await _calendarService.getEventsForDateRange(
        startDate: startDate,
        endDate: endDate,
      );

      print(
        'CalendarIntegrationScreen: Found ${events.length} events in date range',
      );
      for (int i = 0; i < events.length; i++) {
        print('Event $i: ${events[i].title} - ${events[i].date}');
      }

      setState(() {
        _externalEvents = events;
        _isLoading = false;
      });
    } catch (e) {
      print('CalendarIntegrationScreen: Error loading all events: $e');
      setState(() {
        _error = 'Failed to load calendar events: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _clearStoredData() async {
    try {
      await _calendarService.clearStoredData();
      setState(() {
        _hasPermission = false;
        _externalEvents = [];
        _error = null;
      });
      print('CalendarIntegrationScreen: Cleared all stored OAuth data');
    } catch (e) {
      print('CalendarIntegrationScreen: Error clearing stored data: $e');
      setState(() {
        _error = 'Failed to clear stored data: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: AppBar(
        title: Text(
          'Calendar Integration',
          style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        actions: [
          IconButton(
            onPressed: _clearStoredData,
            icon: const Icon(Icons.clear_all_rounded),
            tooltip: 'Clear Stored Data',
          ),
          IconButton(
            onPressed: _loadAllEvents,
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh Events',
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Permission Status Card
            _buildPermissionCard(),

            // Events List
            Expanded(child: _buildEventsList()),
          ],
        ),
      ),
    );
  }

  Widget _buildPermissionCard() {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outline.withOpacity(0.2),
          width: 0.5,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _hasPermission
                      ? colorScheme.secondary
                      : colorScheme.error.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _hasPermission
                      ? Icons.check_circle_rounded
                      : Icons.lock_rounded,
                  color: _hasPermission ? Colors.white : colorScheme.error,
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _hasPermission
                          ? (kIsWeb
                                ? 'Google Calendar Connected'
                                : 'Calendar Access Granted')
                          : (kIsWeb
                                ? 'Google Calendar Required'
                                : 'Calendar Access Required'),
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _hasPermission
                          ? (kIsWeb
                                ? 'You can view and manage your Google Calendar events'
                                : 'You can view and manage your calendar events')
                          : (kIsWeb
                                ? 'Connect your Google Calendar to sync events'
                                : 'Grant permission to access your calendar events'),
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (!_hasPermission) ...[
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  print('CalendarIntegrationScreen: Button pressed');
                  _requestPermissions();
                },
                child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(
                        kIsWeb ? 'Connect Google Calendar' : 'Grant Permission',
                      ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEventsList() {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    if (!_hasPermission) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.calendar_today_outlined,
              size: 64,
              color: colorScheme.onSurface.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'Calendar Access Required',
              style: textTheme.titleLarge?.copyWith(
                color: colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Grant permission to view your calendar events',
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface.withOpacity(0.4),
              ),
            ),
          ],
        ),
      );
    }

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 64,
              color: colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Error Loading Events',
              style: textTheme.titleLarge?.copyWith(color: colorScheme.error),
            ),
            const SizedBox(height: 8),
            Text(
              _error!,
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface.withOpacity(0.6),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadExternalEvents,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_externalEvents.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.event_available_outlined,
              size: 64,
              color: colorScheme.onSurface.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'No Events Found',
              style: textTheme.titleLarge?.copyWith(
                color: colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'No calendar events found for today',
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface.withOpacity(0.4),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: _externalEvents.length,
      itemBuilder: (context, index) {
        final event = _externalEvents[index];
        return _buildEventCard(event);
      },
    );
  }

  Widget _buildEventCard(CalendarEvent event) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.outline.withOpacity(0.2),
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: _getEventColor(event),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  event.title,
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getEventColor(event).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  event.source ?? 'Unknown',
                  style: textTheme.bodySmall?.copyWith(
                    color: _getEventColor(event),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          if (event.description.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              event.description,
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(
                Icons.access_time_rounded,
                size: 16,
                color: colorScheme.onSurface.withOpacity(0.4),
              ),
              const SizedBox(width: 8),
              Text(
                _formatEventTime(event),
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
              if (event.location != null && event.location!.isNotEmpty) ...[
                const SizedBox(width: 16),
                Icon(
                  Icons.location_on_outlined,
                  size: 16,
                  color: colorScheme.onSurface.withOpacity(0.4),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    event.location!,
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurface.withOpacity(0.6),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Color _getEventColor(CalendarEvent event) {
    switch (event.source) {
      case 'device_calendar':
        return Colors.blue;
      case 'google_calendar':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  String _formatEventTime(CalendarEvent event) {
    if (event.isAllDay) {
      return 'All Day';
    }

    if (event.startDate != null && event.endDate != null) {
      final startTime =
          '${event.startDate!.hour.toString().padLeft(2, '0')}:${event.startDate!.minute.toString().padLeft(2, '0')}';
      final endTime =
          '${event.endDate!.hour.toString().padLeft(2, '0')}:${event.endDate!.minute.toString().padLeft(2, '0')}';
      return '$startTime - $endTime';
    }

    if (event.startTime != null) {
      return '${event.startTime!.hour.toString().padLeft(2, '0')}:${event.startTime!.minute.toString().padLeft(2, '0')}';
    }

    return 'No time set';
  }
}
