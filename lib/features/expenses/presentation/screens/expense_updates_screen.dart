import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../components/atoms/app_button.dart';

class ExpenseUpdatesScreen extends StatefulWidget {
  const ExpenseUpdatesScreen({super.key});

  @override
  State<ExpenseUpdatesScreen> createState() => _ExpenseUpdatesScreenState();
}

class _ExpenseUpdatesScreenState extends State<ExpenseUpdatesScreen> {
  bool _isSettled = false;

  void _handleSettleUp() {
    setState(() {
      _isSettled = true;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Payment of ₱420 sent to Louie via GCash!'),
        backgroundColor: AppColors.semanticGreen,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_left, color: AppColors.chucky, size: 24),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Expense Updates',
          style: AppTypography.titleLarge.copyWith(color: AppColors.chucky),
        ),
        actions: [
          IconButton(
            icon: const Icon(Iconsax.receipt_add, color: AppColors.chucky),
            onPressed: () {},
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Balance Alert Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: _isSettled ? AppColors.semanticGreenLight : AppColors.primaryOrangeLight,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: _isSettled ? AppColors.semanticGreen : AppColors.chucky,
                    width: 2.0,
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: AppColors.chucky,
                      offset: Offset(0, 4),
                      blurRadius: 0,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: _isSettled ? AppColors.semanticGreen : AppColors.primaryOrange,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: AppColors.chucky, width: 2),
                          ),
                          child: Icon(
                            _isSettled ? Iconsax.tick_circle : Iconsax.moneys,
                            color: AppColors.white,
                            size: 26,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _isSettled ? 'All Settled!' : 'Unpaid Balance',
                                style: AppTypography.caption.copyWith(
                                  color: AppColors.chucky,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                _isSettled ? '₱0.00' : '₱420.00',
                                style: AppTypography.h2.copyWith(
                                  color: AppColors.chucky,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Text(
                      _isSettled
                          ? 'You are all caught up for Bantayan Trip expenses.'
                          : 'You owe ₱420 to Louie Abella for Bantayan Ferry & Environmental Fee.',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.chucky,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (!_isSettled) ...[
                      const SizedBox(height: 16),
                      AppButton(
                        text: 'Settle Up Now (₱420.00)',
                        variant: AppButtonVariant.primaryOrange,
                        size: AppButtonSize.medium,
                        iconLeading: const Icon(Iconsax.wallet_3, color: AppColors.white, size: 20),
                        onPressed: _handleSettleUp,
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Breakdown Header
              Text(
                'Bantayan Trip Shared Expenses',
                style: AppTypography.titleLarge.copyWith(color: AppColors.chucky),
              ),
              const SizedBox(height: 12),

              _buildExpenseRow(
                title: 'Island Hopping Boat Rental',
                paidBy: 'Paid by Louie Abella',
                total: '₱3,600.00',
                yourShare: '₱600.00',
                status: 'Settled',
                statusColor: AppColors.semanticGreen,
              ),
              const SizedBox(height: 10),
              _buildExpenseRow(
                title: 'Ferry Tickets & Port Fees',
                paidBy: 'Paid by Louie Abella',
                total: '₱2,520.00',
                yourShare: '₱420.00',
                status: _isSettled ? 'Settled' : 'Unpaid',
                statusColor: _isSettled ? AppColors.semanticGreen : AppColors.primaryOrange,
              ),
              const SizedBox(height: 10),
              _buildExpenseRow(
                title: 'Kota Beach Resort Cottage',
                paidBy: 'Paid by Sarah Jenkins',
                total: '₱4,200.00',
                yourShare: '₱700.00',
                status: 'Settled',
                statusColor: AppColors.semanticGreen,
              ),
              const SizedBox(height: 10),
              _buildExpenseRow(
                title: 'MJ Square Seafood Feast',
                paidBy: 'Paid by You (blackxswann)',
                total: '₱3,000.00',
                yourShare: '+₱2,500.00 collected',
                status: 'Received',
                statusColor: AppColors.primaryNavy,
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExpenseRow({
    required String title,
    required String paidBy,
    required String total,
    required String yourShare,
    required String status,
    required Color statusColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.chucky, width: 2.0),
        boxShadow: const [
          BoxShadow(
            color: AppColors.chucky,
            offset: Offset(0, 3),
            blurRadius: 0,
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.titleMedium.copyWith(color: AppColors.chucky),
                ),
                const SizedBox(height: 2),
                Text(
                  '$paidBy • Total: $total',
                  style: AppTypography.caption.copyWith(color: AppColors.shayne),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                yourShare,
                style: AppTypography.titleMedium.copyWith(
                  color: AppColors.chucky,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  status,
                  style: AppTypography.caption.copyWith(
                    color: statusColor,
                    fontWeight: FontWeight.w700,
                    fontSize: 10,
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
