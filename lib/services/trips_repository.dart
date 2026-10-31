import 'package:flutter/foundation.dart';

import '../models/expense.dart';
import '../models/trip.dart';
import 'expenses_service.dart';
import 'trip_map_service.dart';
import 'trips_service.dart';

/// In-memory trips and groups, seeded with sample data.
///
/// There are no trips/groups tables in Supabase yet; once they exist this
/// class is the one place that needs to load from and write to them.
class TripsRepository extends ChangeNotifier {
  TripsRepository._() {
    _seed();
  }

  static final TripsRepository instance = TripsRepository._();

  ExpensesService expensesService = ExpensesService();
  TripMapService mapService = TripMapService();
  TripsService tripsService = TripsService();

  final List<TripGroup> _groups = [];
  final List<Trip> _trips = [];
  var _nextId = 1;

  List<TripGroup> get groups => List.unmodifiable(_groups);
  List<Trip> get trips => List.unmodifiable(_trips);

  Trip? tripById(String id) {
    for (final trip in _trips) {
      if (trip.id == id) return trip;
    }
    return null;
  }

  Trip createTrip({
    required String title,
    required String destination,
    required TripGroup group,
    required DateTime startDate,
    required DateTime endDate,
    required String description,
  }) {
    final trip = Trip(
      id: _newId(),
      title: title,
      destination: destination,
      group: group,
      startDate: startDate,
      endDate: endDate,
      description: description,
      isOrganizer: true,
      organizerId: _youIn(group)?.id,
      // Dummy map until locations come from Supabase.
      meetingPoint: MeetingPoint(
        name: '$destination meetup',
        position: const GeoPoint(14.5995, 120.9842),
      ),
      memberLocations: [
        for (var i = 0; i < group.members.length && i < 3; i++)
          MemberLocation(
            memberId: group.members[i].id,
            position: GeoPoint(14.6035 - i * 0.003, 120.9800 + i * 0.004),
          ),
      ],
    );
    _trips.insert(0, trip);
    notifyListeners();
    return trip;
  }

  void addItineraryItem(
    Trip trip, {
    required String title,
    required ActivityCategory category,
    required String location,
    required DateTime start,
    required DateTime end,
  }) {
    trip.itinerary.add(
      ItineraryItem(
        id: _newId(),
        title: title,
        category: category,
        location: location,
        start: start,
        end: end,
      ),
    );
    notifyListeners();
  }

  /// Saves the expense to Supabase (`expenses` + `expense_shares`) when the
  /// trip exists there, then adds it to the trip. Throws if the online save
  /// fails, in which case nothing is added.
  ///
  /// Returns whether it was saved online (false for device-only trips).
  Future<bool> addExpense(
    Trip trip, {
    required String title,
    required ExpenseCategory category,
    required int amountCents,
    required String paidById,
    required SplitMethod splitMethod,
    required Map<String, int> sharesCents,
    required DateTime occurredAt,
  }) async {
    var expense = Expense(
      id: _newId(),
      title: title,
      category: category,
      amountCents: amountCents,
      paidById: paidById,
      splitMethod: splitMethod,
      sharesCents: Map.unmodifiable(sharesCents),
      occurredAt: occurredAt,
    );
    final savedOnline = trip.remoteId != null;
    if (savedOnline) {
      final remoteId = await expensesService.insert(trip, expense);
      expense = expense.withId(remoteId);
    }
    trip.expenses.add(expense);
    notifyListeners();
    return savedOnline;
  }

  /// Replaces [item] (matched by id) with the edited values.
  void updateItineraryItem(
    Trip trip,
    ItineraryItem item, {
    required String title,
    required ActivityCategory category,
    required String location,
    required DateTime start,
    required DateTime end,
  }) {
    final index = trip.itinerary.indexWhere((i) => i.id == item.id);
    if (index < 0) return;
    trip.itinerary[index] = ItineraryItem(
      id: item.id,
      title: title,
      category: category,
      location: location,
      start: start,
      end: end,
    );
    notifyListeners();
  }

  void removeItineraryItem(Trip trip, ItineraryItem item) {
    trip.itinerary.removeWhere((i) => i.id == item.id);
    notifyListeners();
  }

  /// Renames an expense, saving to Supabase when the trip exists there.
  Future<void> renameExpense(Trip trip, Expense expense, String title) async {
    if (trip.remoteId != null) {
      await expensesService.rename(expense.id, title);
    }
    final index = trip.expenses.indexWhere((e) => e.id == expense.id);
    if (index < 0) return;
    final e = trip.expenses[index];
    trip.expenses[index] = Expense(
      id: e.id,
      title: title,
      category: e.category,
      amountCents: e.amountCents,
      paidById: e.paidById,
      splitMethod: e.splitMethod,
      sharesCents: e.sharesCents,
      occurredAt: e.occurredAt,
    );
    notifyListeners();
  }

  /// Deletes an expense and its shares.
  Future<void> deleteExpense(Trip trip, Expense expense) async {
    if (trip.remoteId != null) {
      await expensesService.delete(expense.id);
    }
    trip.expenses.removeWhere((e) => e.id == expense.id);
    notifyListeners();
  }

  /// Organizer-only: renames the trip, saving it to Supabase when the trip
  /// exists there.
  Future<void> renameTrip(Trip trip, String name) async {
    if (!trip.isOrganizer) {
      throw StateError('Only the organizer can rename the trip.');
    }
    if (trip.remoteId != null) {
      await tripsService.rename(trip.remoteId!, name);
    }
    trip.title = name;
    notifyListeners();
  }

  /// Reloads the trip's expenses from Supabase. Device-only trips have
  /// nothing to load.
  Future<void> loadExpenses(Trip trip) async {
    if (trip.remoteId == null) return;
    final expenses = await expensesService.fetch(trip);
    trip.expenses
      ..clear()
      ..addAll(expenses);
    notifyListeners();
  }

  /// Reloads the meeting point and shared locations from Supabase.
  Future<void> loadMap(Trip trip) async {
    if (trip.remoteId == null) return;
    final data = await mapService.fetch(trip);
    trip.meetingPoint = data.meetingPoint;
    trip.memberLocations
      ..clear()
      ..addAll(data.locations);
    notifyListeners();
  }

  /// Organizer-only: sets the meeting point, saving it to Supabase when the
  /// trip exists there.
  Future<void> setMeetingPoint(Trip trip, MeetingPoint point) async {
    if (!trip.isOrganizer) {
      throw StateError('Only the organizer can change the meeting point.');
    }
    var saved = point;
    if (trip.remoteId != null) {
      saved = point.copyWith(
        id: await mapService.saveMeetingPoint(trip, point),
      );
    }
    trip.meetingPoint = saved;
    notifyListeners();
  }

  static TripMember? _youIn(TripGroup group) {
    for (final m in group.members) {
      if (m.isYou) return m;
    }
    return null;
  }

  String _newId() => '${_nextId++}';

  void _seed() {
    const barkada = TripGroup(
      id: 'g1',
      name: 'The Group',
      memberCount: 6,
      members: [
        TripMember(id: 'm1', name: 'Lorraine', isYou: true),
        TripMember(id: 'm2', name: 'Izzie'),
        TripMember(id: 'm3', name: 'Ellee'),
        TripMember(id: 'm4', name: 'Hannah'),
        TripMember(id: 'm5', name: 'Louielyn'),
        TripMember(id: 'm6', name: 'Yuan'),
      ],
    );
    const family = TripGroup(
      id: 'g2',
      name: 'Family',
      memberCount: 4,
      members: [
        TripMember(id: 'm7', name: 'Lorraine', isYou: true),
        TripMember(id: 'm8', name: 'Mama'),
        TripMember(id: 'm9', name: 'Papa'),
        TripMember(id: 'm10', name: 'Kuya'),
      ],
    );
    const office = TripGroup(
      id: 'g3',
      name: 'Office Friends',
      memberCount: 8,
      members: [
        TripMember(id: 'm11', name: 'Lorraine', isYou: true),
        TripMember(id: 'm12', name: 'Paolo'),
        TripMember(id: 'm13', name: 'Bea'),
        TripMember(id: 'm14', name: 'Jules'),
        TripMember(id: 'm15', name: 'Kat'),
        TripMember(id: 'm16', name: 'Migs'),
        TripMember(id: 'm17', name: 'Tin'),
        TripMember(id: 'm18', name: 'Ron'),
      ],
    );
    _groups.addAll([barkada, family, office]);

    // Built around "now" so Happening Now / Up Next have something to show.
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    DateTime at(int dayOffset, int hour, [int minute = 0]) =>
        DateTime(today.year, today.month, today.day + dayOffset, hour, minute);

    _trips.addAll([
      Trip(
        id: _newId(),
        title: 'Trip to Bantayan',
        destination: 'Bantayan, Philippines',
        group: barkada,
        startDate: at(-1, 0),
        endDate: at(3, 0),
        description:
            'Five days of island hopping, beach time and seafood with the group.',
        isOrganizer: true,
        organizerId: 'm1',
        itinerary: [
          ItineraryItem(
            id: _newId(),
            title: 'Check in at Kota Beach Resort',
            category: ActivityCategory.checkIn,
            location: 'Kota Beach Resort',
            start: at(-1, 13),
            end: at(-1, 14),
          ),
          ItineraryItem(
            id: _newId(),
            title: 'Eat at Jollibee',
            category: ActivityCategory.food,
            location: 'Santa Fe, Bantayan',
            start: at(0, 7),
            end: at(0, 8),
          ),
          ItineraryItem(
            id: _newId(),
            title: 'Island Hopping',
            category: ActivityCategory.activity,
            location: 'Santa Fe, Bantayan',
            start: DateTime(now.year, now.month, now.day, now.hour),
            end: DateTime(now.year, now.month, now.day, now.hour + 2),
          ),
          ItineraryItem(
            id: _newId(),
            title: 'Dinner at MJ Square',
            category: ActivityCategory.food,
            location: 'Santa Fe, Bantayan',
            start: DateTime(now.year, now.month, now.day, now.hour + 4),
            end: DateTime(now.year, now.month, now.day, now.hour + 5),
          ),
          ItineraryItem(
            id: _newId(),
            title: 'Paradise Beach',
            category: ActivityCategory.activity,
            location: 'Paradise Beach, Bantayan',
            start: at(1, 9),
            end: at(1, 12),
          ),
          ItineraryItem(
            id: _newId(),
            title: 'Ferry back to Hagnaya',
            category: ActivityCategory.transport,
            location: 'Santa Fe Port',
            start: at(3, 10),
            end: at(3, 11),
          ),
        ],
        meetingPoint: const MeetingPoint(
          name: 'Santa Fe Pier',
          position: GeoPoint(11.1592, 123.7955),
        ),
        memberLocations: const [
          MemberLocation(memberId: 'm1', position: GeoPoint(11.1662, 123.7878)),
          MemberLocation(memberId: 'm4', position: GeoPoint(11.1641, 123.7972)),
          MemberLocation(memberId: 'm5', position: GeoPoint(11.1616, 123.7898)),
        ],
        expenses: [
          Expense(
            id: _newId(),
            title: 'Kota Beach Resort (2 nights)',
            category: ExpenseCategory.accommodation,
            amountCents: 1200000,
            paidById: 'm1',
            splitMethod: SplitMethod.equal,
            sharesCents: splitEqually(1200000, [
              'm1',
              'm2',
              'm3',
              'm4',
              'm5',
              'm6',
            ]),
            occurredAt: at(-1, 13),
          ),
          Expense(
            id: _newId(),
            title: 'Breakfast at Jollibee',
            category: ExpenseCategory.food,
            amountCents: 60000,
            paidById: 'm4',
            splitMethod: SplitMethod.equal,
            sharesCents: splitEqually(60000, ['m1', 'm4', 'm5']),
            occurredAt: at(0, 7),
          ),
          Expense(
            id: _newId(),
            title: 'Island hopping boat',
            category: ExpenseCategory.activity,
            amountCents: 300000,
            paidById: 'm2',
            splitMethod: SplitMethod.custom,
            sharesCents: const {
              'm1': 50000,
              'm2': 100000,
              'm3': 50000,
              'm4': 50000,
              'm5': 50000,
            },
            occurredAt: at(0, 9),
          ),
        ],
      ),
      Trip(
        id: _newId(),
        title: 'Baguio Getaway',
        destination: 'Baguio, Philippines',
        group: family,
        startDate: at(20, 0),
        endDate: at(23, 0),
        description: 'Cool weather, strawberries and the night market.',
        isOrganizer: true,
        organizerId: 'm7',
        meetingPoint: const MeetingPoint(
          name: 'Burnham Park',
          position: GeoPoint(16.4123, 120.5930),
        ),
        memberLocations: const [
          MemberLocation(memberId: 'm7', position: GeoPoint(16.4160, 120.5975)),
          MemberLocation(memberId: 'm8', position: GeoPoint(16.4098, 120.5898)),
          MemberLocation(memberId: 'm9', position: GeoPoint(16.4141, 120.5879)),
        ],
        itinerary: [
          ItineraryItem(
            id: _newId(),
            title: 'Bus to Baguio',
            category: ActivityCategory.transport,
            location: 'Victory Liner, Cubao',
            start: at(20, 5),
            end: at(20, 11),
          ),
          ItineraryItem(
            id: _newId(),
            title: 'Strawberry farm',
            category: ActivityCategory.activity,
            location: 'La Trinidad, Benguet',
            start: at(21, 8),
            end: at(21, 11),
          ),
        ],
      ),
      Trip(
        id: _newId(),
        title: 'Siargao Surf Week',
        destination: 'Siargao, Philippines',
        group: office,
        startDate: at(-60, 0),
        endDate: at(-54, 0),
        description: 'Surf lessons at Cloud 9 and a day trip to Sugba Lagoon.',
        isOrganizer: true,
        organizerId: 'm11',
        meetingPoint: const MeetingPoint(
          name: 'Cloud 9 Boardwalk',
          position: GeoPoint(9.8130, 126.1640),
        ),
        memberLocations: const [
          MemberLocation(memberId: 'm11', position: GeoPoint(9.8172, 126.1602)),
          MemberLocation(memberId: 'm12', position: GeoPoint(9.8098, 126.1681)),
          MemberLocation(memberId: 'm13', position: GeoPoint(9.8155, 126.1695)),
          MemberLocation(memberId: 'm14', position: GeoPoint(9.8089, 126.1611)),
        ],
        expenses: [
          Expense(
            id: _newId(),
            title: 'Surf lessons',
            category: ExpenseCategory.activity,
            amountCents: 400000,
            paidById: 'm12',
            splitMethod: SplitMethod.equal,
            sharesCents: splitEqually(400000, ['m11', 'm12', 'm13', 'm14']),
            occurredAt: at(-60, 9),
          ),
        ],
      ),
      // You joined this one; Hannah organizes it, so it shows the Member view.
      Trip(
        id: _newId(),
        title: 'Cebu Food Crawl',
        destination: 'Cebu City, Philippines',
        group: barkada,
        startDate: at(8, 0),
        endDate: at(9, 0),
        description: 'Lechon, larsian and dessert spots around downtown Cebu.',
        isOrganizer: false,
        organizerId: 'm4',
        meetingPoint: const MeetingPoint(
          name: 'Larsian BBQ',
          position: GeoPoint(10.3065, 123.8930),
        ),
        memberLocations: const [
          MemberLocation(memberId: 'm4', position: GeoPoint(10.3101, 123.8899)),
          MemberLocation(memberId: 'm2', position: GeoPoint(10.3040, 123.8975)),
        ],
        itinerary: [
          ItineraryItem(
            id: _newId(),
            title: "Lechon lunch at Rico's",
            category: ActivityCategory.food,
            location: 'Mabolo, Cebu City',
            start: at(8, 12),
            end: at(8, 13),
          ),
        ],
      ),
    ]);
  }
}
