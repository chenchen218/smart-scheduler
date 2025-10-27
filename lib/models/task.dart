import 'package:flutter/material.dart';

class Task {
  String id;
  String name;
  String priority;
  bool done;
  DateTime? deadline;
  DateTime createdAt;
  DateTime? updatedAt;

  Task({
    required this.id,
    required this.name,
    this.priority = "Low",
    this.done = false,
    this.deadline,
    DateTime? createdAt,
    this.updatedAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Color get color => priority == "High"
      ? Colors.red
      : (priority == "Medium" ? Colors.orange : Colors.green);

  // Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'priority': priority,
      'done': done,
      'deadline': deadline?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  // Create from JSON
  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      priority: json['priority'] ?? 'Low',
      done: json['done'] ?? false,
      deadline: json['deadline'] != null
          ? DateTime.parse(json['deadline'])
          : null,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
    );
  }

  // Copy with method for updates
  Task copyWith({
    String? id,
    String? name,
    String? priority,
    bool? done,
    DateTime? deadline,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Task(
      id: id ?? this.id,
      name: name ?? this.name,
      priority: priority ?? this.priority,
      done: done ?? this.done,
      deadline: deadline ?? this.deadline,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }
}
