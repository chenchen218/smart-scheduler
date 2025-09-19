import '../models/calendar_event.dart';
import 'local_storage_service.dart';

class CalendarService {
  final LocalStorageService _localStorageService = LocalStorageService();

  /// Get all events from local storage
  Future<List<CalendarEvent>> getEvents() async {
    try {
      return await _localStorageService.getEvents();
    } catch (e) {
      print('Error fetching events: $e');
      return [];
    }
  }

  /// Create a new event in local storage
  Future<CalendarEvent> createEvent(CalendarEvent event) async {
    try {
      await _localStorageService.addEvent(event);
      return event;
    } catch (e) {
      print('Error creating event: $e');
      rethrow;
    }
  }

  /// Update an existing event in local storage
  Future<CalendarEvent> updateEvent(CalendarEvent event) async {
    try {
      await _localStorageService.updateEvent(event);
      return event;
    } catch (e) {
      print('Error updating event: $e');
      rethrow;
    }
  }

  /// Delete an event from local storage
  Future<void> deleteEvent(String eventId) async {
    try {
      await _localStorageService.deleteEvent(eventId);
    } catch (e) {
      print('Error deleting event: $e');
      rethrow;
    }
  }

  /// Get events for a specific date from local storage
  Future<List<CalendarEvent>> getEventsForDate(DateTime date) async {
    try {
      return await _localStorageService.getEventsForDate(date);
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
