import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../core/constants/app_colors.dart';

/// Formats a numeric value in Philippine Peso with two decimal places.
String formatPeso(double amount) {
  final normalized = amount.abs() < 0.005 ? 0.0 : amount;
  return '₱${normalized.toStringAsFixed(2)}';
}

/// Expense categories matching Figma 10.04.
enum ExpenseCategory {
  accommodation,
  food,
  transport,
  activity,
  shopping,
  other,
}

extension ExpenseCategoryX on ExpenseCategory {
  String get label {
    switch (this) {
      case ExpenseCategory.accommodation:
        return 'Accommodation';
      case ExpenseCategory.food:
        return 'Food';
      case ExpenseCategory.transport:
        return 'Transport';
      case ExpenseCategory.activity:
        return 'Activity';
      case ExpenseCategory.shopping:
        return 'Shopping';
      case ExpenseCategory.other:
        return 'Other';
    }
  }

  IconData get icon {
    switch (this) {
      case ExpenseCategory.accommodation:
        return Iconsax.home_15;
      case ExpenseCategory.food:
        return Icons.restaurant_rounded;
      case ExpenseCategory.transport:
        return Icons.directions_boat_filled_rounded;
      case ExpenseCategory.activity:
        return Iconsax.sun_fog5;
      case ExpenseCategory.shopping:
        return Icons.shopping_basket_rounded;
      case ExpenseCategory.other:
        return Icons.grid_view_rounded;
    }
  }
}

/// How an expense is split among participating members.
enum SplitMethod {
  equal,
  custom,
}

/// A member participating in the trip.
class TripMember {
  final String id;
  final String firstName;
  final String fullName;
  final bool isCurrentUser;
  final Color avatarColor;

  const TripMember({
    required this.id,
    required this.firstName,
    required this.fullName,
    this.isCurrentUser = false,
    this.avatarColor = AppColors.semanticYellow,
  });

  String get shortLabel => isCurrentUser ? 'You' : firstName;

  String get listLabel => isCurrentUser ? '$firstName (You)' : firstName;

  String get dropdownLabel =>
      isCurrentUser ? 'You ($fullName)' : fullName;

  String get paidByLabel =>
      isCurrentUser ? '$firstName (you)' : firstName;
}

/// A single member's share and settlement status within an expense.
class MemberSplit {
  final String memberId;
  final double amount;
  final bool isSettled;
  final DateTime? settledAt;

  const MemberSplit({
    required this.memberId,
    required this.amount,
    this.isSettled = false,
    this.settledAt,
  });

  MemberSplit copyWith({
    String? memberId,
    double? amount,
    bool? isSettled,
    DateTime? settledAt,
  }) {
    return MemberSplit(
      memberId: memberId ?? this.memberId,
      amount: amount ?? this.amount,
      isSettled: isSettled ?? this.isSettled,
      settledAt: settledAt ?? this.settledAt,
    );
  }
}

/// A day within the trip schedule.
class TripDay {
  final int dayNumber;
  final String dateLabel;

  const TripDay({
    required this.dayNumber,
    required this.dateLabel,
  });
}

/// A single trip expense entry.
class TripExpense {
  final String id;
  final int dayIndex;
  final ExpenseCategory category;
  final String title;
  final double amount;
  final String paidByMemberId;
  final SplitMethod splitMethod;
  final List<MemberSplit> splits;
  final bool isLocked;
  final DateTime createdAt;

  const TripExpense({
    required this.id,
    required this.dayIndex,
    required this.category,
    required this.title,
    required this.amount,
    required this.paidByMemberId,
    required this.splitMethod,
    required this.splits,
    this.isLocked = false,
    required this.createdAt,
  });

  /// Splits belonging to members other than the payer.
  List<MemberSplit> get nonPayerSplits =>
      splits.where((s) => s.memberId != paidByMemberId).toList();

  /// Number of non-payer members who have settled.
  int get settledOtherCount =>
      nonPayerSplits.where((s) => s.isSettled).length;

  /// Total number of non-payer members who owe a share.
  int get totalOtherCount => nonPayerSplits.length;

  /// Total amount received from other members so far.
  double get receivedAmount => nonPayerSplits
      .where((s) => s.isSettled)
      .fold(0.0, (sum, s) => sum + s.amount);

  /// Total amount still owed by other members.
  double get stillToReceiveAmount => nonPayerSplits
      .where((s) => !s.isSettled)
      .fold(0.0, (sum, s) => sum + s.amount);

  /// Total amount owed by all non-payer members.
  double get totalOwedByOthers =>
      nonPayerSplits.fold(0.0, (sum, s) => sum + s.amount);

  /// Settlement progress ratio in [0.0, 1.0].
  double get settlementProgress {
    if (totalOwedByOthers <= 0.001) return 1.0;
    return (receivedAmount / totalOwedByOthers).clamp(0.0, 1.0);
  }

  TripExpense copyWith({
    String? id,
    int? dayIndex,
    ExpenseCategory? category,
    String? title,
    double? amount,
    String? paidByMemberId,
    SplitMethod? splitMethod,
    List<MemberSplit>? splits,
    bool? isLocked,
    DateTime? createdAt,
  }) {
    return TripExpense(
      id: id ?? this.id,
      dayIndex: dayIndex ?? this.dayIndex,
      category: category ?? this.category,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      paidByMemberId: paidByMemberId ?? this.paidByMemberId,
      splitMethod: splitMethod ?? this.splitMethod,
      splits: splits ?? this.splits,
      isLocked: isLocked ?? this.isLocked,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

/// Computes an equal split across [memberIds] that sums exactly to [totalAmount]
/// (distributing any 1-centavo rounding remainder cleanly to the first members).
Map<String, double> computeEqualSplit(
  double totalAmount,
  List<String> memberIds,
) {
  if (memberIds.isEmpty) return {};
  final totalCents = (totalAmount * 100).round();
  final count = memberIds.length;
  final baseCents = totalCents ~/ count;
  final remainderCents = totalCents - (baseCents * count);

  final result = <String, double>{};
  for (var i = 0; i < count; i++) {
    final cents = baseCents + (i < remainderCents ? 1 : 0);
    result[memberIds[i]] = cents / 100.0;
  }
  return result;
}

/// Reactive in-memory store for trip expenses, splits, and settlements.
class ExpensesStore extends ChangeNotifier {
  ExpensesStore._() {
    _seedInitialData();
  }

  static final ExpensesStore instance = ExpensesStore._();

  final List<TripDay> days = const [
    TripDay(dayNumber: 1, dateLabel: 'Friday, November 13'),
    TripDay(dayNumber: 2, dateLabel: 'Saturday, November 14'),
    TripDay(dayNumber: 3, dateLabel: 'Sunday, November 15'),
  ];

  final List<TripMember> members = const [
    TripMember(
      id: 'm_olivia',
      firstName: 'Olivia',
      fullName: 'Olivia Rodrigo',
      isCurrentUser: true,
    ),
    TripMember(
      id: 'm_lizzie',
      firstName: 'Lizzie',
      fullName: 'Lizzie Santos',
    ),
    TripMember(
      id: 'm_elle',
      firstName: 'Elle',
      fullName: 'Elle Reyes',
    ),
    TripMember(
      id: 'm_izzie',
      firstName: 'Izzie',
      fullName: 'Izzie Cruz',
    ),
    TripMember(
      id: 'm_hannah',
      firstName: 'Hannah',
      fullName: 'Hannah Labandero',
    ),
    TripMember(
      id: 'm_marcus',
      firstName: 'Marcus',
      fullName: 'Marcus Tan',
    ),
  ];

  final List<TripExpense> _expenses = [];
  int _nextId = 100;

  void _seedInitialData() {
    _expenses
      ..clear()
      ..addAll([
        // Day 1 (index 0) intentionally starts empty to showcase Figma 10.01.
        // Day 2 (index 1) has sample entries including a locked card (10.02 & 10.03).
        TripExpense(
          id: 'exp_1',
          dayIndex: 1,
          category: ExpenseCategory.food,
          title: 'Balut',
          amount: 600.00,
          paidByMemberId: 'm_hannah',
          splitMethod: SplitMethod.equal,
          splits: const [
            MemberSplit(memberId: 'm_olivia', amount: 120.00, isSettled: false),
            MemberSplit(memberId: 'm_lizzie', amount: 120.00, isSettled: true),
            MemberSplit(memberId: 'm_elle', amount: 120.00, isSettled: false),
            MemberSplit(memberId: 'm_izzie', amount: 120.00, isSettled: false),
            MemberSplit(memberId: 'm_hannah', amount: 120.00, isSettled: true),
          ],
          isLocked: false,
          createdAt: DateTime(2026, 11, 14, 18, 30),
        ),
        TripExpense(
          id: 'exp_2',
          dayIndex: 1,
          category: ExpenseCategory.food,
          title: 'Seafood Dinner',
          amount: 1500.00,
          paidByMemberId: 'm_olivia',
          splitMethod: SplitMethod.equal,
          splits: const [
            MemberSplit(memberId: 'm_olivia', amount: 300.00, isSettled: true),
            MemberSplit(memberId: 'm_lizzie', amount: 300.00, isSettled: false),
            MemberSplit(memberId: 'm_elle', amount: 300.00, isSettled: false),
            MemberSplit(memberId: 'm_izzie', amount: 300.00, isSettled: false),
            MemberSplit(memberId: 'm_hannah', amount: 300.00, isSettled: true),
          ],
          isLocked: false,
          createdAt: DateTime(2026, 11, 14, 20, 0),
        ),
        TripExpense(
          id: 'exp_3',
          dayIndex: 1,
          category: ExpenseCategory.accommodation,
          title: 'Beachfront Villa',
          amount: 2500.00,
          paidByMemberId: 'm_elle',
          splitMethod: SplitMethod.custom,
          splits: const [
            MemberSplit(memberId: 'm_olivia', amount: 500.00, isSettled: true),
            MemberSplit(memberId: 'm_lizzie', amount: 500.00, isSettled: true),
            MemberSplit(memberId: 'm_elle', amount: 500.00, isSettled: true),
            MemberSplit(memberId: 'm_izzie', amount: 500.00, isSettled: false),
            MemberSplit(memberId: 'm_hannah', amount: 500.00, isSettled: false),
          ],
          isLocked: true,
          createdAt: DateTime(2026, 11, 14, 14, 0),
        ),
        // Day 3 (index 2)
        TripExpense(
          id: 'exp_4',
          dayIndex: 2,
          category: ExpenseCategory.transport,
          title: 'Ferry Tickets',
          amount: 1000.00,
          paidByMemberId: 'm_olivia',
          splitMethod: SplitMethod.equal,
          splits: const [
            MemberSplit(memberId: 'm_olivia', amount: 200.00, isSettled: true),
            MemberSplit(memberId: 'm_lizzie', amount: 200.00, isSettled: false),
            MemberSplit(memberId: 'm_elle', amount: 200.00, isSettled: false),
            MemberSplit(memberId: 'm_izzie', amount: 200.00, isSettled: false),
            MemberSplit(memberId: 'm_hannah', amount: 200.00, isSettled: false),
          ],
          isLocked: false,
          createdAt: DateTime(2026, 11, 15, 9, 0),
        ),
      ]);
  }

  /// Resets the store to its default seeded state (useful for tests).
  void reset() {
    _seedInitialData();
    notifyListeners();
  }

  List<TripExpense> get allExpenses => List.unmodifiable(_expenses);

  List<TripExpense> expensesForDay(
    int dayIndex, {
    ExpenseCategory? categoryFilter,
  }) {
    return _expenses.where((e) {
      if (e.dayIndex != dayIndex) return false;
      if (categoryFilter != null && e.category != categoryFilter) return false;
      return true;
    }).toList();
  }

  TripExpense? findById(String id) {
    for (final e in _expenses) {
      if (e.id == id) return e;
    }
    return null;
  }

  TripMember findMember(String id) {
    return members.firstWhere(
      (m) => m.id == id,
      orElse: () => members.first,
    );
  }

  TripMember get currentUser =>
      members.firstWhere((m) => m.isCurrentUser, orElse: () => members.first);

  TripExpense addExpense({
    required int dayIndex,
    required ExpenseCategory category,
    required String title,
    required double amount,
    required String paidByMemberId,
    required SplitMethod splitMethod,
    required List<MemberSplit> splits,
  }) {
    final normalizedSplits = splits
        .map(
          (s) => s.memberId == paidByMemberId
              ? s.copyWith(isSettled: true)
              : s,
        )
        .toList();

    final expense = TripExpense(
      id: 'exp_${_nextId++}',
      dayIndex: dayIndex,
      category: category,
      title: title.trim(),
      amount: amount,
      paidByMemberId: paidByMemberId,
      splitMethod: splitMethod,
      splits: normalizedSplits,
      isLocked: false,
      createdAt: DateTime.now(),
    );
    _expenses.add(expense);
    notifyListeners();
    return expense;
  }

  void updateExpense(TripExpense updated) {
    final idx = _expenses.indexWhere((e) => e.id == updated.id);
    if (idx == -1) return;

    final previous = _expenses[idx];
    final prevSettledMap = {
      for (final s in previous.splits) s.memberId: s.isSettled,
    };

    final preservedSplits = updated.splits.map((s) {
      if (s.memberId == updated.paidByMemberId) {
        return s.copyWith(isSettled: true);
      }
      return s.copyWith(isSettled: prevSettledMap[s.memberId] ?? s.isSettled);
    }).toList();

    _expenses[idx] = updated.copyWith(splits: preservedSplits);
    notifyListeners();
  }

  void deleteExpenses(Set<String> ids) {
    _expenses.removeWhere((e) => ids.contains(e.id) && !e.isLocked);
    notifyListeners();
  }

  void markMemberSettled(
    String expenseId,
    String memberId, {
    bool settled = true,
  }) {
    final idx = _expenses.indexWhere((e) => e.id == expenseId);
    if (idx == -1) return;
    final exp = _expenses[idx];
    final updatedSplits = exp.splits.map((s) {
      if (s.memberId != memberId) return s;
      return s.copyWith(
        isSettled: settled,
        settledAt: settled ? DateTime.now() : null,
      );
    }).toList();
    _expenses[idx] = exp.copyWith(splits: updatedSplits);
    notifyListeners();
  }
}
