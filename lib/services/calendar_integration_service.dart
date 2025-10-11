import 'package:device_calendar/device_calendar.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter/foundation.dart';
import '../models/calendar_event.dart';
import 'google_calendar_service.dart';

/// Calendar Integration Service
/// Handles reading from and writing to device calendars
class CalendarIntegrationService {
  static final CalendarIntegrationService _instance =
      CalendarIntegrationService._internal();
  factory CalendarIntegrationService() => _instance;
  CalendarIntegrationService._internal();

  final DeviceCalendarPlugin _deviceCalendarPlugin = DeviceCalendarPlugin();
  final GoogleCalendarService _googleCalendarService = GoogleCalendarService();
  List<Calendar> _calendars = [];
  bool _hasPermission = false;

  /// Get all available calendars on the device
  Future<List<Calendar>> getCalendars() async {
    // On web, use Google Calendar
    if (kIsWeb) {
      await _googleCalendarService.initialize();
      if (!_googleCalendarService.isAuthenticated) {
        throw Exception('Google Calendar not authenticated');
      }

      final googleCalendars = await _googleCalendarService.getCalendars();
      // Convert Google calendars to device calendar format for compatibility
      _calendars = googleCalendars
          .map(
            (cal) => Calendar(
              id: cal.id,
              name: cal.name,
              color:
                  int.tryParse(cal.color.replaceAll('#', ''), radix: 16) ??
                  0xFF4285F4,
              isReadOnly: false,
              isDefault: cal.isPrimary,
            ),
          )
          .toList();
      return _calendars;
    }

    // Mobile device calendar logic
    if (!_hasPermission) {
      await _requestPermissions();
    }

    if (!_hasPermission) {
      throw Exception('Calendar permission not granted');
    }

    try {
      final result = await _deviceCalendarPlugin.retrieveCalendars();
      if (result.isSuccess && result.data != null) {
        _calendars = result.data!;
        return _calendars;
      } else {
        throw Exception('Failed to retrieve calendars: ${result.errors}');
      }
    } catch (e) {
      throw Exception('Failed to retrieve calendars: $e');
    }
  }

  /// Get events from a specific calendar
  Future<List<CalendarEvent>> getEventsFromCalendar(
    String calendarId, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    if (!_hasPermission) {
      await _requestPermissions();
    }

    if (!_hasPermission) {
      throw Exception('Calendar permission not granted');
    }

    try {
      final result = await _deviceCalendarPlugin.retrieveEvents(
        calendarId,
        RetrieveEventsParams(
          startDate:
              startDate ?? DateTime.now().subtract(const Duration(days: 30)),
          endDate: endDate ?? DateTime.now().add(const Duration(days: 30)),
        ),
      );

      if (result.isSuccess && result.data != null) {
        return result.data!.map((event) => _convertToAppEvent(event)).toList();
      } else {
        throw Exception('Failed to retrieve events: ${result.errors}');
      }
    } catch (e) {
      throw Exception('Failed to retrieve events: $e');
    }
  }

  /// Get all events from all calendars
  Future<List<CalendarEvent>> getAllEvents({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    // On web, use Google Calendar
    if (kIsWeb) {
      await _googleCalendarService.initialize();
      if (!_googleCalendarService.isAuthenticated) {
        throw Exception('Google Calendar not authenticated');
      }

      return await _googleCalendarService.getEvents(
        startDate: startDate,
        endDate: endDate,
      );
    }

    if (!_hasPermission) {
      await _requestPermissions();
    }

    if (!_hasPermission) {
      throw Exception('Calendar permission not granted');
    }

    try {
      final calendars = await getCalendars();
      List<CalendarEvent> allEvents = [];

      for (final calendar in calendars) {
        final events = await getEventsFromCalendar(
          calendar.id!,
          startDate: startDate,
          endDate: endDate,
        );
        allEvents.addAll(events);
      }

      // Sort events by date
      allEvents.sort((a, b) {
        final aDate = a.startDate ?? a.date;
        final bDate = b.startDate ?? b.date;
        return aDate.compareTo(bDate);
      });
      return allEvents;
    } catch (e) {
      throw Exception('Failed to retrieve all events: $e');
    }
  }

  /// Create a new event in a calendar
  Future<String?> createEvent({
    required String calendarId,
    required String title,
    required String description,
    required DateTime startDate,
    required DateTime endDate,
    String? location,
  }) async {
    if (!_hasPermission) {
      await _requestPermissions();
    }

    if (!_hasPermission) {
      throw Exception('Calendar permission not granted');
    }

    try {
      final event = Event(
        calendarId,
        title: title,
        description: description,
        start: TZDateTime.from(startDate, tz.local),
        end: TZDateTime.from(endDate, tz.local),
        allDay: false,
        location: location,
      );

      final result = await _deviceCalendarPlugin.createOrUpdateEvent(event);
      return result?.isSuccess == true ? result?.data : null;
    } catch (e) {
      throw Exception('Failed to create event: $e');
    }
  }

  /// Update an existing event
  Future<bool> updateEvent({
    required String eventId,
    required String calendarId,
    String? title,
    String? description,
    DateTime? startDate,
    DateTime? endDate,
    String? location,
  }) async {
    if (!_hasPermission) {
      await _requestPermissions();
    }

    if (!_hasPermission) {
      throw Exception('Calendar permission not granted');
    }

    try {
      final event = Event(
        calendarId,
        eventId: eventId,
        title: title,
        description: description,
        start: startDate != null ? TZDateTime.from(startDate, tz.local) : null,
        end: endDate != null ? TZDateTime.from(endDate, tz.local) : null,
        location: location,
      );

      final result = await _deviceCalendarPlugin.createOrUpdateEvent(event);
      return result?.isSuccess == true;
    } catch (e) {
      throw Exception('Failed to update event: $e');
    }
  }

  /// Delete an event
  Future<bool> deleteEvent(String eventId, String calendarId) async {
    if (!_hasPermission) {
      await _requestPermissions();
    }

    if (!_hasPermission) {
      throw Exception('Calendar permission not granted');
    }

    try {
      final result = await _deviceCalendarPlugin.deleteEvent(
        calendarId,
        eventId,
      );
      return result.isSuccess;
    } catch (e) {
      throw Exception('Failed to delete event: $e');
    }
  }

  /// Request calendar permissions
  Future<bool> _requestPermissions() async {
    // Calendar permissions are not supported on web
    if (kIsWeb) {
      _hasPermission = false;
      return false;
    }

    try {
      final permission = await Permission.calendar.request();
      _hasPermission = permission.isGranted;
      return _hasPermission;
    } catch (e) {
      _hasPermission = false;
      return false;
    }
  }

  /// Check if calendar permission is granted
  Future<bool> hasPermission() async {
    // Calendar permissions are not supported on web
    if (kIsWeb) {
      _hasPermission = false;
      return false;
    }

    final permission = await Permission.calendar.status;
    _hasPermission = permission.isGranted;
    return _hasPermission;
  }

  /// Initialize calendar service (for web Google Calendar)
  Future<void> initialize() async {
    if (kIsWeb) {
      await _googleCalendarService.initialize();
    }
  }

  /// Get authentication status (for web Google Calendar)
  bool get isAuthenticated {
    if (kIsWeb) {
      return _googleCalendarService.isAuthenticated;
    }
    return _hasPermission;
  }

  /// Authenticate with calendar service (for web Google Calendar)
  Future<bool> authenticate() async {
    if (kIsWeb) {
      return await _googleCalendarService.authenticate();
    }
    return await _requestPermissions();
  }

  /// Clear stored OAuth/auth data and reset local state
  Future<void> clearStoredData() async {
    if (kIsWeb) {
      await _googleCalendarService.clearStoredData();
      return;
    }
    // Mobile: just reset cached state
    _hasPermission = false;
    _calendars = [];
  }

  /// Convert device calendar event to app event model
  CalendarEvent _convertToAppEvent(Event event) {
    final startDate = event.start?.toLocal() ?? DateTime.now();
    return CalendarEvent(
      id: event.eventId ?? '',
      title: event.title ?? '',
      description: event.description ?? '',
      date: startDate,
      startDate: startDate,
      endDate: event.end?.toLocal() ?? startDate,
      location: event.location ?? '',
      isAllDay: event.allDay ?? false,
      source: 'device_calendar',
    );
  }

  /// Get today's events from all calendars
  Future<List<CalendarEvent>> getTodaysEvents() async {
    // On web, use Google Calendar
    if (kIsWeb) {
      await _googleCalendarService.initialize();
      if (!_googleCalendarService.isAuthenticated) {
        throw Exception('Google Calendar not authenticated');
      }

      return await _googleCalendarService.getTodaysEvents();
    }

    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);

    return await getAllEvents(startDate: startOfDay, endDate: endOfDay);
  }

  /// Get events for a specific date range
  Future<List<CalendarEvent>> getEventsForDateRange({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    // On web, use Google Calendar
    if (kIsWeb) {
      await _googleCalendarService.initialize();
      if (!_googleCalendarService.isAuthenticated) {
        throw Exception('Google Calendar not authenticated');
      }

      return await _googleCalendarService.getEvents(
        startDate: startDate,
        endDate: endDate,
      );
    }

    return await getAllEvents(startDate: startDate, endDate: endDate);
  }

  /// Check for conflicts between app events and calendar events
  Future<List<CalendarEvent>> checkConflicts(
    List<CalendarEvent> appEvents,
  ) async {
    final calendarEvents = await getAllEvents();
    List<CalendarEvent> conflicts = [];

    for (final appEvent in appEvents) {
      for (final calendarEvent in calendarEvents) {
        if (_eventsOverlap(appEvent, calendarEvent)) {
          conflicts.add(calendarEvent);
        }
      }
    }

    return conflicts;
  }

  /// Check if two events overlap in time
  bool _eventsOverlap(CalendarEvent event1, CalendarEvent event2) {
    final event1Start = event1.startDate ?? event1.date;
    final event1End = event1.endDate ?? event1.date;
    final event2Start = event2.startDate ?? event2.date;
    final event2End = event2.endDate ?? event2.date;

    return event1Start.isBefore(event2End) && event1End.isAfter(event2Start);
  }
}
