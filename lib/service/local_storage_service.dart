import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/calendar_event.dart';

class LocalStorageService {
  static const String _eventsKey = 'calendar_events';
  static const String _tasksKey = 'tasks';

  /// Get all events from local storage
  Future<List<CalendarEvent>> getEvents() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final eventsJson = prefs.getStringList(_eventsKey) ?? [];
      return eventsJson
          .map((json) => CalendarEvent.fromJson(jsonDecode(json)))
          .toList();
    } catch (e) {
      print('Error loading events: $e');
      return [];
    }
  }

  /// Save events to local storage
  Future<void> saveEvents(List<CalendarEvent> events) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final eventsJson = events
          .map((event) => jsonEncode(event.toJson()))
          .toList();
      await prefs.setStringList(_eventsKey, eventsJson);
    } catch (e) {
      print('Error saving events: $e');
    }
  }

  /// Add a new event
  Future<void> addEvent(CalendarEvent event) async {
    try {
      final events = await getEvents();
      events.add(event);
      await saveEvents(events);
    } catch (e) {
      print('Error adding event: $e');
    }
  }

  /// Update an existing event
  Future<void> updateEvent(CalendarEvent event) async {
    try {
      final events = await getEvents();
      final index = events.indexWhere((e) => e.id == event.id);
      if (index != -1) {
        events[index] = event;
        await saveEvents(events);
      }
    } catch (e) {
      print('Error updating event: $e');
    }
  }

  /// Delete an event
  Future<void> deleteEvent(String eventId) async {
    try {
      final events = await getEvents();
      events.removeWhere((event) => event.id == eventId);
      await saveEvents(events);
    } catch (e) {
      print('Error deleting event: $e');
    }
  }

  /// Get events for a specific date
  Future<List<CalendarEvent>> getEventsForDate(DateTime date) async {
    try {
      final events = await getEvents();
      return events.where((event) {
        return event.date.year == date.year &&
            event.date.month == date.month &&
            event.date.day == date.day;
      }).toList();
    } catch (e) {
      print('Error getting events for date: $e');
      return [];
    }
  }

  /// Get events for a specific month
  Future<List<CalendarEvent>> getEventsForMonth(DateTime month) async {
    try {
      final events = await getEvents();
      return events.where((event) {
        return event.date.year == month.year && event.date.month == month.month;
      }).toList();
    } catch (e) {
      print('Error getting events for month: $e');
      return [];
    }
  }

  /// Get events by priority
  Future<List<CalendarEvent>> getEventsByPriority(String priority) async {
    try {
      final events = await getEvents();
      return events.where((event) => event.priority == priority).toList();
    } catch (e) {
      print('Error getting events by priority: $e');
      return [];
    }
  }

  /// Get completed events
  Future<List<CalendarEvent>> getCompletedEvents() async {
    try {
      final events = await getEvents();
      return events.where((event) => event.isCompleted).toList();
    } catch (e) {
      print('Error getting completed events: $e');
      return [];
    }
  }

  /// Get pending events
  Future<List<CalendarEvent>> getPendingEvents() async {
    try {
      final events = await getEvents();
      return events.where((event) => !event.isCompleted).toList();
    } catch (e) {
      print('Error getting pending events: $e');
      return [];
    }
  }

  /// Search events by title
  Future<List<CalendarEvent>> searchEvents(String query) async {
    try {
      final events = await getEvents();
      return events
          .where(
            (event) =>
                event.title.toLowerCase().contains(query.toLowerCase()) ||
                event.description.toLowerCase().contains(query.toLowerCase()),
          )
          .toList();
    } catch (e) {
      print('Error searching events: $e');
      return [];
    }
  }
}
