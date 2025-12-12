import 'package:flutter/material.dart';

/// Calendar view types
enum CalendarViewType { day, week, month, agenda, year }

extension CalendarViewTypeExtension on CalendarViewType {
  String get displayName {
    switch (this) {
      case CalendarViewType.day:
        return 'Day';
      case CalendarViewType.week:
        return 'Week';
      case CalendarViewType.month:
        return 'Month';
      case CalendarViewType.agenda:
        return 'Agenda';
      case CalendarViewType.year:
        return 'Year';
    }
  }

  IconData get icon {
    switch (this) {
      case CalendarViewType.day:
        return Icons.view_day;
      case CalendarViewType.week:
        return Icons.view_week;
      case CalendarViewType.month:
        return Icons.calendar_month;
      case CalendarViewType.agenda:
        return Icons.view_list;
      case CalendarViewType.year:
        return Icons.view_module;
    }
  }
}
