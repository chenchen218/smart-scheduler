import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/team.dart';
import '../models/shared_event.dart';

/// Team Collaboration Service
/// Handles all team-related operations including team creation, member management, and shared events
class TeamCollaborationService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Get the current user
  User? get currentUser => _auth.currentUser;

  /// Get teams collection reference
  CollectionReference get _teamsCollection => _firestore.collection('teams');

  /// Get shared events collection reference
  CollectionReference get _sharedEventsCollection =>
      _firestore.collection('shared_events');

  /// Get team invitations collection reference
  CollectionReference get _teamInvitationsCollection =>
      _firestore.collection('team_invitations');

  // ==================== TEAM MANAGEMENT ====================

  /// Create a new team
  Future<Team> createTeam({
    required String name,
    required String description,
    String? color,
    String? icon,
  }) async {
    print('🏗️ createTeam: Starting team creation');
    final user = currentUser;
    if (user == null) {
      print('❌ createTeam: User not authenticated');
      throw Exception('User not authenticated');
    }

    print('👤 createTeam: User: ${user.uid} (${user.email})');
    print(
      '📝 createTeam: Team details - Name: $name, Description: $description, Color: $color, Icon: $icon',
    );

    final team = Team.create(
      name: name,
      description: description,
      ownerId: user.uid,
      ownerEmail: user.email ?? '',
      color: color,
      icon: icon,
    );

    print('📋 createTeam: Team object created: ${team.name} (${team.id})');

    final docRef = _teamsCollection.doc();
    final teamWithId = team.copyWith(id: docRef.id);
    print('🆔 createTeam: Team ID: ${docRef.id}');

    print('💾 createTeam: Saving team to Firestore...');
    await docRef.set(teamWithId.toJson());
    print('✅ createTeam: Team saved to Firestore successfully');

    // Add team to user's teams list
    print('👥 createTeam: Adding team to user\'s teams list...');
    await _addTeamToUser(user.uid, docRef.id);

    print('🎉 createTeam: Team creation completed successfully');
    return teamWithId;
  }

  /// Get user's teams
  Future<List<Team>> getUserTeams() async {
    final user = currentUser;
    if (user == null) {
      print('❌ getUserTeams: User not authenticated');
      throw Exception('User not authenticated');
    }

    print('🔍 getUserTeams: Starting for user ${user.uid} (${user.email})');

    try {
      print('📄 getUserTeams: Fetching user document...');
      final userDoc = await _firestore.collection('users').doc(user.uid).get();

      // If user document doesn't exist, create it and return empty list
      if (!userDoc.exists) {
        print('⚠️ getUserTeams: User document does not exist, creating it...');
        await _createUserDocument(user.uid);
        print('✅ getUserTeams: User document created, returning empty list');
        return [];
      }

      print('✅ getUserTeams: User document exists');
      final userData = userDoc.data();
      print('📊 getUserTeams: User data: $userData');

      final teamIds = List<String>.from(userData?['teamIds'] ?? []);
      print('🔢 getUserTeams: Found ${teamIds.length} team IDs: $teamIds');

      if (teamIds.isEmpty) {
        print('📭 getUserTeams: No team IDs found, returning empty list');
        return [];
      }

      print('🏢 getUserTeams: Fetching team documents...');
      final teams = <Team>[];
      for (int i = 0; i < teamIds.length; i++) {
        final teamId = teamIds[i];
        print('🔍 getUserTeams: Fetching team $i/$teamIds.length: $teamId');

        final teamDoc = await _teamsCollection.doc(teamId).get();
        if (teamDoc.exists) {
          print('✅ getUserTeams: Team $teamId exists, adding to list');
          final teamData = teamDoc.data() as Map<String, dynamic>;
          print(
            '📊 getUserTeams: Team data: ${teamData['name']} (${teamData['id']})',
          );
          teams.add(Team.fromJson(teamData));
        } else {
          print('❌ getUserTeams: Team $teamId does not exist');
        }
      }

      print('🎉 getUserTeams: Successfully fetched ${teams.length} teams');
      for (final team in teams) {
        print('   - ${team.name} (${team.id})');
      }

      return teams;
    } catch (e) {
      print('💥 getUserTeams: Error fetching user teams: $e');
      print('💥 getUserTeams: Error type: ${e.runtimeType}');
      if (e.toString().contains('permission-denied')) {
        print('🚫 getUserTeams: Permission denied - check Firestore rules');
      }
      return [];
    }
  }

  /// Get team by ID
  Future<Team?> getTeam(String teamId) async {
    try {
      final teamDoc = await _teamsCollection.doc(teamId).get();
      if (teamDoc.exists) {
        return Team.fromJson(teamDoc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      print('Error fetching team: $e');
      return null;
    }
  }

  /// Update team information
  Future<bool> updateTeam({
    required String teamId,
    String? name,
    String? description,
    String? color,
    String? icon,
    TeamSettings? settings,
  }) async {
    final user = currentUser;
    if (user == null) throw Exception('User not authenticated');

    try {
      final team = await getTeam(teamId);
      if (team == null) throw Exception('Team not found');

      if (!team.canManageTeam(user.uid)) {
        throw Exception('Insufficient permissions');
      }

      final updateData = <String, dynamic>{
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      };

      if (name != null) updateData['name'] = name;
      if (description != null) updateData['description'] = description;
      if (color != null) updateData['color'] = color;
      if (icon != null) updateData['icon'] = icon;
      if (settings != null) updateData['settings'] = settings.toJson();

      await _teamsCollection.doc(teamId).update(updateData);
      return true;
    } catch (e) {
      print('Error updating team: $e');
      return false;
    }
  }

  /// Delete team
  Future<bool> deleteTeam(String teamId) async {
    final user = currentUser;
    if (user == null) throw Exception('User not authenticated');

    try {
      final team = await getTeam(teamId);
      if (team == null) throw Exception('Team not found');

      if (!team.isOwner(user.uid)) {
        throw Exception('Only team owner can delete team');
      }

      // Delete team document
      await _teamsCollection.doc(teamId).delete();

      // Remove team from all members
      for (final member in team.members) {
        await _removeTeamFromUser(member.userId, teamId);
      }

      // Delete all shared events for this team
      final eventsQuery = await _sharedEventsCollection
          .where('teamId', isEqualTo: teamId)
          .get();

      for (final eventDoc in eventsQuery.docs) {
        await eventDoc.reference.delete();
      }

      return true;
    } catch (e) {
      print('Error deleting team: $e');
      return false;
    }
  }

  // ==================== MEMBER MANAGEMENT ====================

  /// Invite user to team
  Future<bool> inviteUserToTeam({
    required String teamId,
    required String email,
    required String role,
  }) async {
    final user = currentUser;
    if (user == null) throw Exception('User not authenticated');

    try {
      final team = await getTeam(teamId);
      if (team == null) throw Exception('Team not found');

      if (!team.canInviteMembers(user.uid)) {
        throw Exception('Insufficient permissions');
      }

      // Check if user is already a member
      if (team.members.any((member) => member.email == email)) {
        throw Exception('User is already a member');
      }

      // Create invitation
      final invitation = {
        'teamId': teamId,
        'teamName': team.name,
        'invitedBy': user.uid,
        'invitedByEmail': user.email,
        'invitedByName': user.displayName,
        'inviteeEmail': email,
        'role': role,
        'status': 'pending',
        'createdAt': Timestamp.fromDate(DateTime.now()),
        'expiresAt': Timestamp.fromDate(
          DateTime.now().add(const Duration(days: 7)),
        ),
      };

      await _teamInvitationsCollection.add(invitation);
      return true;
    } catch (e) {
      print('Error inviting user: $e');
      return false;
    }
  }

  /// Accept team invitation
  Future<bool> acceptTeamInvitation(String invitationId) async {
    final user = currentUser;
    if (user == null) throw Exception('User not authenticated');

    try {
      final invitationDoc = await _teamInvitationsCollection
          .doc(invitationId)
          .get();
      if (!invitationDoc.exists) throw Exception('Invitation not found');

      final invitation = invitationDoc.data() as Map<String, dynamic>;
      final teamId = invitation['teamId'] as String;
      final role = invitation['role'] as String;

      // Check if invitation is still valid
      final expiresAt = (invitation['expiresAt'] as Timestamp).toDate();
      if (DateTime.now().isAfter(expiresAt)) {
        throw Exception('Invitation has expired');
      }

      // Get team
      final team = await getTeam(teamId);
      if (team == null) throw Exception('Team not found');

      // Add user to team
      final newMember = TeamMember(
        userId: user.uid,
        email: user.email ?? '',
        displayName: user.displayName,
        name: user.displayName,
        photoURL: user.photoURL,
        role: TeamRole.values.firstWhere((r) => r.name == role),
        joinedAt: DateTime.now(),
        permissions: _getPermissionsForRole(role),
      );

      final updatedMembers = List<TeamMember>.from(team.members)
        ..add(newMember);

      await _teamsCollection.doc(teamId).update({
        'members': updatedMembers.map((m) => m.toJson()).toList(),
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });

      // Add team to user's teams list
      await _addTeamToUser(user.uid, teamId);

      // Update invitation status
      await _teamInvitationsCollection.doc(invitationId).update({
        'status': 'accepted',
        'acceptedAt': Timestamp.fromDate(DateTime.now()),
      });

      return true;
    } catch (e) {
      print('Error accepting invitation: $e');
      return false;
    }
  }

  /// Remove member from team
  Future<bool> removeMemberFromTeam({
    required String teamId,
    required String userId,
  }) async {
    final currentUserId = currentUser?.uid;
    if (currentUserId == null) throw Exception('User not authenticated');

    try {
      final team = await getTeam(teamId);
      if (team == null) throw Exception('Team not found');

      if (!team.canManageTeam(currentUserId)) {
        throw Exception('Insufficient permissions');
      }

      // Cannot remove team owner
      if (team.isOwner(userId)) {
        throw Exception('Cannot remove team owner');
      }

      // Remove member from team
      final updatedMembers = team.members
          .where((m) => m.userId != userId)
          .toList();

      await _teamsCollection.doc(teamId).update({
        'members': updatedMembers.map((m) => m.toJson()).toList(),
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });

      // Remove team from user's teams list
      await _removeTeamFromUser(userId, teamId);

      return true;
    } catch (e) {
      print('Error removing member: $e');
      return false;
    }
  }

  /// Update member role
  Future<bool> updateMemberRole({
    required String teamId,
    required String userId,
    required String newRole,
  }) async {
    final currentUserId = currentUser?.uid;
    if (currentUserId == null) throw Exception('User not authenticated');

    try {
      final team = await getTeam(teamId);
      if (team == null) throw Exception('Team not found');

      if (!team.canManageTeam(currentUserId)) {
        throw Exception('Insufficient permissions');
      }

      // Update member role
      final updatedMembers = team.members.map((member) {
        if (member.userId == userId) {
          return member.copyWith(
            role: TeamRole.values.firstWhere((r) => r.name == newRole),
            permissions: _getPermissionsForRole(newRole),
          );
        }
        return member;
      }).toList();

      await _teamsCollection.doc(teamId).update({
        'members': updatedMembers.map((m) => m.toJson()).toList(),
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });

      return true;
    } catch (e) {
      print('Error updating member role: $e');
      return false;
    }
  }

  // ==================== SHARED EVENTS ====================

  /// Create a shared event
  Future<SharedEvent> createSharedEvent({
    required String teamId,
    required String title,
    required String description,
    required DateTime date,
    DateTime? startDate,
    DateTime? endDate,
    required String priority,
    String? location,
    List<String> tags = const [],
    Map<String, dynamic> customFields = const {},
    String? recurringPattern,
    DateTime? recurringUntil,
  }) async {
    final user = currentUser;
    if (user == null) throw Exception('User not authenticated');

    try {
      // Verify user is team member
      final team = await getTeam(teamId);
      if (team == null) throw Exception('Team not found');
      if (!team.isMember(user.uid)) throw Exception('Not a team member');

      final event = SharedEvent.create(
        title: title,
        description: description,
        date: date,
        startDate: startDate,
        endDate: endDate,
        priority: priority,
        teamId: teamId,
        createdBy: user.uid,
        createdByName: user.displayName,
        createdByEmail: user.email,
        location: location,
        tags: tags,
        customFields: customFields,
        recurringPattern: recurringPattern,
        recurringUntil: recurringUntil,
      );

      final docRef = _sharedEventsCollection.doc();
      final eventWithId = event.copyWith(id: docRef.id);

      await docRef.set(eventWithId.toJson());
      return eventWithId;
    } catch (e) {
      print('Error creating shared event: $e');
      rethrow;
    }
  }

  /// Get team's shared events
  Future<List<SharedEvent>> getTeamEvents({
    required String teamId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      Query query = _sharedEventsCollection.where('teamId', isEqualTo: teamId);

      if (startDate != null) {
        query = query.where('date', isGreaterThanOrEqualTo: startDate);
      }
      if (endDate != null) {
        query = query.where('date', isLessThanOrEqualTo: endDate);
      }

      final querySnapshot = await query.orderBy('date').get();
      return querySnapshot.docs
          .map(
            (doc) => SharedEvent.fromJson(doc.data() as Map<String, dynamic>),
          )
          .toList();
    } catch (e) {
      print('Error fetching team events: $e');
      return [];
    }
  }

  /// Update shared event
  Future<bool> updateSharedEvent({
    required String eventId,
    String? title,
    String? description,
    DateTime? date,
    DateTime? startDate,
    DateTime? endDate,
    String? priority,
    String? location,
    List<String>? tags,
    Map<String, dynamic>? customFields,
  }) async {
    final user = currentUser;
    if (user == null) throw Exception('User not authenticated');

    try {
      final eventDoc = await _sharedEventsCollection.doc(eventId).get();
      if (!eventDoc.exists) throw Exception('Event not found');

      final event = SharedEvent.fromJson(
        eventDoc.data() as Map<String, dynamic>,
      );

      if (!event.canEdit(user.uid)) {
        throw Exception('Insufficient permissions');
      }

      final updateData = <String, dynamic>{
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      };

      if (title != null) updateData['title'] = title;
      if (description != null) updateData['description'] = description;
      if (date != null) updateData['date'] = Timestamp.fromDate(date);
      if (startDate != null)
        updateData['startDate'] = Timestamp.fromDate(startDate);
      if (endDate != null) updateData['endDate'] = Timestamp.fromDate(endDate);
      if (priority != null) updateData['priority'] = priority;
      if (location != null) updateData['location'] = location;
      if (tags != null) updateData['tags'] = tags;
      if (customFields != null) updateData['customFields'] = customFields;

      await _sharedEventsCollection.doc(eventId).update(updateData);
      return true;
    } catch (e) {
      print('Error updating shared event: $e');
      return false;
    }
  }

  /// Delete shared event
  Future<bool> deleteSharedEvent(String eventId) async {
    final user = currentUser;
    if (user == null) throw Exception('User not authenticated');

    try {
      final eventDoc = await _sharedEventsCollection.doc(eventId).get();
      if (!eventDoc.exists) throw Exception('Event not found');

      final event = SharedEvent.fromJson(
        eventDoc.data() as Map<String, dynamic>,
      );

      if (!event.canDelete(user.uid)) {
        throw Exception('Insufficient permissions');
      }

      await _sharedEventsCollection.doc(eventId).delete();
      return true;
    } catch (e) {
      print('Error deleting shared event: $e');
      return false;
    }
  }

  // ==================== HELPER METHODS ====================

  /// Create user document if it doesn't exist
  Future<void> _createUserDocument(String userId) async {
    print('🔧 _createUserDocument: Creating user document for $userId');
    try {
      final userData = {'teamIds': [], 'createdAt': Timestamp.now()};
      print('📝 _createUserDocument: User data to create: $userData');

      await _firestore.collection('users').doc(userId).set(userData);
      print('✅ _createUserDocument: User document created successfully');
    } catch (e) {
      print('💥 _createUserDocument: Error creating user document: $e');
      print('💥 _createUserDocument: Error type: ${e.runtimeType}');
    }
  }

  /// Add team to user's teams list
  Future<void> _addTeamToUser(String userId, String teamId) async {
    print('🔧 _addTeamToUser: Adding team $teamId to user $userId');
    try {
      final userDocRef = _firestore.collection('users').doc(userId);
      print('📄 _addTeamToUser: Fetching user document...');
      final userDoc = await userDocRef.get();

      if (!userDoc.exists) {
        print(
          '⚠️ _addTeamToUser: User document does not exist, creating with team',
        );
        final userData = {
          'teamIds': [teamId],
          'createdAt': Timestamp.now(),
        };
        print('📝 _addTeamToUser: Creating user document with data: $userData');
        await userDocRef.set(userData);
        print('✅ _addTeamToUser: User document created with team');
      } else {
        print('✅ _addTeamToUser: User document exists, updating team list');
        final currentTeamIds = List<String>.from(
          userDoc.data()?['teamIds'] ?? [],
        );
        print('🔢 _addTeamToUser: Current team IDs: $currentTeamIds');

        if (!currentTeamIds.contains(teamId)) {
          currentTeamIds.add(teamId);
          print('➕ _addTeamToUser: Adding team to list: $currentTeamIds');
          await userDocRef.update({'teamIds': currentTeamIds});
          print('✅ _addTeamToUser: Team added successfully');
        } else {
          print('⚠️ _addTeamToUser: Team already exists in user list');
        }
      }
    } catch (e) {
      print('💥 _addTeamToUser: Error adding team to user: $e');
      print('💥 _addTeamToUser: Error type: ${e.runtimeType}');
    }
  }

  /// Remove team from user's teams list
  Future<void> _removeTeamFromUser(String userId, String teamId) async {
    try {
      final userDocRef = _firestore.collection('users').doc(userId);
      final userDoc = await userDocRef.get();

      if (!userDoc.exists) {
        // User document doesn't exist, nothing to remove
        return;
      }

      final currentTeamIds = List<String>.from(
        userDoc.data()?['teamIds'] ?? [],
      );

      currentTeamIds.remove(teamId);
      await userDocRef.update({'teamIds': currentTeamIds});
    } catch (e) {
      print('Error removing team from user: $e');
    }
  }

  /// Get permissions for role
  TeamPermissions _getPermissionsForRole(String role) {
    switch (role) {
      case 'owner':
        return TeamPermissions.all();
      case 'admin':
        return TeamPermissions.admin();
      case 'member':
        return TeamPermissions.member();
      case 'viewer':
        return TeamPermissions.viewer();
      default:
        return TeamPermissions.member();
    }
  }
}

/// Extension to add copyWith method to SharedEvent
extension SharedEventCopyWith on SharedEvent {
  SharedEvent copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? date,
    DateTime? startDate,
    DateTime? endDate,
    String? priority,
    bool? isCompleted,
    String? teamId,
    String? createdBy,
    String? createdByName,
    String? createdByEmail,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<EventParticipant>? participants,
    EventVisibility? visibility,
    EventStatus? status,
    String? location,
    List<String>? tags,
    Map<String, dynamic>? customFields,
    String? recurringPattern,
    DateTime? recurringUntil,
    List<EventAttachment>? attachments,
    List<EventComment>? comments,
    EventReminderSettings? reminderSettings,
  }) {
    return SharedEvent(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      date: date ?? this.date,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      priority: priority ?? this.priority,
      isCompleted: isCompleted ?? this.isCompleted,
      teamId: teamId ?? this.teamId,
      createdBy: createdBy ?? this.createdBy,
      createdByName: createdByName ?? this.createdByName,
      createdByEmail: createdByEmail ?? this.createdByEmail,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      participants: participants ?? this.participants,
      visibility: visibility ?? this.visibility,
      status: status ?? this.status,
      location: location ?? this.location,
      tags: tags ?? this.tags,
      customFields: customFields ?? this.customFields,
      recurringPattern: recurringPattern ?? this.recurringPattern,
      recurringUntil: recurringUntil ?? this.recurringUntil,
      attachments: attachments ?? this.attachments,
      comments: comments ?? this.comments,
      reminderSettings: reminderSettings ?? this.reminderSettings,
    );
  }
}
