import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../components/atoms/app_avatar.dart';
import '../../../../components/atoms/app_button.dart';
import '../../../../components/atoms/app_icon.dart';
import '../../../../components/organisms/app_bottom_navigation.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../domain/trip_view_models.dart';
import '../widgets/trip_card_widgets.dart';
import 'trip_edit_expense_screen.dart';

/// "View Expense Details" & Member Settlements screen matching
/// Figma 11.06 (Completed) & 11.15 (Cancelled).
class TripExpenseSettlementsScreen extends StatefulWidget {
  final TripExpenseItem expense;
  final TripStatus tripStatus;
  final int totalDays;
  final ValueChanged<TripExpenseItem>? onExpenseUpdated;
  final VoidCallback? onExpenseDeleted;

  const TripExpenseSettlementsScreen({
    super.key,
    required this.expense,
    required this.tripStatus,
    this.totalDays = 3,
    this.onExpenseUpdated,
    this.onExpenseDeleted,
  });

  @override
  State<TripExpenseSettlementsScreen> createState() =>
      _TripExpenseSettlementsScreenState();
}

class _TripExpenseSettlementsScreenState
    extends State<TripExpenseSettlementsScreen> {
  late TripExpenseItem _expense;
  late List<TripExpenseSettlement> _settlements;

  @override
  void initState() {
    super.initState();
    _expense = widget.expense;
    _settlements = List<TripExpenseSettlement>.from(widget.expense.settlements);
  }

  List<TripExpenseSettlement> get _nonPayerSettlements =>
      _settlements.where((s) => !s.isPaidAtPurchase).toList();

  int get _settledCount =>
      _nonPayerSettlements.where((s) => s.isSettled).length;

  int get _totalToSettleCount => _nonPayerSettlements.length;

  double get _receivedAmount => _settlements
      .where((s) => s.isSettled || s.isPaidAtPurchase)
      .fold<double>(0.0, (sum, s) => sum + s.amount);

  double get _stillToReceiveAmount =>
      (_expense.totalAmount - _receivedAmount).clamp(0.0, _expense.totalAmount);

  double get _progress => _expense.totalAmount <= 0
      ? 0.0
      : (_receivedAmount / _expense.totalAmount).clamp(0.0, 1.0);

  void _confirmSettlement(int index) {
    final target = _settlements[index];
    if (target.isSettled || target.isPaidAtPurchase) return;

    setState(() {
      _settlements[index] = target.copyWith(isSettled: true);
      _expense = _expense.copyWith(
        settlements: List<TripExpenseSettlement>.from(_settlements),
      );
    });
    widget.onExpenseUpdated?.call(_expense);
  }

  void _showMarkAsSettledModal(int index) {
    final target = _settlements[index];
    if (target.isSettled || target.isPaidAtPurchase) return;

    final remainingAfter =
        (_stillToReceiveAmount - target.amount).clamp(0.0, _expense.totalAmount);

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          decoration: const BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            border: Border(
              top: BorderSide(color: AppColors.secondaryDark, width: 2.0),
              left: BorderSide(color: AppColors.secondaryDark, width: 2.0),
              right: BorderSide(color: AppColors.secondaryDark, width: 2.0),
            ),
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Top Handle Bar
                Center(
                  child: Container(
                    width: 44,
                    height: 4.5,
                    decoration: BoxDecoration(
                      color: AppColors.secondaryDark,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
                // Top-Right Close Button ("X")
                Align(
                  alignment: Alignment.centerRight,
                  child: TripModalCloseButton(
                    onTap: () => Navigator.of(ctx).pop(),
                  ),
                ),

                // Blue Scalloped Verified Badge Icon
                const Center(
                  child: Icon(
                    Icons.verified_rounded,
                    color: AppColors.primaryNavy,
                    size: 58,
                  ),
                ),
                const SizedBox(height: 10),

                // Title
                Text(
                  'Mark as Settled',
                  textAlign: TextAlign.center,
                  style: AppTypography.h3.copyWith(
                    color: AppColors.secondaryDark,
                    fontWeight: FontWeight.w800,
                    fontSize: 23,
                  ),
                ),
                const SizedBox(height: 8),

                // Subtitle
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Text(
                    "Confirm that you've received ₱${target.amount.toStringAsFixed(2)} from ${target.memberName} for the ${_expense.title} expense.",
                    textAlign: TextAlign.center,
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.shayne,
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Summary Card (Member / Amount received / Expense)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceMuted,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    children: [
                      _SettlementSummaryRow(
                        label: 'Member',
                        value: target.memberName,
                      ),
                      const SizedBox(height: 10),
                      _SettlementSummaryRow(
                        label: 'Amount received',
                        value: '₱${target.amount.toStringAsFixed(2)}',
                      ),
                      const SizedBox(height: 10),
                      _SettlementSummaryRow(
                        label: 'Expense',
                        value: _expense.title,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // Remaining Amount Note
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    'After confirmation, your remaining amount to receive will be ₱${remainingAfter.toStringAsFixed(2)}.',
                    textAlign: TextAlign.center,
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.shayne,
                      fontSize: 12.5,
                      height: 1.4,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Primary Confirm Button
                AppButton(
                  key: const Key('confirm_settlement_button'),
                  text: 'Confirm Settlement',
                  variant: AppButtonVariant.primaryNavy,
                  borderRadius: 16,
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    _confirmSettlement(index);
                  },
                ),
                const SizedBox(height: 10),

                // Secondary Cancel Button
                AppButton(
                  key: const Key('cancel_settlement_button'),
                  text: 'Cancel',
                  variant: AppButtonVariant.secondary,
                  borderRadius: 16,
                  onPressed: () => Navigator.of(ctx).pop(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _openEditExpenseScreen() async {
    final result = await Navigator.of(context).push<TripEditExpenseResult>(
      MaterialPageRoute(
        builder: (_) => TripEditExpenseScreen(
          expense: _expense,
          totalDays: widget.totalDays,
        ),
      ),
    );

    if (!mounted || result == null) return;

    if (result.isDeleted) {
      widget.onExpenseDeleted?.call();
      Navigator.of(context).pop();
      return;
    }

    if (result.updatedExpense != null) {
      setState(() {
        _expense = result.updatedExpense!;
        _settlements = List<TripExpenseSettlement>.from(
          result.updatedExpense!.settlements,
        );
      });
      widget.onExpenseUpdated?.call(_expense);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: const TripSubTopBar(title: 'View Expense Details'),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 24),
          children: [
            // Orange Total Expense Summary Card
            Container(
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
              decoration: BoxDecoration(
                color: AppColors.primaryOrange,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: AppColors.secondaryDark,
                  width: 2.0,
                ),
                boxShadow: kTripHardShadow,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Total Expense',
                              style: AppTypography.bodyMedium.copyWith(
                                color: AppColors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 13.5,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '₱${_expense.totalAmount.toStringAsFixed(2)}',
                              style: AppTypography.h1.copyWith(
                                color: AppColors.white,
                                fontWeight: FontWeight.w800,
                                fontSize: 34,
                                height: 1.1,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              _expense.paidByLabel,
                              style: AppTypography.caption.copyWith(
                                color: AppColors.white.withValues(alpha: 0.92),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const DashedCircleIconBadge(
                        size: 62,
                        child: AppIcon(
                          Iconsax.wallet_25,
                          color: AppColors.white,
                          size: 28,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Settlement Progress Bar
                  Container(
                    height: 18,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppColors.white.withValues(alpha: 0.92),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: _progress.clamp(0.08, 1.0),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 240),
                        decoration: BoxDecoration(
                          color: AppColors.secondaryDark,
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Received vs Still to Receive
                  IntrinsicHeight(
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Received',
                                style: AppTypography.caption.copyWith(
                                  color: AppColors.white.withValues(alpha: 0.9),
                                  fontSize: 11.5,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '₱${_receivedAmount.toStringAsFixed(2)}',
                                style: AppTypography.h3.copyWith(
                                  color: AppColors.white,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 20,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: 1,
                          margin: const EdgeInsets.symmetric(horizontal: 14),
                          color: AppColors.white.withValues(alpha: 0.45),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Still to Receive',
                                style: AppTypography.caption.copyWith(
                                  color: AppColors.white.withValues(alpha: 0.9),
                                  fontSize: 11.5,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '₱${_stillToReceiveAmount.toStringAsFixed(2)}',
                                style: AppTypography.h3.copyWith(
                                  color: AppColors.white,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 20,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 22),

            // Header row: Member settlements | X of Y settled
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Member settlements',
                  style: AppTypography.h4.copyWith(
                    color: AppColors.secondaryDark,
                    fontWeight: FontWeight.w800,
                    fontSize: 17.5,
                  ),
                ),
                Text(
                  '$_settledCount of $_totalToSettleCount settled',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.carla,
                    fontWeight: FontWeight.w600,
                    fontSize: 12.5,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Member Settlements Card
            Container(
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: AppColors.secondaryDark,
                  width: 2.0,
                ),
                boxShadow: kTripHardShadow,
              ),
              child: Column(
                children: [
                  for (int i = 0; i < _settlements.length; i++) ...[
                    _MemberSettlementRow(
                      settlement: _settlements[i],
                      onActionTap: (_settlements[i].isSettled ||
                              _settlements[i].isPaidAtPurchase)
                          ? null
                          : () => _showMarkAsSettledModal(i),
                    ),
                    if (i < _settlements.length - 1)
                      const Divider(
                        height: 1,
                        thickness: 1,
                        color: AppColors.borderLight,
                      ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Edit Expense CTA Button
            AppButton(
              key: const Key('edit_expense_button'),
              text: 'Edit Expense',
              variant: AppButtonVariant.primaryNavy,
              borderRadius: 16,
              iconLeading: const Icon(
                Iconsax.edit_2,
                color: AppColors.white,
                size: 18,
              ),
              onPressed: _openEditExpenseScreen,
            ),
          ],
        ),
      ),
      bottomNavigationBar: AppBottomNavigation(
        currentIndex: 1,
        onTabSelected: (index) {
          if (index == 1) return;
          Navigator.of(context).popUntil((route) => route.isFirst);
        },
      ),
    );
  }
}

class _SettlementSummaryRow extends StatelessWidget {
  final String label;
  final String value;

  const _SettlementSummaryRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.shayne,
              fontSize: 13,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          value,
          style: AppTypography.titleMedium.copyWith(
            color: AppColors.secondaryDark,
            fontWeight: FontWeight.w800,
            fontSize: 13.5,
          ),
        ),
      ],
    );
  }
}

class _MemberSettlementRow extends StatelessWidget {
  final TripExpenseSettlement settlement;
  final VoidCallback? onActionTap;

  const _MemberSettlementRow({
    required this.settlement,
    this.onActionTap,
  });

  @override
  Widget build(BuildContext context) {
    // Only "Settled" and "Mark as Settled" statuses are displayed (no "Paid").
    final isSettled = settlement.isSettled || settlement.isPaidAtPurchase;

    final statusPill = AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      constraints: const BoxConstraints(minWidth: 116),
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isSettled ? AppColors.primaryOrange : AppColors.secondaryDark,
          width: 1.6,
        ),
      ),
      child: Center(
        child: Text(
          isSettled ? 'Settled' : 'Mark as Settled',
          style: AppTypography.caption.copyWith(
            color: isSettled ? AppColors.primaryOrange : AppColors.secondaryDark,
            fontWeight: FontWeight.w800,
            fontSize: 11.5,
          ),
        ),
      ),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      child: Row(
        children: [
          AppAvatar.singleUser(size: 42),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  settlement.displayName,
                  style: AppTypography.titleMedium.copyWith(
                    color: AppColors.secondaryDark,
                    fontWeight: FontWeight.w800,
                    fontSize: 14.5,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  settlement.subtitle,
                  style: AppTypography.caption.copyWith(
                    color: AppColors.shayne,
                    fontSize: 11.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '₱${settlement.amount.toStringAsFixed(2)}',
                style: AppTypography.titleMedium.copyWith(
                  color: AppColors.secondaryDark,
                  fontWeight: FontWeight.w800,
                  fontSize: 14.5,
                ),
              ),
              const SizedBox(height: 6),
              // Once Settled, it is no longer clickable.
              if (isSettled)
                statusPill
              else
                GestureDetector(
                  onTap: onActionTap,
                  child: statusPill,
                ),
            ],
          ),
        ],
      ),
    );
  }
}
