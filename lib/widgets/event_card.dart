import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/calendar_event.dart';

class EventCard extends StatelessWidget {
  final CalendarEvent event;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const EventCard({
    super.key,
    required this.event,
    this.onTap,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isToday = event.isToday;
    final isPast = event.isPast;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Card(
        elevation: event.isCompleted ? 1 : 3,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: event.isCompleted
                  ? LinearGradient(
                      colors: [
                        colorScheme.surface,
                        colorScheme.surfaceContainerHighest.withOpacity(0.3),
                      ],
                    )
                  : null,
              border: isToday && !event.isCompleted
                  ? Border.all(
                      color: colorScheme.primary.withOpacity(0.5),
                      width: 2,
                    )
                  : null,
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Time indicator
                  Container(
                    width: 4,
                    height: 60,
                    decoration: BoxDecoration(
                      color: event.color,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Event content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                event.title,
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(
                                      decoration: event.isCompleted
                                          ? TextDecoration.lineThrough
                                          : null,
                                      fontWeight: FontWeight.w600,
                                      color: event.isCompleted
                                          ? colorScheme.onSurfaceVariant
                                          : colorScheme.onSurface,
                                    ),
                              ),
                            ),
                            if (isToday && !event.isCompleted)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: colorScheme.primary.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  'Today',
                                  style: Theme.of(context).textTheme.labelSmall
                                      ?.copyWith(
                                        color: colorScheme.primary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                ),
                              ),
                          ],
                        ),
                        if (event.description.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            event.description,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(color: colorScheme.onSurfaceVariant),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            // Time
                            if (event.formattedTime.isNotEmpty) ...[
                              Icon(
                                event.isAllDay
                                    ? Icons.all_inclusive_rounded
                                    : Icons.access_time_rounded,
                                size: 16,
                                color: colorScheme.onSurfaceVariant,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                event.formattedTime,
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                              ),
                              const SizedBox(width: 16),
                            ],
                            // Location
                            if (event.location != null &&
                                event.location!.isNotEmpty) ...[
                              Icon(
                                Icons.location_on_rounded,
                                size: 16,
                                color: colorScheme.onSurfaceVariant,
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  event.location!,
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(
                                        color: colorScheme.onSurfaceVariant,
                                      ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                            const Spacer(),
                            // Status indicator
                            if (event.isCompleted)
                              Icon(
                                Icons.check_circle_rounded,
                                color: colorScheme.primary,
                                size: 20,
                              )
                            else if (isPast)
                              Icon(
                                Icons.schedule_rounded,
                                color: colorScheme.error,
                                size: 20,
                              ),
                          ],
                        ),
                        // Tags
                        if (event.tags.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 4,
                            children: event.tags.map((tag) {
                              return Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: event.color.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: event.color.withOpacity(0.3),
                                    width: 1,
                                  ),
                                ),
                                child: Text(
                                  tag,
                                  style: Theme.of(context).textTheme.labelSmall
                                      ?.copyWith(
                                        color: event.color,
                                        fontWeight: FontWeight.w500,
                                      ),
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ],
                    ),
                  ),
                  // Action buttons
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      switch (value) {
                        case 'edit':
                          onEdit?.call();
                          break;
                        case 'delete':
                          onDelete?.call();
                          break;
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit_rounded),
                            SizedBox(width: 8),
                            Text('Edit'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete_rounded, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Delete', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                    child: Icon(
                      Icons.more_vert_rounded,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
