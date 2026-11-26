import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../components/atoms/app_icon.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../domain/trip_view_models.dart';
import '../widgets/trip_card_widgets.dart';
import 'trip_expense_settlements_screen.dart';

/// Read-only "View Expenses" screen matching Figma 11.05 (Completed) & 11.14 (Cancelled).
class TripExpensesScreen extends StatefulWidget {
  final TripDetailData trip;
  final int initialDay;
  final List<TripExpenseItem>? expenses;
  final ValueChanged<List<TripExpenseItem>>? onExpensesChanged;

  const TripExpensesScreen({
    super.key,
    required this.trip,
    this.initialDay = 1,
    this.expenses,
    this.onExpensesChanged,
  });

  @override
  State<TripExpensesScreen> createState() => _TripExpensesScreenState();
}

class _TripExpensesScreenState extends State<TripExpensesScreen> {
  late int _selectedDay;
  late List<TripExpenseItem> _expenses;

  @override
  void initState() {
    super.initState();
    _selectedDay = widget.initialDay.clamp(1, widget.trip.totalDays);
    _expenses = List<TripExpenseItem>.from(
      widget.expenses ?? widget.trip.expenses,
    );
  }

  void _updateExpense(TripExpenseItem updated) {
    setState(() {
      final idx = _expenses.indexWhere((e) => e.id == updated.id);
      if (idx != -1) {
        _expenses[idx] = updated;
      }
    });
    widget.onExpensesChanged?.call(List<TripExpenseItem>.from(_expenses));
  }

  void _deleteExpense(String expenseId) {
    setState(() {
      _expenses.removeWhere((e) => e.id == expenseId);
    });
    widget.onExpensesChanged?.call(List<TripExpenseItem>.from(_expenses));
  }

  @override
  Widget build(BuildContext context) {
    final daySubtitle = (_selectedDay - 1) < widget.trip.fullDayDates.length
        ? widget.trip.fullDayDates[_selectedDay - 1]
        : 'Day $_selectedDay';

    final dayExpenses =
        _expenses.where((e) => e.dayNumber == _selectedDay).toList();

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: const TripSubTopBar(title: 'View Expenses'),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 28),
          children: [
            TripDayStepperHeader(
              currentDay: _selectedDay,
              totalDays: widget.trip.totalDays,
              dateSubtitle: daySubtitle,
              onDayChanged: (day) => setState(() => _selectedDay = day),
            ),
            const SizedBox(height: 24),
            if (dayExpenses.isEmpty)
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: AppColors.secondaryDark,
                    width: 1.8,
                  ),
                ),
                child: Column(
                  children: [
                    const Icon(
                      Iconsax.wallet_remove,
                      size: 32,
                      color: AppColors.shayne,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'No expenses recorded for Day $_selectedDay',
                      style: AppTypography.titleMedium.copyWith(
                        color: AppColors.carla,
                      ),
                    ),
                  ],
                ),
              )
            else
              ...dayExpenses.map(
                (expense) => Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: _ExpenseListCard(
                    expense: expense,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => TripExpenseSettlementsScreen(
                            expense: expense,
                            tripStatus: widget.trip.status,
                            totalDays: widget.trip.totalDays,
                            onExpenseUpdated: _updateExpense,
                            onExpenseDeleted: () => _deleteExpense(expense.id),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ExpenseListCard extends StatelessWidget {
  final TripExpenseItem expense;
  final VoidCallback onTap;

  const _ExpenseListCard({
    required this.expense,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: AppColors.secondaryDark,
            width: 2.0,
          ),
          boxShadow: kTripHardShadow,
        ),
        child: Row(
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.primaryOrange,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Center(
                child: Icon(
                  Icons.lunch_dining_rounded,
                  color: AppColors.white,
                  size: 32,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 22,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEB9C88),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      expense.category,
                      style: AppTypography.caption.copyWith(
                        color: AppColors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 11,
                      ),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    expense.title,
                    style: AppTypography.titleMedium.copyWith(
                      color: AppColors.secondaryDark,
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      const AppIcon(
                        Iconsax.wallet_25,
                        color: AppColors.primaryOrange,
                        size: 13,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        '₱${expense.totalAmount.toStringAsFixed(2)}',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.carla,
                          fontWeight: FontWeight.w600,
                          fontSize: 12.5,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      const AppIcon(
                        Iconsax.user5,
                        color: AppColors.primaryOrange,
                        size: 13,
                      ),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          'Paid by: ${expense.paidByName}',
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.carla,
                            fontSize: 12.5,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 6),
            const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.secondaryDark,
              size: 24,
            ),
          ],
        ),
      ),
    );
  }
}
