import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/calendar_event.dart';
import '../../models/task.dart';
import '../../models/shared_event.dart';
import '../../services/search_service.dart';
import '../../services/team_collaboration_service.dart';
import '../add_event/add_event_screen.dart';
import '../teams/team_details_screen.dart';

/// Search Screen - Global search with filters
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final SearchService _searchService = SearchService();
  final TeamCollaborationService _teamService = TeamCollaborationService();
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  List<SearchResult> _searchResults = [];
  List<String> _recentSearches = [];
  bool _isSearching = false;
  bool _showFilters = false;
  SearchFilters _filters = const SearchFilters();

  @override
  void initState() {
    super.initState();
    _loadRecentSearches();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    if (_searchController.text.isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
    }
  }

  Future<void> _loadRecentSearches() async {
    final searches = await _searchService.getRecentSearches();
    setState(() {
      _recentSearches = searches;
    });
  }

  Future<void> _performSearch() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }

    setState(() {
      _isSearching = true;
    });

    try {
      final results = await _searchService.search(
        query: query,
        filters: _filters,
      );

      // Save to recent searches
      await _searchService.saveRecentSearch(query);
      await _loadRecentSearches();

      setState(() {
        _searchResults = results;
        _isSearching = false;
      });
    } catch (e) {
      setState(() {
        _isSearching = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Search error: $e')));
      }
    }
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _searchResults = [];
      _isSearching = false;
    });
  }

  void _useRecentSearch(String query) {
    _searchController.text = query;
    _performSearch();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search'),
        actions: [
          IconButton(
            icon: Icon(
              _showFilters ? Icons.filter_list : Icons.filter_list_outlined,
            ),
            onPressed: () {
              setState(() {
                _showFilters = !_showFilters;
              });
            },
            tooltip: 'Filters',
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              focusNode: _searchFocusNode,
              decoration: InputDecoration(
                hintText: 'Search events, tasks, and team events...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: _clearSearch,
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
              ),
              onSubmitted: (_) => _performSearch(),
              textInputAction: TextInputAction.search,
            ),
          ),

          // Filters (if shown)
          if (_showFilters) _buildFilters(),

          // Content
          Expanded(
            child: _searchController.text.isEmpty && _searchResults.isEmpty
                ? _buildRecentSearches()
                : _buildSearchResults(),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant,
        border: Border(
          bottom: BorderSide(color: Theme.of(context).dividerColor),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Filters',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              // Content Type Filter
              FilterChip(
                label: const Text('Events'),
                selected: _filters.searchTypes.contains('events'),
                onSelected: (selected) {
                  setState(() {
                    final types = List<String>.from(_filters.searchTypes);
                    if (selected) {
                      types.add('events');
                    } else {
                      types.remove('events');
                    }
                    _filters = _filters.copyWith(searchTypes: types);
                  });
                },
              ),
              FilterChip(
                label: const Text('Tasks'),
                selected: _filters.searchTypes.contains('tasks'),
                onSelected: (selected) {
                  setState(() {
                    final types = List<String>.from(_filters.searchTypes);
                    if (selected) {
                      types.add('tasks');
                    } else {
                      types.remove('tasks');
                    }
                    _filters = _filters.copyWith(searchTypes: types);
                  });
                },
              ),
              FilterChip(
                label: const Text('Team Events'),
                selected: _filters.searchTypes.contains('team_events'),
                onSelected: (selected) {
                  setState(() {
                    final types = List<String>.from(_filters.searchTypes);
                    if (selected) {
                      types.add('team_events');
                    } else {
                      types.remove('team_events');
                    }
                    _filters = _filters.copyWith(searchTypes: types);
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Priority Filter
          DropdownButtonFormField<String>(
            value: _filters.priority,
            decoration: const InputDecoration(
              labelText: 'Priority',
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            items: const [
              DropdownMenuItem(value: null, child: Text('All Priorities')),
              DropdownMenuItem(value: 'High', child: Text('High')),
              DropdownMenuItem(value: 'Medium', child: Text('Medium')),
              DropdownMenuItem(value: 'Low', child: Text('Low')),
            ],
            onChanged: (value) {
              setState(() {
                _filters = _filters.copyWith(priority: value);
              });
            },
          ),
          const SizedBox(height: 12),
          // Date Range
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: _filters.startDate ?? DateTime.now(),
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2030),
                    );
                    if (date != null) {
                      setState(() {
                        _filters = _filters.copyWith(startDate: date);
                      });
                    }
                  },
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Start Date',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                    ),
                    child: Text(
                      _filters.startDate != null
                          ? DateFormat(
                              'MMM dd, yyyy',
                            ).format(_filters.startDate!)
                          : 'Select date',
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: InkWell(
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: _filters.endDate ?? DateTime.now(),
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2030),
                    );
                    if (date != null) {
                      setState(() {
                        _filters = _filters.copyWith(endDate: date);
                      });
                    }
                  },
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'End Date',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                    ),
                    child: Text(
                      _filters.endDate != null
                          ? DateFormat('MMM dd, yyyy').format(_filters.endDate!)
                          : 'Select date',
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Clear Filters Button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {
                setState(() {
                  _filters = const SearchFilters();
                });
              },
              child: const Text('Clear Filters'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentSearches() {
    if (_recentSearches.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search,
              size: 64,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              'Start searching...',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Search across events, tasks, and team events',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Searches',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            TextButton(
              onPressed: () async {
                await _searchService.clearRecentSearches();
                await _loadRecentSearches();
              },
              child: const Text('Clear'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ..._recentSearches.map(
          (search) => ListTile(
            leading: const Icon(Icons.history),
            title: Text(search),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => _useRecentSearch(search),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchResults() {
    if (_isSearching) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_searchResults.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              'No results found',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Try adjusting your search or filters',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final result = _searchResults[index];
        return _buildResultItem(result);
      },
    );
  }

  Widget _buildResultItem(SearchResult result) {
    switch (result.type) {
      case 'event':
        return _buildEventResult(result.event!);
      case 'task':
        return _buildTaskResult(result.task!);
      case 'team_event':
        return _buildTeamEventResult(result.teamEvent!);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildEventResult(CalendarEvent event) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: event.color,
          child: const Icon(Icons.event, color: Colors.white),
        ),
        title: Text(event.title),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (event.description.isNotEmpty) Text(event.description),
            const SizedBox(height: 4),
            Text(
              DateFormat(
                'MMM dd, yyyy • hh:mm a',
              ).format(event.startDate ?? event.date),
            ),
            if (event.isRecurring)
              Text(
                event.recurrenceDisplayText,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontSize: 12,
                ),
              ),
          ],
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddEventScreen(eventToEdit: event),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTaskResult(Task task) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: task.done
              ? Colors.grey
              : task.priority == 'High'
              ? Colors.red
              : task.priority == 'Medium'
              ? Colors.orange
              : Colors.green,
          child: Icon(
            task.done ? Icons.check : Icons.task,
            color: Colors.white,
          ),
        ),
        title: Text(
          task.name,
          style: TextStyle(
            decoration: task.done ? TextDecoration.lineThrough : null,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Priority: ${task.priority}'),
            if (task.deadline != null)
              Text(
                'Deadline: ${DateFormat('MMM dd, yyyy').format(task.deadline!)}',
              ),
          ],
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          // Navigate to task details or home screen
          Navigator.pop(context);
        },
      ),
    );
  }

  Widget _buildTeamEventResult(SharedEvent event) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: const CircleAvatar(
          backgroundColor: Colors.blue,
          child: Icon(Icons.group, color: Colors.white),
        ),
        title: Text(event.title),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (event.description.isNotEmpty) Text(event.description),
            const SizedBox(height: 4),
            Text(
              DateFormat(
                'MMM dd, yyyy • hh:mm a',
              ).format(event.startDate ?? event.date),
            ),
            Text(
              'Team Event • ${event.priority} priority',
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontSize: 12,
              ),
            ),
          ],
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () async {
          // Navigate to team details screen
          try {
            final teams = await _teamService.getUserTeams();
            final team = teams.firstWhere((t) => t.id == event.teamId);
            if (mounted) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TeamDetailsScreen(team: team),
                ),
              );
            }
          } catch (e) {
            if (mounted) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text('Team not found: $e')));
            }
          }
        },
      ),
    );
  }
}
