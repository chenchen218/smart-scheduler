import 'package:flutter/material.dart';

class Task {
  String name;
  String priority;
  bool done;
  Color get color => priority == "High"
      ? Colors.red
      : (priority == "Medium" ? Colors.orange : Colors.green);

  Task({required this.name, this.priority = "Low", this.done = false});
}
