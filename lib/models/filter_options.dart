/// Filter options for tasks and events
class FilterOptions {
  final List<String>? priorities; // null means all, empty list means none
  final List<String>? tags; // null means all, empty list means none
  final DateTime? startDate;
  final DateTime? endDate;
  final List<String>? sources; // ['app', 'google_calendar', 'device_calendar']
  final bool? isCompleted; // null means all, true/false for specific
  final String? quickFilter; // 'today', 'this_week', 'overdue', 'high_priority'

  const FilterOptions({
    this.priorities,
    this.tags,
    this.startDate,
    this.endDate,
    this.sources,
    this.isCompleted,
    this.quickFilter,
  });

  FilterOptions copyWith({
    List<String>? priorities,
    List<String>? tags,
    DateTime? startDate,
    DateTime? endDate,
    List<String>? sources,
    bool? isCompleted,
    String? quickFilter,
  }) {
    return FilterOptions(
      priorities: priorities ?? this.priorities,
      tags: tags ?? this.tags,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      sources: sources ?? this.sources,
      isCompleted: isCompleted ?? this.isCompleted,
      quickFilter: quickFilter ?? this.quickFilter,
    );
  }

  /// Clear all filters
  FilterOptions clear() {
    return const FilterOptions();
  }

  /// Check if any filter is active
  bool get hasActiveFilters {
    return priorities != null ||
        tags != null ||
        startDate != null ||
        endDate != null ||
        sources != null ||
        isCompleted != null ||
        quickFilter != null;
  }

  Map<String, dynamic> toJson() {
    return {
      'priorities': priorities,
      'tags': tags,
      'startDate': startDate?.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'sources': sources,
      'isCompleted': isCompleted,
      'quickFilter': quickFilter,
    };
  }

  factory FilterOptions.fromJson(Map<String, dynamic> json) {
    return FilterOptions(
      priorities: json['priorities'] != null
          ? List<String>.from(json['priorities'])
          : null,
      tags: json['tags'] != null ? List<String>.from(json['tags']) : null,
      startDate: json['startDate'] != null
          ? DateTime.parse(json['startDate'])
          : null,
      endDate: json['endDate'] != null ? DateTime.parse(json['endDate']) : null,
      sources: json['sources'] != null
          ? List<String>.from(json['sources'])
          : null,
      isCompleted: json['isCompleted'] as bool?,
      quickFilter: json['quickFilter'] as String?,
    );
  }
}

/// Sort options for tasks and events
enum SortField { date, priority, title }

enum SortOrder { ascending, descending }

class SortOptions {
  final SortField field;
  final SortOrder order;

  const SortOptions({
    this.field = SortField.date,
    this.order = SortOrder.ascending,
  });

  SortOptions copyWith({SortField? field, SortOrder? order}) {
    return SortOptions(field: field ?? this.field, order: order ?? this.order);
  }

  String get displayName {
    final fieldName = field.name.replaceFirst(
      field.name[0],
      field.name[0].toUpperCase(),
    );
    final orderName = order == SortOrder.ascending ? 'Ascending' : 'Descending';
    return '$fieldName ($orderName)';
  }

  Map<String, dynamic> toJson() {
    return {'field': field.name, 'order': order.name};
  }

  factory SortOptions.fromJson(Map<String, dynamic> json) {
    return SortOptions(
      field: SortField.values.firstWhere(
        (e) => e.name == json['field'],
        orElse: () => SortField.date,
      ),
      order: SortOrder.values.firstWhere(
        (e) => e.name == json['order'],
        orElse: () => SortOrder.ascending,
      ),
    );
  }
}

/// Filter preset for saving and loading filter configurations
class FilterPreset {
  final String id;
  final String name;
  final FilterOptions filters;
  final SortOptions? sort;

  const FilterPreset({
    required this.id,
    required this.name,
    required this.filters,
    this.sort,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'filters': filters.toJson(),
      'sort': sort?.toJson(),
    };
  }

  factory FilterPreset.fromJson(Map<String, dynamic> json) {
    return FilterPreset(
      id: json['id'],
      name: json['name'],
      filters: FilterOptions.fromJson(json['filters']),
      sort: json['sort'] != null ? SortOptions.fromJson(json['sort']) : null,
    );
  }
}
