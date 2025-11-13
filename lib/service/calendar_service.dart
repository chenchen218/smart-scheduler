import '../models/calendar_event.dart';
import 'local_storage_service.dart';
import '../services/firestore_event_service.dart';
import '../services/recurrence_service.dart';

class CalendarService {
  final LocalStorageService _localStorageService = LocalStorageService();
  final FirestoreEventService _firestoreEventService = FirestoreEventService();
  final RecurrenceService _recurrenceService = RecurrenceService();

  /// Get all events from Firebase Firestore
  /// This expands recurring events into instances for the next 6 months
  Future<List<CalendarEvent>> getEvents() async {
    try {
      final events = await _firestoreEventService.getEvents();
      return _expandRecurringEvents(events);
    } catch (e) {
      print('Error fetching events from Firestore: $e');
      // Fallback to local storage if Firestore fails
      try {
        final events = await _localStorageService.getEvents();
        return _expandRecurringEvents(events);
      } catch (localError) {
        print('Error fetching events from local storage: $localError');
        return [];
      }
    }
  }

  /// Expand recurring events into instances for a date range
  List<CalendarEvent> _expandRecurringEvents(List<CalendarEvent> events) {
    final now = DateTime.now();
    final endDate = DateTime(now.year, now.month + 6, now.day);
    return _recurrenceService.expandRecurringEvents(
      events: events,
      startDate: now,
      endDate: endDate,
    );
  }

  /// Create a new event in Firebase Firestore
  Future<CalendarEvent> createEvent(CalendarEvent event) async {
    try {
      await _firestoreEventService.createEvent(event);
      // Also save to local storage as backup
      await _localStorageService.addEvent(event);
      return event;
    } catch (e) {
      print('Error creating event in Firestore: $e');
      // Fallback to local storage only
      try {
        await _localStorageService.addEvent(event);
        return event;
      } catch (localError) {
        print('Error creating event in local storage: $localError');
        rethrow;
      }
    }
  }

  /// Update an existing event in Firebase Firestore
  Future<CalendarEvent> updateEvent(CalendarEvent event) async {
    try {
      await _firestoreEventService.updateEvent(event);
      // Also update local storage as backup
      await _localStorageService.updateEvent(event);
      return event;
    } catch (e) {
      print('Error updating event in Firestore: $e');
      // Fallback to local storage only
      try {
        await _localStorageService.updateEvent(event);
        return event;
      } catch (localError) {
        print('Error updating event in local storage: $localError');
        rethrow;
      }
    }
  }

  /// Delete an event from Firebase Firestore
  Future<void> deleteEvent(String eventId) async {
    try {
      await _firestoreEventService.deleteEvent(eventId);
      // Also delete from local storage
      await _localStorageService.deleteEvent(eventId);
    } catch (e) {
      print('Error deleting event from Firestore: $e');
      // Fallback to local storage only
      try {
        await _localStorageService.deleteEvent(eventId);
      } catch (localError) {
        print('Error deleting event from local storage: $localError');
        rethrow;
      }
    }
  }

  /// Get events for a specific date
  /// This expands recurring events to show instances on that date
  Future<List<CalendarEvent>> getEventsForDate(DateTime date) async {
    try {
      // Get all events and expand recurring ones
      final allEvents = await getEvents();

      // Filter for events on this date
      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

      return allEvents.where((event) {
        final eventDate = event.startDate ?? event.date;
        return eventDate.isAfter(
              startOfDay.subtract(const Duration(seconds: 1)),
            ) &&
            eventDate.isBefore(endOfDay.add(const Duration(seconds: 1)));
      }).toList();
    } catch (e) {
      print('Error fetching events for date: $e');
      return [];
    }
  }

  /// Get events for a specific month from local storage
  Future<List<CalendarEvent>> getEventsForMonth(DateTime month) async {
    try {
      return await _localStorageService.getEventsForMonth(month);
    } catch (e) {
      print('Error fetching events for month: $e');
      return [];
    }
  }

  /// Get events by priority from local storage
  Future<List<CalendarEvent>> getEventsByPriority(String priority) async {
    try {
      return await _localStorageService.getEventsByPriority(priority);
    } catch (e) {
      print('Error fetching events by priority: $e');
      return [];
    }
  }

  /// Get completed events from local storage
  Future<List<CalendarEvent>> getCompletedEvents() async {
    try {
      return await _localStorageService.getCompletedEvents();
    } catch (e) {
      print('Error fetching completed events: $e');
      return [];
    }
  }

  /// Get pending events from local storage
  Future<List<CalendarEvent>> getPendingEvents() async {
    try {
      return await _localStorageService.getPendingEvents();
    } catch (e) {
      print('Error fetching pending events: $e');
      return [];
    }
  }

  /// Search events by title in local storage
  Future<List<CalendarEvent>> searchEvents(String query) async {
    try {
      return await _localStorageService.searchEvents(query);
    } catch (e) {
      print('Error searching events: $e');
      return [];
    }
  }
}
