/// One quota on the Manage Subscription screen, e.g. "Groups: 1 of 1".
///
/// [limit] is null when the plan has no limit (unlimited).
class QuotaUsage {
  const QuotaUsage({required this.used, this.limit});

  final int used;
  final int? limit;

  bool get isUnlimited => limit == null;
  bool get isAtLimit => limit != null && used >= limit!;

  /// 0.0 - 1.0, for a progress bar. Unlimited quotas show as empty.
  double get fraction {
    if (limit == null || limit == 0) return 0;
    return (used / limit!).clamp(0, 1).toDouble();
  }

  String get label => limit == null ? '$used used' : '$used of $limit';

  factory QuotaUsage.fromMap(Map<String, dynamic>? map) => QuotaUsage(
    used: _toInt(map?['used']) ?? 0,
    limit: _toInt(map?['limit']),
  );
}

/// Member count for one group the user owns.
class GroupMemberUsage {
  const GroupMemberUsage({
    required this.groupId,
    required this.groupName,
    required this.members,
  });

  final String groupId;
  final String groupName;
  final QuotaUsage members;
}

/// Result of the `anotara_get_subscription_usage` database function.
class SubscriptionUsage {
  const SubscriptionUsage({
    required this.planId,
    required this.planName,
    this.periodEnd,
    required this.groups,
    required this.activeTrips,
    required this.aiGenerations,
    this.aiResetsAt,
    this.membersPerGroupLimit,
    this.groupMembers = const [],
  });

  final String planId;
  final String planName;
  final DateTime? periodEnd;
  final QuotaUsage groups;
  final QuotaUsage activeTrips;
  final QuotaUsage aiGenerations;
  final DateTime? aiResetsAt;
  final int? membersPerGroupLimit;
  final List<GroupMemberUsage> groupMembers;

  bool get isFree => planId == 'free';

  factory SubscriptionUsage.fromMap(Map<String, dynamic> map) {
    final ai = _asMap(map['ai_generations']);
    final members = _asMap(map['members_per_group']);
    final memberLimit = _toInt(members?['limit']);
    final memberGroups = (members?['groups'] as List?) ?? const [];

    return SubscriptionUsage(
      planId: (map['plan_id'] ?? 'free').toString(),
      planName: (map['plan_name'] ?? 'Free').toString(),
      periodEnd: _toDate(map['period_end']),
      groups: QuotaUsage.fromMap(_asMap(map['groups'])),
      activeTrips: QuotaUsage.fromMap(_asMap(map['active_trips'])),
      aiGenerations: QuotaUsage.fromMap(ai),
      aiResetsAt: _toDate(ai?['resets_at']),
      membersPerGroupLimit: memberLimit,
      groupMembers: [
        for (final g in memberGroups.whereType<Map>())
          GroupMemberUsage(
            groupId: g['group_id'].toString(),
            groupName: (g['group_name'] ?? 'Group').toString(),
            members: QuotaUsage(used: _toInt(g['used']) ?? 0, limit: memberLimit),
          ),
      ],
    );
  }
}

Map<String, dynamic>? _asMap(Object? value) =>
    value is Map ? Map<String, dynamic>.from(value) : null;

int? _toInt(Object? value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value);
  return null;
}

DateTime? _toDate(Object? value) =>
    value == null ? null : DateTime.tryParse(value.toString())?.toLocal();
