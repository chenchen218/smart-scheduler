/// Recurrence pattern types for recurring events
enum RecurrenceType { none, daily, weekly, monthly, yearly, custom }

/// Recurrence pattern model
class RecurrencePattern {
  final RecurrenceType type;
  final int interval; // e.g., every 2 weeks, every 3 months
  final List<int>? daysOfWeek; // For weekly: [1,3,5] = Mon, Wed, Fri
  final int? dayOfMonth; // For monthly: day 15
  final int? weekOfMonth; // For monthly: first, second, third, fourth, last
  final int? monthOfYear; // For yearly: month number (1-12)
  final int? occurrenceCount; // Number of occurrences (alternative to endDate)
  final DateTime? endDate; // End date for recurrence

  const RecurrencePattern({
    required this.type,
    this.interval = 1,
    this.daysOfWeek,
    this.dayOfMonth,
    this.weekOfMonth,
    this.monthOfYear,
    this.occurrenceCount,
    this.endDate,
  });

  /// Create a daily recurrence
  factory RecurrencePattern.daily({
    int interval = 1,
    int? occurrenceCount,
    DateTime? endDate,
  }) {
    return RecurrencePattern(
      type: RecurrenceType.daily,
      interval: interval,
      occurrenceCount: occurrenceCount,
      endDate: endDate,
    );
  }

  /// Create a weekly recurrence
  factory RecurrencePattern.weekly({
    int interval = 1,
    List<int>? daysOfWeek, // 1 = Monday, 7 = Sunday
    int? occurrenceCount,
    DateTime? endDate,
  }) {
    return RecurrencePattern(
      type: RecurrenceType.weekly,
      interval: interval,
      daysOfWeek: daysOfWeek,
      occurrenceCount: occurrenceCount,
      endDate: endDate,
    );
  }

  /// Create a monthly recurrence
  factory RecurrencePattern.monthly({
    int interval = 1,
    int? dayOfMonth, // Day of month (1-31)
    int? weekOfMonth, // Week of month (1-4, 5 = last)
    int? occurrenceCount,
    DateTime? endDate,
  }) {
    return RecurrencePattern(
      type: RecurrenceType.monthly,
      interval: interval,
      dayOfMonth: dayOfMonth,
      weekOfMonth: weekOfMonth,
      occurrenceCount: occurrenceCount,
      endDate: endDate,
    );
  }

  /// Create a yearly recurrence
  factory RecurrencePattern.yearly({
    int interval = 1,
    int? monthOfYear, // Month (1-12)
    int? dayOfMonth, // Day of month
    int? occurrenceCount,
    DateTime? endDate,
  }) {
    return RecurrencePattern(
      type: RecurrenceType.yearly,
      interval: interval,
      monthOfYear: monthOfYear,
      dayOfMonth: dayOfMonth,
      occurrenceCount: occurrenceCount,
      endDate: endDate,
    );
  }

  /// Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'type': type.name,
      'interval': interval,
      'daysOfWeek': daysOfWeek,
      'dayOfMonth': dayOfMonth,
      'weekOfMonth': weekOfMonth,
      'monthOfYear': monthOfYear,
      'occurrenceCount': occurrenceCount,
      'endDate': endDate?.toIso8601String(),
    };
  }

  /// Create from JSON
  factory RecurrencePattern.fromJson(Map<String, dynamic> json) {
    return RecurrencePattern(
      type: RecurrenceType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => RecurrenceType.none,
      ),
      interval: json['interval'] ?? 1,
      daysOfWeek: json['daysOfWeek'] != null
          ? List<int>.from(json['daysOfWeek'])
          : null,
      dayOfMonth: json['dayOfMonth'],
      weekOfMonth: json['weekOfMonth'],
      monthOfYear: json['monthOfYear'],
      occurrenceCount: json['occurrenceCount'],
      endDate: json['endDate'] != null ? DateTime.parse(json['endDate']) : null,
    );
  }

  /// Convert to human-readable string
  String toDisplayString() {
    switch (type) {
      case RecurrenceType.none:
        return 'No repeat';
      case RecurrenceType.daily:
        if (interval == 1) {
          return 'Daily';
        }
        return 'Every $interval days';
      case RecurrenceType.weekly:
        if (interval == 1) {
          if (daysOfWeek != null && daysOfWeek!.length == 1) {
            final dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
            return 'Every ${dayNames[daysOfWeek![0] - 1]}';
          }
          return 'Weekly';
        }
        return 'Every $interval weeks';
      case RecurrenceType.monthly:
        if (interval == 1) {
          if (dayOfMonth != null) {
            return 'Monthly on day $dayOfMonth';
          }
          return 'Monthly';
        }
        return 'Every $interval months';
      case RecurrenceType.yearly:
        if (interval == 1) {
          return 'Yearly';
        }
        return 'Every $interval years';
      case RecurrenceType.custom:
        return 'Custom';
    }
  }

  /// Check if recurrence has ended
  bool hasEnded(DateTime startDate) {
    if (endDate != null) {
      return DateTime.now().isAfter(endDate!);
    }
    if (occurrenceCount != null) {
      // This would need to be calculated based on generated instances
      return false; // Simplified for now
    }
    return false; // No end date
  }
}
