import 'package:flutter/material.dart';
import '../../models/team.dart';
import '../../services/team_collaboration_service.dart';
import '../../utils/icon_helper.dart';
import 'create_team_screen.dart';
import 'team_details_screen.dart';

/// Team List Screen
/// Displays all teams the user is a member of
class TeamListScreen extends StatefulWidget {
  const TeamListScreen({super.key});

  @override
  State<TeamListScreen> createState() => _TeamListScreenState();
}

class _TeamListScreenState extends State<TeamListScreen> {
  final TeamCollaborationService _teamService = TeamCollaborationService();
  List<Team> _teams = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadTeams();
  }

  Future<void> _loadTeams() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final teams = await _teamService.getUserTeams();
      setState(() {
        _teams = teams;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: AppBar(
        title: Text(
          'Teams',
          style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        actions: [
          IconButton(
            onPressed: () => _showCreateTeamDialog(),
            icon: const Icon(Icons.add_rounded),
            tooltip: 'Create Team',
          ),
        ],
      ),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateTeamDialog(),
        icon: const Icon(Icons.group_add_rounded),
        label: const Text('Create Team'),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return _buildErrorState();
    }

    if (_teams.isEmpty) {
      return _buildEmptyState();
    }

    return _buildTeamsList();
  }

  Widget _buildErrorState() {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 64,
              color: colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Error Loading Teams',
              style: textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _error ?? 'Unknown error occurred',
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface.withOpacity(0.6),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadTeams,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.group_outlined,
              size: 64,
              color: colorScheme.onSurface.withOpacity(0.4),
            ),
            const SizedBox(height: 16),
            Text(
              'No Teams Yet',
              style: textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Create your first team to start collaborating with others',
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface.withOpacity(0.6),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => _showCreateTeamDialog(),
              icon: const Icon(Icons.group_add_rounded),
              label: const Text('Create Team'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTeamsList() {
    return RefreshIndicator(
      onRefresh: _loadTeams,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _teams.length,
        itemBuilder: (context, index) {
          final team = _teams[index];
          return _buildTeamCard(team);
        },
      ),
    );
  }

  Widget _buildTeamCard(Team team) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _navigateToTeamDetails(team),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Team icon/avatar
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color:
                          (team.color != null
                                  ? Color(
                                      int.parse(
                                        team.color!.replaceFirst('#', '0xff'),
                                      ),
                                    )
                                  : colorScheme.primary)
                              .withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      IconHelper.getIcon(team.icon),
                      color: team.color != null
                          ? Color(
                              int.parse(team.color!.replaceFirst('#', '0xff')),
                            )
                          : colorScheme.primary,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Team info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          team.name,
                          style: textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          team.description,
                          style: textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurface.withOpacity(0.6),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  // Member count
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceVariant,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${team.members.length} members',
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Team stats
              Row(
                children: [
                  Icon(
                    Icons.calendar_today_outlined,
                    size: 16,
                    color: colorScheme.onSurface.withOpacity(0.6),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Created ${_formatDate(team.createdAt)}',
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                  const Spacer(),
                  if (team.isOwner(_teamService.currentUser?.uid ?? ''))
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: colorScheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Owner',
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showCreateTeamDialog() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CreateTeamScreen()),
    ).then((_) {
      // Refresh teams list when returning
      _loadTeams();
    });
  }

  void _navigateToTeamDetails(Team team) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => TeamDetailsScreen(team: team)),
    ).then((_) {
      // Refresh teams list when returning
      _loadTeams();
    });
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date).inDays;

    if (difference == 0) {
      return 'today';
    } else if (difference == 1) {
      return 'yesterday';
    } else if (difference < 7) {
      return '$difference days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
