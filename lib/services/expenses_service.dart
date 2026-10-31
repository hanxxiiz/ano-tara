import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/expense.dart';
import '../models/trip.dart';

class ExpenseSaveException implements Exception {
  ExpenseSaveException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Writes expenses to Supabase: one row in `expenses` plus one row per
/// person in `expense_shares`.
class ExpensesService {
  ExpensesService([SupabaseClient? client]) : _clientOverride = client;

  static const expensesTable = 'expenses';
  static const sharesTable = 'expense_shares';
  static const currency = 'PHP';

  final SupabaseClient? _clientOverride;

  // Resolved lazily so screens can be built (e.g. in widget tests) without
  // Supabase being initialized.
  SupabaseClient get _client => _clientOverride ?? Supabase.instance.client;

  /// Inserts [expense] for [trip] and returns the new `expenses.id`.
  Future<String> insert(Trip trip, Expense expense) async {
    final tripId = trip.remoteId;
    if (tripId == null) {
      throw ExpenseSaveException('This trip is not saved online yet.');
    }
    final userId = _client.auth.currentUser?.id;
    if (userId == null) {
      throw ExpenseSaveException('Sign in to save expenses.');
    }

    String userIdOf(String memberId) {
      final id = trip.group.memberById(memberId)?.userId;
      if (id == null) {
        throw ExpenseSaveException(
          'A member in this split has no account yet.',
        );
      }
      return id;
    }

    final payerId = userIdOf(expense.paidById);
    final shareUserIds = {
      for (final entry in expense.sharesCents.entries)
        entry.key: userIdOf(entry.key),
    };

    final row = await _client
        .from(expensesTable)
        .insert({
          'trip_id': tripId,
          'description': expense.title,
          'amount': expense.amountCents / 100,
          'currency': currency,
          'category': expense.category.dbValue,
          'paid_by': payerId,
          'created_by': userId,
          'split_method': expense.splitMethod.dbValue,
          'occurred_at': expense.occurredAt.toUtc().toIso8601String(),
        })
        .select('id')
        .single();
    final expenseId = row['id'].toString();

    try {
      await _client.from(sharesTable).insert([
        for (final entry in expense.sharesCents.entries)
          {
            'expense_id': expenseId,
            'user_id': shareUserIds[entry.key],
            'share_amount': entry.value / 100,
            // The payer's own share is already covered.
            'is_settled': entry.key == expense.paidById,
          },
      ]);
    } catch (_) {
      // No client-side transactions: undo the expense so it isn't left
      // without shares.
      await _client.from(expensesTable).delete().eq('id', expenseId);
      rethrow;
    }
    return expenseId;
  }

  Future<void> rename(String expenseId, String title) async {
    await _client
        .from(expensesTable)
        .update({'description': title})
        .eq('id', expenseId);
  }

  /// Removes the shares first in case the foreign key doesn't cascade.
  Future<void> delete(String expenseId) async {
    await _client.from(sharesTable).delete().eq('expense_id', expenseId);
    await _client.from(expensesTable).delete().eq('id', expenseId);
  }

  /// Loads the trip's expenses with their shares, newest first.
  Future<List<Expense>> fetch(Trip trip) async {
    final rows = await _client
        .from(expensesTable)
        .select(
          'id, description, amount, category, paid_by, split_method, occurred_at, created_at, '
          '$sharesTable(user_id, share_amount)',
        )
        .eq('trip_id', trip.remoteId!)
        .order('occurred_at', ascending: false);

    String memberIdFor(Object? userId) {
      final id = userId.toString();
      for (final m in trip.group.members) {
        if (m.userId == id) return m.id;
      }
      return id;
    }

    int cents(Object? value) => (((value as num?) ?? 0) * 100).round();

    return [
      for (final row in rows)
        Expense(
          id: row['id'].toString(),
          title: (row['description'] ?? '').toString(),
          category: ExpenseCategory.values.firstWhere(
            (c) => c.dbValue == row['category'],
            orElse: () => ExpenseCategory.other,
          ),
          amountCents: cents(row['amount']),
          paidById: memberIdFor(row['paid_by']),
          splitMethod: row['split_method'] == SplitMethod.custom.dbValue
              ? SplitMethod.custom
              : SplitMethod.equal,
          sharesCents: {
            for (final share in (row[sharesTable] as List? ?? const []))
              memberIdFor(share['user_id']): cents(share['share_amount']),
          },
          occurredAt:
              DateTime.tryParse(
                (row['occurred_at'] ?? row['created_at']).toString(),
              )?.toLocal() ??
              DateTime.now(),
        ),
    ];
  }
}
