import 'package:flutter/material.dart';

/// Calendar Header Widget
/// Displays the calendar title, selected date, navigation, and add button
class CalendarHeader extends StatelessWidget {
  final String selectedDateText;
  final VoidCallback onAddEvent;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;
  final VoidCallback? onToday;

  const CalendarHeader({
    super.key,
    required this.selectedDateText,
    required this.onAddEvent,
    this.onPrevious,
    this.onNext,
    this.onToday,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colorScheme.primary,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              Icons.calendar_month_rounded,
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
                  "Calendar",
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
                Text(
                  selectedDateText,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          // Navigation buttons
          if (onPrevious != null || onNext != null || onToday != null) ...[
            if (onPrevious != null)
              IconButton(
                onPressed: onPrevious,
                icon: Icon(
                  Icons.chevron_left_rounded,
                  color: colorScheme.primary,
                ),
                tooltip: 'Previous',
              ),
            if (onToday != null)
              TextButton(
                onPressed: onToday,
                child: Text(
                  'Today',
                  style: TextStyle(color: colorScheme.primary),
                ),
              ),
            if (onNext != null)
              IconButton(
                onPressed: onNext,
                icon: Icon(
                  Icons.chevron_right_rounded,
                  color: colorScheme.primary,
                ),
                tooltip: 'Next',
              ),
          ],
          IconButton(
            onPressed: onAddEvent,
            icon: Icon(Icons.add_rounded, color: colorScheme.primary),
            tooltip: 'Add Event',
          ),
        ],
      ),
    );
  }
}
