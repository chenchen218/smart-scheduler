import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import '../models/task.dart';
import '../widgets/task_card.dart';
import 'add_event_screen.dart';

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
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              colorScheme.primaryContainer.withOpacity(0.3),
              colorScheme.secondaryContainer.withOpacity(0.2),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Modern App Bar
              Container(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: colorScheme.primary,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Icon(
                            Icons.task_alt_rounded,
                            color: colorScheme.onPrimary,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Auto To-Do Demo",
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: colorScheme.onSurface,
                                    ),
                              ),
                              Text(
                                "${tasks.where((t) => t.done).length} of ${tasks.length} completed",
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                              ),
                            ],
                          ),
                        ),
                        // Add Event Button
                        IconButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const AddEventScreen(),
                              ),
                            );
                          },
                          icon: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: colorScheme.secondary,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.event_rounded,
                              color: colorScheme.onSecondary,
                              size: 20,
                            ),
                          ),
                          tooltip: 'Add Event',
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    // Progress Bar
                    if (tasks.isNotEmpty)
                      Container(
                        height: 8,
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceVariant,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: FractionallySizedBox(
                          alignment: Alignment.centerLeft,
                          widthFactor: tasks.isEmpty
                              ? 0
                              : tasks.where((t) => t.done).length /
                                    tasks.length,
                          child: Container(
                            decoration: BoxDecoration(
                              color: colorScheme.primary,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              // Tasks List
              Expanded(
                child: tasks.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.task_alt_outlined,
                              size: 64,
                              color: colorScheme.onSurfaceVariant.withOpacity(
                                0.5,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              "No tasks yet",
                              style: Theme.of(context).textTheme.titleLarge
                                  ?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "Tasks will appear automatically",
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(
                                    color: colorScheme.onSurfaceVariant
                                        .withOpacity(0.7),
                                  ),
                            ),
                          ],
                        ),
                      )
                    : AnimatedList(
                        key: _listKey,
                        initialItemCount: tasks.length,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemBuilder: (context, index, animation) {
                          final task = tasks[index];
                          return SlideTransition(
                            position: animation.drive(
                              Tween(
                                begin: const Offset(1, 0),
                                end: Offset.zero,
                              ).chain(CurveTween(curve: Curves.easeOutCubic)),
                            ),
                            child: FadeTransition(
                              opacity: animation,
                              child: Dismissible(
                                key: Key(task.name + index.toString()),
                                background: Container(
                                  margin: const EdgeInsets.symmetric(
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.red.shade400,
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  alignment: Alignment.centerLeft,
                                  padding: const EdgeInsets.only(left: 20),
                                  child: const Icon(
                                    Icons.delete_rounded,
                                    color: Colors.white,
                                    size: 28,
                                  ),
                                ),
                                onDismissed: (_) =>
                                    setState(() => tasks.removeAt(index)),
                                child: TaskCard(
                                  task: task,
                                  onChecked: (val) =>
                                      setState(() => task.done = val ?? false),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
