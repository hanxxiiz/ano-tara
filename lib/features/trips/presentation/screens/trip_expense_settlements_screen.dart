import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../components/atoms/app_avatar.dart';
import '../../../../components/atoms/app_icon.dart';
import '../../../../components/organisms/app_bottom_navigation.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../domain/trip_view_models.dart';
import '../widgets/trip_card_widgets.dart';

/// Read-only "View Expense Details" & Member Settlements screen matching
/// Figma 11.06 (Completed) & 11.15 (Cancelled).
/// Enforces read-only trip policy: expense details cannot be edited for
/// Completed or Cancelled trips, while outstanding balances can be reviewed
/// and settled as noted in Figma 11.10.
class TripExpenseSettlementsScreen extends StatefulWidget {
  final TripExpenseItem expense;
  final TripStatus tripStatus;

  const TripExpenseSettlementsScreen({
    super.key,
    required this.expense,
    required this.tripStatus,
  });

  @override
  State<TripExpenseSettlementsScreen> createState() =>
      _TripExpenseSettlementsScreenState();
}

class _TripExpenseSettlementsScreenState
    extends State<TripExpenseSettlementsScreen> {
  late List<TripExpenseSettlement> _settlements;

  @override
  void initState() {
    super.initState();
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
      (widget.expense.totalAmount - _receivedAmount)
          .clamp(0.0, widget.expense.totalAmount);

  double get _progress => widget.expense.totalAmount <= 0
      ? 0.0
      : (_receivedAmount / widget.expense.totalAmount).clamp(0.0, 1.0);

  void _toggleSettlement(int index) {
    final target = _settlements[index];
    if (target.isPaidAtPurchase) return;
    setState(() {
      _settlements[index] = target.copyWith(isSettled: !target.isSettled);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      // No Edit button on Completed or Cancelled trips (strictly non-editable).
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
                              '₱${widget.expense.totalAmount.toStringAsFixed(2)}',
                              style: AppTypography.h1.copyWith(
                                color: AppColors.white,
                                fontWeight: FontWeight.w800,
                                fontSize: 34,
                                height: 1.1,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              widget.expense.paidByLabel,
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
                      onActionTap: _settlements[i].isPaidAtPurchase
                          ? null
                          : () => _toggleSettlement(i),
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

class _MemberSettlementRow extends StatelessWidget {
  final TripExpenseSettlement settlement;
  final VoidCallback? onActionTap;

  const _MemberSettlementRow({
    required this.settlement,
    this.onActionTap,
  });

  @override
  Widget build(BuildContext context) {
    final isSettled = settlement.isSettled && !settlement.isPaidAtPurchase;
    final isPayer = settlement.isPaidAtPurchase;

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
              GestureDetector(
                onTap: onActionTap,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  constraints: const BoxConstraints(minWidth: 116),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: isPayer
                        ? AppColors.surfaceMuted
                        : AppColors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isSettled
                          ? AppColors.primaryOrange
                          : (isPayer
                              ? AppColors.ann
                              : AppColors.secondaryDark),
                      width: 1.6,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      isPayer
                          ? 'Paid'
                          : (isSettled ? 'Settled' : 'Mark as Settled'),
                      style: AppTypography.caption.copyWith(
                        color: isSettled
                            ? AppColors.primaryOrange
                            : (isPayer
                                ? AppColors.shayne
                                : AppColors.secondaryDark),
                        fontWeight: FontWeight.w800,
                        fontSize: 11.5,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
