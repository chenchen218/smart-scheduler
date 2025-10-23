import 'package:cloud_firestore/cloud_firestore.dart';

/// Team model for collaboration features
class Team {
  final String id;
  final String name;
  final String description;
  final String ownerId;
  final String ownerEmail;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<TeamMember> members;
  final TeamSettings settings;
  final String? color;
  final String? icon;

  const Team({
    required this.id,
    required this.name,
    required this.description,
    required this.ownerId,
    required this.ownerEmail,
    required this.createdAt,
    required this.updatedAt,
    required this.members,
    required this.settings,
    this.color,
    this.icon,
  });

  /// Create a new team
  factory Team.create({
    required String name,
    required String description,
    required String ownerId,
    required String ownerEmail,
    String? color,
    String? icon,
  }) {
    final now = DateTime.now();
    return Team(
      id: '',
      name: name,
      description: description,
      ownerId: ownerId,
      ownerEmail: ownerEmail,
      createdAt: now,
      updatedAt: now,
      members: [
        TeamMember(
          userId: ownerId,
          email: ownerEmail,
          name: ownerEmail.split('@')[0], // Use email prefix as default name
          role: TeamRole.owner,
          joinedAt: now,
          permissions: TeamPermissions.all(),
        ),
      ],
      settings: TeamSettings.defaultSettings(),
      color: color,
      icon: icon,
    );
  }

  /// Convert to JSON for Firestore
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'ownerId': ownerId,
      'ownerEmail': ownerEmail,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'members': members.map((member) => member.toJson()).toList(),
      'settings': settings.toJson(),
      'color': color,
      'icon': icon,
    };
  }

  /// Create from Firestore document
  factory Team.fromJson(Map<String, dynamic> json) {
    return Team(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      ownerId: json['ownerId'] ?? '',
      ownerEmail: json['ownerEmail'] ?? '',
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      updatedAt: (json['updatedAt'] as Timestamp).toDate(),
      members:
          (json['members'] as List<dynamic>?)
              ?.map((member) => TeamMember.fromJson(member))
              .toList() ??
          [],
      settings: TeamSettings.fromJson(json['settings'] ?? {}),
      color: json['color'],
      icon: json['icon'],
    );
  }

  /// Copy with changes
  Team copyWith({
    String? id,
    String? name,
    String? description,
    String? ownerId,
    String? ownerEmail,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<TeamMember>? members,
    TeamSettings? settings,
    String? color,
    String? icon,
  }) {
    return Team(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      ownerId: ownerId ?? this.ownerId,
      ownerEmail: ownerEmail ?? this.ownerEmail,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      members: members ?? this.members,
      settings: settings ?? this.settings,
      color: color ?? this.color,
      icon: icon ?? this.icon,
    );
  }

  /// Get member by user ID
  TeamMember? getMember(String userId) {
    try {
      return members.firstWhere((member) => member.userId == userId);
    } catch (e) {
      return null;
    }
  }

  /// Check if user is member
  bool isMember(String userId) {
    return getMember(userId) != null;
  }

  /// Check if user is owner
  bool isOwner(String userId) {
    return ownerId == userId;
  }

  /// Check if user can manage team
  bool canManageTeam(String userId) {
    final member = getMember(userId);
    return member?.role == TeamRole.owner || member?.role == TeamRole.admin;
  }

  /// Check if user can invite members
  bool canInviteMembers(String userId) {
    final member = getMember(userId);
    return member?.permissions.canInviteMembers ?? false;
  }
}

/// Team member model
class TeamMember {
  final String userId;
  final String email;
  final String? displayName;
  final String? name; // Add name field for easier access
  final String? photoURL;
  final TeamRole role;
  final DateTime joinedAt;
  final TeamPermissions permissions;
  final bool isActive;

  const TeamMember({
    required this.userId,
    required this.email,
    this.displayName,
    this.name,
    this.photoURL,
    required this.role,
    required this.joinedAt,
    required this.permissions,
    this.isActive = true,
  });

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'email': email,
      'displayName': displayName,
      'name': name,
      'photoURL': photoURL,
      'role': role.name,
      'joinedAt': Timestamp.fromDate(joinedAt),
      'permissions': permissions.toJson(),
      'isActive': isActive,
    };
  }

  /// Create from JSON
  factory TeamMember.fromJson(Map<String, dynamic> json) {
    return TeamMember(
      userId: json['userId'] ?? '',
      email: json['email'] ?? '',
      displayName: json['displayName'],
      name: json['name'],
      photoURL: json['photoURL'],
      role: TeamRole.values.firstWhere(
        (role) => role.name == json['role'],
        orElse: () => TeamRole.member,
      ),
      joinedAt: (json['joinedAt'] as Timestamp).toDate(),
      permissions: TeamPermissions.fromJson(json['permissions'] ?? {}),
      isActive: json['isActive'] ?? true,
    );
  }

  /// Copy with changes
  TeamMember copyWith({
    String? userId,
    String? email,
    String? displayName,
    String? name,
    String? photoURL,
    TeamRole? role,
    DateTime? joinedAt,
    TeamPermissions? permissions,
    bool? isActive,
  }) {
    return TeamMember(
      userId: userId ?? this.userId,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      name: name ?? this.name,
      photoURL: photoURL ?? this.photoURL,
      role: role ?? this.role,
      joinedAt: joinedAt ?? this.joinedAt,
      permissions: permissions ?? this.permissions,
      isActive: isActive ?? this.isActive,
    );
  }
}

/// Team role enum
enum TeamRole { owner, admin, member, viewer }

/// Team permissions model
class TeamPermissions {
  final bool canCreateEvents;
  final bool canEditEvents;
  final bool canDeleteEvents;
  final bool canInviteMembers;
  final bool canRemoveMembers;
  final bool canManageSettings;
  final bool canViewAllEvents;
  final bool canEditTeamInfo;

  const TeamPermissions({
    required this.canCreateEvents,
    required this.canEditEvents,
    required this.canDeleteEvents,
    required this.canInviteMembers,
    required this.canRemoveMembers,
    required this.canManageSettings,
    required this.canViewAllEvents,
    required this.canEditTeamInfo,
  });

  /// All permissions (for owners)
  factory TeamPermissions.all() {
    return const TeamPermissions(
      canCreateEvents: true,
      canEditEvents: true,
      canDeleteEvents: true,
      canInviteMembers: true,
      canRemoveMembers: true,
      canManageSettings: true,
      canViewAllEvents: true,
      canEditTeamInfo: true,
    );
  }

  /// Admin permissions
  factory TeamPermissions.admin() {
    return const TeamPermissions(
      canCreateEvents: true,
      canEditEvents: true,
      canDeleteEvents: true,
      canInviteMembers: true,
      canRemoveMembers: true,
      canManageSettings: false,
      canViewAllEvents: true,
      canEditTeamInfo: false,
    );
  }

  /// Member permissions
  factory TeamPermissions.member() {
    return const TeamPermissions(
      canCreateEvents: true,
      canEditEvents: true,
      canDeleteEvents: false,
      canInviteMembers: false,
      canRemoveMembers: false,
      canManageSettings: false,
      canViewAllEvents: true,
      canEditTeamInfo: false,
    );
  }

  /// Viewer permissions
  factory TeamPermissions.viewer() {
    return const TeamPermissions(
      canCreateEvents: false,
      canEditEvents: false,
      canDeleteEvents: false,
      canInviteMembers: false,
      canRemoveMembers: false,
      canManageSettings: false,
      canViewAllEvents: true,
      canEditTeamInfo: false,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'canCreateEvents': canCreateEvents,
      'canEditEvents': canEditEvents,
      'canDeleteEvents': canDeleteEvents,
      'canInviteMembers': canInviteMembers,
      'canRemoveMembers': canRemoveMembers,
      'canManageSettings': canManageSettings,
      'canViewAllEvents': canViewAllEvents,
      'canEditTeamInfo': canEditTeamInfo,
    };
  }

  /// Create from JSON
  factory TeamPermissions.fromJson(Map<String, dynamic> json) {
    return TeamPermissions(
      canCreateEvents: json['canCreateEvents'] ?? false,
      canEditEvents: json['canEditEvents'] ?? false,
      canDeleteEvents: json['canDeleteEvents'] ?? false,
      canInviteMembers: json['canInviteMembers'] ?? false,
      canRemoveMembers: json['canRemoveMembers'] ?? false,
      canManageSettings: json['canManageSettings'] ?? false,
      canViewAllEvents: json['canViewAllEvents'] ?? false,
      canEditTeamInfo: json['canEditTeamInfo'] ?? false,
    );
  }
}

/// Team settings model
class TeamSettings {
  final bool allowMemberInvites;
  final bool requireApprovalForEvents;
  final bool allowExternalInvites;
  final bool enableNotifications;
  final String defaultEventDuration;
  final List<String> allowedEventTypes;
  final Map<String, dynamic> customFields;

  const TeamSettings({
    required this.allowMemberInvites,
    required this.requireApprovalForEvents,
    required this.allowExternalInvites,
    required this.enableNotifications,
    required this.defaultEventDuration,
    required this.allowedEventTypes,
    required this.customFields,
  });

  /// Default settings
  factory TeamSettings.defaultSettings() {
    return const TeamSettings(
      allowMemberInvites: true,
      requireApprovalForEvents: false,
      allowExternalInvites: true,
      enableNotifications: true,
      defaultEventDuration: '60',
      allowedEventTypes: ['meeting', 'task', 'reminder', 'deadline'],
      customFields: {},
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'allowMemberInvites': allowMemberInvites,
      'requireApprovalForEvents': requireApprovalForEvents,
      'allowExternalInvites': allowExternalInvites,
      'enableNotifications': enableNotifications,
      'defaultEventDuration': defaultEventDuration,
      'allowedEventTypes': allowedEventTypes,
      'customFields': customFields,
    };
  }

  /// Create from JSON
  factory TeamSettings.fromJson(Map<String, dynamic> json) {
    return TeamSettings(
      allowMemberInvites: json['allowMemberInvites'] ?? true,
      requireApprovalForEvents: json['requireApprovalForEvents'] ?? false,
      allowExternalInvites: json['allowExternalInvites'] ?? true,
      enableNotifications: json['enableNotifications'] ?? true,
      defaultEventDuration: json['defaultEventDuration'] ?? '60',
      allowedEventTypes: List<String>.from(json['allowedEventTypes'] ?? []),
      customFields: Map<String, dynamic>.from(json['customFields'] ?? {}),
    );
  }
}
