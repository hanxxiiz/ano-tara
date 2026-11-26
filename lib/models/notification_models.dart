import 'package:flutter/material.dart';

/// Invitation category distinguishing Group vs Trip invitations.
enum InvitationType { group, trip }

/// Lifecycle status of an invitation.
enum InvitationStatus { pending, accepted, declined }

/// Category of an activity notification for filtering.
enum ActivityCategory {
  tripUpdates,
  expenseUpdates,
  memberResponses,
  groupUpdates,
  itineraryUpdates,
}

extension ActivityCategoryLabel on ActivityCategory {
  String get label {
    switch (this) {
      case ActivityCategory.tripUpdates:
        return 'Trip Updates';
      case ActivityCategory.expenseUpdates:
        return 'Expense Updates';
      case ActivityCategory.memberResponses:
        return 'Member Responses';
      case ActivityCategory.groupUpdates:
        return 'Group Updates';
      case ActivityCategory.itineraryUpdates:
        return 'Itinerary Updates';
    }
  }
}

extension InvitationStatusLabel on InvitationStatus {
  String get label {
    switch (this) {
      case InvitationStatus.pending:
        return 'Pending';
      case InvitationStatus.accepted:
        return 'Accepted';
      case InvitationStatus.declined:
        return 'Declined';
    }
  }
}

/// Filter state for the Activity tab modal.
class ActivityFilterState {
  const ActivityFilterState({
    this.readStatus = 'All Notifications',
    this.activityType = 'All Activities',
    this.sortBy = 'Newest First',
  });

  final String readStatus;
  final String activityType;
  final String sortBy;

  static const ActivityFilterState defaults = ActivityFilterState();

  bool get isDefault =>
      readStatus == defaults.readStatus &&
      activityType == defaults.activityType &&
      sortBy == defaults.sortBy;

  ActivityFilterState copyWith({
    String? readStatus,
    String? activityType,
    String? sortBy,
  }) {
    return ActivityFilterState(
      readStatus: readStatus ?? this.readStatus,
      activityType: activityType ?? this.activityType,
      sortBy: sortBy ?? this.sortBy,
    );
  }
}

/// Filter state for the Invitations tab modal.
class InvitationFilterState {
  const InvitationFilterState({
    this.status = 'All Statuses',
    this.type = 'All Invitations',
  });

  final String status;
  final String type;

  static const InvitationFilterState defaults = InvitationFilterState();

  bool get isDefault =>
      status == defaults.status && type == defaults.type;

  InvitationFilterState copyWith({
    String? status,
    String? type,
  }) {
    return InvitationFilterState(
      status: status ?? this.status,
      type: type ?? this.type,
    );
  }
}

/// Model representing an Activity notification item.
class ActivityNotificationItem {
  ActivityNotificationItem({
    required this.id,
    required this.title,
    required this.description,
    required this.timestamp,
    required this.icon,
    required this.isUnread,
    required this.category,
    required this.createdAt,
  });

  final String id;
  final String title;
  final String description;
  final String timestamp;
  final IconData icon;
  final ActivityCategory category;
  final DateTime createdAt;
  bool isUnread;
}

/// Model representing a Group or Trip invitation item.
class InvitationItem {
  InvitationItem({
    required this.id,
    required this.title,
    required this.inviterName,
    this.inviterHandle,
    this.organizerName,
    required this.timestamp,
    required this.type,
    required this.status,
    required this.summary,
    this.memberCount = 0,
    this.plannedTripsCount = 0,
    this.location,
    this.dateRange,
    this.groupName,
    this.estimatedBudget,
    this.memberNames = const [],
  });

  final String id;
  final String title;
  final String inviterName;
  final String? inviterHandle;
  final String? organizerName;
  final String timestamp;
  final InvitationType type;
  InvitationStatus status;
  final String summary;

  // Group-specific metadata
  final int memberCount;
  final int plannedTripsCount;
  final List<String> memberNames;

  // Trip-specific metadata
  final String? location;
  final String? dateRange;
  final String? groupName;
  final String? estimatedBudget;

  String get displayHandle {
    if (inviterHandle != null && inviterHandle!.trim().isNotEmpty) {
      return inviterHandle!.startsWith('@')
          ? inviterHandle!
          : '@$inviterHandle';
    }
    final slug = inviterName
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9\s]'), '')
        .trim()
        .replaceAll(RegExp(r'\s+'), '.');
    return '@$slug';
  }

  String get displayOrganizer => organizerName ?? inviterName;

  String get cardDescription {
    final prefix = type == InvitationType.group
        ? 'Group invitation'
        : 'Trip invitation';
    return '$prefix from $inviterName.';
  }
}
