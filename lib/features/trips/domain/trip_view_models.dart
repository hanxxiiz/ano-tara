import 'package:flutter/material.dart';

/// Lifecycle status of a trip.
enum TripStatus {
  upcoming,
  ongoing,
  completed,
  cancelled;

  bool get isReadOnly => this == completed || this == cancelled;

  String get badgeLabel {
    switch (this) {
      case TripStatus.upcoming:
        return 'Upcoming';
      case TripStatus.ongoing:
        return 'Ongoing';
      case TripStatus.completed:
        return 'Completed';
      case TripStatus.cancelled:
        return 'Cancelled';
    }
  }
}

/// Historical or final RSVP status for a trip member.
enum TripMemberRsvp {
  going,
  notGoing,
  pending;

  String get label {
    switch (this) {
      case TripMemberRsvp.going:
        return 'Going';
      case TripMemberRsvp.notGoing:
        return 'Not Going';
      case TripMemberRsvp.pending:
        return 'Pending';
    }
  }
}

/// Itinerary entry type matching Figma (Accommodation, Activity, Dining).
enum TripEntryType {
  accommodation,
  activity,
  dining;

  String get label {
    switch (this) {
      case TripEntryType.accommodation:
        return 'Accommodation';
      case TripEntryType.activity:
        return 'Activity';
      case TripEntryType.dining:
        return 'Dining';
    }
  }

  String get categoryTag {
    switch (this) {
      case TripEntryType.accommodation:
        return 'Stay';
      case TripEntryType.activity:
        return 'Activity';
      case TripEntryType.dining:
        return 'Food';
    }
  }
}

/// Read-only itinerary entry model.
class TripItineraryEntry {
  final String id;
  final int dayNumber;
  final TripEntryType type;
  final String categoryLabel;
  final String title;
  final String placeName;
  final String location;
  final double rating;
  final String startTime;
  final String endTime;
  final String notes;
  final Offset mapPosition;

  const TripItineraryEntry({
    required this.id,
    required this.dayNumber,
    required this.type,
    required this.categoryLabel,
    required this.title,
    required this.placeName,
    required this.location,
    this.rating = 4.8,
    required this.startTime,
    required this.endTime,
    this.notes = '',
    this.mapPosition = const Offset(0.52, 0.44),
  });

  String get timeRange => '$startTime - $endTime';
}

/// Settlement row for a single member inside an expense.
class TripExpenseSettlement {
  final String id;
  final String memberName;
  final bool isCurrentUser;
  final bool isPaidAtPurchase;
  final double amount;
  final bool isSettled;

  const TripExpenseSettlement({
    required this.id,
    required this.memberName,
    this.isCurrentUser = false,
    this.isPaidAtPurchase = false,
    required this.amount,
    required this.isSettled,
  });

  String get displayName => isCurrentUser ? '$memberName (You)' : memberName;

  String get subtitle {
    if (isPaidAtPurchase) return 'Paid at purchase';
    return isSettled ? 'Payment received' : 'Awaiting payment';
  }

  TripExpenseSettlement copyWith({
    String? memberName,
    bool? isCurrentUser,
    bool? isPaidAtPurchase,
    double? amount,
    bool? isSettled,
  }) {
    return TripExpenseSettlement(
      id: id,
      memberName: memberName ?? this.memberName,
      isCurrentUser: isCurrentUser ?? this.isCurrentUser,
      isPaidAtPurchase: isPaidAtPurchase ?? this.isPaidAtPurchase,
      amount: amount ?? this.amount,
      isSettled: isSettled ?? this.isSettled,
    );
  }
}

/// Expense item model with per-member settlements.
class TripExpenseItem {
  final String id;
  final int dayNumber;
  final String category;
  final String title;
  final double totalAmount;
  final String paidByName;
  final bool isPaidByYou;
  final List<TripExpenseSettlement> settlements;

  const TripExpenseItem({
    required this.id,
    required this.dayNumber,
    required this.category,
    required this.title,
    required this.totalAmount,
    required this.paidByName,
    this.isPaidByYou = false,
    required this.settlements,
  });

  TripExpenseItem copyWith({
    int? dayNumber,
    String? category,
    String? title,
    double? totalAmount,
    String? paidByName,
    bool? isPaidByYou,
    List<TripExpenseSettlement>? settlements,
  }) {
    return TripExpenseItem(
      id: id,
      dayNumber: dayNumber ?? this.dayNumber,
      category: category ?? this.category,
      title: title ?? this.title,
      totalAmount: totalAmount ?? this.totalAmount,
      paidByName: paidByName ?? this.paidByName,
      isPaidByYou: isPaidByYou ?? this.isPaidByYou,
      settlements: settlements ?? this.settlements,
    );
  }

  String get paidByLabel =>
      isPaidByYou ? 'Paid by: $paidByName (you)' : 'Paid by: $paidByName';

  List<TripExpenseSettlement> get nonPayerSettlements =>
      settlements.where((s) => !s.isPaidAtPurchase).toList();

  int get settledCount =>
      nonPayerSettlements.where((s) => s.isSettled).length;

  int get totalToSettleCount => nonPayerSettlements.length;

  double get receivedAmount => settlements
      .where((s) => s.isSettled || s.isPaidAtPurchase)
      .fold<double>(0.0, (sum, s) => sum + s.amount);

  double get stillToReceiveAmount =>
      (totalAmount - receivedAmount).clamp(0.0, totalAmount);

  double get settlementProgress =>
      totalAmount <= 0 ? 0.0 : (receivedAmount / totalAmount).clamp(0.0, 1.0);
}

/// Member RSVP record for Completed / Cancelled trip views.
class TripMemberResponse {
  final String id;
  final String fullName;
  final String username;
  final TripMemberRsvp status;

  const TripMemberResponse({
    required this.id,
    required this.fullName,
    required this.username,
    required this.status,
  });
}

/// Member marker data for the Trip Map screen.
class TripMapMember {
  final String id;
  final String name;
  final String initials;
  final Color avatarColor;
  final bool isCurrentUser;
  final bool isSharingLocation;
  final String statusSubtitle;
  final String distanceFromMeetingPoint;
  final Offset normalizedPosition;

  const TripMapMember({
    required this.id,
    required this.name,
    required this.initials,
    required this.avatarColor,
    this.isCurrentUser = false,
    this.isSharingLocation = true,
    required this.statusSubtitle,
    required this.distanceFromMeetingPoint,
    required this.normalizedPosition,
  });

  TripMapMember copyWith({
    bool? isSharingLocation,
    String? statusSubtitle,
  }) {
    return TripMapMember(
      id: id,
      name: name,
      initials: initials,
      avatarColor: avatarColor,
      isCurrentUser: isCurrentUser,
      isSharingLocation: isSharingLocation ?? this.isSharingLocation,
      statusSubtitle: statusSubtitle ?? this.statusSubtitle,
      distanceFromMeetingPoint: distanceFromMeetingPoint,
      normalizedPosition: normalizedPosition,
    );
  }
}

/// Complete view model for Trip Overview (Completed / Cancelled) and Trip Map.
class TripDetailData {
  final String id;
  final String title;
  final String location;
  final String about;
  final TripStatus status;
  final List<String> memberInitials;
  final int extraMemberCount;
  final int totalDays;
  final int currentDay;
  final List<String> shortDayDates;
  final List<String> fullDayDates;
  final String fullDateRange;
  final String? cancelledByText;
  final String? cancellationReason;
  final String meetingPointName;
  final String meetingPointAddress;
  final Offset meetingPointPosition;
  final List<TripItineraryEntry> itineraryEntries;
  final List<TripExpenseItem> expenses;
  final List<TripMemberResponse> memberResponses;
  final int respondedCount;
  final int totalInvitedCount;
  final int goingCount;
  final int notGoingCount;
  final int noResponseCount;
  final List<TripMapMember> mapMembers;

  const TripDetailData({
    required this.id,
    required this.title,
    required this.location,
    required this.about,
    required this.status,
    required this.memberInitials,
    required this.extraMemberCount,
    required this.totalDays,
    required this.currentDay,
    required this.shortDayDates,
    required this.fullDayDates,
    required this.fullDateRange,
    this.cancelledByText,
    this.cancellationReason,
    required this.meetingPointName,
    required this.meetingPointAddress,
    this.meetingPointPosition = const Offset(0.50, 0.45),
    required this.itineraryEntries,
    required this.expenses,
    required this.memberResponses,
    required this.respondedCount,
    required this.totalInvitedCount,
    required this.goingCount,
    required this.notGoingCount,
    required this.noResponseCount,
    required this.mapMembers,
  });

  bool get isCompleted => status == TripStatus.completed;
  bool get isCancelled => status == TripStatus.cancelled;
  bool get isReadOnly => status.isReadOnly;

  static List<TripItineraryEntry> get _sampleItinerary => const [
        TripItineraryEntry(
          id: 'it-1',
          dayNumber: 1,
          type: TripEntryType.accommodation,
          categoryLabel: 'Stay',
          title: 'Check-in at Beach Resort',
          placeName: "Hannah's Beach Resort",
          location: 'Santa Fe, Bantayan',
          rating: 4.8,
          startTime: '1:00 PM',
          endTime: '2:30 PM',
          notes: 'Early check-in confirmed for 6 guests.',
          mapPosition: Offset(0.48, 0.42),
        ),
        TripItineraryEntry(
          id: 'it-2',
          dayNumber: 2,
          type: TripEntryType.dining,
          categoryLabel: 'Food',
          title: 'Eat at Jollibee',
          placeName: "Hannah's Beach Resort",
          location: 'Santa Fe, Bantayan',
          rating: 4.8,
          startTime: '9:00 AM',
          endTime: '10:00 AM',
          notes: '',
          mapPosition: Offset(0.52, 0.46),
        ),
        TripItineraryEntry(
          id: 'it-3',
          dayNumber: 2,
          type: TripEntryType.dining,
          categoryLabel: 'Food',
          title: 'Eat at Jollibee',
          placeName: "Hannah's Beach Resort",
          location: 'Santa Fe, Bantayan',
          rating: 4.8,
          startTime: '9:00 AM',
          endTime: '10:00 AM',
          notes: '',
          mapPosition: Offset(0.55, 0.48),
        ),
        TripItineraryEntry(
          id: 'it-4',
          dayNumber: 3,
          type: TripEntryType.activity,
          categoryLabel: 'Activity',
          title: 'Virgin Island Hopping',
          placeName: 'Virgin Island Sandbar',
          location: 'Santa Fe, Bantayan',
          rating: 4.9,
          startTime: '8:30 AM',
          endTime: '12:00 PM',
          notes: 'Bring reef-safe sunscreen and dry bags.',
          mapPosition: Offset(0.60, 0.36),
        ),
      ];

  static List<TripExpenseItem> get _sampleExpenses => const [
        TripExpenseItem(
          id: 'exp-1',
          dayNumber: 1,
          category: 'Food',
          title: 'Balut',
          totalAmount: 600.00,
          paidByName: 'Hannah',
          isPaidByYou: true,
          settlements: [
            TripExpenseSettlement(
              id: 'set-1',
              memberName: 'Olivia',
              amount: 120.00,
              isSettled: false,
            ),
            TripExpenseSettlement(
              id: 'set-2',
              memberName: 'Lizzie',
              amount: 120.00,
              isSettled: true,
            ),
            TripExpenseSettlement(
              id: 'set-3',
              memberName: 'Elle',
              amount: 120.00,
              isSettled: false,
            ),
            TripExpenseSettlement(
              id: 'set-4',
              memberName: 'Izzie',
              amount: 120.00,
              isSettled: false,
            ),
            TripExpenseSettlement(
              id: 'set-5',
              memberName: 'Hannah',
              isCurrentUser: true,
              isPaidAtPurchase: true,
              amount: 120.00,
              isSettled: true,
            ),
          ],
        ),
        TripExpenseItem(
          id: 'exp-2',
          dayNumber: 1,
          category: 'Food',
          title: 'Balut',
          totalAmount: 600.00,
          paidByName: 'Hannah',
          isPaidByYou: true,
          settlements: [
            TripExpenseSettlement(
              id: 'set-6',
              memberName: 'Olivia',
              amount: 120.00,
              isSettled: false,
            ),
            TripExpenseSettlement(
              id: 'set-7',
              memberName: 'Lizzie',
              amount: 120.00,
              isSettled: true,
            ),
            TripExpenseSettlement(
              id: 'set-8',
              memberName: 'Elle',
              amount: 120.00,
              isSettled: false,
            ),
            TripExpenseSettlement(
              id: 'set-9',
              memberName: 'Izzie',
              amount: 120.00,
              isSettled: false,
            ),
            TripExpenseSettlement(
              id: 'set-10',
              memberName: 'Hannah',
              isCurrentUser: true,
              isPaidAtPurchase: true,
              amount: 120.00,
              isSettled: true,
            ),
          ],
        ),
      ];

  static List<TripMemberResponse> get _sampleMembers => const [
        TripMemberResponse(
          id: 'mem-1',
          fullName: 'Louielyn Abella',
          username: '@blackxswann',
          status: TripMemberRsvp.pending,
        ),
        TripMemberResponse(
          id: 'mem-2',
          fullName: 'Louielyn Abella',
          username: '@blackxswann',
          status: TripMemberRsvp.notGoing,
        ),
        TripMemberResponse(
          id: 'mem-3',
          fullName: 'Louielyn Abella',
          username: '@blackxswann',
          status: TripMemberRsvp.going,
        ),
      ];

  static List<TripMapMember> get _sampleMapMembers => const [
        TripMapMember(
          id: 'map-1',
          name: 'Hannah (You)',
          initials: 'HL',
          avatarColor: Color(0xFFF9CF09),
          isCurrentUser: true,
          isSharingLocation: true,
          statusSubtitle: 'Sharing live • Just now',
          distanceFromMeetingPoint: '180 m away',
          normalizedPosition: Offset(0.36, 0.34),
        ),
        TripMapMember(
          id: 'map-2',
          name: 'Louielyn Abella',
          initials: 'LA',
          avatarColor: Color(0xFFE24B27),
          isSharingLocation: true,
          statusSubtitle: 'Sharing live • 1m ago',
          distanceFromMeetingPoint: '320 m away',
          normalizedPosition: Offset(0.66, 0.30),
        ),
        TripMapMember(
          id: 'map-3',
          name: 'Elle Bernante',
          initials: 'EB',
          avatarColor: Color(0xFF144885),
          isSharingLocation: true,
          statusSubtitle: 'Sharing live • 2m ago',
          distanceFromMeetingPoint: '450 m away',
          normalizedPosition: Offset(0.28, 0.56),
        ),
        TripMapMember(
          id: 'map-4',
          name: 'Olivia Cruz',
          initials: 'OC',
          avatarColor: Color(0xFF10B981),
          isSharingLocation: true,
          statusSubtitle: 'Sharing live • 3m ago',
          distanceFromMeetingPoint: '610 m away',
          normalizedPosition: Offset(0.71, 0.54),
        ),
        TripMapMember(
          id: 'map-5',
          name: 'Izzie Reyes',
          initials: 'IR',
          avatarColor: Color(0xFF868097),
          isSharingLocation: false,
          statusSubtitle: 'Location sharing off',
          distanceFromMeetingPoint: 'Hidden',
          normalizedPosition: Offset(0.42, 0.64),
        ),
      ];

  /// Sample matching Figma 11.01–11.07 (Completed Trip).
  factory TripDetailData.completedSample() {
    return TripDetailData(
      id: 'trip-bantayan-completed',
      title: 'Bantayan Trip',
      location: 'Bantayan, Philippines',
      about:
          'Island hopping, beach dinners and as many sunsets as we can fit in.',
      status: TripStatus.completed,
      memberInitials: const ['MR', 'MR', 'MR', 'MR'],
      extraMemberCount: 3,
      totalDays: 3,
      currentDay: 3,
      shortDayDates: const ['Nov 13', 'Nov 14', 'Nov 15'],
      fullDayDates: const [
        'Friday, November 13',
        'Saturday, November 14',
        'Sunday, November 15',
      ],
      fullDateRange: 'November 13 - November 15',
      meetingPointName: "Hannah's Beach Resort",
      meetingPointAddress: 'Santa Fe, Bantayan, Cebu',
      itineraryEntries: _sampleItinerary,
      expenses: _sampleExpenses,
      memberResponses: _sampleMembers,
      respondedCount: 3,
      totalInvitedCount: 5,
      goingCount: 2,
      notGoingCount: 1,
      noResponseCount: 10,
      mapMembers: _sampleMapMembers,
    );
  }

  /// Sample matching Figma 11.10–11.16 (Cancelled Trip).
  factory TripDetailData.cancelledSample() {
    return TripDetailData(
      id: 'trip-bantayan-cancelled',
      title: 'Bantayan Trip',
      location: 'Bantayan, Philippines',
      about:
          'Island hopping, beach dinners and as many sunsets as we can fit in.',
      status: TripStatus.cancelled,
      memberInitials: const ['MR', 'MR', 'MR', 'MR'],
      extraMemberCount: 3,
      totalDays: 3,
      currentDay: 2,
      shortDayDates: const ['Nov 13', 'Nov 14', 'Nov 15'],
      fullDayDates: const [
        'Friday, November 13',
        'Saturday, November 14',
        'Sunday, November 15',
      ],
      fullDateRange: 'November 13 - November 15',
      cancelledByText: 'You cancelled on November 10',
      cancellationReason: 'Sorry guys, wala gituyo',
      meetingPointName: "Hannah's Beach Resort",
      meetingPointAddress: 'Santa Fe, Bantayan, Cebu',
      itineraryEntries: _sampleItinerary,
      expenses: _sampleExpenses,
      memberResponses: _sampleMembers,
      respondedCount: 3,
      totalInvitedCount: 5,
      goingCount: 2,
      notGoingCount: 1,
      noResponseCount: 10,
      mapMembers: _sampleMapMembers,
    );
  }

  /// Sample for an active Trip Map view.
  factory TripDetailData.activeMapSample() {
    return TripDetailData(
      id: 'trip-bantayan-live',
      title: 'Bantayan Trip',
      location: 'Bantayan, Philippines',
      about:
          'Island hopping, beach dinners and as many sunsets as we can fit in.',
      status: TripStatus.ongoing,
      memberInitials: const ['HL', 'LA', 'EB', 'OC'],
      extraMemberCount: 1,
      totalDays: 3,
      currentDay: 2,
      shortDayDates: const ['Nov 13', 'Nov 14', 'Nov 15'],
      fullDayDates: const [
        'Friday, November 13',
        'Saturday, November 14',
        'Sunday, November 15',
      ],
      fullDateRange: 'November 13 - November 15',
      meetingPointName: "Hannah's Beach Resort",
      meetingPointAddress: 'Santa Fe, Bantayan, Cebu',
      itineraryEntries: _sampleItinerary,
      expenses: _sampleExpenses,
      memberResponses: _sampleMembers,
      respondedCount: 4,
      totalInvitedCount: 5,
      goingCount: 4,
      notGoingCount: 0,
      noResponseCount: 1,
      mapMembers: _sampleMapMembers,
    );
  }
}
