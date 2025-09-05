import 'package:flutter/material.dart';
import '../models/task.dart';

class TaskCard extends StatelessWidget {
  final Task task;
  final Function(bool?) onChecked;

  const TaskCard({super.key, required this.task, required this.onChecked});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: ListTile(
        leading: Checkbox(value: task.done, onChanged: onChecked),
        title: Text(
          task.name,
          style: TextStyle(
            decoration: task.done ? TextDecoration.lineThrough : null,
            fontWeight: task.priority == "High"
                ? FontWeight.bold
                : FontWeight.normal,
          ),
        ),
        trailing: Text(
          task.priority,
          style: TextStyle(color: task.color, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
