import 'package:flutter/material.dart';
import '../../../models/filter_options.dart';

/// Sort Panel Widget
/// Provides UI for sorting tasks and events
class SortPanel extends StatefulWidget {
  final SortOptions currentSort;
  final Function(SortOptions) onSortChanged;

  const SortPanel({
    super.key,
    required this.currentSort,
    required this.onSortChanged,
  });

  @override
  State<SortPanel> createState() => _SortPanelState();
}

class _SortPanelState extends State<SortPanel> {
  late SortOptions _sort;

  @override
  void initState() {
    super.initState();
    _sort = widget.currentSort;
  }

  @override
  void didUpdateWidget(SortPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentSort != widget.currentSort) {
      _sort = widget.currentSort;
    }
  }

  void _updateSort(SortOptions newSort) {
    setState(() {
      _sort = newSort;
    });
    widget.onSortChanged(newSort);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Sort By', style: theme.textTheme.titleLarge),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Sort Field
          _buildSortField(theme),
          const SizedBox(height: 16),
          // Sort Order
          _buildSortOrder(theme),
          const SizedBox(height: 24),
          // Apply Button
          FilledButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }

  Widget _buildSortField(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Sort Field', style: theme.textTheme.titleSmall),
        const SizedBox(height: 8),
        SegmentedButton<SortField>(
          segments: const [
            ButtonSegment(
              value: SortField.date,
              label: Text('Date'),
              icon: Icon(Icons.calendar_today, size: 18),
            ),
            ButtonSegment(
              value: SortField.priority,
              label: Text('Priority'),
              icon: Icon(Icons.flag, size: 18),
            ),
            ButtonSegment(
              value: SortField.title,
              label: Text('Title'),
              icon: Icon(Icons.title, size: 18),
            ),
          ],
          selected: {_sort.field},
          onSelectionChanged: (Set<SortField> selected) {
            _updateSort(_sort.copyWith(field: selected.first));
          },
        ),
      ],
    );
  }

  Widget _buildSortOrder(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Sort Order', style: theme.textTheme.titleSmall),
        const SizedBox(height: 8),
        SegmentedButton<SortOrder>(
          segments: const [
            ButtonSegment(
              value: SortOrder.ascending,
              label: Text('Ascending'),
              icon: Icon(Icons.arrow_upward, size: 18),
            ),
            ButtonSegment(
              value: SortOrder.descending,
              label: Text('Descending'),
              icon: Icon(Icons.arrow_downward, size: 18),
            ),
          ],
          selected: {_sort.order},
          onSelectionChanged: (Set<SortOrder> selected) {
            _updateSort(_sort.copyWith(order: selected.first));
          },
        ),
      ],
    );
  }
}
