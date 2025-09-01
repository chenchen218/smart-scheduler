import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'models/todo_list.dart';
import 'screens/home.dart';

void main() {
  runApp(
    ChangeNotifierProvider(create: (_) => TodoList(), child: const MyApp()),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mini To-Do App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const HomeScreen(),
    );
  }
}
