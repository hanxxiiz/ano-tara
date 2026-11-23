import 'package:flutter/material.dart';

/// Invitation category distinguishing Group vs Trip invitations.
enum InvitationType { group, trip }

/// Lifecycle status of an invitation.
enum InvitationStatus { pending, accepted, declined }

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

/// Model representing an Activity notification item.
class ActivityNotificationItem {
  ActivityNotificationItem({
    required this.id,
    required this.title,
    required this.description,
    required this.timestamp,
    required this.icon,
    required this.isUnread,
  });

  final String id;
  final String title;
  final String description;
  final String timestamp;
  final IconData icon;
  bool isUnread;
}

/// Model representing a Group or Trip invitation item.
class InvitationItem {
  InvitationItem({
    required this.id,
    required this.title,
    required this.inviterName,
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

  String get cardDescription {
    final prefix = type == InvitationType.group
        ? 'Group invitation'
        : 'Trip invitation';
    return '$prefix from $inviterName.';
  }
}
