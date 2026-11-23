import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../../components/atoms/app_icon.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import '../../models/expense_models.dart';
import '../../widgets/expense_widgets.dart';
import 'expense_form_screen.dart';

/// View Expense Details screen matching Figma "10.08 · Expense — member-level settlements.png".
/// Shows total expense summary, received vs still to receive, settlement progress bar,
/// per-member settlement rows with "Mark as Settled" dialog, and Edit Expense button.
class ExpenseDetailsScreen extends StatefulWidget {
  final String expenseId;

  const ExpenseDetailsScreen({
    super.key,
    required this.expenseId,
  });

  @override
  State<ExpenseDetailsScreen> createState() => _ExpenseDetailsScreenState();
}

class _ExpenseDetailsScreenState extends State<ExpenseDetailsScreen> {
  final ExpensesStore _store = ExpensesStore.instance;

  @override
  void initState() {
    super.initState();
    _store.addListener(_onStoreChanged);
  }

  @override
  void dispose() {
    _store.removeListener(_onStoreChanged);
    super.dispose();
  }

  void _onStoreChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _handleMarkAsSettled(
    TripExpense expense,
    MemberSplit split,
    TripMember member,
  ) async {
    final confirmed = await showMarkAsSettledDialog(
      context,
      memberName: member.firstName,
      amountLabel: formatPeso(split.amount),
      expenseTitle: expense.title,
    );
    if (!confirmed || !mounted) return;

    _store.markMemberSettled(expense.id, split.memberId, settled: true);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${member.firstName} marked as settled.'),
      ),
    );
  }

  void _openEditExpense(TripExpense expense) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ExpenseFormScreen(
          dayIndex: expense.dayIndex,
          category: expense.category,
          existingExpense: expense,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final expense = _store.findById(widget.expenseId);
    if (expense == null) {
      return const Scaffold(
        backgroundColor: AppColors.white,
        appBar: ExpenseTopBar(title: 'View Expense Details'),
        body: Center(child: Text('Expense not found.')),
        bottomNavigationBar: ExpensesBottomNav(),
      );
    }

    final payer = _store.findMember(expense.paidByMemberId);

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: ExpenseTopBar(
        title: 'View Expense Details',
        actions: [
          GestureDetector(
            key: const Key('edit_expense_button'),
            onTap: () => _openEditExpense(expense),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              decoration: BoxDecoration(
                color: AppColors.semanticYellow,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.secondaryDark, width: 2),
                boxShadow: const [
                  BoxShadow(
                    color: AppColors.secondaryDark,
                    offset: Offset(0, 3),
                    blurRadius: 0,
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.edit_rounded,
                    color: AppColors.secondaryDark,
                    size: 16,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    'Edit',
                    style: AppTypography.buttonMedium.copyWith(
                      color: AppColors.secondaryDark,
                      fontWeight: FontWeight.w800,
                      fontSize: 13.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Orange summary card
              _buildSummaryCard(expense, payer),
              const SizedBox(height: 22),

              // Member settlements header
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Member settlements',
                      style: AppTypography.h4.copyWith(
                        color: AppColors.secondaryDark,
                        fontWeight: FontWeight.w800,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  Text(
                    '${expense.settledOtherCount} of ${expense.totalOtherCount} settled',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.carla,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Member settlements card
              _buildMemberSettlementsCard(expense),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const ExpensesBottomNav(),
    );
  }

  Widget _buildSummaryCard(TripExpense expense, TripMember payer) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
      decoration: BoxDecoration(
        color: AppColors.primaryOrange,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.secondaryDark, width: 2),
        boxShadow: const [
          BoxShadow(
            color: AppColors.secondaryDark,
            offset: Offset(0, 4),
            blurRadius: 0,
          ),
        ],
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
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 2),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        formatPeso(expense.amount),
                        style: AppTypography.h1.copyWith(
                          color: AppColors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 36,
                          height: 1.1,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Paid by: ${payer.paidByLabel}',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.white.withValues(alpha: 0.92),
                        fontSize: 12.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              _DashedCircleIconBadge(icon: Iconsax.wallet_25),
            ],
          ),
          const SizedBox(height: 14),

          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: Container(
              height: 18,
              width: double.infinity,
              color: AppColors.white.withValues(alpha: 0.92),
              alignment: Alignment.centerLeft,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 280),
                    curve: Curves.easeOutCubic,
                    width: constraints.maxWidth * expense.settlementProgress,
                    height: 18,
                    decoration: BoxDecoration(
                      color: AppColors.secondaryDark,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Received & Still to Receive
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
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 2),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          formatPeso(expense.receivedAmount),
                          style: AppTypography.h3.copyWith(
                            color: AppColors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 21,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 1.2,
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
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 2),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          formatPeso(expense.stillToReceiveAmount),
                          style: AppTypography.h3.copyWith(
                            color: AppColors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 21,
                          ),
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
    );
  }

  Widget _buildMemberSettlementsCard(TripExpense expense) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.secondaryDark, width: 2),
        boxShadow: const [
          BoxShadow(
            color: AppColors.secondaryDark,
            offset: Offset(0, 4),
            blurRadius: 0,
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: List.generate(expense.splits.length, (index) {
          final split = expense.splits[index];
          final member = _store.findMember(split.memberId);
          final isPayer = split.memberId == expense.paidByMemberId;
          final isLast = index == expense.splits.length - 1;

          final String statusText;
          if (isPayer) {
            statusText = 'Paid at purchase';
          } else if (split.isSettled) {
            statusText = 'Payment received';
          } else {
            statusText = 'Awaiting payment';
          }

          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              border: isLast
                  ? null
                  : const Border(
                      bottom: BorderSide(
                        color: AppColors.borderLight,
                        width: 1,
                      ),
                    ),
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    color: AppColors.semanticYellow,
                    shape: BoxShape.circle,
                  ),
                  child: const AppIcon(
                    Iconsax.user5,
                    color: AppColors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        member.listLabel,
                        style: AppTypography.titleMedium.copyWith(
                          color: AppColors.secondaryDark,
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        statusText,
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.shayne,
                          fontSize: 12.5,
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
                      formatPeso(split.amount),
                      style: AppTypography.titleLarge.copyWith(
                        color: AppColors.secondaryDark,
                        fontWeight: FontWeight.w800,
                        fontSize: 15.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    if (isPayer || split.isSettled)
                      Container(
                        width: 126,
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: AppColors.primaryOrange,
                            width: 1.8,
                          ),
                        ),
                        child: Text(
                          'Settled',
                          style: AppTypography.buttonMedium.copyWith(
                            color: AppColors.primaryOrange,
                            fontWeight: FontWeight.w700,
                            fontSize: 12.5,
                          ),
                        ),
                      )
                    else
                      GestureDetector(
                        key: Key('mark_settled_${member.id}'),
                        onTap: () => _handleMarkAsSettled(
                          expense,
                          split,
                          member,
                        ),
                        child: Container(
                          width: 126,
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: AppColors.secondaryDark,
                              width: 1.8,
                            ),
                          ),
                          child: Text(
                            'Mark as Settled',
                            style: AppTypography.buttonMedium.copyWith(
                              color: AppColors.secondaryDark,
                              fontWeight: FontWeight.w700,
                              fontSize: 12.5,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}

class _DashedCircleIconBadge extends StatelessWidget {
  final IconData icon;

  const _DashedCircleIconBadge({required this.icon});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DashedCirclePainter(
        color: AppColors.white.withValues(alpha: 0.85),
        strokeWidth: 1.8,
      ),
      child: SizedBox(
        width: 64,
        height: 64,
        child: Center(
          child: AppIcon(icon, color: AppColors.white, size: 30),
        ),
      ),
    );
  }
}

class _DashedCirclePainter extends CustomPainter {
  final Color color;
  final double strokeWidth;

  const _DashedCirclePainter({
    required this.color,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final radius = (math.min(size.width, size.height) - strokeWidth) / 2;
    final rect = Rect.fromCircle(
      center: Offset(size.width / 2, size.height / 2),
      radius: radius,
    );

    const dashCount = 18;
    const sweep = (2 * math.pi) / dashCount;
    for (int i = 0; i < dashCount; i++) {
      canvas.drawArc(rect, i * sweep, sweep * 0.55, false, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _DashedCirclePainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.strokeWidth != strokeWidth;
}
