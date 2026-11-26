import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../components/atoms/app_avatar.dart';
import '../../../../components/atoms/app_button.dart';
import '../../../../components/atoms/app_checkbox.dart';
import '../../../../components/atoms/app_input_field.dart';
import '../../../../components/molecules/app_dropdown_field.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../domain/trip_view_models.dart';
import '../widgets/trip_card_widgets.dart';

/// Result returned from [TripEditExpenseScreen].
class TripEditExpenseResult {
  final TripExpenseItem? updatedExpense;
  final bool isDeleted;

  const TripEditExpenseResult._({
    this.updatedExpense,
    this.isDeleted = false,
  });

  factory TripEditExpenseResult.updated(TripExpenseItem expense) =>
      TripEditExpenseResult._(updatedExpense: expense);

  factory TripEditExpenseResult.deleted() =>
      const TripEditExpenseResult._(isDeleted: true);
}

/// Screen 1 of the Edit Expense flow: edit expense details (category, title,
/// total amount, day, payer) and launch [TripEditExpenseSplitScreen] to edit
/// member splits, or delete the expense.
class TripEditExpenseScreen extends StatefulWidget {
  final TripExpenseItem expense;
  final int totalDays;

  const TripEditExpenseScreen({
    super.key,
    required this.expense,
    this.totalDays = 3,
  });

  @override
  State<TripEditExpenseScreen> createState() => _TripEditExpenseScreenState();
}

class _TripEditExpenseScreenState extends State<TripEditExpenseScreen> {
  static const List<String> _defaultCategories = [
    'Food',
    'Transport',
    'Accommodation',
    'Activities',
    'Shopping',
    'Miscellaneous',
  ];

  late final TextEditingController _titleController;
  late final TextEditingController _amountController;
  late String _selectedCategory;
  late int _selectedDay;
  late String _selectedPayer;
  late List<TripExpenseSettlement> _settlements;
  late List<String> _categories;
  late List<String> _memberNames;
  bool _isCustomSplit = false;

  String? _titleError;
  String? _amountError;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.expense.title);
    _amountController = TextEditingController(
      text: widget.expense.totalAmount.toStringAsFixed(2),
    );
    _selectedCategory = widget.expense.category;
    _selectedDay = widget.expense.dayNumber.clamp(1, widget.totalDays);
    _selectedPayer = widget.expense.paidByName;
    _settlements = List<TripExpenseSettlement>.from(widget.expense.settlements);

    _categories = [
      ..._defaultCategories,
      if (!_defaultCategories.contains(widget.expense.category))
        widget.expense.category,
    ];

    _memberNames = _settlements.map((s) => s.memberName).toSet().toList();
    if (!_memberNames.contains(_selectedPayer)) {
      _memberNames.insert(0, _selectedPayer);
    }

    _isCustomSplit = _detectCustomSplit(_settlements);
  }

  bool _detectCustomSplit(List<TripExpenseSettlement> list) {
    if (list.length <= 1) return false;
    final first = list.first.amount;
    return list.any((s) => (s.amount - first).abs() > 0.02);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  double get _parsedAmount {
    final cleaned = _amountController.text.replaceAll(',', '').trim();
    return double.tryParse(cleaned) ?? widget.expense.totalAmount;
  }

  void _recalculateEqualSplit(double newTotal) {
    if (_settlements.isEmpty || newTotal <= 0) return;
    final share = double.parse((newTotal / _settlements.length).toStringAsFixed(2));
    double allocated = 0;
    final updated = <TripExpenseSettlement>[];
    for (int i = 0; i < _settlements.length; i++) {
      final isLast = i == _settlements.length - 1;
      final amount = isLast
          ? double.parse((newTotal - allocated).toStringAsFixed(2))
          : share;
      allocated += amount;
      updated.add(_settlements[i].copyWith(amount: amount));
    }
    _settlements = updated;
  }

  void _onPayerChanged(String? newPayer) {
    if (newPayer == null) return;
    setState(() {
      _selectedPayer = newPayer;
      _settlements = _settlements.map((s) {
        final isNewPayer = s.memberName == newPayer;
        return s.copyWith(
          isPaidAtPurchase: isNewPayer,
          isSettled: isNewPayer ? true : (s.isPaidAtPurchase ? false : s.isSettled),
        );
      }).toList();
    });
  }

  Future<void> _openEditSplitScreen() async {
    final total = _parsedAmount;
    if (total <= 0) {
      setState(() => _amountError = 'Enter a valid amount greater than 0');
      return;
    }

    final result = await Navigator.of(context).push<List<TripExpenseSettlement>>(
      MaterialPageRoute(
        builder: (_) => TripEditExpenseSplitScreen(
          expenseTitle: _titleController.text.trim().isEmpty
              ? widget.expense.title
              : _titleController.text.trim(),
          totalAmount: total,
          paidByName: _selectedPayer,
          initialSettlements: _settlements,
          initialIsCustom: _isCustomSplit,
        ),
      ),
    );

    if (result != null && mounted) {
      setState(() {
        _settlements = result;
        _isCustomSplit = _detectCustomSplit(result);
      });
    }
  }

  void _saveChanges() {
    final title = _titleController.text.trim();
    final amountText = _amountController.text.replaceAll(',', '').trim();
    final amount = double.tryParse(amountText);

    setState(() {
      _titleError = title.isEmpty ? 'Expense title is required' : null;
      _amountError = (amount == null || amount <= 0)
          ? 'Enter a valid amount greater than 0'
          : null;
    });

    if (_titleError != null || _amountError != null || amount == null) {
      return;
    }

    // Ensure settlements sum matches the updated total when in equal mode
    if (!_isCustomSplit) {
      _recalculateEqualSplit(amount);
    } else {
      final sum = _settlements.fold<double>(0.0, (acc, s) => acc + s.amount);
      if ((sum - amount).abs() > 0.05) {
        _recalculateEqualSplit(amount);
      }
    }

    final currentUserName = _settlements
        .where((s) => s.isCurrentUser)
        .map((s) => s.memberName)
        .firstOrNull;

    final updated = widget.expense.copyWith(
      dayNumber: _selectedDay,
      category: _selectedCategory,
      title: title,
      totalAmount: amount,
      paidByName: _selectedPayer,
      isPaidByYou:
          currentUserName != null && _selectedPayer == currentUserName,
      settlements: _settlements,
    );

    Navigator.of(context).pop(TripEditExpenseResult.updated(updated));
  }

  void _showDeleteExpenseModal() {
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
                Align(
                  alignment: Alignment.centerRight,
                  child: TripModalCloseButton(
                    onTap: () => Navigator.of(ctx).pop(),
                  ),
                ),
                const Center(
                  child: Icon(
                    Iconsax.trash,
                    color: AppColors.primaryOrange,
                    size: 46,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Delete Expense',
                  textAlign: TextAlign.center,
                  style: AppTypography.h3.copyWith(
                    color: AppColors.secondaryDark,
                    fontWeight: FontWeight.w800,
                    fontSize: 22,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Are you sure you want to delete "${widget.expense.title}"? All settlement records for this expense will be removed.',
                  textAlign: TextAlign.center,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.shayne,
                    fontSize: 13.5,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 22),
                AppButton(
                  text: 'Delete Expense',
                  variant: AppButtonVariant.destructive,
                  borderRadius: 16,
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    Navigator.of(context).pop(TripEditExpenseResult.deleted());
                  },
                ),
                const SizedBox(height: 10),
                AppButton(
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: const TripSubTopBar(title: 'Edit Expense'),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 28),
          children: [
            // Expense Category Dropdown
            AppDropdownField(
              label: 'Category',
              hintText: 'Choose expense type',
              selectedValue: _selectedCategory,
              items: _categories,
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedCategory = value);
                }
              },
            ),
            const SizedBox(height: 16),

            // Expense Title
            AppInputField(
              label: 'Expense Title',
              hint: 'e.g., Balut, Ferry Tickets',
              controller: _titleController,
              errorText: _titleError,
              onChanged: (_) {
                if (_titleError != null) {
                  setState(() => _titleError = null);
                }
              },
            ),
            const SizedBox(height: 16),

            // Total Amount
            AppInputField(
              label: 'Total Amount',
              hint: '0.00',
              controller: _amountController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              errorText: _amountError,
              prefixIcon: Center(
                widthFactor: 1.0,
                child: Text(
                  '₱',
                  style: AppTypography.titleLarge.copyWith(
                    color: AppColors.secondaryDark,
                    fontWeight: FontWeight.w800,
                    fontSize: 17,
                  ),
                ),
              ),
              onChanged: (val) {
                if (_amountError != null) {
                  setState(() => _amountError = null);
                }
                final parsed = double.tryParse(val.replaceAll(',', '').trim());
                if (parsed != null && parsed > 0 && !_isCustomSplit) {
                  setState(() => _recalculateEqualSplit(parsed));
                }
              },
            ),
            const SizedBox(height: 16),

            // Day Selector
            Text(
              'Trip Day',
              style: AppTypography.inputLabel.copyWith(
                color: AppColors.secondaryDark,
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: List.generate(widget.totalDays, (index) {
                final day = index + 1;
                final isSelected = day == _selectedDay;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedDay = day),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      margin: EdgeInsets.only(
                        right: index < widget.totalDays - 1 ? 10 : 0,
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 11),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primaryNavy
                            : AppColors.secondaryLight,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: AppColors.secondaryDark,
                          width: 1.8,
                        ),
                        boxShadow: isSelected ? kTripSmallHardShadow : null,
                      ),
                      child: Center(
                        child: Text(
                          'Day $day',
                          style: AppTypography.titleMedium.copyWith(
                            color: isSelected
                                ? AppColors.white
                                : AppColors.secondaryDark,
                            fontWeight: FontWeight.w800,
                            fontSize: 13.5,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 16),

            // Paid By Dropdown
            AppDropdownField(
              label: 'Paid By',
              hintText: 'Select who paid',
              selectedValue: _selectedPayer,
              items: _memberNames,
              onChanged: _onPayerChanged,
            ),
            const SizedBox(height: 20),

            // Split Between Summary Card + Edit Split Navigation
            Container(
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Split Between',
                              style: AppTypography.titleMedium.copyWith(
                                color: AppColors.secondaryDark,
                                fontWeight: FontWeight.w800,
                                fontSize: 15.5,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${_settlements.length} members • ${_isCustomSplit ? 'Custom split' : 'Equal split'}',
                              style: AppTypography.caption.copyWith(
                                color: AppColors.shayne,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        key: const Key('edit_split_button'),
                        onTap: _openEditSplitScreen,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.semanticYellow,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppColors.secondaryDark,
                              width: 1.6,
                            ),
                            boxShadow: kTripSmallHardShadow,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Iconsax.edit_2,
                                color: AppColors.secondaryDark,
                                size: 15,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Edit Split',
                                style: AppTypography.caption.copyWith(
                                  color: AppColors.secondaryDark,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Divider(
                    height: 1,
                    thickness: 1,
                    color: AppColors.borderLight,
                  ),
                  const SizedBox(height: 10),
                  ..._settlements.map(
                    (s) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      child: Row(
                        children: [
                          AppAvatar.singleUser(size: 32),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              s.displayName,
                              style: AppTypography.bodyMedium.copyWith(
                                color: AppColors.secondaryDark,
                                fontWeight: FontWeight.w700,
                                fontSize: 13.5,
                              ),
                            ),
                          ),
                          Text(
                            '₱${s.amount.toStringAsFixed(2)}',
                            style: AppTypography.titleMedium.copyWith(
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
            ),
            const SizedBox(height: 24),

            // Save Changes CTA
            AppButton(
              key: const Key('save_expense_changes_button'),
              text: 'Save Changes',
              variant: AppButtonVariant.primaryNavy,
              borderRadius: 16,
              onPressed: _saveChanges,
            ),
            const SizedBox(height: 12),

            // Delete Expense CTA
            AppButton(
              key: const Key('delete_expense_button'),
              text: 'Delete Expense',
              variant: AppButtonVariant.destructive,
              borderRadius: 16,
              iconLeading: const Icon(
                Iconsax.trash,
                color: AppColors.white,
                size: 18,
              ),
              onPressed: _showDeleteExpenseModal,
            ),
          ],
        ),
      ),
    );
  }
}

/// Screen 2 of the Edit Expense flow: customize which members are included in
/// the split and switch between Equal Split and Custom Split amounts.
class TripEditExpenseSplitScreen extends StatefulWidget {
  final String expenseTitle;
  final double totalAmount;
  final String paidByName;
  final List<TripExpenseSettlement> initialSettlements;
  final bool initialIsCustom;

  const TripEditExpenseSplitScreen({
    super.key,
    required this.expenseTitle,
    required this.totalAmount,
    required this.paidByName,
    required this.initialSettlements,
    this.initialIsCustom = false,
  });

  @override
  State<TripEditExpenseSplitScreen> createState() =>
      _TripEditExpenseSplitScreenState();
}

class _TripEditExpenseSplitScreenState
    extends State<TripEditExpenseSplitScreen> {
  late bool _isCustomSplit;
  late List<TripExpenseSettlement> _allMembers;
  late Map<String, bool> _includedMap;
  late Map<String, TextEditingController> _amountControllers;
  String? _validationError;

  @override
  void initState() {
    super.initState();
    _isCustomSplit = widget.initialIsCustom;
    _allMembers = List<TripExpenseSettlement>.from(widget.initialSettlements);
    _includedMap = {
      for (final s in _allMembers) s.id: true,
    };
    _amountControllers = {
      for (final s in _allMembers)
        s.id: TextEditingController(text: s.amount.toStringAsFixed(2)),
    };
  }

  @override
  void dispose() {
    for (final c in _amountControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  List<TripExpenseSettlement> get _includedMembers =>
      _allMembers.where((m) => _includedMap[m.id] == true).toList();

  double get _allocatedTotal {
    if (!_isCustomSplit) {
      return _includedMembers.isEmpty ? 0.0 : widget.totalAmount;
    }
    double sum = 0.0;
    for (final m in _includedMembers) {
      final parsed = double.tryParse(
            _amountControllers[m.id]?.text.replaceAll(',', '').trim() ?? '',
          ) ??
          0.0;
      sum += parsed;
    }
    return sum;
  }

  double get _remainingAmount => widget.totalAmount - _allocatedTotal;

  void _redistributeEqually() {
    final included = _includedMembers;
    if (included.isEmpty) return;
    final share =
        double.parse((widget.totalAmount / included.length).toStringAsFixed(2));
    double running = 0.0;
    for (int i = 0; i < included.length; i++) {
      final isLast = i == included.length - 1;
      final amt = isLast
          ? double.parse((widget.totalAmount - running).toStringAsFixed(2))
          : share;
      running += amt;
      _amountControllers[included[i].id]?.text = amt.toStringAsFixed(2);
    }
  }

  void _applySplit() {
    final included = _includedMembers;
    if (included.isEmpty) {
      setState(() => _validationError = 'Select at least one member.');
      return;
    }

    if (_isCustomSplit && _remainingAmount.abs() > 0.01) {
      setState(() {
        _validationError =
            'Custom split amounts must total ₱${widget.totalAmount.toStringAsFixed(2)}.';
      });
      return;
    }

    final result = <TripExpenseSettlement>[];
    if (!_isCustomSplit) {
      final share = double.parse(
        (widget.totalAmount / included.length).toStringAsFixed(2),
      );
      double running = 0.0;
      for (int i = 0; i < included.length; i++) {
        final isLast = i == included.length - 1;
        final amt = isLast
            ? double.parse((widget.totalAmount - running).toStringAsFixed(2))
            : share;
        running += amt;
        result.add(included[i].copyWith(amount: amt));
      }
    } else {
      for (final m in included) {
        final amt = double.tryParse(
              _amountControllers[m.id]?.text.replaceAll(',', '').trim() ?? '',
            ) ??
            0.0;
        result.add(m.copyWith(amount: amt));
      }
    }

    Navigator.of(context).pop(result);
  }

  @override
  Widget build(BuildContext context) {
    final isBalanced = _remainingAmount.abs() <= 0.01;
    final equalShare = _includedMembers.isEmpty
        ? 0.0
        : widget.totalAmount / _includedMembers.length;

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: const TripSubTopBar(title: 'Edit Split'),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 28),
          children: [
            // Summary Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primaryNavy,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: AppColors.secondaryDark,
                  width: 2.0,
                ),
                boxShadow: kTripHardShadow,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.expenseTitle,
                          style: AppTypography.caption.copyWith(
                            color: AppColors.white.withValues(alpha: 0.85),
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '₱${widget.totalAmount.toStringAsFixed(2)}',
                          style: AppTypography.h2.copyWith(
                            color: AppColors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 28,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: isBalanced
                          ? AppColors.semanticYellow
                          : AppColors.primaryOrange,
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                        color: AppColors.secondaryDark,
                        width: 1.5,
                      ),
                    ),
                    child: Text(
                      isBalanced
                          ? 'Balanced'
                          : 'Diff: ₱${_remainingAmount.abs().toStringAsFixed(2)}',
                      style: AppTypography.caption.copyWith(
                        color: isBalanced
                            ? AppColors.secondaryDark
                            : AppColors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 11.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // Equal vs Custom Split Mode Toggle
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _isCustomSplit = false;
                        _validationError = null;
                        _redistributeEqually();
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: !_isCustomSplit
                            ? AppColors.secondaryDark
                            : AppColors.secondaryLight,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: AppColors.secondaryDark,
                          width: 1.8,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          'Equal Split',
                          style: AppTypography.titleMedium.copyWith(
                            color: !_isCustomSplit
                                ? AppColors.white
                                : AppColors.secondaryDark,
                            fontWeight: FontWeight.w800,
                            fontSize: 13.5,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _isCustomSplit = true;
                        _validationError = null;
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: _isCustomSplit
                            ? AppColors.secondaryDark
                            : AppColors.secondaryLight,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: AppColors.secondaryDark,
                          width: 1.8,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          'Custom Split',
                          style: AppTypography.titleMedium.copyWith(
                            color: _isCustomSplit
                                ? AppColors.white
                                : AppColors.secondaryDark,
                            fontWeight: FontWeight.w800,
                            fontSize: 13.5,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),

            // Member Split Rows Card
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
                  for (int i = 0; i < _allMembers.length; i++) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      child: Row(
                        children: [
                          AppCheckbox(
                            size: AppCheckboxSize.mini,
                            value: _includedMap[_allMembers[i].id] == true,
                            onChanged: (checked) {
                              setState(() {
                                _includedMap[_allMembers[i].id] = checked;
                                _validationError = null;
                                if (!_isCustomSplit) {
                                  _redistributeEqually();
                                }
                              });
                            },
                          ),
                          const SizedBox(width: 6),
                          AppAvatar.singleUser(size: 36),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              _allMembers[i].displayName,
                              style: AppTypography.titleMedium.copyWith(
                                color: AppColors.secondaryDark,
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          if (_isCustomSplit)
                            SizedBox(
                              width: 104,
                              child: AppInputField(
                                controller:
                                    _amountControllers[_allMembers[i].id],
                                isEnabled:
                                    _includedMap[_allMembers[i].id] == true,
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                  decimal: true,
                                ),
                                onChanged: (_) {
                                  setState(() => _validationError = null);
                                },
                              ),
                            )
                          else
                            Text(
                              _includedMap[_allMembers[i].id] == true
                                  ? '₱${equalShare.toStringAsFixed(2)}'
                                  : '₱0.00',
                              style: AppTypography.titleMedium.copyWith(
                                color: _includedMap[_allMembers[i].id] == true
                                    ? AppColors.secondaryDark
                                    : AppColors.shayne,
                                fontWeight: FontWeight.w800,
                                fontSize: 14,
                              ),
                            ),
                        ],
                      ),
                    ),
                    if (i < _allMembers.length - 1)
                      const Divider(
                        height: 1,
                        thickness: 1,
                        color: AppColors.borderLight,
                      ),
                  ],
                ],
              ),
            ),

            if (_validationError != null) ...[
              const SizedBox(height: 12),
              Text(
                _validationError!,
                textAlign: TextAlign.center,
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.primaryOrange,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],

            const SizedBox(height: 24),
            AppButton(
              key: const Key('apply_split_button'),
              text: 'Apply Split',
              variant: AppButtonVariant.primaryNavy,
              borderRadius: 16,
              onPressed: _applySplit,
            ),
          ],
        ),
      ),
    );
  }
}
