import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/task.dart';
import 'notification_service.dart';

class TaskService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  final NotificationService _notificationService = NotificationService();

  /// Get the current user's tasks collection reference
  CollectionReference get _tasksCollection {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }
    return _firestore.collection('users').doc(user.uid).collection('tasks');
  }

  /// Get all tasks for the current user
  Future<List<Task>> getTasks() async {
    try {
      final snapshot = await _tasksCollection
          .orderBy('createdAt', descending: true)
          .get();
      return snapshot.docs
          .map((doc) => Task.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error fetching tasks from Firestore: $e');
      return [];
    }
  }

  /// Create a new task
  Future<Task> createTask(Task task) async {
    try {
      await _tasksCollection.doc(task.id).set(task.toJson());

      // Schedule notification for the task if it has a deadline
      if (task.deadline != null) {
        await _notificationService.scheduleTaskDeadline(task);
      }

      return task;
    } catch (e) {
      print('Error creating task in Firestore: $e');
      rethrow;
    }
  }

  /// Update an existing task
  Future<Task> updateTask(Task task) async {
    try {
      await _tasksCollection.doc(task.id).update(task.toJson());

      // Cancel old notification and schedule new one if deadline changed
      await _notificationService.cancelNotification(task.id.hashCode);
      if (task.deadline != null) {
        await _notificationService.scheduleTaskDeadline(task);
      }

      return task;
    } catch (e) {
      print('Error updating task in Firestore: $e');
      rethrow;
    }
  }

  /// Delete a task
  Future<void> deleteTask(String taskId) async {
    try {
      await _tasksCollection.doc(taskId).delete();

      // Cancel notification for deleted task
      await _notificationService.cancelNotification(taskId.hashCode);
    } catch (e) {
      print('Error deleting task from Firestore: $e');
      rethrow;
    }
  }

  /// Toggle task completion status
  Future<Task> toggleTaskCompletion(String taskId) async {
    try {
      final doc = await _tasksCollection.doc(taskId).get();
      if (!doc.exists) {
        throw Exception('Task not found');
      }

      final task = Task.fromJson(doc.data() as Map<String, dynamic>);
      final updatedTask = task.copyWith(done: !task.done);

      await _tasksCollection.doc(taskId).update(updatedTask.toJson());

      // Cancel notification if task is completed
      if (updatedTask.done) {
        await _notificationService.cancelNotification(taskId.hashCode);
      } else if (updatedTask.deadline != null) {
        // Reschedule notification if task is uncompleted and has deadline
        await _notificationService.scheduleTaskDeadline(updatedTask);
      }

      return updatedTask;
    } catch (e) {
      print('Error toggling task completion: $e');
      rethrow;
    }
  }

  /// Get tasks with upcoming deadlines
  Future<List<Task>> getTasksWithUpcomingDeadlines({int daysAhead = 7}) async {
    try {
      final now = DateTime.now();
      final futureDate = now.add(Duration(days: daysAhead));

      final snapshot = await _tasksCollection
          .where('deadline', isGreaterThan: now.toIso8601String())
          .where('deadline', isLessThan: futureDate.toIso8601String())
          .where('done', isEqualTo: false)
          .orderBy('deadline')
          .get();

      return snapshot.docs
          .map((doc) => Task.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error fetching tasks with upcoming deadlines: $e');
      return [];
    }
  }

  /// Schedule notifications for all tasks with deadlines
  Future<void> scheduleAllTaskNotifications() async {
    try {
      final tasks = await getTasks();
      for (final task in tasks) {
        if (task.deadline != null && !task.done) {
          await _notificationService.scheduleTaskDeadline(task);
        }
      }
      print('TaskService: Scheduled notifications for ${tasks.length} tasks');
    } catch (e) {
      print('TaskService: Error scheduling task notifications: $e');
    }
  }

  /// Search tasks by name
  Future<List<Task>> searchTasks(String query) async {
    try {
      final allTasks = await getTasks();
      final queryLower = query.toLowerCase();
      return allTasks
          .where((task) => task.name.toLowerCase().contains(queryLower))
          .toList();
    } catch (e) {
      print('Error searching tasks: $e');
      return [];
    }
  }
}
