import '../models/calendar_event.dart';
import 'firebase_service.dart';

class CalendarService {
  final FirebaseService _firebaseService = FirebaseService();

  /// Get all events from Firebase
  Future<List<CalendarEvent>> getEvents() async {
    try {
      return await _firebaseService.getEvents();
    } catch (e) {
      print('Error fetching events: $e');
      return [];
    }
  }

  /// Create a new event in Firebase
  Future<CalendarEvent> createEvent(CalendarEvent event) async {
    try {
      final eventId = await _firebaseService.createEvent(event);
      return event.copyWith(id: eventId);
    } catch (e) {
      print('Error creating event: $e');
      rethrow;
    }
  }

  /// Update an existing event in Firebase
  Future<CalendarEvent> updateEvent(CalendarEvent event) async {
    try {
      await _firebaseService.updateEvent(event);
      return event;
    } catch (e) {
      print('Error updating event: $e');
      rethrow;
    }
  }

  /// Delete an event from Firebase
  Future<void> deleteEvent(String eventId) async {
    try {
      await _firebaseService.deleteEvent(eventId);
    } catch (e) {
      print('Error deleting event: $e');
      rethrow;
    }
  }

  /// Get events for a specific date from Firebase
  Future<List<CalendarEvent>> getEventsForDate(DateTime date) async {
    try {
      return await _firebaseService.getEventsForDate(date);
    } catch (e) {
      print('Error fetching events for date: $e');
      return [];
    }
  }

  /// Get events for a specific month from Firebase
  Future<List<CalendarEvent>> getEventsForMonth(DateTime month) async {
    try {
      return await _firebaseService.getEventsForMonth(month);
    } catch (e) {
      print('Error fetching events for month: $e');
      return [];
    }
  }

  /// Get events by priority from Firebase
  Future<List<CalendarEvent>> getEventsByPriority(String priority) async {
    try {
      return await _firebaseService.getEventsByPriority(priority);
    } catch (e) {
      print('Error fetching events by priority: $e');
      return [];
    }
  }

  /// Get completed events from Firebase
  Future<List<CalendarEvent>> getCompletedEvents() async {
    try {
      return await _firebaseService.getCompletedEvents();
    } catch (e) {
      print('Error fetching completed events: $e');
      return [];
    }
  }

  /// Get pending events from Firebase
  Future<List<CalendarEvent>> getPendingEvents() async {
    try {
      return await _firebaseService.getPendingEvents();
    } catch (e) {
      print('Error fetching pending events: $e');
      return [];
    }
  }

  /// Search events by title in Firebase
  Future<List<CalendarEvent>> searchEvents(String query) async {
    try {
      return await _firebaseService.searchEvents(query);
    } catch (e) {
      print('Error searching events: $e');
      return [];
    }
  }
}
