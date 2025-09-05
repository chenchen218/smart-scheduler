import 'package:flutter/material.dart';
import 'screens/home.dart';

void main() => runApp(MiniTodoApp());

class MiniTodoApp extends StatelessWidget {
  const MiniTodoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Mini To-Do App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: HomePage(),
    );
  }
}
