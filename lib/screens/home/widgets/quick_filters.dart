import 'package:flutter/material.dart';
import '../../../models/filter_options.dart';

/// Quick Filter Buttons Widget
/// Provides quick access to common filter presets
class QuickFilters extends StatelessWidget {
  final FilterOptions? currentFilters;
  final Function(FilterOptions) onQuickFilterSelected;

  const QuickFilters({
    super.key,
    this.currentFilters,
    required this.onQuickFilterSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          _buildQuickFilterButton(
            context,
            label: 'Today',
            icon: Icons.today,
            filter: _getTodayFilter(),
          ),
          const SizedBox(width: 8),
          _buildQuickFilterButton(
            context,
            label: 'This Week',
            icon: Icons.view_week,
            filter: _getThisWeekFilter(),
          ),
          const SizedBox(width: 8),
          _buildQuickFilterButton(
            context,
            label: 'Overdue',
            icon: Icons.warning,
            filter: _getOverdueFilter(),
          ),
          const SizedBox(width: 8),
          _buildQuickFilterButton(
            context,
            label: 'High Priority',
            icon: Icons.flag,
            filter: _getHighPriorityFilter(),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickFilterButton(
    BuildContext context, {
    required String label,
    required IconData icon,
    required FilterOptions filter,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isActive = currentFilters?.quickFilter == filter.quickFilter;

    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [Icon(icon, size: 16), const SizedBox(width: 4), Text(label)],
      ),
      selected: isActive,
      onSelected: (selected) {
        if (selected) {
          onQuickFilterSelected(filter);
        } else {
          onQuickFilterSelected(const FilterOptions());
        }
      },
      selectedColor: colorScheme.primaryContainer,
      checkmarkColor: colorScheme.onPrimaryContainer,
    );
  }

  FilterOptions _getTodayFilter() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    return FilterOptions(
      startDate: today,
      endDate: tomorrow,
      quickFilter: 'today',
    );
  }

  FilterOptions _getThisWeekFilter() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final startOfWeek = today.subtract(Duration(days: today.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 7));
    return FilterOptions(
      startDate: startOfWeek,
      endDate: endOfWeek,
      quickFilter: 'this_week',
    );
  }

  FilterOptions _getOverdueFilter() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return FilterOptions(
      endDate: today,
      isCompleted: false,
      quickFilter: 'overdue',
    );
  }

  FilterOptions _getHighPriorityFilter() {
    return FilterOptions(priorities: ['High'], quickFilter: 'high_priority');
  }
}
