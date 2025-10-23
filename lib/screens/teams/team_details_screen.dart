import 'package:flutter/material.dart';
import '../../models/team.dart';
import '../../models/shared_event.dart';
import '../../services/team_collaboration_service.dart';
import '../../utils/icon_helper.dart';
import '../add_event/add_event_screen.dart';

/// Team Details Screen
/// Shows team information, members, and shared events
class TeamDetailsScreen extends StatefulWidget {
  final Team team;

  const TeamDetailsScreen({super.key, required this.team});

  @override
  State<TeamDetailsScreen> createState() => _TeamDetailsScreenState();
}

class _TeamDetailsScreenState extends State<TeamDetailsScreen>
    with SingleTickerProviderStateMixin {
  final TeamCollaborationService _teamService = TeamCollaborationService();
  late TabController _tabController;

  List<SharedEvent> _events = [];
  bool _isLoadingEvents = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadTeamEvents();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadTeamEvents() async {
    setState(() {
      _isLoadingEvents = true;
      _error = null;
    });

    try {
      final events = await _teamService.getTeamEvents(teamId: widget.team.id);
      setState(() {
        _events = events;
        _isLoadingEvents = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoadingEvents = false;
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
          widget.team.name,
          style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        actions: [
          PopupMenuButton<String>(
            onSelected: _handleMenuAction,
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'invite',
                child: ListTile(
                  leading: Icon(Icons.person_add_rounded),
                  title: Text('Invite Members'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem(
                value: 'settings',
                child: ListTile(
                  leading: Icon(Icons.settings_rounded),
                  title: Text('Team Settings'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              if (widget.team.isOwner(_teamService.currentUser?.uid ?? ''))
                const PopupMenuItem(
                  value: 'delete',
                  child: ListTile(
                    leading: Icon(
                      Icons.delete_forever_rounded,
                      color: Colors.red,
                    ),
                    title: Text(
                      'Delete Team',
                      style: TextStyle(color: Colors.red),
                    ),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
            ],
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.info_outline_rounded), text: 'Info'),
            Tab(icon: Icon(Icons.people_outline_rounded), text: 'Members'),
            Tab(icon: Icon(Icons.event_outlined), text: 'Events'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildTeamInfoTab(), _buildMembersTab(), _buildEventsTab()],
      ),
      floatingActionButton: _tabController.index == 2
          ? FloatingActionButton.extended(
              onPressed: _createSharedEvent,
              icon: const Icon(Icons.add_rounded),
              label: const Text('Add Event'),
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
            )
          : null,
    );
  }

  Widget _buildTeamInfoTab() {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Team header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: colorScheme.outline.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Column(
              children: [
                // Team icon
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color:
                        (widget.team.color != null
                                ? Color(
                                    int.parse(
                                      widget.team.color!.replaceFirst(
                                        '#',
                                        '0xff',
                                      ),
                                    ),
                                  )
                                : colorScheme.primary)
                            .withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(
                    IconHelper.getIcon(widget.team.icon),
                    color: widget.team.color != null
                        ? Color(
                            int.parse(
                              widget.team.color!.replaceFirst('#', '0xff'),
                            ),
                          )
                        : colorScheme.primary,
                    size: 40,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  widget.team.name,
                  style: textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  widget.team.description,
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurface.withOpacity(0.6),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // Team stats
          _buildTeamStats(),
          const SizedBox(height: 24),
          // Team settings
          _buildTeamSettings(),
        ],
      ),
    );
  }

  Widget _buildTeamStats() {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.outline.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Team Statistics',
            style: textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  icon: Icons.people_rounded,
                  label: 'Members',
                  value: '${widget.team.members.length}',
                  color: colorScheme.primary,
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  icon: Icons.event_rounded,
                  label: 'Events',
                  value: '${_events.length}',
                  color: colorScheme.secondary,
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  icon: Icons.calendar_today_rounded,
                  label: 'Created',
                  value: _formatDate(widget.team.createdAt),
                  color: colorScheme.tertiary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
        Text(
          label,
          style: textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
      ],
    );
  }

  Widget _buildTeamSettings() {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.outline.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Team Settings',
            style: textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          _buildSettingItem(
            icon: Icons.person_add_rounded,
            title: 'Allow Member Invites',
            subtitle: 'Members can invite others',
            value: widget.team.settings.allowMemberInvites,
          ),
          _buildSettingItem(
            icon: Icons.approval_rounded,
            title: 'Require Event Approval',
            subtitle: 'Events need approval before creation',
            value: widget.team.settings.requireApprovalForEvents,
          ),
          _buildSettingItem(
            icon: Icons.public_rounded,
            title: 'Allow External Invites',
            subtitle: 'Invite users outside the organization',
            value: widget.team.settings.allowExternalInvites,
          ),
          _buildSettingItem(
            icon: Icons.notifications_rounded,
            title: 'Enable Notifications',
            subtitle: 'Send team notifications',
            value: widget.team.settings.enableNotifications,
          ),
        ],
      ),
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: colorScheme.onSurface.withOpacity(0.6)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: colorScheme.onSurface,
                  ),
                ),
                Text(
                  subtitle,
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
          Icon(
            value ? Icons.check_circle_rounded : Icons.cancel_rounded,
            color: value ? Colors.green : Colors.red,
            size: 20,
          ),
        ],
      ),
    );
  }

  Widget _buildMembersTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: widget.team.members.length,
      itemBuilder: (context, index) {
        final member = widget.team.members[index];
        return _buildMemberCard(member);
      },
    );
  }

  Widget _buildMemberCard(TeamMember member) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: member.photoURL != null
              ? NetworkImage(member.photoURL!)
              : null,
          child: member.photoURL == null
              ? Text(
                  member.name?.substring(0, 1).toUpperCase() ??
                      member.email.substring(0, 1).toUpperCase(),
                )
              : null,
        ),
        title: Text(
          member.name ?? member.email,
          style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(member.email),
            const SizedBox(height: 4),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: _getRoleColor(member.role).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    member.role.name.toUpperCase(),
                    style: textTheme.bodySmall?.copyWith(
                      color: _getRoleColor(member.role),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Joined ${_formatDate(member.joinedAt)}',
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing:
            widget.team.canManageTeam(_teamService.currentUser?.uid ?? '') &&
                !widget.team.isOwner(member.userId)
            ? PopupMenuButton<String>(
                onSelected: (value) => _handleMemberAction(value, member),
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'change_role',
                    child: Text('Change Role'),
                  ),
                  const PopupMenuItem(
                    value: 'remove',
                    child: Text(
                      'Remove Member',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                ],
              )
            : null,
      ),
    );
  }

  Widget _buildEventsTab() {
    if (_isLoadingEvents) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline_rounded, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text('Error loading events: $_error'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadTeamEvents,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_events.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_outlined, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text('No events yet'),
            const SizedBox(height: 8),
            const Text('Create your first team event'),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _createSharedEvent,
              icon: const Icon(Icons.add_rounded),
              label: const Text('Add Event'),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _events.length,
      itemBuilder: (context, index) {
        final event = _events[index];
        return _buildEventCard(event);
      },
    );
  }

  Widget _buildEventCard(SharedEvent event) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: _getPriorityColor(event.priority).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.event_rounded,
            color: _getPriorityColor(event.priority),
            size: 24,
          ),
        ),
        title: Text(
          event.title,
          style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(event.description),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  Icons.access_time_rounded,
                  size: 16,
                  color: colorScheme.onSurface.withOpacity(0.6),
                ),
                const SizedBox(width: 4),
                Text(
                  _formatDateTime(event.date),
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
                const SizedBox(width: 16),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: _getPriorityColor(event.priority).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    event.priority.toUpperCase(),
                    style: textTheme.bodySmall?.copyWith(
                      color: _getPriorityColor(event.priority),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: event.canEdit(_teamService.currentUser?.uid ?? '')
            ? PopupMenuButton<String>(
                onSelected: (value) => _handleEventAction(value, event),
                itemBuilder: (context) => [
                  const PopupMenuItem(value: 'edit', child: Text('Edit')),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Text('Delete', style: TextStyle(color: Colors.red)),
                  ),
                ],
              )
            : null,
      ),
    );
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'invite':
        _showInviteDialog();
        break;
      case 'settings':
        _showSettingsDialog();
        break;
      case 'delete':
        _showDeleteDialog();
        break;
    }
  }

  void _handleMemberAction(String action, TeamMember member) {
    switch (action) {
      case 'change_role':
        _showChangeRoleDialog(member);
        break;
      case 'remove':
        _showRemoveMemberDialog(member);
        break;
    }
  }

  void _handleEventAction(String action, SharedEvent event) {
    switch (action) {
      case 'edit':
        // TODO: Navigate to edit event screen
        break;
      case 'delete':
        _showDeleteEventDialog(event);
        break;
    }
  }

  void _createSharedEvent() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddEventScreen()),
    ).then((_) {
      _loadTeamEvents();
    });
  }

  void _showInviteDialog() {
    // TODO: Implement invite dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Invite functionality coming soon!')),
    );
  }

  void _showSettingsDialog() {
    // TODO: Implement settings dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Settings functionality coming soon!')),
    );
  }

  void _showDeleteDialog() {
    // TODO: Implement delete dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Delete functionality coming soon!')),
    );
  }

  void _showChangeRoleDialog(TeamMember member) {
    // TODO: Implement change role dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Change role functionality coming soon!')),
    );
  }

  void _showRemoveMemberDialog(TeamMember member) {
    // TODO: Implement remove member dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Remove member functionality coming soon!')),
    );
  }

  void _showDeleteEventDialog(SharedEvent event) {
    // TODO: Implement delete event dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Delete event functionality coming soon!')),
    );
  }

  Color _getRoleColor(TeamRole role) {
    switch (role) {
      case TeamRole.owner:
        return Colors.purple;
      case TeamRole.admin:
        return Colors.blue;
      case TeamRole.member:
        return Colors.green;
      case TeamRole.viewer:
        return Colors.orange;
    }
  }

  Color _getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      case 'low':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = date.difference(now).inDays;

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

  String _formatDateTime(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}
