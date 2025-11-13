import 'package:flutter/material.dart';
import 'recurrence_pattern.dart';

class CalendarEvent {
  final String id;
  final String title;
  final String description;
  final DateTime date;
  final TimeOfDay? startTime;
  final TimeOfDay? endTime;
  final Color color;
  final bool isAllDay;
  final String? location;
  final List<String> tags;
  final bool isCompleted;
  final String priority;

  // External calendar integration fields
  final String? source; // 'app', 'device_calendar', 'google_calendar'
  final String? externalId; // ID from external calendar
  final String? calendarId; // Calendar ID from external system
  final DateTime? startDate; // Full start date with time
  final DateTime? endDate; // Full end date with time

  // Recurring event fields
  final RecurrencePattern? recurrencePattern;
  final String?
  parentEventId; // ID of the parent recurring event (for instances)
  final bool
  isRecurringInstance; // True if this is an instance of a recurring event

  CalendarEvent({
    required this.id,
    required this.title,
    this.description = '',
    required this.date,
    this.startTime,
    this.endTime,
    this.color = Colors.blue,
    this.isAllDay = false,
    this.location,
    this.tags = const [],
    this.isCompleted = false,
    this.priority = 'Medium',
    this.source = 'app',
    this.externalId,
    this.calendarId,
    this.startDate,
    this.endDate,
    this.recurrencePattern,
    this.parentEventId,
    this.isRecurringInstance = false,
  });

  CalendarEvent copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? date,
    TimeOfDay? startTime,
    TimeOfDay? endTime,
    Color? color,
    bool? isAllDay,
    String? location,
    List<String>? tags,
    bool? isCompleted,
    String? priority,
    String? source,
    String? externalId,
    String? calendarId,
    DateTime? startDate,
    DateTime? endDate,
    RecurrencePattern? recurrencePattern,
    String? parentEventId,
    bool? isRecurringInstance,
  }) {
    return CalendarEvent(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      date: date ?? this.date,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      color: color ?? this.color,
      isAllDay: isAllDay ?? this.isAllDay,
      location: location ?? this.location,
      tags: tags ?? this.tags,
      isCompleted: isCompleted ?? this.isCompleted,
      priority: priority ?? this.priority,
      source: source ?? this.source,
      externalId: externalId ?? this.externalId,
      calendarId: calendarId ?? this.calendarId,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      recurrencePattern: recurrencePattern ?? this.recurrencePattern,
      parentEventId: parentEventId ?? this.parentEventId,
      isRecurringInstance: isRecurringInstance ?? this.isRecurringInstance,
    );
  }

  /// Helper method to parse TimeOfDay from string
  static TimeOfDay _parseTimeOfDay(String timeString) {
    final parts = timeString.split(':');
    if (parts.length == 2) {
      return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
    }
    // Fallback to current time if parsing fails
    return TimeOfDay.now();
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'date': date.toIso8601String(),
      'startTime': startTime != null
          ? '${startTime!.hour}:${startTime!.minute}'
          : null,
      'endTime': endTime != null ? '${endTime!.hour}:${endTime!.minute}' : null,
      'color': color.value,
      'isAllDay': isAllDay,
      'location': location,
      'tags': tags,
      'isCompleted': isCompleted,
      'priority': priority,
      'source': source,
      'externalId': externalId,
      'calendarId': calendarId,
      'startDate': startDate?.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'recurrencePattern': recurrencePattern?.toJson(),
      'parentEventId': parentEventId,
      'isRecurringInstance': isRecurringInstance,
    };
  }

  factory CalendarEvent.fromJson(Map<String, dynamic> json) {
    return CalendarEvent(
      id: json['id'],
      title: json['title'],
      description: json['description'] ?? '',
      date: DateTime.parse(json['date']),
      startTime: json['startTime'] != null
          ? _parseTimeOfDay(json['startTime'])
          : null,
      endTime: json['endTime'] != null
          ? _parseTimeOfDay(json['endTime'])
          : null,
      color: Color(json['color']),
      isAllDay: json['isAllDay'] ?? false,
      location: json['location'],
      tags: List<String>.from(json['tags'] ?? []),
      isCompleted: json['isCompleted'] ?? false,
      priority: json['priority'] ?? 'Medium',
      source: json['source'] ?? 'app',
      externalId: json['externalId'],
      calendarId: json['calendarId'],
      startDate: json['startDate'] != null
          ? DateTime.parse(json['startDate'])
          : null,
      endDate: json['endDate'] != null ? DateTime.parse(json['endDate']) : null,
      recurrencePattern: json['recurrencePattern'] != null
          ? RecurrencePattern.fromJson(json['recurrencePattern'])
          : null,
      parentEventId: json['parentEventId'],
      isRecurringInstance: json['isRecurringInstance'] ?? false,
    );
  }

  String get formattedTime {
    if (isAllDay) return 'All Day';
    if (startTime == null) return '';
    if (endTime == null) return _formatTimeOfDay(startTime!);
    return '${_formatTimeOfDay(startTime!)} - ${_formatTimeOfDay(endTime!)}';
  }

  String _formatTimeOfDay(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  bool get isToday {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  bool get isPast {
    final now = DateTime.now();
    return date.isBefore(DateTime(now.year, now.month, now.day));
  }

  /// Check if this event is recurring
  bool get isRecurring {
    return recurrencePattern != null &&
        recurrencePattern!.type != RecurrenceType.none;
  }

  /// Get display text for recurrence
  String get recurrenceDisplayText {
    if (!isRecurring) return '';
    return recurrencePattern!.toDisplayString();
  }
}
