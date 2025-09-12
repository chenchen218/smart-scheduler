import 'package:flutter/material.dart';

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
    );
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
    };
  }

  factory CalendarEvent.fromJson(Map<String, dynamic> json) {
    return CalendarEvent(
      id: json['id'],
      title: json['title'],
      description: json['description'] ?? '',
      date: DateTime.parse(json['date']),
      startTime: json['startTime'] != null
          ? TimeOfDay.fromDateTime(
              DateTime.parse('2023-01-01 ${json['startTime']}'),
            )
          : null,
      endTime: json['endTime'] != null
          ? TimeOfDay.fromDateTime(
              DateTime.parse('2023-01-01 ${json['endTime']}'),
            )
          : null,
      color: Color(json['color']),
      isAllDay: json['isAllDay'] ?? false,
      location: json['location'],
      tags: List<String>.from(json['tags'] ?? []),
      isCompleted: json['isCompleted'] ?? false,
      priority: json['priority'] ?? 'Medium',
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
}
