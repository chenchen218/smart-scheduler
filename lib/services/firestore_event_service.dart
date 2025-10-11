import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/calendar_event.dart';

class FirestoreEventService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Get the current user's events collection reference
  CollectionReference get _eventsCollection {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }
    return _firestore.collection('users').doc(user.uid).collection('events');
  }

  /// Get all events for the current user
  Future<List<CalendarEvent>> getEvents() async {
    try {
      final snapshot = await _eventsCollection.get();
      return snapshot.docs
          .map(
            (doc) => CalendarEvent.fromJson(doc.data() as Map<String, dynamic>),
          )
          .toList();
    } catch (e) {
      print('Error fetching events from Firestore: $e');
      return [];
    }
  }

  /// Create a new event
  Future<CalendarEvent> createEvent(CalendarEvent event) async {
    try {
      await _eventsCollection.doc(event.id).set(event.toJson());
      return event;
    } catch (e) {
      print('Error creating event in Firestore: $e');
      rethrow;
    }
  }

  /// Update an existing event
  Future<CalendarEvent> updateEvent(CalendarEvent event) async {
    try {
      await _eventsCollection.doc(event.id).update(event.toJson());
      return event;
    } catch (e) {
      print('Error updating event in Firestore: $e');
      rethrow;
    }
  }

  /// Delete an event
  Future<void> deleteEvent(String eventId) async {
    try {
      await _eventsCollection.doc(eventId).delete();
    } catch (e) {
      print('Error deleting event from Firestore: $e');
      rethrow;
    }
  }

  /// Get events for a specific date
  Future<List<CalendarEvent>> getEventsForDate(DateTime date) async {
    try {
      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

      final snapshot = await _eventsCollection
          .where('date', isGreaterThanOrEqualTo: startOfDay.toIso8601String())
          .where('date', isLessThan: endOfDay.toIso8601String())
          .get();

      return snapshot.docs
          .map(
            (doc) => CalendarEvent.fromJson(doc.data() as Map<String, dynamic>),
          )
          .toList();
    } catch (e) {
      print('Error fetching events for date from Firestore: $e');
      return [];
    }
  }

  /// Get events for a specific month
  Future<List<CalendarEvent>> getEventsForMonth(DateTime month) async {
    try {
      final startOfMonth = DateTime(month.year, month.month, 1);
      final endOfMonth = DateTime(month.year, month.month + 1, 1);

      final snapshot = await _eventsCollection
          .where('date', isGreaterThanOrEqualTo: startOfMonth.toIso8601String())
          .where('date', isLessThan: endOfMonth.toIso8601String())
          .get();

      return snapshot.docs
          .map(
            (doc) => CalendarEvent.fromJson(doc.data() as Map<String, dynamic>),
          )
          .toList();
    } catch (e) {
      print('Error fetching events for month from Firestore: $e');
      return [];
    }
  }

  /// Get events by priority
  Future<List<CalendarEvent>> getEventsByPriority(String priority) async {
    try {
      final snapshot = await _eventsCollection
          .where('priority', isEqualTo: priority)
          .get();

      return snapshot.docs
          .map(
            (doc) => CalendarEvent.fromJson(doc.data() as Map<String, dynamic>),
          )
          .toList();
    } catch (e) {
      print('Error fetching events by priority from Firestore: $e');
      return [];
    }
  }

  /// Get completed events
  Future<List<CalendarEvent>> getCompletedEvents() async {
    try {
      final snapshot = await _eventsCollection
          .where('isCompleted', isEqualTo: true)
          .get();

      return snapshot.docs
          .map(
            (doc) => CalendarEvent.fromJson(doc.data() as Map<String, dynamic>),
          )
          .toList();
    } catch (e) {
      print('Error fetching completed events from Firestore: $e');
      return [];
    }
  }

  /// Get pending events
  Future<List<CalendarEvent>> getPendingEvents() async {
    try {
      final snapshot = await _eventsCollection
          .where('isCompleted', isEqualTo: false)
          .get();

      return snapshot.docs
          .map(
            (doc) => CalendarEvent.fromJson(doc.data() as Map<String, dynamic>),
          )
          .toList();
    } catch (e) {
      print('Error fetching pending events from Firestore: $e');
      return [];
    }
  }

  /// Search events by title
  Future<List<CalendarEvent>> searchEvents(String query) async {
    try {
      final snapshot = await _eventsCollection.get();
      return snapshot.docs
          .map(
            (doc) => CalendarEvent.fromJson(doc.data() as Map<String, dynamic>),
          )
          .where(
            (event) => event.title.toLowerCase().contains(query.toLowerCase()),
          )
          .toList();
    } catch (e) {
      print('Error searching events in Firestore: $e');
      return [];
    }
  }
}
