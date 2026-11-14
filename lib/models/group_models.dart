/// Strips the time so dates compare by calendar day.
DateTime dateOnly(DateTime date) => DateTime(date.year, date.month, date.day);

int daysInMonth(DateTime month) => DateTime(month.year, month.month + 1, 0).day;

enum GroupRole { organizer, member }

enum TripStatus { upcoming, ongoing, completed, cancelled }

extension TripStatusLabel on TripStatus {
  String get label => switch (this) {
    TripStatus.upcoming => 'Upcoming',
    TripStatus.ongoing => 'Ongoing',
    TripStatus.completed => 'Completed',
    TripStatus.cancelled => 'Cancelled',
  };
}

enum TripSort { dateNewest, dateOldest, nameAz, nameZa }

extension TripSortLabel on TripSort {
  String get label => switch (this) {
    TripSort.dateNewest => 'Trip Date (Newest First)',
    TripSort.dateOldest => 'Trip Date (Oldest First)',
    TripSort.nameAz => 'Trip Name (A-Z)',
    TripSort.nameZa => 'Trip Name (Z-A)',
  };
}

/// Status filter + sort order chosen in the Filter Trips sheet.
/// A null [status] means "All Trips".
class TripFilter {
  final TripStatus? status;
  final TripSort sort;

  const TripFilter({this.status, this.sort = TripSort.dateNewest});

  bool get isDefault => status == null && sort == TripSort.dateNewest;

  List<GroupTrip> apply(List<GroupTrip> trips) {
    final result = trips
        .where((trip) => status == null || trip.status == status)
        .toList();
    result.sort(
      (a, b) => switch (sort) {
        TripSort.dateNewest => b.startDate.compareTo(a.startDate),
        TripSort.dateOldest => a.startDate.compareTo(b.startDate),
        TripSort.nameAz => a.title.toLowerCase().compareTo(
          b.title.toLowerCase(),
        ),
        TripSort.nameZa => b.title.toLowerCase().compareTo(
          a.title.toLowerCase(),
        ),
      },
    );
    return result;
  }
}

class GroupTrip {
  final String id;
  final String title;
  final String location;
  final DateTime startDate;
  final DateTime endDate;
  final TripStatus status;
  final List<String> memberNames;

  const GroupTrip({
    required this.id,
    required this.title,
    required this.location,
    required this.startDate,
    required this.endDate,
    required this.status,
    this.memberNames = const [],
  });

  String get dateRange => '${_formatDay(startDate)} - ${_formatDay(endDate)}';

  static String _formatDay(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}';
  }
}

enum MemberStatus { joined, pending }

extension MemberStatusLabel on MemberStatus {
  String get label => switch (this) {
    MemberStatus.joined => 'Joined',
    MemberStatus.pending => 'Pending Invitation',
  };
}

enum MemberSort { nameAz, nameZa, recentlyJoined, oldestFirst }

extension MemberSortLabel on MemberSort {
  String get label => switch (this) {
    MemberSort.nameAz => 'Name (A-Z)',
    MemberSort.nameZa => 'Name (Z-A)',
    MemberSort.recentlyJoined => 'Recently Joined',
    MemberSort.oldestFirst => 'Oldest Members First',
  };
}

class GroupMember {
  final String id;
  final String name;
  final String handle;
  final MemberStatus status;

  /// When the member joined, or was invited if still pending.
  final DateTime addedAt;
  final bool isCurrentUser;

  const GroupMember({
    required this.id,
    required this.name,
    required this.handle,
    required this.addedAt,
    this.status = MemberStatus.joined,
    this.isCurrentUser = false,
  });

  bool get isPending => status == MemberStatus.pending;
}

/// Status filter + sort order chosen in the Filter Members sheet.
/// A null [status] means "All Members".
class MemberFilter {
  final MemberStatus? status;
  final MemberSort sort;

  const MemberFilter({this.status, this.sort = MemberSort.nameAz});

  bool get isDefault => status == null && sort == MemberSort.nameAz;

  List<GroupMember> apply(List<GroupMember> members, {String query = ''}) {
    final needle = query.trim().toLowerCase();
    final result = members
        .where((m) => status == null || m.status == status)
        .where(
          (m) =>
              needle.isEmpty ||
              m.name.toLowerCase().contains(needle) ||
              m.handle.toLowerCase().contains(needle),
        )
        .toList();
    result.sort(
      (a, b) => switch (sort) {
        MemberSort.nameAz => a.name.toLowerCase().compareTo(
          b.name.toLowerCase(),
        ),
        MemberSort.nameZa => b.name.toLowerCase().compareTo(
          a.name.toLowerCase(),
        ),
        MemberSort.recentlyJoined => b.addedAt.compareTo(a.addedAt),
        MemberSort.oldestFirst => a.addedAt.compareTo(b.addedAt),
      },
    );
    return result;
  }
}

/// Someone who can be invited to a group (05.09 Invite Members search).
class UserProfile {
  final String id;
  final String name;
  final String handle;

  const UserProfile({
    required this.id,
    required this.name,
    required this.handle,
  });

  bool matches(String query) {
    final needle = query.trim().toLowerCase();
    return needle.isEmpty ||
        name.toLowerCase().contains(needle) ||
        handle.toLowerCase().contains(needle);
  }

  /// Placeholder directory until user search is backed by Supabase.
  static const sampleDirectory = [
    UserProfile(id: 'jane', name: 'Jane Doe', handle: '@janedoe'),
    UserProfile(id: 'miguel', name: 'Miguel Santos', handle: '@miguel.s'),
    UserProfile(id: 'bea', name: 'Bea Tan', handle: '@beatan'),
    UserProfile(id: 'paolo', name: 'Paolo Ramos', handle: '@paolor'),
    UserProfile(id: 'rica', name: 'Rica Lim', handle: '@ricalim'),
    UserProfile(id: 'jules', name: 'Jules Garcia', handle: '@julesg'),
  ];
}

class GroupDetails {
  final String id;
  final String name;
  final String description;
  final String inviteCode;
  final GroupRole currentUserRole;
  final List<GroupMember> members;
  final List<GroupTrip> trips;

  /// Dates (time stripped) each member marked as available, keyed by member id.
  final Map<String, Set<DateTime>> availability;

  const GroupDetails({
    required this.id,
    required this.name,
    this.description = '',
    required this.inviteCode,
    this.currentUserRole = GroupRole.member,
    this.members = const [],
    this.trips = const [],
    this.availability = const {},
  });

  GroupMember? get currentUser {
    for (final m in members) {
      if (m.isCurrentUser) return m;
    }
    return null;
  }

  Set<DateTime> get myAvailability =>
      availability[currentUser?.id] ?? const <DateTime>{};

  /// Members who marked [date] as available.
  List<GroupMember> availableOn(DateTime date) {
    final day = dateOnly(date);
    return [
      for (final m in members)
        if (availability[m.id]?.contains(day) ?? false) m,
    ];
  }

  /// Up to [count] dates in [month] with the most members available,
  /// earliest first on ties. Dates nobody can make are skipped.
  List<DateTime> bestDates(DateTime month, {int count = 3}) {
    final days = daysInMonth(month);
    final ranked =
        [
          for (var d = 1; d <= days; d++) DateTime(month.year, month.month, d),
        ].where((day) => availableOn(day).isNotEmpty).toList()..sort((a, b) {
          final byCount = availableOn(
            b,
          ).length.compareTo(availableOn(a).length);
          return byCount != 0 ? byCount : a.compareTo(b);
        });
    return ranked.take(count).toList();
  }

  GroupDetails withMyAvailability(Set<DateTime> dates) {
    final me = currentUser;
    if (me == null) return this;
    return copyWith(
      availability: {
        ...availability,
        me.id: {for (final d in dates) dateOnly(d)},
      },
    );
  }

  bool get isOrganizer => currentUserRole == GroupRole.organizer;

  List<String> get memberNames => [for (final m in members) m.name];

  GroupDetails copyWith({
    String? name,
    String? description,
    String? inviteCode,
    List<GroupMember>? members,
    Map<String, Set<DateTime>>? availability,
  }) => GroupDetails(
    id: id,
    name: name ?? this.name,
    description: description ?? this.description,
    inviteCode: inviteCode ?? this.inviteCode,
    currentUserRole: currentUserRole,
    members: members ?? this.members,
    trips: trips,
    availability: availability ?? this.availability,
  );

  /// Adds [people] as pending invitations, skipping anyone already listed.
  GroupDetails withInvited(List<UserProfile> people) {
    final existing = {for (final m in members) m.id};
    return copyWith(
      members: [
        ...members,
        for (final p in people)
          if (!existing.contains(p.id))
            GroupMember(
              id: p.id,
              name: p.name,
              handle: p.handle,
              addedAt: DateTime.now(),
              status: MemberStatus.pending,
            ),
      ],
    );
  }

  /// Placeholder data until groups are backed by Supabase.
  static GroupDetails sample(
    String name, {
    GroupRole role = GroupRole.organizer,
  }) {
    final memberList = [
      GroupMember(
        id: 'marco',
        name: 'Marco Reyes',
        handle: '@marcoreyes',
        addedAt: DateTime(2026, 1, 4),
        isCurrentUser: true,
      ),
      GroupMember(
        id: 'louielyn',
        name: 'Louielyn Abella',
        handle: '@blackxswann',
        addedAt: DateTime(2026, 11, 2),
        status: MemberStatus.pending,
      ),
      GroupMember(
        id: 'hannah',
        name: 'Hannah Labandero',
        handle: '@hannahsl',
        addedAt: DateTime(2026, 2, 10),
      ),
      GroupMember(
        id: 'elle',
        name: 'Elle Bernante',
        handle: '@ellebee',
        addedAt: DateTime(2026, 3, 22),
      ),
      GroupMember(
        id: 'carla',
        name: 'Carla Santos',
        handle: '@carlasantos',
        addedAt: DateTime(2026, 5, 8),
      ),
      GroupMember(
        id: 'ann',
        name: 'Ann Villanueva',
        handle: '@annv',
        addedAt: DateTime(2026, 7, 19),
      ),
      GroupMember(
        id: 'shayne',
        name: 'Shayne Cruz',
        handle: '@shaynecruz',
        addedAt: DateTime(2026, 9, 1),
      ),
    ];
    final members = [for (final m in memberList) m.name];

    // Deterministic spread over this month and next so the heat map varies.
    final now = DateTime.now();
    final availability = <String, Set<DateTime>>{};
    for (var i = 0; i < memberList.length; i++) {
      final member = memberList[i];
      if (member.isPending) continue;
      availability[member.id] = {
        for (var m = 0; m < 2; m++)
          for (
            var d = 1;
            d <= daysInMonth(DateTime(now.year, now.month + m));
            d++
          )
            if ((d + i * 2) % 5 < 3) DateTime(now.year, now.month + m, d),
      };
    }

    return GroupDetails(
      id: name.toLowerCase().replaceAll(' ', '-'),
      name: name,
      description: 'Pasyara mi plss.',
      inviteCode: 'BTN73',
      currentUserRole: role,
      members: memberList,
      availability: availability,
      trips: [
        GroupTrip(
          id: 'bantayan',
          title: 'Bantayan Trip',
          location: 'Bantayan, Philippines',
          startDate: DateTime(2026, 11, 13),
          endDate: DateTime(2026, 11, 15),
          status: TripStatus.ongoing,
          memberNames: members,
        ),
        GroupTrip(
          id: 'siargao',
          title: 'Siargao Getaway',
          location: 'Siargao, Philippines',
          startDate: DateTime(2026, 12, 20),
          endDate: DateTime(2026, 12, 27),
          status: TripStatus.upcoming,
          memberNames: members.take(5).toList(),
        ),
        GroupTrip(
          id: 'baguio',
          title: 'Baguio Retreat',
          location: 'Baguio, Philippines',
          startDate: DateTime(2026, 8, 1),
          endDate: DateTime(2026, 8, 5),
          status: TripStatus.completed,
          memberNames: members,
        ),
      ],
    );
  }
}
