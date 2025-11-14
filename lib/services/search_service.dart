import '../models/calendar_event.dart';
import '../models/task.dart';
import '../models/shared_event.dart';
import '../service/calendar_service.dart';
import 'task_service.dart';
import 'team_collaboration_service.dart';
import 'settings_service.dart';

/// Search filters for advanced search
class SearchFilters {
  final DateTime? startDate;
  final DateTime? endDate;
  final String? priority;
  final List<String> tags;
  final bool? isCompleted;
  final List<String> searchTypes; // ['events', 'tasks', 'team_events']

  const SearchFilters({
    this.startDate,
    this.endDate,
    this.priority,
    this.tags = const [],
    this.isCompleted,
    this.searchTypes = const ['events', 'tasks', 'team_events'],
  });

  SearchFilters copyWith({
    DateTime? startDate,
    DateTime? endDate,
    String? priority,
    List<String>? tags,
    bool? isCompleted,
    List<String>? searchTypes,
  }) {
    return SearchFilters(
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      priority: priority ?? this.priority,
      tags: tags ?? this.tags,
      isCompleted: isCompleted ?? this.isCompleted,
      searchTypes: searchTypes ?? this.searchTypes,
    );
  }
}

/// Search result model
class SearchResult {
  final CalendarEvent? event;
  final Task? task;
  final SharedEvent? teamEvent;
  final String type; // 'event', 'task', 'team_event'
  final double relevanceScore; // For sorting

  const SearchResult({
    this.event,
    this.task,
    this.teamEvent,
    required this.type,
    this.relevanceScore = 0.0,
  });

  String get title {
    if (event != null) return event!.title;
    if (task != null) return task!.name;
    if (teamEvent != null) return teamEvent!.title;
    return '';
  }

  DateTime? get date {
    if (event != null) return event!.startDate ?? event!.date;
    if (task != null) return task!.deadline;
    if (teamEvent != null) return teamEvent!.startDate ?? teamEvent!.date;
    return null;
  }
}

/// Unified search service for events, tasks, and team events
class SearchService {
  final CalendarService _calendarService = CalendarService();
  final TaskService _taskService = TaskService();
  final TeamCollaborationService _teamService = TeamCollaborationService();
  final SettingsService _settingsService = SettingsService();

  /// Perform a comprehensive search across all content types
  Future<List<SearchResult>> search({
    required String query,
    SearchFilters? filters,
  }) async {
    if (query.trim().isEmpty) {
      return [];
    }

    final effectiveFilters = filters ?? const SearchFilters();
    final results = <SearchResult>[];

    // Search events
    if (effectiveFilters.searchTypes.contains('events')) {
      final events = await _searchEvents(query, effectiveFilters);
      results.addAll(
        events.map(
          (e) => SearchResult(
            event: e,
            type: 'event',
            relevanceScore: _calculateRelevanceScore(e.title, query),
          ),
        ),
      );
    }

    // Search tasks
    if (effectiveFilters.searchTypes.contains('tasks')) {
      final tasks = await _searchTasks(query, effectiveFilters);
      results.addAll(
        tasks.map(
          (t) => SearchResult(
            task: t,
            type: 'task',
            relevanceScore: _calculateRelevanceScore(t.name, query),
          ),
        ),
      );
    }

    // Search team events
    if (effectiveFilters.searchTypes.contains('team_events')) {
      final teamEvents = await _searchTeamEvents(query, effectiveFilters);
      results.addAll(
        teamEvents.map(
          (te) => SearchResult(
            teamEvent: te,
            type: 'team_event',
            relevanceScore: _calculateRelevanceScore(te.title, query),
          ),
        ),
      );
    }

    // Sort by relevance score (highest first)
    results.sort((a, b) => b.relevanceScore.compareTo(a.relevanceScore));

    return results;
  }

  /// Search events with filters
  Future<List<CalendarEvent>> _searchEvents(
    String query,
    SearchFilters filters,
  ) async {
    try {
      // Get all events (this will expand recurring events)
      final allEvents = await _calendarService.getEvents();

      // Filter by query
      var filtered = allEvents.where((event) {
        final queryLower = query.toLowerCase();
        return event.title.toLowerCase().contains(queryLower) ||
            event.description.toLowerCase().contains(queryLower) ||
            (event.location?.toLowerCase().contains(queryLower) ?? false) ||
            event.tags.any((tag) => tag.toLowerCase().contains(queryLower));
      }).toList();

      // Apply filters
      if (filters.startDate != null || filters.endDate != null) {
        filtered = filtered.where((event) {
          final eventDate = event.startDate ?? event.date;
          if (filters.startDate != null &&
              eventDate.isBefore(filters.startDate!)) {
            return false;
          }
          if (filters.endDate != null && eventDate.isAfter(filters.endDate!)) {
            return false;
          }
          return true;
        }).toList();
      }

      if (filters.priority != null) {
        filtered = filtered
            .where((e) => e.priority == filters.priority)
            .toList();
      }

      if (filters.tags.isNotEmpty) {
        filtered = filtered.where((e) {
          return filters.tags.any((tag) => e.tags.contains(tag));
        }).toList();
      }

      if (filters.isCompleted != null) {
        filtered = filtered
            .where((e) => e.isCompleted == filters.isCompleted)
            .toList();
      }

      return filtered;
    } catch (e) {
      print('Error searching events: $e');
      return [];
    }
  }

  /// Search tasks with filters
  Future<List<Task>> _searchTasks(String query, SearchFilters filters) async {
    try {
      final allTasks = await _taskService.getTasks();

      // Filter by query
      var filtered = allTasks.where((task) {
        final queryLower = query.toLowerCase();
        return task.name.toLowerCase().contains(queryLower);
      }).toList();

      // Apply filters
      if (filters.startDate != null || filters.endDate != null) {
        filtered = filtered.where((task) {
          if (task.deadline == null) return false;
          if (filters.startDate != null &&
              task.deadline!.isBefore(filters.startDate!)) {
            return false;
          }
          if (filters.endDate != null &&
              task.deadline!.isAfter(filters.endDate!)) {
            return false;
          }
          return true;
        }).toList();
      }

      if (filters.priority != null) {
        filtered = filtered
            .where((t) => t.priority == filters.priority)
            .toList();
      }

      if (filters.isCompleted != null) {
        filtered = filtered
            .where((t) => t.done == filters.isCompleted)
            .toList();
      }

      return filtered;
    } catch (e) {
      print('Error searching tasks: $e');
      return [];
    }
  }

  /// Search team events with filters
  Future<List<SharedEvent>> _searchTeamEvents(
    String query,
    SearchFilters filters,
  ) async {
    try {
      final teams = await _teamService.getUserTeams();
      final allTeamEvents = <SharedEvent>[];

      // Get events from all teams
      for (final team in teams) {
        final events = await _teamService.getTeamEvents(teamId: team.id);
        allTeamEvents.addAll(events);
      }

      // Filter by query
      var filtered = allTeamEvents.where((event) {
        final queryLower = query.toLowerCase();
        return event.title.toLowerCase().contains(queryLower) ||
            event.description.toLowerCase().contains(queryLower) ||
            (event.location?.toLowerCase().contains(queryLower) ?? false) ||
            event.tags.any((tag) => tag.toLowerCase().contains(queryLower));
      }).toList();

      // Apply filters
      if (filters.startDate != null || filters.endDate != null) {
        filtered = filtered.where((event) {
          final eventDate = event.startDate ?? event.date;
          if (filters.startDate != null &&
              eventDate.isBefore(filters.startDate!)) {
            return false;
          }
          if (filters.endDate != null && eventDate.isAfter(filters.endDate!)) {
            return false;
          }
          return true;
        }).toList();
      }

      if (filters.priority != null) {
        filtered = filtered
            .where((e) => e.priority == filters.priority)
            .toList();
      }

      if (filters.tags.isNotEmpty) {
        filtered = filtered.where((e) {
          return filters.tags.any((tag) => e.tags.contains(tag));
        }).toList();
      }

      if (filters.isCompleted != null) {
        filtered = filtered
            .where((e) => e.isCompleted == filters.isCompleted)
            .toList();
      }

      return filtered;
    } catch (e) {
      print('Error searching team events: $e');
      return [];
    }
  }

  /// Calculate relevance score for search results
  double _calculateRelevanceScore(String text, String query) {
    final textLower = text.toLowerCase();
    final queryLower = query.toLowerCase();

    // Exact match gets highest score
    if (textLower == queryLower) return 100.0;

    // Starts with query gets high score
    if (textLower.startsWith(queryLower)) return 80.0;

    // Contains query gets medium score
    if (textLower.contains(queryLower)) return 50.0;

    // Word match gets lower score
    final words = textLower.split(' ');
    final queryWords = queryLower.split(' ');
    int matches = 0;
    for (final word in words) {
      if (queryWords.any((qw) => word.contains(qw))) {
        matches++;
      }
    }
    if (matches > 0) {
      return (matches / words.length) * 30.0;
    }

    return 0.0;
  }

  /// Save recent search query
  Future<void> saveRecentSearch(String query) async {
    if (query.trim().isEmpty) return;

    try {
      final recentSearches = await getRecentSearches();
      // Remove if already exists
      recentSearches.remove(query.trim());
      // Add to beginning
      recentSearches.insert(0, query.trim());
      // Keep only last 10
      if (recentSearches.length > 10) {
        recentSearches.removeRange(10, recentSearches.length);
      }
      await _settingsService.setRecentSearches(recentSearches);
    } catch (e) {
      print('Error saving recent search: $e');
    }
  }

  /// Get recent searches
  Future<List<String>> getRecentSearches() async {
    try {
      return await _settingsService.getRecentSearches();
    } catch (e) {
      print('Error getting recent searches: $e');
      return [];
    }
  }

  /// Clear recent searches
  Future<void> clearRecentSearches() async {
    try {
      await _settingsService.setRecentSearches([]);
    } catch (e) {
      print('Error clearing recent searches: $e');
    }
  }
}
