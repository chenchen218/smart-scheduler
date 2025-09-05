import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import '../models/task.dart';
import '../widgets/task_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<Task> tasks = [];
  final GlobalKey<AnimatedListState> _listKey = GlobalKey();
  final Random rand = Random();
  Timer? autoTimer;

  final List<String> sampleTasks = [
    "Buy groceries",
    "Read Flutter docs",
    "Walk the dog",
    "Check emails",
    "Call Alice",
    "Fix bug #23",
    "Push new commit",
    "Prepare slides",
  ];

  @override
  void initState() {
    super.initState();
    _startAutoAddTasks();
  }

  void _startAutoAddTasks() {
    autoTimer = Timer.periodic(Duration(milliseconds: 500), (_) {
      if (tasks.length >= 8) {
        autoTimer?.cancel();
        return;
      }
      final name = sampleTasks[rand.nextInt(sampleTasks.length)];
      final priority = ["Low", "Medium", "High"][rand.nextInt(3)];
      final task = Task(name: name, priority: priority);
      tasks.insert(0, task);
      _listKey.currentState?.insertItem(0);

      Future.delayed(Duration(milliseconds: 1000 + rand.nextInt(1000)), () {
        if (mounted && tasks.contains(task)) {
          setState(() {
            task.done = true;
          });
        }
      });
    });
  }

  @override
  void dispose() {
    autoTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Auto To-Do Demo")),
      body: AnimatedList(
        key: _listKey,
        initialItemCount: tasks.length,
        itemBuilder: (context, index, animation) {
          final task = tasks[index];
          return SizeTransition(
            sizeFactor: animation,
            child: Dismissible(
              key: Key(task.name + index.toString()),
              background: Container(
                color: Colors.red,
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.only(left: 16),
                child: Icon(Icons.delete, color: Colors.white, size: 36),
              ),
              onDismissed: (_) => setState(() => tasks.removeAt(index)),
              child: TaskCard(
                task: task,
                onChecked: (val) => setState(() => task.done = val ?? false),
              ),
            ),
          );
        },
      ),
    );
  }
}
