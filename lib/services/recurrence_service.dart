import '../models/calendar_event.dart';
import '../models/recurrence_pattern.dart';

/// Service for generating recurring event instances
class RecurrenceService {
  /// Generate recurring event instances for a given date range
  ///
  /// [parentEvent] - The parent recurring event
  /// [startDate] - Start of the date range to generate instances for
  /// [endDate] - End of the date range to generate instances for
  ///
  /// Returns a list of CalendarEvent instances
  List<CalendarEvent> generateInstances({
    required CalendarEvent parentEvent,
    required DateTime startDate,
    required DateTime endDate,
  }) {
    if (!parentEvent.isRecurring) {
      return [];
    }

    final pattern = parentEvent.recurrencePattern!;
    final instances = <CalendarEvent>[];

    // Start from the parent event's date
    DateTime currentDate = parentEvent.date;

    // Adjust currentDate if it's before startDate
    if (currentDate.isBefore(startDate)) {
      currentDate = _getNextOccurrence(
        pattern: pattern,
        fromDate: startDate,
        originalDate: parentEvent.date,
      );
    }

    // Generate instances until endDate or recurrence end
    int occurrenceCount = 0;
    while (currentDate.isBefore(endDate) ||
        currentDate.isAtSameMomentAs(endDate)) {
      // Check if recurrence has ended
      if (pattern.endDate != null && currentDate.isAfter(pattern.endDate!)) {
        break;
      }

      if (pattern.occurrenceCount != null) {
        if (occurrenceCount >= pattern.occurrenceCount!) {
          break;
        }
      }

      // Create instance
      final instance = _createInstance(
        parentEvent: parentEvent,
        instanceDate: currentDate,
      );
      instances.add(instance);

      // Get next occurrence
      currentDate = _getNextOccurrence(
        pattern: pattern,
        fromDate: currentDate,
        originalDate: parentEvent.date,
      );

      occurrenceCount++;

      // Safety limit to prevent infinite loops
      if (occurrenceCount > 1000) {
        break;
      }
    }

    return instances;
  }

  /// Get the next occurrence date based on the recurrence pattern
  DateTime _getNextOccurrence({
    required RecurrencePattern pattern,
    required DateTime fromDate,
    required DateTime originalDate,
  }) {
    switch (pattern.type) {
      case RecurrenceType.daily:
        return _getNextDailyOccurrence(
          fromDate: fromDate,
          interval: pattern.interval,
        );

      case RecurrenceType.weekly:
        return _getNextWeeklyOccurrence(
          fromDate: fromDate,
          originalDate: originalDate,
          interval: pattern.interval,
          daysOfWeek: pattern.daysOfWeek,
        );

      case RecurrenceType.monthly:
        return _getNextMonthlyOccurrence(
          fromDate: fromDate,
          originalDate: originalDate,
          interval: pattern.interval,
          dayOfMonth: pattern.dayOfMonth,
          weekOfMonth: pattern.weekOfMonth,
        );

      case RecurrenceType.yearly:
        return _getNextYearlyOccurrence(
          fromDate: fromDate,
          originalDate: originalDate,
          interval: pattern.interval,
          monthOfYear: pattern.monthOfYear,
          dayOfMonth: pattern.dayOfMonth,
        );

      case RecurrenceType.none:
      case RecurrenceType.custom:
        return fromDate.add(const Duration(days: 365)); // Default fallback
    }
  }

  /// Get next daily occurrence
  DateTime _getNextDailyOccurrence({
    required DateTime fromDate,
    required int interval,
  }) {
    return fromDate.add(Duration(days: interval));
  }

  /// Get next weekly occurrence
  DateTime _getNextWeeklyOccurrence({
    required DateTime fromDate,
    required DateTime originalDate,
    required int interval,
    List<int>? daysOfWeek,
  }) {
    if (daysOfWeek != null && daysOfWeek.isNotEmpty) {
      // Find next occurrence on specified days of week
      DateTime next = fromDate;

      // If we have specific days, find the next one
      for (int i = 0; i < 14; i++) {
        next = fromDate.add(Duration(days: i));
        final dayOfWeek = next.weekday;

        // Check if this day matches any of the specified days
        if (daysOfWeek.contains(dayOfWeek)) {
          // Check if we're in the right week interval
          final weeksSinceOriginal = (next.difference(originalDate).inDays / 7)
              .floor();
          if (weeksSinceOriginal % interval == 0) {
            return next;
          }
        }
      }
    }

    // Default: same day of week, every N weeks
    final daysSinceOriginal = fromDate.difference(originalDate).inDays;
    final weeksSinceOriginal = (daysSinceOriginal / 7).floor();
    final nextWeekNumber = ((weeksSinceOriginal ~/ interval) + 1) * interval;
    return originalDate.add(Duration(days: nextWeekNumber * 7));
  }

  /// Get next monthly occurrence
  DateTime _getNextMonthlyOccurrence({
    required DateTime fromDate,
    required DateTime originalDate,
    required int interval,
    int? dayOfMonth,
    int? weekOfMonth,
  }) {
    if (dayOfMonth != null) {
      // Same day of month
      DateTime next = DateTime(
        fromDate.year,
        fromDate.month + interval,
        dayOfMonth,
      );
      if (next.isBefore(fromDate)) {
        next = DateTime(
          fromDate.year,
          fromDate.month + interval * 2,
          dayOfMonth,
        );
      }
      return next;
    }

    if (weekOfMonth != null) {
      // Same week of month (e.g., first Monday, last Friday)
      // Simplified: use the same day of week as original
      final originalDayOfWeek = originalDate.weekday;
      DateTime next = DateTime(fromDate.year, fromDate.month + interval, 1);

      // Find the Nth occurrence of this day of week
      int found = 0;
      while (next.month == (fromDate.month + interval) % 12 ||
          next.month == 1) {
        if (next.weekday == originalDayOfWeek) {
          found++;
          if (found == weekOfMonth) {
            return next;
          }
        }
        next = next.add(const Duration(days: 1));
      }
    }

    // Default: same day of month as original
    return DateTime(fromDate.year, fromDate.month + interval, originalDate.day);
  }

  /// Get next yearly occurrence
  DateTime _getNextYearlyOccurrence({
    required DateTime fromDate,
    required DateTime originalDate,
    required int interval,
    int? monthOfYear,
    int? dayOfMonth,
  }) {
    final targetMonth = monthOfYear ?? originalDate.month;
    final targetDay = dayOfMonth ?? originalDate.day;

    DateTime next = DateTime(fromDate.year + interval, targetMonth, targetDay);
    if (next.isBefore(fromDate)) {
      next = DateTime(fromDate.year + interval * 2, targetMonth, targetDay);
    }
    return next;
  }

  /// Create an instance of a recurring event
  CalendarEvent _createInstance({
    required CalendarEvent parentEvent,
    required DateTime instanceDate,
  }) {
    // Calculate start and end dates/times for the instance
    DateTime? instanceStartDate;
    DateTime? instanceEndDate;

    if (parentEvent.startDate != null && parentEvent.endDate != null) {
      // Calculate duration
      final duration = parentEvent.endDate!.difference(parentEvent.startDate!);

      // Set start date to instance date with same time
      instanceStartDate = DateTime(
        instanceDate.year,
        instanceDate.month,
        instanceDate.day,
        parentEvent.startDate!.hour,
        parentEvent.startDate!.minute,
      );

      // Set end date
      instanceEndDate = instanceStartDate.add(duration);
    } else if (parentEvent.startTime != null) {
      instanceStartDate = DateTime(
        instanceDate.year,
        instanceDate.month,
        instanceDate.day,
        parentEvent.startTime!.hour,
        parentEvent.startTime!.minute,
      );

      if (parentEvent.endTime != null) {
        instanceEndDate = DateTime(
          instanceDate.year,
          instanceDate.month,
          instanceDate.day,
          parentEvent.endTime!.hour,
          parentEvent.endTime!.minute,
        );
      }
    }

    return parentEvent.copyWith(
      id: '${parentEvent.id}_${instanceDate.millisecondsSinceEpoch}',
      date: instanceDate,
      startDate: instanceStartDate,
      endDate: instanceEndDate,
      parentEventId: parentEvent.id,
      isRecurringInstance: true,
    );
  }

  /// Expand recurring events into instances for a date range
  /// This is used when loading events to show all instances
  List<CalendarEvent> expandRecurringEvents({
    required List<CalendarEvent> events,
    required DateTime startDate,
    required DateTime endDate,
  }) {
    final expanded = <CalendarEvent>[];

    for (final event in events) {
      if (event.isRecurring && !event.isRecurringInstance) {
        // Generate instances for this recurring event
        final instances = generateInstances(
          parentEvent: event,
          startDate: startDate,
          endDate: endDate,
        );
        expanded.addAll(instances);
      } else {
        // Non-recurring event or already an instance
        expanded.add(event);
      }
    }

    return expanded;
  }
}
