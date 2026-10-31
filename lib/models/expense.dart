import 'package:flutter/material.dart';

/// Expense categories. [dbValue] is what is stored in `expenses.category`.
enum ExpenseCategory {
  accommodation('Accommodation', 'accommodation', Icons.home_rounded),
  food('Food', 'food', Icons.restaurant_rounded),
  transport('Transport', 'transport', Icons.directions_bus_rounded),
  activity('Activity', 'activity', Icons.wb_sunny_rounded),
  shopping('Shopping', 'shopping', Icons.shopping_basket_rounded),
  other('Other', 'other', Icons.grid_view_rounded);

  const ExpenseCategory(this.label, this.dbValue, this.icon);

  final String label;
  final String dbValue;
  final IconData icon;
}

/// How an expense is divided. [dbValue] is stored in `expenses.split_method`.
enum SplitMethod {
  equal('Split Equally', 'equal'),
  custom('Custom Split', 'custom');

  const SplitMethod(this.label, this.dbValue);

  final String label;
  final String dbValue;
}

/// Amounts are kept in centavos to avoid rounding drift when splitting.
class Expense {
  const Expense({
    required this.id,
    required this.title,
    required this.category,
    required this.amountCents,
    required this.paidById,
    required this.splitMethod,
    required this.sharesCents,
    required this.occurredAt,
  });

  final String id;
  final String title;
  final ExpenseCategory category;
  final int amountCents;

  /// [TripMember.id] of whoever paid.
  final String paidById;
  final SplitMethod splitMethod;

  /// [TripMember.id] -> what that member owes, in centavos.
  final Map<String, int> sharesCents;
  final DateTime occurredAt;

  Expense withId(String newId) => Expense(
    id: newId,
    title: title,
    category: category,
    amountCents: amountCents,
    paidById: paidById,
    splitMethod: splitMethod,
    sharesCents: sharesCents,
    occurredAt: occurredAt,
  );
}

/// Splits [totalCents] evenly; leftover centavos go to the first members so
/// the shares always add up to the total.
Map<String, int> splitEqually(int totalCents, List<String> memberIds) {
  if (memberIds.isEmpty) return {};
  final base = totalCents ~/ memberIds.length;
  final remainder = totalCents % memberIds.length;
  return {
    for (var i = 0; i < memberIds.length; i++)
      memberIds[i]: base + (i < remainder ? 1 : 0),
  };
}

/// Parses "1,250.5" style input into centavos; null if it isn't a number.
int? parsePesoCents(String input) {
  final cleaned = input.replaceAll(',', '').replaceAll('₱', '').trim();
  if (cleaned.isEmpty) return null;
  final value = double.tryParse(cleaned);
  if (value == null || value < 0) return null;
  return (value * 100).round();
}

String formatPeso(int cents) {
  final negative = cents < 0;
  final abs = cents.abs();
  final whole = (abs ~/ 100).toString().replaceAllMapped(
    RegExp(r'\B(?=(\d{3})+(?!\d))'),
    (_) => ',',
  );
  final fraction = (abs % 100).toString().padLeft(2, '0');
  return '${negative ? '-' : ''}₱$whole.$fraction';
}
