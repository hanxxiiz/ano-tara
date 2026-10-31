import 'package:flutter/material.dart';

import '../../models/trip.dart';
import '../../services/trips_repository.dart';
import '../../widgets/trip_widgets.dart';
import 'add_expense_flow.dart';
import 'item_details.dart';

class ExpensesScreen extends StatefulWidget {
  const ExpensesScreen({
    super.key,
    required this.tripId,
    TripsRepository? repository,
  }) : _repository = repository;

  /// Route name the add-expense flow pops back to.
  static const routeName = '/trips/expenses';

  final String tripId;
  final TripsRepository? _repository;

  static Route<void> route({
    required String tripId,
    TripsRepository? repository,
  }) {
    return MaterialPageRoute(
      settings: const RouteSettings(name: routeName),
      builder: (_) => ExpensesScreen(tripId: tripId, repository: repository),
    );
  }

  @override
  State<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends State<ExpensesScreen> {
  late final TripsRepository _repo =
      widget._repository ?? TripsRepository.instance;
  DateTime? _selectedDay;
  var _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future<void> _refresh() async {
    final trip = _repo.tripById(widget.tripId);
    if (trip == null || trip.remoteId == null) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await _repo.loadExpenses(trip);
    } catch (_) {
      _error = "Couldn't load expenses. Check your connection and try again.";
    }
    if (mounted) setState(() => _loading = false);
  }

  /// Today when the trip is underway, otherwise its first day.
  DateTime _defaultDay(Trip trip) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final days = trip.days;
    return days.contains(today) ? today : days.first;
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _repo,
      builder: (context, _) {
        final trip = _repo.tripById(widget.tripId);
        if (trip == null) {
          return const Scaffold(
            body: Center(child: Text('This trip no longer exists.')),
          );
        }
        final days = trip.days;
        final selected = _selectedDay != null && days.contains(_selectedDay)
            ? _selectedDay!
            : _defaultDay(trip);
        final expenses = trip.expensesOn(selected);

        return Scaffold(
          appBar: TitleBar(
            title: 'View Expenses',
            onAdd: () => startAddExpense(
              context,
              trip: trip,
              day: selected,
              repository: _repo,
            ),
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(15, 24, 15, 28),
            children: [
              DateTabStrip(
                days: days,
                selected: selected,
                onSelected: (day) => setState(() => _selectedDay = day),
              ),
              const SizedBox(height: 25),
              if (_loading)
                const LoadingCard(message: 'Loading expenses…')
              else if (_error != null)
                ErrorCard(message: _error!, onRetry: _refresh)
              else if (expenses.isEmpty)
                const EmptyCard(
                  message: 'No expenses for this day yet. Tap Add to log one.',
                )
              else
                for (final expense in expenses) ...[
                  ExpenseCard(
                    expense: expense,
                    onTap: () => showExpenseDetails(
                      context,
                      trip: trip,
                      expense: expense,
                      repository: _repo,
                    ),
                    payerName:
                        trip.group.memberById(expense.paidById)?.name ??
                        'Unknown',
                  ),
                  const SizedBox(height: 24),
                ],
            ],
          ),
        );
      },
    );
  }
}
