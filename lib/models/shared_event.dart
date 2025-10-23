import 'package:cloud_firestore/cloud_firestore.dart';
import 'calendar_event.dart';

/// Shared event model for team collaboration
class SharedEvent {
  final String id;
  final String title;
  final String description;
  final DateTime date;
  final DateTime? startDate;
  final DateTime? endDate;
  final String priority;
  final bool isCompleted;
  final String teamId;
  final String createdBy;
  final String? createdByName;
  final String? createdByEmail;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<EventParticipant> participants;
  final EventVisibility visibility;
  final EventStatus status;
  final String? location;
  final List<String> tags;
  final Map<String, dynamic> customFields;
  final String? recurringPattern;
  final DateTime? recurringUntil;
  final List<EventAttachment> attachments;
  final List<EventComment> comments;
  final EventReminderSettings reminderSettings;

  const SharedEvent({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    this.startDate,
    this.endDate,
    required this.priority,
    required this.isCompleted,
    required this.teamId,
    required this.createdBy,
    this.createdByName,
    this.createdByEmail,
    required this.createdAt,
    required this.updatedAt,
    required this.participants,
    required this.visibility,
    required this.status,
    this.location,
    required this.tags,
    required this.customFields,
    this.recurringPattern,
    this.recurringUntil,
    required this.attachments,
    required this.comments,
    required this.reminderSettings,
  });

  /// Create a new shared event
  factory SharedEvent.create({
    required String title,
    required String description,
    required DateTime date,
    DateTime? startDate,
    DateTime? endDate,
    required String priority,
    required String teamId,
    required String createdBy,
    String? createdByName,
    String? createdByEmail,
    String? location,
    List<String> tags = const [],
    Map<String, dynamic> customFields = const {},
    String? recurringPattern,
    DateTime? recurringUntil,
  }) {
    final now = DateTime.now();
    return SharedEvent(
      id: '',
      title: title,
      description: description,
      date: date,
      startDate: startDate,
      endDate: endDate,
      priority: priority,
      isCompleted: false,
      teamId: teamId,
      createdBy: createdBy,
      createdByName: createdByName,
      createdByEmail: createdByEmail,
      createdAt: now,
      updatedAt: now,
      participants: [
        EventParticipant(
          userId: createdBy,
          email: createdByEmail ?? '',
          name: createdByName,
          role: EventRole.organizer,
          status: EventParticipationStatus.accepted,
          joinedAt: now,
        ),
      ],
      visibility: EventVisibility.team,
      status: EventStatus.active,
      location: location,
      tags: tags,
      customFields: customFields,
      recurringPattern: recurringPattern,
      recurringUntil: recurringUntil,
      attachments: [],
      comments: [],
      reminderSettings: EventReminderSettings.defaultSettings(),
    );
  }

  /// Convert to JSON for Firestore
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'date': Timestamp.fromDate(date),
      'startDate': startDate != null ? Timestamp.fromDate(startDate!) : null,
      'endDate': endDate != null ? Timestamp.fromDate(endDate!) : null,
      'priority': priority,
      'isCompleted': isCompleted,
      'teamId': teamId,
      'createdBy': createdBy,
      'createdByName': createdByName,
      'createdByEmail': createdByEmail,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'participants': participants.map((p) => p.toJson()).toList(),
      'visibility': visibility.name,
      'status': status.name,
      'location': location,
      'tags': tags,
      'customFields': customFields,
      'recurringPattern': recurringPattern,
      'recurringUntil': recurringUntil != null
          ? Timestamp.fromDate(recurringUntil!)
          : null,
      'attachments': attachments.map((a) => a.toJson()).toList(),
      'comments': comments.map((c) => c.toJson()).toList(),
      'reminderSettings': reminderSettings.toJson(),
    };
  }

  /// Create from Firestore document
  factory SharedEvent.fromJson(Map<String, dynamic> json) {
    return SharedEvent(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      date: (json['date'] as Timestamp).toDate(),
      startDate: json['startDate'] != null
          ? (json['startDate'] as Timestamp).toDate()
          : null,
      endDate: json['endDate'] != null
          ? (json['endDate'] as Timestamp).toDate()
          : null,
      priority: json['priority'] ?? 'medium',
      isCompleted: json['isCompleted'] ?? false,
      teamId: json['teamId'] ?? '',
      createdBy: json['createdBy'] ?? '',
      createdByName: json['createdByName'],
      createdByEmail: json['createdByEmail'],
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      updatedAt: (json['updatedAt'] as Timestamp).toDate(),
      participants:
          (json['participants'] as List<dynamic>?)
              ?.map((p) => EventParticipant.fromJson(p))
              .toList() ??
          [],
      visibility: EventVisibility.values.firstWhere(
        (v) => v.name == json['visibility'],
        orElse: () => EventVisibility.team,
      ),
      status: EventStatus.values.firstWhere(
        (s) => s.name == json['status'],
        orElse: () => EventStatus.active,
      ),
      location: json['location'],
      tags: List<String>.from(json['tags'] ?? []),
      customFields: Map<String, dynamic>.from(json['customFields'] ?? {}),
      recurringPattern: json['recurringPattern'],
      recurringUntil: json['recurringUntil'] != null
          ? (json['recurringUntil'] as Timestamp).toDate()
          : null,
      attachments:
          (json['attachments'] as List<dynamic>?)
              ?.map((a) => EventAttachment.fromJson(a))
              .toList() ??
          [],
      comments:
          (json['comments'] as List<dynamic>?)
              ?.map((c) => EventComment.fromJson(c))
              .toList() ??
          [],
      reminderSettings: EventReminderSettings.fromJson(
        json['reminderSettings'] ?? {},
      ),
    );
  }

  /// Convert to regular CalendarEvent
  CalendarEvent toCalendarEvent() {
    return CalendarEvent(
      id: id,
      title: title,
      description: description,
      date: date,
      startDate: startDate,
      endDate: endDate,
      priority: priority,
      isCompleted: isCompleted,
      source: 'team',
      externalId: null,
      calendarId: teamId,
    );
  }

  /// Check if user is participant
  bool isParticipant(String userId) {
    return participants.any((p) => p.userId == userId);
  }

  /// Get participant by user ID
  EventParticipant? getParticipant(String userId) {
    try {
      return participants.firstWhere((p) => p.userId == userId);
    } catch (e) {
      return null;
    }
  }

  /// Check if user can edit event
  bool canEdit(String userId) {
    final participant = getParticipant(userId);
    return participant?.role == EventRole.organizer ||
        participant?.role == EventRole.coOrganizer;
  }

  /// Check if user can delete event
  bool canDelete(String userId) {
    final participant = getParticipant(userId);
    return participant?.role == EventRole.organizer;
  }
}

/// Event participant model
class EventParticipant {
  final String userId;
  final String email;
  final String? name;
  final String? photoURL;
  final EventRole role;
  final EventParticipationStatus status;
  final DateTime joinedAt;
  final DateTime? respondedAt;
  final String? responseNote;

  const EventParticipant({
    required this.userId,
    required this.email,
    this.name,
    this.photoURL,
    required this.role,
    required this.status,
    required this.joinedAt,
    this.respondedAt,
    this.responseNote,
  });

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'email': email,
      'name': name,
      'photoURL': photoURL,
      'role': role.name,
      'status': status.name,
      'joinedAt': Timestamp.fromDate(joinedAt),
      'respondedAt': respondedAt != null
          ? Timestamp.fromDate(respondedAt!)
          : null,
      'responseNote': responseNote,
    };
  }

  /// Create from JSON
  factory EventParticipant.fromJson(Map<String, dynamic> json) {
    return EventParticipant(
      userId: json['userId'] ?? '',
      email: json['email'] ?? '',
      name: json['name'],
      photoURL: json['photoURL'],
      role: EventRole.values.firstWhere(
        (r) => r.name == json['role'],
        orElse: () => EventRole.attendee,
      ),
      status: EventParticipationStatus.values.firstWhere(
        (s) => s.name == json['status'],
        orElse: () => EventParticipationStatus.pending,
      ),
      joinedAt: (json['joinedAt'] as Timestamp).toDate(),
      respondedAt: json['respondedAt'] != null
          ? (json['respondedAt'] as Timestamp).toDate()
          : null,
      responseNote: json['responseNote'],
    );
  }
}

/// Event attachment model
class EventAttachment {
  final String id;
  final String name;
  final String url;
  final String type;
  final int size;
  final String uploadedBy;
  final DateTime uploadedAt;

  const EventAttachment({
    required this.id,
    required this.name,
    required this.url,
    required this.type,
    required this.size,
    required this.uploadedBy,
    required this.uploadedAt,
  });

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'url': url,
      'type': type,
      'size': size,
      'uploadedBy': uploadedBy,
      'uploadedAt': Timestamp.fromDate(uploadedAt),
    };
  }

  /// Create from JSON
  factory EventAttachment.fromJson(Map<String, dynamic> json) {
    return EventAttachment(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      url: json['url'] ?? '',
      type: json['type'] ?? '',
      size: json['size'] ?? 0,
      uploadedBy: json['uploadedBy'] ?? '',
      uploadedAt: (json['uploadedAt'] as Timestamp).toDate(),
    );
  }
}

/// Event comment model
class EventComment {
  final String id;
  final String userId;
  final String userName;
  final String userEmail;
  final String? userPhotoURL;
  final String content;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isEdited;
  final List<String> mentions;

  const EventComment({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userEmail,
    this.userPhotoURL,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
    this.isEdited = false,
    required this.mentions,
  });

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'userEmail': userEmail,
      'userPhotoURL': userPhotoURL,
      'content': content,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'isEdited': isEdited,
      'mentions': mentions,
    };
  }

  /// Create from JSON
  factory EventComment.fromJson(Map<String, dynamic> json) {
    return EventComment(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      userName: json['userName'] ?? '',
      userEmail: json['userEmail'] ?? '',
      userPhotoURL: json['userPhotoURL'],
      content: json['content'] ?? '',
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      updatedAt: (json['updatedAt'] as Timestamp).toDate(),
      isEdited: json['isEdited'] ?? false,
      mentions: List<String>.from(json['mentions'] ?? []),
    );
  }
}

/// Event reminder settings model
class EventReminderSettings {
  final bool enabled;
  final List<int> reminderMinutes;
  final bool emailReminders;
  final bool pushReminders;
  final bool smsReminders;

  const EventReminderSettings({
    required this.enabled,
    required this.reminderMinutes,
    required this.emailReminders,
    required this.pushReminders,
    required this.smsReminders,
  });

  /// Default reminder settings
  factory EventReminderSettings.defaultSettings() {
    return const EventReminderSettings(
      enabled: true,
      reminderMinutes: [15, 60, 1440], // 15 min, 1 hour, 1 day
      emailReminders: true,
      pushReminders: true,
      smsReminders: false,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'enabled': enabled,
      'reminderMinutes': reminderMinutes,
      'emailReminders': emailReminders,
      'pushReminders': pushReminders,
      'smsReminders': smsReminders,
    };
  }

  /// Create from JSON
  factory EventReminderSettings.fromJson(Map<String, dynamic> json) {
    return EventReminderSettings(
      enabled: json['enabled'] ?? true,
      reminderMinutes: List<int>.from(
        json['reminderMinutes'] ?? [15, 60, 1440],
      ),
      emailReminders: json['emailReminders'] ?? true,
      pushReminders: json['pushReminders'] ?? true,
      smsReminders: json['smsReminders'] ?? false,
    );
  }
}

/// Event role enum
enum EventRole { organizer, coOrganizer, attendee }

/// Event participation status enum
enum EventParticipationStatus { pending, accepted, declined, tentative }

/// Event visibility enum
enum EventVisibility { public, team, private }

/// Event status enum
enum EventStatus { active, cancelled, completed, postponed }
