import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../../components/atoms/app_button.dart';
import '../../components/atoms/app_icon.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import '../../models/expense_models.dart';
import '../../widgets/expense_widgets.dart';
import 'add_expense_category_screen.dart';
import 'expense_details_screen.dart';

/// View Expenses screen matching Figma:
/// - 10.01 · Expenses — empty day
/// - 10.02 · Expenses — entries by day
/// - 10.03 · Expenses — select for bulk delete
/// - 10.11 & 10.12 · Delete confirmation dialogs
class ViewExpensesScreen extends StatefulWidget {
  final int initialDayIndex;

  const ViewExpensesScreen({
    super.key,
    this.initialDayIndex = 0,
  });

  @override
  State<ViewExpensesScreen> createState() => _ViewExpensesScreenState();
}

class _ViewExpensesScreenState extends State<ViewExpensesScreen> {
  final ExpensesStore _store = ExpensesStore.instance;

  late int _dayIndex;
  bool _isSelectMode = false;
  final Set<String> _selectedIds = {};
  ExpenseCategory? _categoryFilter;

  @override
  void initState() {
    super.initState();
    _dayIndex = widget.initialDayIndex.clamp(0, _store.days.length - 1);
    _store.addListener(_onStoreChanged);
  }

  @override
  void dispose() {
    _store.removeListener(_onStoreChanged);
    super.dispose();
  }

  void _onStoreChanged() {
    if (!mounted) return;
    // Prune any selected IDs that no longer exist
    final currentIds =
        _store.expensesForDay(_dayIndex).map((e) => e.id).toSet();
    _selectedIds.removeWhere((id) => !currentIds.contains(id));
    setState(() {});
  }

  void _goToDay(int newIndex) {
    if (_isSelectMode) return;
    final clamped = newIndex.clamp(0, _store.days.length - 1);
    if (clamped == _dayIndex) return;
    setState(() {
      _dayIndex = clamped;
      _selectedIds.clear();
    });
  }

  void _enterSelectMode() {
    setState(() {
      _isSelectMode = true;
      _selectedIds.clear();
    });
  }

  void _exitSelectMode() {
    setState(() {
      _isSelectMode = false;
      _selectedIds.clear();
    });
  }

  void _toggleSelectExpense(TripExpense expense) {
    if (expense.isLocked) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('This expense is locked and cannot be deleted.'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }
    setState(() {
      if (_selectedIds.contains(expense.id)) {
        _selectedIds.remove(expense.id);
      } else {
        _selectedIds.add(expense.id);
      }
    });
  }

  void _toggleSelectAll(List<TripExpense> visibleExpenses) {
    final selectableIds =
        visibleExpenses.where((e) => !e.isLocked).map((e) => e.id).toSet();
    if (selectableIds.isEmpty) return;
    setState(() {
      if (_selectedIds.length == selectableIds.length) {
        _selectedIds.clear();
      } else {
        _selectedIds
          ..clear()
          ..addAll(selectableIds);
      }
    });
  }

  Future<void> _confirmAndDelete(List<TripExpense> visibleExpenses) async {
    if (_selectedIds.isEmpty) return;

    String? singleName;
    if (_selectedIds.length == 1) {
      final targetId = _selectedIds.first;
      for (final e in visibleExpenses) {
        if (e.id == targetId) {
          singleName = e.title;
          break;
        }
      }
    }

    final confirmed = await showDeleteExpenseSheet(
      context,
      count: _selectedIds.length,
      singleExpenseName: singleName,
    );
    if (!confirmed || !mounted) return;

    final deletedCount = _selectedIds.length;
    _store.deleteExpenses(Set<String>.from(_selectedIds));
    setState(() {
      _selectedIds.clear();
      _isSelectMode = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          deletedCount == 1
              ? 'Expense deleted.'
              : '$deletedCount expenses deleted.',
        ),
      ),
    );
  }

  Future<void> _openFilterSheet() async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            border: Border(
              top: BorderSide(color: AppColors.secondaryDark, width: 2),
              left: BorderSide(color: AppColors.secondaryDark, width: 2),
              right: BorderSide(color: AppColors.secondaryDark, width: 2),
            ),
          ),
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Filter by Category',
                        style: AppTypography.h4.copyWith(
                          color: AppColors.secondaryDark,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    HardShadowSquareButton(
                      icon: Icons.close_rounded,
                      backgroundColor: AppColors.white,
                      size: 34,
                      iconSize: 18,
                      onTap: () => Navigator.of(sheetContext).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    _FilterOptionChip(
                      label: 'All',
                      selected: _categoryFilter == null,
                      onTap: () {
                        setState(() => _categoryFilter = null);
                        Navigator.of(sheetContext).pop();
                      },
                    ),
                    ...ExpenseCategory.values.map(
                      (cat) => _FilterOptionChip(
                        label: cat.label,
                        selected: _categoryFilter == cat,
                        onTap: () {
                          setState(() => _categoryFilter = cat);
                          Navigator.of(sheetContext).pop();
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _openAddExpense() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AddExpenseCategoryScreen(dayIndex: _dayIndex),
      ),
    );
  }

  void _openExpenseDetails(TripExpense expense) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ExpenseDetailsScreen(expenseId: expense.id),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final day = _store.days[_dayIndex];
    final allDayExpenses = _store.expensesForDay(_dayIndex);
    final visibleExpenses = _store.expensesForDay(
      _dayIndex,
      categoryFilter: _categoryFilter,
    );
    final selectableCount =
        visibleExpenses.where((e) => !e.isLocked).length;
    final allSelected =
        selectableCount > 0 && _selectedIds.length == selectableCount;

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: _isSelectMode
          ? ExpenseTopBar(
              title: '',
              leading: IconButton(
                icon: const Icon(
                  Icons.close_rounded,
                  color: AppColors.primaryOrange,
                  size: 24,
                ),
                onPressed: _exitSelectMode,
                splashRadius: 22,
              ),
              titleWidget: Text(
                '${_selectedIds.length} selected',
                style: AppTypography.h4.copyWith(
                  color: AppColors.primaryOrange,
                  fontWeight: FontWeight.w800,
                  fontSize: 19,
                ),
              ),
              actions: [
                GestureDetector(
                  onTap: () => _toggleSelectAll(visibleExpenses),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.secondaryLight,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.secondaryDark,
                        width: 1.8,
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color: AppColors.secondaryDark,
                          offset: Offset(0, 3),
                          blurRadius: 0,
                        ),
                      ],
                    ),
                    child: Text(
                      allSelected ? 'Deselect All' : 'Select All',
                      style: AppTypography.buttonMedium.copyWith(
                        color: AppColors.secondaryDark,
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              ],
            )
          : const ExpenseTopBar(title: 'View Expenses'),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            // Day navigator
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 8),
              child: _buildDayNavigator(day),
            ),

            // Main content area
            Expanded(
              child: allDayExpenses.isEmpty
                  ? _buildEmptyState()
                  : _buildPopulatedState(visibleExpenses),
            ),

            // Select mode bottom delete bar
            if (_isSelectMode)
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 8, 18, 14),
                child: AppButton(
                  text: 'Delete (${_selectedIds.length})',
                  variant: AppButtonVariant.primaryOrange,
                  isDisabled: _selectedIds.isEmpty,
                  borderRadius: 16,
                  iconLeading: const Icon(
                    Icons.delete_outline_rounded,
                    color: AppColors.white,
                    size: 20,
                  ),
                  onPressed: () => _confirmAndDelete(visibleExpenses),
                ),
              ),
          ],
        ),
      ),
      bottomNavigationBar: const ExpensesBottomNav(),
    );
  }

  Widget _buildDayNavigator(TripDay day) {
    final canGoPrev = _dayIndex > 0 && !_isSelectMode;
    final canGoNext = _dayIndex < _store.days.length - 1 && !_isSelectMode;

    return Column(
      children: [
        Row(
          children: [
            HardShadowSquareButton(
              icon: Icons.chevron_left_rounded,
              muted: !canGoPrev,
              onTap: () => _goToDay(_dayIndex - 1),
            ),
            Expanded(
              child: Opacity(
                opacity: _isSelectMode ? 0.55 : 1.0,
                child: Column(
                  children: [
                    Text(
                      'Day ${day.dayNumber} of ${_store.days.length}',
                      style: AppTypography.titleLarge.copyWith(
                        color: AppColors.secondaryDark,
                        fontWeight: FontWeight.w800,
                        fontSize: 17,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      day.dateLabel,
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.shayne,
                        fontSize: 12.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            HardShadowSquareButton(
              icon: Icons.chevron_right_rounded,
              muted: !canGoNext,
              onTap: () => _goToDay(_dayIndex + 1),
            ),
          ],
        ),
        const SizedBox(height: 14),
        // Progress pills
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(_store.days.length, (index) {
            final isActive = index == _dayIndex;
            return GestureDetector(
              onTap: () => _goToDay(index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: 52,
                height: 8.5,
                decoration: BoxDecoration(
                  color: isActive
                      ? (_isSelectMode
                          ? AppColors.shayne
                          : AppColors.secondaryDark)
                      : AppColors.secondaryLight,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: _isSelectMode
                        ? AppColors.shayne
                        : AppColors.secondaryDark,
                    width: 1.2,
                  ),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 168,
              height: 168,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                color: AppColors.primaryOrange,
                shape: BoxShape.circle,
              ),
              child: const AppIcon(
                Iconsax.wallet_25,
                color: AppColors.white,
                size: 86,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No expenses yet',
              style: AppTypography.h3.copyWith(
                color: AppColors.secondaryDark,
                fontWeight: FontWeight.w800,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 270),
              child: Text(
                'Keep track of your trip spending by adding your first expense.',
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.carla,
                  height: 1.45,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 26),
            AppButton(
              text: 'Add Expense',
              variant: AppButtonVariant.secondary,
              borderRadius: 16,
              iconLeading: const Icon(
                Icons.add_rounded,
                color: AppColors.secondaryDark,
                size: 20,
              ),
              onPressed: _openAddExpense,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPopulatedState(List<TripExpense> visibleExpenses) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 24),
      children: [
        // Header row: Expenses + Filter + Select
        Row(
          children: [
            Expanded(
              child: Text(
                'Expenses',
                style: AppTypography.h3.copyWith(
                  color: _isSelectMode
                      ? AppColors.shayne
                      : AppColors.secondaryDark,
                  fontWeight: FontWeight.w800,
                  fontSize: 21,
                ),
              ),
            ),
            _SmallToolbarChip(
              icon: Icons.tune_rounded,
              label: _categoryFilter == null ? 'Filter' : _categoryFilter!.label,
              muted: _isSelectMode,
              highlighted: _categoryFilter != null && !_isSelectMode,
              onTap: _isSelectMode ? null : _openFilterSheet,
            ),
            const SizedBox(width: 8),
            _SmallToolbarChip(
              icon: Icons.check_box_outlined,
              label: 'Select',
              muted: _isSelectMode,
              onTap: _isSelectMode ? null : _enterSelectMode,
            ),
          ],
        ),
        const SizedBox(height: 16),

        if (visibleExpenses.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 36),
            child: Column(
              children: [
                Text(
                  'No ${_categoryFilter?.label ?? ''} expenses on this day.',
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.shayne,
                  ),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () => setState(() => _categoryFilter = null),
                  child: const Text('Clear filter'),
                ),
              ],
            ),
          )
        else
          ...visibleExpenses.map(
            (expense) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _ExpenseCard(
                expense: expense,
                payerName: _store.findMember(expense.paidByMemberId).firstName,
                isSelectMode: _isSelectMode,
                isSelected: _selectedIds.contains(expense.id),
                onTap: () {
                  if (_isSelectMode) {
                    _toggleSelectExpense(expense);
                  } else {
                    _openExpenseDetails(expense);
                  }
                },
              ),
            ),
          ),

        if (!_isSelectMode) ...[
          const SizedBox(height: 4),
          DashedAddExpenseButton(onTap: _openAddExpense),
        ],
      ],
    );
  }
}

class _SmallToolbarChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final bool muted;
  final bool highlighted;

  const _SmallToolbarChip({
    required this.icon,
    required this.label,
    required this.onTap,
    this.muted = false,
    this.highlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    final fg = muted
        ? AppColors.shayne
        : (highlighted ? AppColors.white : AppColors.secondaryDark);
    final bg = highlighted
        ? AppColors.primaryNavy
        : AppColors.secondaryLight.withValues(alpha: 0.75);
    final border = muted ? AppColors.shayne : AppColors.secondaryDark;

    return GestureDetector(
      onTap: muted ? null : onTap,
      child: Opacity(
        opacity: muted ? 0.65 : 1.0,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: border, width: 1.3),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 15, color: fg),
              const SizedBox(width: 5),
              Text(
                label,
                style: AppTypography.caption.copyWith(
                  color: fg,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ExpenseCard extends StatelessWidget {
  final TripExpense expense;
  final String payerName;
  final bool isSelectMode;
  final bool isSelected;
  final VoidCallback onTap;

  const _ExpenseCard({
    required this.expense,
    required this.payerName,
    required this.isSelectMode,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool showLockedStyle = isSelectMode && expense.isLocked;
    final Color cardBg =
        showLockedStyle ? const Color(0xFFEAE8E5) : AppColors.white;
    final Color borderColor =
        showLockedStyle ? AppColors.shayne : AppColors.secondaryDark;
    final Color iconBoxBg = showLockedStyle
        ? const Color(0xFFD5A598)
        : AppColors.primaryOrange;
    final Color pillBg = showLockedStyle
        ? const Color(0xFFD4A79B)
        : const Color(0xFFF09D87);
    final Color detailIconColor =
        showLockedStyle ? AppColors.shayne : AppColors.primaryOrange;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: borderColor, width: 2),
          boxShadow: [
            BoxShadow(
              color: borderColor,
              offset: const Offset(0, 4),
              blurRadius: 0,
            ),
          ],
        ),
        child: Row(
          children: [
            // Left orange rounded square icon
            Container(
              width: 76,
              height: 76,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: iconBoxBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: AppIcon(
                expense.category.icon,
                color: showLockedStyle
                    ? AppColors.white.withValues(alpha: 0.85)
                    : AppColors.white,
                size: 34,
              ),
            ),
            const SizedBox(width: 14),
            // Middle details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: pillBg,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      expense.category.label,
                      style: AppTypography.caption.copyWith(
                        color: AppColors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 11,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    expense.title,
                    style: AppTypography.titleLarge.copyWith(
                      color: showLockedStyle
                          ? AppColors.carla
                          : AppColors.secondaryDark,
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      AppIcon(
                        Iconsax.wallet_25,
                        size: 14,
                        color: detailIconColor,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        formatPeso(expense.amount),
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.carla,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      AppIcon(
                        Iconsax.user5,
                        size: 14,
                        color: detailIconColor,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'Paid by: $payerName',
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.carla,
                            fontSize: 13,
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
            const SizedBox(width: 8),
            // Trailing indicator
            _buildTrailing(showLockedStyle),
          ],
        ),
      ),
    );
  }

  Widget _buildTrailing(bool showLockedStyle) {
    if (!isSelectMode) {
      return const Icon(
        Icons.chevron_right_rounded,
        color: AppColors.secondaryDark,
        size: 24,
      );
    }
    if (showLockedStyle) {
      return const Icon(
        Icons.lock_rounded,
        color: AppColors.carla,
        size: 22,
      );
    }
    if (isSelected) {
      return Container(
        width: 24,
        height: 24,
        alignment: Alignment.center,
        decoration: const BoxDecoration(
          color: AppColors.primaryOrange,
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.close_rounded,
          color: AppColors.white,
          size: 16,
        ),
      );
    }
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: AppColors.white,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.secondaryDark, width: 1.8),
      ),
    );
  }
}

class _FilterOptionChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterOptionChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.primaryOrange : AppColors.secondaryLight,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.secondaryDark, width: 1.6),
          boxShadow: const [
            BoxShadow(
              color: AppColors.secondaryDark,
              offset: Offset(0, 2.5),
              blurRadius: 0,
            ),
          ],
        ),
        child: Text(
          label,
          style: AppTypography.buttonMedium.copyWith(
            color: selected ? AppColors.white : AppColors.secondaryDark,
            fontWeight: FontWeight.w700,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}
