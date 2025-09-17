import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/calendar_event.dart';

class FirebaseService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  // Collection name for events
  static const String _eventsCollection = 'events';

  /// Get the current user ID, create anonymous user if not authenticated
  Future<String> _getCurrentUserId() async {
    User? user = _auth.currentUser;
    if (user == null) {
      // Sign in anonymously if no user is authenticated
      UserCredential userCredential = await _auth.signInAnonymously();
      return userCredential.user!.uid;
    }
    return user.uid;
  }

  /// Get all events for the current user
  Future<List<CalendarEvent>> getEvents() async {
    try {
      final userId = await _getCurrentUserId();
      final QuerySnapshot snapshot = await _firestore
          .collection(_eventsCollection)
          .where('userId', isEqualTo: userId)
          .orderBy('date', descending: false)
          .get();

      return snapshot.docs
          .map(
            (doc) => CalendarEvent.fromJson({
              'id': doc.id,
              ...doc.data() as Map<String, dynamic>,
            }),
          )
          .toList();
    } catch (e) {
      print('Error getting events: $e');
      return [];
    }
  }

  /// Get events for a specific date
  Future<List<CalendarEvent>> getEventsForDate(DateTime date) async {
    try {
      final userId = await _getCurrentUserId();
      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

      final QuerySnapshot snapshot = await _firestore
          .collection(_eventsCollection)
          .where('userId', isEqualTo: userId)
          .where('date', isGreaterThanOrEqualTo: startOfDay)
          .where('date', isLessThanOrEqualTo: endOfDay)
          .orderBy('date')
          .get();

      return snapshot.docs
          .map(
            (doc) => CalendarEvent.fromJson({
              'id': doc.id,
              ...doc.data() as Map<String, dynamic>,
            }),
          )
          .toList();
    } catch (e) {
      print('Error getting events for date: $e');
      return [];
    }
  }

  /// Get events for a specific month
  Future<List<CalendarEvent>> getEventsForMonth(DateTime month) async {
    try {
      final userId = await _getCurrentUserId();
      final startOfMonth = DateTime(month.year, month.month, 1);
      final endOfMonth = DateTime(month.year, month.month + 1, 0, 23, 59, 59);

      final QuerySnapshot snapshot = await _firestore
          .collection(_eventsCollection)
          .where('userId', isEqualTo: userId)
          .where('date', isGreaterThanOrEqualTo: startOfMonth)
          .where('date', isLessThanOrEqualTo: endOfMonth)
          .orderBy('date')
          .get();

      return snapshot.docs
          .map(
            (doc) => CalendarEvent.fromJson({
              'id': doc.id,
              ...doc.data() as Map<String, dynamic>,
            }),
          )
          .toList();
    } catch (e) {
      print('Error getting events for month: $e');
      return [];
    }
  }

  /// Create a new event
  Future<String> createEvent(CalendarEvent event) async {
    try {
      final userId = await _getCurrentUserId();
      final eventData = event.toJson();
      eventData['userId'] = userId;
      eventData['createdAt'] = FieldValue.serverTimestamp();
      eventData['updatedAt'] = FieldValue.serverTimestamp();

      final DocumentReference docRef = await _firestore
          .collection(_eventsCollection)
          .add(eventData);

      return docRef.id;
    } catch (e) {
      print('Error creating event: $e');
      throw Exception('Failed to create event: $e');
    }
  }

  /// Update an existing event
  Future<void> updateEvent(CalendarEvent event) async {
    try {
      final userId = await _getCurrentUserId();
      final eventData = event.toJson();
      eventData['userId'] = userId;
      eventData['updatedAt'] = FieldValue.serverTimestamp();

      await _firestore
          .collection(_eventsCollection)
          .doc(event.id)
          .update(eventData);
    } catch (e) {
      print('Error updating event: $e');
      throw Exception('Failed to update event: $e');
    }
  }

  /// Delete an event
  Future<void> deleteEvent(String eventId) async {
    try {
      await _firestore.collection(_eventsCollection).doc(eventId).delete();
    } catch (e) {
      print('Error deleting event: $e');
      throw Exception('Failed to delete event: $e');
    }
  }

  /// Get a specific event by ID
  Future<CalendarEvent?> getEventById(String eventId) async {
    try {
      final DocumentSnapshot doc = await _firestore
          .collection(_eventsCollection)
          .doc(eventId)
          .get();

      if (doc.exists) {
        return CalendarEvent.fromJson({
          'id': doc.id,
          ...doc.data() as Map<String, dynamic>,
        });
      }
      return null;
    } catch (e) {
      print('Error getting event by ID: $e');
      return null;
    }
  }

  /// Search events by title
  Future<List<CalendarEvent>> searchEvents(String query) async {
    try {
      final userId = await _getCurrentUserId();
      final QuerySnapshot snapshot = await _firestore
          .collection(_eventsCollection)
          .where('userId', isEqualTo: userId)
          .where('title', isGreaterThanOrEqualTo: query)
          .where('title', isLessThan: query + 'z')
          .orderBy('title')
          .get();

      return snapshot.docs
          .map(
            (doc) => CalendarEvent.fromJson({
              'id': doc.id,
              ...doc.data() as Map<String, dynamic>,
            }),
          )
          .toList();
    } catch (e) {
      print('Error searching events: $e');
      return [];
    }
  }

  /// Get events by priority
  Future<List<CalendarEvent>> getEventsByPriority(String priority) async {
    try {
      final userId = await _getCurrentUserId();
      final QuerySnapshot snapshot = await _firestore
          .collection(_eventsCollection)
          .where('userId', isEqualTo: userId)
          .where('priority', isEqualTo: priority)
          .orderBy('date', descending: false)
          .get();

      return snapshot.docs
          .map(
            (doc) => CalendarEvent.fromJson({
              'id': doc.id,
              ...doc.data() as Map<String, dynamic>,
            }),
          )
          .toList();
    } catch (e) {
      print('Error getting events by priority: $e');
      return [];
    }
  }

  /// Get completed events
  Future<List<CalendarEvent>> getCompletedEvents() async {
    try {
      final userId = await _getCurrentUserId();
      final QuerySnapshot snapshot = await _firestore
          .collection(_eventsCollection)
          .where('userId', isEqualTo: userId)
          .where('isCompleted', isEqualTo: true)
          .orderBy('date', descending: true)
          .get();

      return snapshot.docs
          .map(
            (doc) => CalendarEvent.fromJson({
              'id': doc.id,
              ...doc.data() as Map<String, dynamic>,
            }),
          )
          .toList();
    } catch (e) {
      print('Error getting completed events: $e');
      return [];
    }
  }

  /// Get pending events (not completed)
  Future<List<CalendarEvent>> getPendingEvents() async {
    try {
      final userId = await _getCurrentUserId();
      final QuerySnapshot snapshot = await _firestore
          .collection(_eventsCollection)
          .where('userId', isEqualTo: userId)
          .where('isCompleted', isEqualTo: false)
          .orderBy('date', descending: false)
          .get();

      return snapshot.docs
          .map(
            (doc) => CalendarEvent.fromJson({
              'id': doc.id,
              ...doc.data() as Map<String, dynamic>,
            }),
          )
          .toList();
    } catch (e) {
      print('Error getting pending events: $e');
      return [];
    }
  }
}
