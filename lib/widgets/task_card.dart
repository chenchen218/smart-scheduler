import 'package:flutter/material.dart';
import '../models/task.dart';

class TaskCard extends StatelessWidget {
  final Task task;
  final Function(bool?) onChecked;

  const TaskCard({super.key, required this.task, required this.onChecked});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isHighPriority = task.priority == "High";

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Card(
        elevation: task.done ? 1 : 3,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: task.done
                ? LinearGradient(
                    colors: [
                      colorScheme.surface,
                      colorScheme.surfaceVariant.withOpacity(0.3),
                    ],
                  )
                : null,
            border: isHighPriority && !task.done
                ? Border.all(
                    color: colorScheme.primary.withOpacity(0.3),
                    width: 1,
                  )
                : null,
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Custom Checkbox
                GestureDetector(
                  onTap: () => onChecked(!task.done),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: task.done
                          ? colorScheme.primary
                          : Colors.transparent,
                      border: Border.all(
                        color: task.done
                            ? colorScheme.primary
                            : colorScheme.outline,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: task.done
                        ? Icon(
                            Icons.check_rounded,
                            color: colorScheme.onPrimary,
                            size: 16,
                          )
                        : null,
                  ),
                ),
                const SizedBox(width: 16),
                // Task Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        task.name,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              decoration: task.done
                                  ? TextDecoration.lineThrough
                                  : null,
                              fontWeight: isHighPriority
                                  ? FontWeight.w600
                                  : FontWeight.w500,
                              color: task.done
                                  ? colorScheme.onSurfaceVariant
                                  : colorScheme.onSurface,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          // Priority Badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: _getPriorityColor(
                                task.priority,
                              ).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: _getPriorityColor(
                                  task.priority,
                                ).withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: BoxDecoration(
                                    color: _getPriorityColor(task.priority),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  task.priority,
                                  style: Theme.of(context).textTheme.labelSmall
                                      ?.copyWith(
                                        color: _getPriorityColor(task.priority),
                                        fontWeight: FontWeight.w600,
                                      ),
                                ),
                              ],
                            ),
                          ),
                          const Spacer(),
                          // Status Icon
                          if (task.done)
                            Icon(
                              Icons.check_circle_rounded,
                              color: colorScheme.primary,
                              size: 20,
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getPriorityColor(String priority) {
    switch (priority) {
      case "High":
        return Colors.red.shade500;
      case "Medium":
        return Colors.orange.shade500;
      case "Low":
        return Colors.green.shade500;
      default:
        return Colors.grey.shade500;
    }
  }
}
