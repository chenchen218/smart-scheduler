import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:flutter/foundation.dart';
import '../models/calendar_event.dart';
import '../models/task.dart';
import 'settings_service.dart';

/// Notification Service
/// Handles local notifications for events and tasks
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();
  final SettingsService _settingsService = SettingsService();

  bool _isInitialized = false;
  bool _notificationsEnabled = true;

  /// Initialize the notification service
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Initialize timezone data
      tz.initializeTimeZones();

      // Android initialization settings
      const AndroidInitializationSettings androidSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      // iOS initialization settings
      const DarwinInitializationSettings iosSettings =
          DarwinInitializationSettings(
            requestAlertPermission: true,
            requestBadgePermission: true,
            requestSoundPermission: true,
          );

      // Combined initialization settings
      const InitializationSettings initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      // Initialize the plugin
      await _notifications.initialize(
        initSettings,
        onDidReceiveNotificationResponse: _onNotificationTapped,
      );

      // Request permissions
      await _requestPermissions();

      // Load notification settings
      _notificationsEnabled = await _settingsService.getNotificationsEnabled();

      _isInitialized = true;
      print('NotificationService: Initialized successfully');
    } catch (e) {
      print('NotificationService: Initialization failed: $e');
    }
  }

  /// Request notification permissions
  Future<void> _requestPermissions() async {
    if (defaultTargetPlatform == TargetPlatform.android) {
      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
          _notifications
              .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin
              >();

      await androidImplementation?.requestNotificationsPermission();
      await androidImplementation?.requestExactAlarmsPermission();
    }
  }

  /// Handle notification tap
  void _onNotificationTapped(NotificationResponse response) {
    print('Notification tapped: ${response.payload}');
    // TODO: Navigate to specific event/task based on payload
  }

  /// Check if notifications are enabled
  Future<bool> get isEnabled async {
    await initialize();
    return _notificationsEnabled;
  }

  /// Enable/disable notifications
  Future<void> setEnabled(bool enabled) async {
    _notificationsEnabled = enabled;
    await _settingsService.setNotificationsEnabled(enabled);

    if (!enabled) {
      // Cancel all pending notifications when disabled
      await cancelAllNotifications();
    }
  }

  /// Schedule event reminder notification
  Future<void> scheduleEventReminder(
    CalendarEvent event, {
    int minutesBefore = 15,
  }) async {
    if (!_notificationsEnabled) return;

    try {
      await initialize();

      final reminderTime = event.startDate?.subtract(
        Duration(minutes: minutesBefore),
      );
      final now = DateTime.now();

      // Don't schedule if reminder time is null or in the past
      if (reminderTime == null || reminderTime.isBefore(now)) return;

      final notificationId = event.id.hashCode;

      const AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
            'event_reminders',
            'Event Reminders',
            channelDescription: 'Notifications for upcoming events',
            importance: Importance.high,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
          );

      const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const NotificationDetails notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _notifications.zonedSchedule(
        notificationId,
        'Event Reminder',
        '${event.title} starts in $minutesBefore minutes',
        tz.TZDateTime.from(reminderTime, tz.local),
        notificationDetails,
        payload: 'event:${event.id}',
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );

      print(
        'NotificationService: Scheduled reminder for "${event.title}" at $reminderTime',
      );
    } catch (e) {
      print('NotificationService: Failed to schedule event reminder: $e');
    }
  }

  /// Schedule task deadline notification
  Future<void> scheduleTaskDeadline(Task task, {int hoursBefore = 1}) async {
    if (!_notificationsEnabled) return;

    try {
      await initialize();

      // For tasks without specific deadline, use a default reminder
      final deadlineTime =
          task.deadline ?? DateTime.now().add(const Duration(hours: 24));
      final reminderTime = deadlineTime.subtract(Duration(hours: hoursBefore));
      final now = DateTime.now();

      // Don't schedule if reminder time is in the past
      if (reminderTime.isBefore(now)) return;

      final notificationId = task.id.hashCode;

      const AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
            'task_deadlines',
            'Task Deadlines',
            channelDescription: 'Notifications for upcoming task deadlines',
            importance: Importance.high,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
          );

      const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const NotificationDetails notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _notifications.zonedSchedule(
        notificationId,
        'Task Deadline',
        '${task.name} deadline is approaching',
        tz.TZDateTime.from(reminderTime, tz.local),
        notificationDetails,
        payload: 'task:${task.id}',
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );

      print(
        'NotificationService: Scheduled deadline reminder for "${task.name}" at $reminderTime',
      );
    } catch (e) {
      print('NotificationService: Failed to schedule task deadline: $e');
    }
  }

  /// Show immediate notification (for testing)
  Future<void> showImmediateNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    if (!_notificationsEnabled) return;

    try {
      await initialize();

      const AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
            'immediate',
            'Immediate Notifications',
            channelDescription: 'Immediate notifications for testing',
            importance: Importance.high,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
          );

      const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const NotificationDetails notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _notifications.show(
        DateTime.now().millisecondsSinceEpoch ~/ 1000,
        title,
        body,
        notificationDetails,
        payload: payload,
      );

      print('NotificationService: Showed immediate notification: $title');
    } catch (e) {
      print('NotificationService: Failed to show immediate notification: $e');
    }
  }

  /// Cancel specific notification
  Future<void> cancelNotification(int id) async {
    try {
      await _notifications.cancel(id);
      print('NotificationService: Cancelled notification $id');
    } catch (e) {
      print('NotificationService: Failed to cancel notification $id: $e');
    }
  }

  /// Cancel all pending notifications
  Future<void> cancelAllNotifications() async {
    try {
      if (!_isInitialized) {
        await initialize();
      }
      await _notifications.cancelAll();
      print('NotificationService: Cancelled all notifications');
    } catch (e) {
      print('NotificationService: Failed to cancel all notifications: $e');
    }
  }

  /// Get pending notifications (for debugging)
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    try {
      return await _notifications.pendingNotificationRequests();
    } catch (e) {
      print('NotificationService: Failed to get pending notifications: $e');
      return [];
    }
  }
}
