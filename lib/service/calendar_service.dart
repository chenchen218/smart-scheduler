import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/calendar_event.dart';

class CalendarService {
  static const String _baseUrl =
      'https://api.example.com/calendar'; // Replace with your API
  static const String _localStorageKey = 'calendar_events';

  // Local storage methods
  Future<List<CalendarEvent>> getLocalEvents() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final eventsJson = prefs.getStringList(_localStorageKey) ?? [];
      return eventsJson
          .map((json) => CalendarEvent.fromJson(jsonDecode(json)))
          .toList();
    } catch (e) {
      print('Error loading local events: $e');
      return [];
    }
  }

  Future<void> saveLocalEvents(List<CalendarEvent> events) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final eventsJson = events
          .map((event) => jsonEncode(event.toJson()))
          .toList();
      await prefs.setStringList(_localStorageKey, eventsJson);
    } catch (e) {
      print('Error saving local events: $e');
    }
  }

  // API methods (mock implementation - replace with real API calls)
  Future<List<CalendarEvent>> getEvents() async {
    try {
      // For now, return local events
      // In a real app, you would make an API call here
      return await getLocalEvents();
    } catch (e) {
      print('Error fetching events: $e');
      return [];
    }
  }

  Future<CalendarEvent> createEvent(CalendarEvent event) async {
    try {
      // Mock API call - replace with real implementation
      final events = await getLocalEvents();
      events.add(event);
      await saveLocalEvents(events);
      return event;
    } catch (e) {
      print('Error creating event: $e');
      rethrow;
    }
  }

  Future<CalendarEvent> updateEvent(CalendarEvent event) async {
    try {
      final events = await getLocalEvents();
      final index = events.indexWhere((e) => e.id == event.id);
      if (index != -1) {
        events[index] = event;
        await saveLocalEvents(events);
      }
      return event;
    } catch (e) {
      print('Error updating event: $e');
      rethrow;
    }
  }

  Future<void> deleteEvent(String eventId) async {
    try {
      final events = await getLocalEvents();
      events.removeWhere((event) => event.id == eventId);
      await saveLocalEvents(events);
    } catch (e) {
      print('Error deleting event: $e');
      rethrow;
    }
  }

  Future<List<CalendarEvent>> getEventsForDate(DateTime date) async {
    try {
      final events = await getLocalEvents();
      return events.where((event) {
        return event.date.year == date.year &&
            event.date.month == date.month &&
            event.date.day == date.day;
      }).toList();
    } catch (e) {
      print('Error fetching events for date: $e');
      return [];
    }
  }

  Future<List<CalendarEvent>> getEventsForMonth(DateTime month) async {
    try {
      final events = await getLocalEvents();
      return events.where((event) {
        return event.date.year == month.year && event.date.month == month.month;
      }).toList();
    } catch (e) {
      print('Error fetching events for month: $e');
      return [];
    }
  }

  // Real API implementation example (uncomment and modify as needed)
  /*
  Future<List<CalendarEvent>> getEventsFromAPI() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/events'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => CalendarEvent.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load events: ${response.statusCode}');
      }
    } catch (e) {
      print('API Error: $e');
      rethrow;
    }
  }

  Future<CalendarEvent> createEventAPI(CalendarEvent event) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/events'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(event.toJson()),
      );

      if (response.statusCode == 201) {
        return CalendarEvent.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to create event: ${response.statusCode}');
      }
    } catch (e) {
      print('API Error: $e');
      rethrow;
    }
  }
  */
}
