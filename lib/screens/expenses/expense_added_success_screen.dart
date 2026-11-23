import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../../components/atoms/app_button.dart';
import '../../components/atoms/app_icon.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import '../../widgets/expense_widgets.dart';
import 'add_expense_category_screen.dart';

/// Success confirmation screen shown after adding an expense.
/// Matches Figma "10.07 · Add expense — success.png".
class ExpenseAddedSuccessScreen extends StatelessWidget {
  final String expenseTitle;
  final int dayIndex;

  const ExpenseAddedSuccessScreen({
    super.key,
    required this.expenseTitle,
    required this.dayIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const Spacer(flex: 3),
              Container(
                width: 170,
                height: 170,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: AppColors.primaryOrange,
                  shape: BoxShape.circle,
                ),
                child: SizedBox(
                  width: 96,
                  height: 96,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      const AppIcon(
                        Iconsax.wallet_25,
                        color: AppColors.white,
                        size: 84,
                      ),
                      Positioned(
                        left: 0,
                        bottom: 4,
                        child: Container(
                          width: 34,
                          height: 34,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.primaryOrange,
                              width: 3,
                            ),
                          ),
                          child: const Icon(
                            Icons.add_rounded,
                            color: AppColors.primaryOrange,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 26),
              Text(
                'Expense Added!',
                style: AppTypography.h2.copyWith(
                  color: AppColors.secondaryDark,
                  fontWeight: FontWeight.w800,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                '$expenseTitle has been added to your trip expenses.',
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.carla,
                  height: 1.45,
                ),
                textAlign: TextAlign.center,
              ),
              const Spacer(flex: 2),
              AppButton(
                text: 'Add More',
                variant: AppButtonVariant.primaryNavy,
                borderRadius: 16,
                onPressed: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (_) =>
                          AddExpenseCategoryScreen(dayIndex: dayIndex),
                    ),
                  );
                },
              ),
              const SizedBox(height: 14),
              AppButton(
                text: 'View Expenses',
                variant: AppButtonVariant.secondary,
                borderRadius: 16,
                onPressed: () {
                  // Pop back to ViewExpensesScreen
                  Navigator.of(context).popUntil((route) {
                    return route.isFirst ||
                        route.settings.name == '/expenses';
                  });
                },
              ),
              const Spacer(flex: 2),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const ExpensesBottomNav(),
    );
  }
}
