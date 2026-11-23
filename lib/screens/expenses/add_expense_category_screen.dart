import 'package:flutter/material.dart';
import '../../components/atoms/app_button.dart';
import '../../components/atoms/app_icon.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import '../../models/expense_models.dart';
import '../../widgets/expense_widgets.dart';
import 'expense_form_screen.dart';

/// Step 1 of Add Expense flow: select expense category.
/// Matches Figma "10.04 · Add expense — select expense category.png".
class AddExpenseCategoryScreen extends StatefulWidget {
  final int dayIndex;

  const AddExpenseCategoryScreen({
    super.key,
    required this.dayIndex,
  });

  @override
  State<AddExpenseCategoryScreen> createState() =>
      _AddExpenseCategoryScreenState();
}

class _AddExpenseCategoryScreenState extends State<AddExpenseCategoryScreen> {
  ExpenseCategory _selectedCategory = ExpenseCategory.accommodation;

  void _continueToDetails() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ExpenseFormScreen(
          dayIndex: widget.dayIndex,
          category: _selectedCategory,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: const ExpenseTopBar(title: 'Add Expense'),
      body: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 26, 20, 20),
          child: Column(
            children: [
              Text(
                'Which category does this expense belong to?',
                style: AppTypography.h3.copyWith(
                  color: AppColors.secondaryDark,
                  fontWeight: FontWeight.w800,
                  fontSize: 20,
                  height: 1.25,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 28),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 3,
                mainAxisSpacing: 16,
                crossAxisSpacing: 14,
                childAspectRatio: 0.92,
                children: ExpenseCategory.values.map((category) {
                  final isSelected = _selectedCategory == category;
                  return _CategoryTile(
                    category: category,
                    isSelected: isSelected,
                    onTap: () => setState(() => _selectedCategory = category),
                  );
                }).toList(),
              ),
              const Spacer(),
              AppButton(
                text: 'Continue',
                variant: AppButtonVariant.primaryNavy,
                borderRadius: 16,
                iconTrailing: const Icon(
                  Icons.arrow_forward_rounded,
                  color: AppColors.white,
                  size: 20,
                ),
                onPressed: _continueToDetails,
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const ExpensesBottomNav(),
    );
  }
}

class _CategoryTile extends StatelessWidget {
  final ExpenseCategory category;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryTile({
    required this.category,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bg = isSelected ? AppColors.primaryOrange : AppColors.white;
    final fg = isSelected ? AppColors.white : AppColors.secondaryDark;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 12),
        decoration: BoxDecoration(
          color: bg,
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
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AppIcon(category.icon, color: fg, size: 38),
            const SizedBox(height: 10),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                category.label,
                style: AppTypography.caption.copyWith(
                  color: fg,
                  fontWeight: FontWeight.w700,
                  fontSize: 12.5,
                ),
                maxLines: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
