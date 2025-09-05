import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/task.dart';

class ApiService {
  final String baseUrl = "https://jsonplaceholder.typicode.com";

  /// Fetch tasks from JSONPlaceholder
  Future<List<Task>> fetchTasks() async {
    final response = await http.get(Uri.parse('$baseUrl/todos?_limit=5'));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) {
        return Task(
          name: json['title'],
          done: json['completed'],
          priority: ["Low", "Medium", "High"][(json['id'] % 3)],
        );
      }).toList();
    } else {
      throw Exception('Failed to load tasks');
    }
  }

  /// Simulate adding a task (JSONPlaceholder ignores POST but returns created object)
  Future<Task> addTask(String name, String priority) async {
    final response = await http.post(
      Uri.parse('$baseUrl/todos'),
      body: json.encode({'title': name, 'completed': false}),
      headers: {"Content-Type": "application/json"},
    );

    if (response.statusCode == 201) {
      return Task(name: name, priority: priority, done: false);
    } else {
      throw Exception('Failed to add task');
    }
  }

  /// Simulate update task
  Future<Task> updateTask(Task task) async {
    final response = await http.put(
      Uri.parse('$baseUrl/todos/1'), // JSONPlaceholder ignores actual ID
      body: json.encode({'title': task.name, 'completed': task.done}),
      headers: {"Content-Type": "application/json"},
    );

    if (response.statusCode == 200) {
      return task;
    } else {
      throw Exception('Failed to update task');
    }
  }

  /// Simulate delete task
  Future<void> deleteTask(Task task) async {
    await http.delete(Uri.parse('$baseUrl/todos/1')); // API ignores actual ID
  }
}
