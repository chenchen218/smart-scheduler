import 'package:flutter/material.dart';
import '../../../models/filter_options.dart';
import '../../../models/task.dart';
import '../../../models/calendar_event.dart';
import 'filter_preset_dialog.dart';

/// Filter Panel Widget
/// Provides UI for filtering tasks and events
class FilterPanel extends StatefulWidget {
  final FilterOptions currentFilters;
  final SortOptions? currentSort;
  final List<Task> allTasks;
  final List<CalendarEvent> allEvents;
  final Function(FilterOptions) onFiltersChanged;
  final Function(SortOptions)? onSortChanged;

  const FilterPanel({
    super.key,
    required this.currentFilters,
    this.currentSort,
    required this.allTasks,
    required this.allEvents,
    required this.onFiltersChanged,
    this.onSortChanged,
  });

  @override
  State<FilterPanel> createState() => _FilterPanelState();
}

class _FilterPanelState extends State<FilterPanel> {
  late FilterOptions _filters;

  @override
  void initState() {
    super.initState();
    _filters = widget.currentFilters;
  }

  @override
  void didUpdateWidget(FilterPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentFilters != widget.currentFilters) {
      _filters = widget.currentFilters;
    }
  }

  void _updateFilters(FilterOptions newFilters) {
    setState(() {
      _filters = newFilters;
    });
    widget.onFiltersChanged(newFilters);
  }

  List<String> _getAllPriorities() {
    final priorities = <String>{};
    for (final task in widget.allTasks) {
      priorities.add(task.priority);
    }
    for (final event in widget.allEvents) {
      priorities.add(event.priority);
    }
    return priorities.toList()..sort();
  }

  List<String> _getAllTags() {
    final tags = <String>{};
    for (final event in widget.allEvents) {
      tags.addAll(event.tags);
    }
    return tags.toList()..sort();
  }

  List<String> _getAllSources() {
    final sources = <String>{};
    for (final event in widget.allEvents) {
      if (event.source != null) {
        sources.add(event.source!);
      }
    }
    return sources.toList()..sort();
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
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Filters', style: theme.textTheme.titleLarge),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.bookmark_outline),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => FilterPresetDialog(
                            currentFilters: _filters,
                            currentSort: widget.currentSort,
                            onPresetSelected: (filters, sort) {
                              _updateFilters(filters);
                              if (sort != null &&
                                  widget.onSortChanged != null) {
                                widget.onSortChanged!(sort);
                              }
                            },
                          ),
                        );
                      },
                      tooltip: 'Presets',
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Priority Filter
            _buildPriorityFilter(theme),
            const SizedBox(height: 16),
            // Tags Filter
            _buildTagsFilter(theme),
            const SizedBox(height: 16),
            // Date Range Filter
            _buildDateRangeFilter(theme),
            const SizedBox(height: 16),
            // Source Filter
            _buildSourceFilter(theme),
            const SizedBox(height: 16),
            // Completion Filter
            _buildCompletionFilter(theme),
            const SizedBox(height: 24),
            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      _updateFilters(const FilterOptions());
                      Navigator.of(context).pop();
                    },
                    child: const Text('Clear All'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Apply'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriorityFilter(ThemeData theme) {
    final priorities = _getAllPriorities();
    if (priorities.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Priority', style: theme.textTheme.titleSmall),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ChoiceChip(
              label: const Text('All'),
              selected: _filters.priorities == null,
              onSelected: (selected) {
                if (selected) {
                  _updateFilters(_filters.copyWith(priorities: null));
                }
              },
            ),
            ...priorities.map((priority) {
              final isSelected =
                  _filters.priorities?.contains(priority) ?? false;
              return ChoiceChip(
                label: Text(priority),
                selected: isSelected,
                onSelected: (selected) {
                  final current = _filters.priorities ?? [];
                  final updated = selected
                      ? [...current, priority]
                      : current.where((p) => p != priority).toList();
                  _updateFilters(
                    _filters.copyWith(
                      priorities: updated.isEmpty ? null : updated,
                    ),
                  );
                },
              );
            }),
          ],
        ),
      ],
    );
  }

  Widget _buildTagsFilter(ThemeData theme) {
    final tags = _getAllTags();
    if (tags.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Tags', style: theme.textTheme.titleSmall),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ChoiceChip(
              label: const Text('All'),
              selected: _filters.tags == null,
              onSelected: (selected) {
                if (selected) {
                  _updateFilters(_filters.copyWith(tags: null));
                }
              },
            ),
            ...tags.map((tag) {
              final isSelected = _filters.tags?.contains(tag) ?? false;
              return ChoiceChip(
                label: Text(tag),
                selected: isSelected,
                onSelected: (selected) {
                  final current = _filters.tags ?? [];
                  final updated = selected
                      ? [...current, tag]
                      : current.where((t) => t != tag).toList();
                  _updateFilters(
                    _filters.copyWith(tags: updated.isEmpty ? null : updated),
                  );
                },
              );
            }),
          ],
        ),
      ],
    );
  }

  Widget _buildDateRangeFilter(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Date Range', style: theme.textTheme.titleSmall),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                icon: const Icon(Icons.calendar_today, size: 18),
                label: Text(
                  _filters.startDate != null
                      ? '${_filters.startDate!.day}/${_filters.startDate!.month}/${_filters.startDate!.year}'
                      : 'Start Date',
                ),
                onPressed: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: _filters.startDate ?? DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (date != null) {
                    _updateFilters(_filters.copyWith(startDate: date));
                  }
                },
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton.icon(
                icon: const Icon(Icons.calendar_today, size: 18),
                label: Text(
                  _filters.endDate != null
                      ? '${_filters.endDate!.day}/${_filters.endDate!.month}/${_filters.endDate!.year}'
                      : 'End Date',
                ),
                onPressed: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: _filters.endDate ?? DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (date != null) {
                    _updateFilters(_filters.copyWith(endDate: date));
                  }
                },
              ),
            ),
          ],
        ),
        if (_filters.startDate != null || _filters.endDate != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: TextButton(
              onPressed: () {
                _updateFilters(
                  _filters.copyWith(startDate: null, endDate: null),
                );
              },
              child: const Text('Clear Date Range'),
            ),
          ),
      ],
    );
  }

  Widget _buildSourceFilter(ThemeData theme) {
    final sources = _getAllSources();
    if (sources.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Source', style: theme.textTheme.titleSmall),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ChoiceChip(
              label: const Text('All'),
              selected: _filters.sources == null,
              onSelected: (selected) {
                if (selected) {
                  _updateFilters(_filters.copyWith(sources: null));
                }
              },
            ),
            ...sources.map((source) {
              final isSelected = _filters.sources?.contains(source) ?? false;
              return ChoiceChip(
                label: Text(_formatSource(source)),
                selected: isSelected,
                onSelected: (selected) {
                  final current = _filters.sources ?? [];
                  final updated = selected
                      ? [...current, source]
                      : current.where((s) => s != source).toList();
                  _updateFilters(
                    _filters.copyWith(
                      sources: updated.isEmpty ? null : updated,
                    ),
                  );
                },
              );
            }),
          ],
        ),
      ],
    );
  }

  Widget _buildCompletionFilter(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Completion Status', style: theme.textTheme.titleSmall),
        const SizedBox(height: 8),
        SegmentedButton<bool?>(
          segments: const [
            ButtonSegment(value: null, label: Text('All')),
            ButtonSegment(value: false, label: Text('Incomplete')),
            ButtonSegment(value: true, label: Text('Completed')),
          ],
          selected: {_filters.isCompleted},
          onSelectionChanged: (Set<bool?> selected) {
            _updateFilters(_filters.copyWith(isCompleted: selected.first));
          },
        ),
      ],
    );
  }

  String _formatSource(String source) {
    switch (source) {
      case 'app':
        return 'App';
      case 'google_calendar':
        return 'Google Calendar';
      case 'device_calendar':
        return 'Device Calendar';
      default:
        return source;
    }
  }
}
