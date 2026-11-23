import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iconsax/iconsax.dart';
import '../../components/atoms/app_button.dart';
import '../../components/atoms/app_checkbox.dart';
import '../../components/atoms/app_icon.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import '../../models/expense_models.dart';
import '../../widgets/expense_widgets.dart';
import 'expense_added_success_screen.dart';

/// Shared form for Add Expense Details (Figma 10.05 & 10.06) and Edit Expense
/// (Figma 10.09), supporting Split Equally, Custom Split with Assigned &
/// Remaining totals, and the Add Members bottom sheet.
class ExpenseFormScreen extends StatefulWidget {
  final int dayIndex;
  final ExpenseCategory category;
  final TripExpense? existingExpense;

  const ExpenseFormScreen({
    super.key,
    required this.dayIndex,
    required this.category,
    this.existingExpense,
  });

  bool get isEditing => existingExpense != null;

  @override
  State<ExpenseFormScreen> createState() => _ExpenseFormScreenState();
}

class _ExpenseFormScreenState extends State<ExpenseFormScreen> {
  final ExpensesStore _store = ExpensesStore.instance;

  late final TextEditingController _titleController;
  late final TextEditingController _amountController;
  late String _paidByMemberId;
  late SplitMethod _splitMethod;
  late List<String> _selectedMemberIds;

  final Map<String, TextEditingController> _customControllers = {};

  @override
  void initState() {
    super.initState();
    final existing = widget.existingExpense;
    if (existing != null) {
      _titleController = TextEditingController(text: existing.title);
      _amountController = TextEditingController(
        text: existing.amount.toStringAsFixed(2),
      );
      _paidByMemberId = existing.paidByMemberId;
      _splitMethod = existing.splitMethod;
      _selectedMemberIds = existing.splits.map((s) => s.memberId).toList();
      for (final split in existing.splits) {
        _customControllers[split.memberId] = TextEditingController(
          text: split.amount.toStringAsFixed(2),
        );
      }
    } else {
      _titleController = TextEditingController();
      _amountController = TextEditingController();
      _paidByMemberId = _store.currentUser.id;
      _splitMethod = SplitMethod.equal;
      // Default to first 5 trip members matching Figma
      _selectedMemberIds = _store.members.take(5).map((m) => m.id).toList();
      for (final id in _selectedMemberIds) {
        _customControllers[id] = TextEditingController();
      }
    }

    _titleController.addListener(_onFormChanged);
    _amountController.addListener(_onFormChanged);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    for (final c in _customControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  void _onFormChanged() {
    if (mounted) setState(() {});
  }

  double get _totalAmount {
    final cleaned = _amountController.text.replaceAll(',', '').trim();
    return double.tryParse(cleaned) ?? 0.0;
  }

  double _customAmountFor(String memberId) {
    final controller = _customControllers[memberId];
    if (controller == null) return 0.0;
    final cleaned = controller.text.replaceAll(',', '').trim();
    return double.tryParse(cleaned) ?? 0.0;
  }

  double get _assignedTotal {
    return _selectedMemberIds.fold(
      0.0,
      (sum, id) => sum + _customAmountFor(id),
    );
  }

  double get _remainingAmount => _totalAmount - _assignedTotal;

  bool get _isCustomRemainingZero => _remainingAmount.abs() < 0.005;

  bool get _canSave {
    if (_titleController.text.trim().isEmpty) return false;
    if (_totalAmount <= 0.0) return false;
    if (_selectedMemberIds.isEmpty) return false;
    if (_splitMethod == SplitMethod.custom && !_isCustomRemainingZero) {
      return false;
    }
    return true;
  }

  void _switchSplitMethod(SplitMethod method) {
    if (_splitMethod == method) return;
    setState(() {
      _splitMethod = method;
      if (method == SplitMethod.custom) {
        final hasAnyCustom = _selectedMemberIds.any(
          (id) => (_customControllers[id]?.text.trim().isNotEmpty ?? false),
        );
        if (!hasAnyCustom && _totalAmount > 0) {
          final equalMap = computeEqualSplit(_totalAmount, _selectedMemberIds);
          for (final id in _selectedMemberIds) {
            _ensureCustomController(id).text =
                (equalMap[id] ?? 0.0).toStringAsFixed(2);
          }
        }
      }
    });
  }

  TextEditingController _ensureCustomController(String memberId) {
    return _customControllers.putIfAbsent(
      memberId,
      () => TextEditingController(),
    );
  }

  Future<void> _openAddMembersSheet() async {
    final tempSelected = Set<String>.from(_selectedMemberIds);

    final confirmed = await showModalBottomSheet<Set<String>>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
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
                  children: [
                    Container(
                      width: 44,
                      height: 4.5,
                      decoration: BoxDecoration(
                        color: AppColors.secondaryDark,
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Add Members',
                            style: AppTypography.h3.copyWith(
                              color: AppColors.secondaryDark,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        HardShadowSquareButton(
                          icon: Icons.close_rounded,
                          backgroundColor: AppColors.white,
                          size: 36,
                          iconSize: 20,
                          onTap: () => Navigator.of(sheetContext).pop(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Select who is included in this expense split.',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.shayne,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxHeight: 320),
                      child: ListView.separated(
                        shrinkWrap: true,
                        itemCount: _store.members.length,
                        separatorBuilder: (_, _) => const Divider(
                          height: 1,
                          color: AppColors.borderLight,
                        ),
                        itemBuilder: (context, index) {
                          final member = _store.members[index];
                          final isChecked = tempSelected.contains(member.id);
                          return InkWell(
                            onTap: () {
                              setSheetState(() {
                                if (isChecked) {
                                  if (tempSelected.length > 1) {
                                    tempSelected.remove(member.id);
                                  }
                                } else {
                                  tempSelected.add(member.id);
                                }
                              });
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              child: Row(
                                children: [
                                  _MemberCircleAvatar(size: 40),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          member.listLabel,
                                          style: AppTypography.titleMedium
                                              .copyWith(
                                            color: AppColors.secondaryDark,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        Text(
                                          member.fullName,
                                          style: AppTypography.bodySmall,
                                        ),
                                      ],
                                    ),
                                  ),
                                  AppCheckbox(
                                    value: isChecked,
                                    onChanged: (val) {
                                      setSheetState(() {
                                        if (val) {
                                          tempSelected.add(member.id);
                                        } else if (tempSelected.length > 1) {
                                          tempSelected.remove(member.id);
                                        }
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 18),
                    AppButton(
                      text: 'Done (${tempSelected.length} selected)',
                      variant: AppButtonVariant.primaryNavy,
                      borderRadius: 16,
                      onPressed: () =>
                          Navigator.of(sheetContext).pop(tempSelected),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    if (confirmed == null || !mounted) return;
    setState(() {
      // Preserve member order from store
      _selectedMemberIds = _store.members
          .where((m) => confirmed.contains(m.id))
          .map((m) => m.id)
          .toList();
      for (final id in _selectedMemberIds) {
        _ensureCustomController(id);
      }
    });
  }

  void _handleSave() {
    if (!_canSave) return;

    final List<MemberSplit> splits;
    if (_splitMethod == SplitMethod.equal) {
      final equalMap = computeEqualSplit(_totalAmount, _selectedMemberIds);
      splits = _selectedMemberIds
          .map(
            (id) => MemberSplit(
              memberId: id,
              amount: equalMap[id] ?? 0.0,
              isSettled: id == _paidByMemberId,
            ),
          )
          .toList();
    } else {
      splits = _selectedMemberIds
          .map(
            (id) => MemberSplit(
              memberId: id,
              amount: _customAmountFor(id),
              isSettled: id == _paidByMemberId,
            ),
          )
          .toList();
    }

    if (widget.isEditing) {
      final updated = widget.existingExpense!.copyWith(
        title: _titleController.text.trim(),
        amount: _totalAmount,
        paidByMemberId: _paidByMemberId,
        splitMethod: _splitMethod,
        splits: splits,
      );
      _store.updateExpense(updated);
      Navigator.of(context).pop(true);
    } else {
      final created = _store.addExpense(
        dayIndex: widget.dayIndex,
        category: widget.category,
        title: _titleController.text.trim(),
        amount: _totalAmount,
        paidByMemberId: _paidByMemberId,
        splitMethod: _splitMethod,
        splits: splits,
      );
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => ExpenseAddedSuccessScreen(
            expenseTitle: created.title,
            dayIndex: widget.dayIndex,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final equalShares = computeEqualSplit(_totalAmount, _selectedMemberIds);

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: ExpenseTopBar(
        title: widget.isEditing ? 'Edit Expense' : 'Add Expense',
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Heading & subtitle
              Text(
                'Expense Details',
                style: AppTypography.h4.copyWith(
                  color: AppColors.secondaryDark,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                widget.isEditing
                    ? 'Update the expense details and adjust how the amount is split.'
                    : 'Enter the expense information and choose how you want to split it.',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.carla,
                  fontSize: 13,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 18),

              // Title input
              _buildFieldLabel('Title'),
              const SizedBox(height: 6),
              _buildTextField(
                key: const Key('expense_title_field'),
                controller: _titleController,
                hintText: 'e.g., Balut, Seafood Dinner',
              ),
              const SizedBox(height: 16),

              // Amount input
              _buildFieldLabel('Amount'),
              const SizedBox(height: 6),
              _buildTextField(
                key: const Key('expense_amount_field'),
                controller: _amountController,
                hintText: '0.00',
                prefixText: '₱',
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                ],
              ),
              const SizedBox(height: 16),

              // Paid by dropdown
              _buildFieldLabel('Paid by'),
              const SizedBox(height: 6),
              _buildPaidByDropdown(),
              const SizedBox(height: 20),

              // Split among
              _buildFieldLabel('Split among'),
              const SizedBox(height: 10),
              _buildSplitAmongRow(),
              const SizedBox(height: 20),

              // Split method
              _buildFieldLabel('Split method'),
              const SizedBox(height: 10),
              _buildSplitMethodToggle(),
              const SizedBox(height: 18),

              // Split breakdown card
              _buildSplitBreakdownCard(equalShares),

              // Assigned & Remaining totals (Custom Split only)
              if (_splitMethod == SplitMethod.custom) ...[
                const SizedBox(height: 18),
                _buildAssignedRemainingRow(),
                if (!_isCustomRemainingZero && _totalAmount > 0) ...[
                  const SizedBox(height: 8),
                  Text(
                    _remainingAmount > 0
                        ? 'Remaining must be ₱0.00 to save (${formatPeso(_remainingAmount)} unassigned).'
                        : 'Assigned exceeds total by ${formatPeso(_remainingAmount.abs())}. Remaining must be ₱0.00.',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.primaryOrange,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ],

              const SizedBox(height: 24),

              // Primary Save / Add button
              AppButton(
                key: const Key('expense_save_button'),
                text: widget.isEditing ? 'Save Changes' : 'Add Expense',
                variant: AppButtonVariant.primaryNavy,
                borderRadius: 16,
                isDisabled: !_canSave,
                onPressed: _handleSave,
              ),
              const SizedBox(height: 12),

              // Cancel button
              AppButton(
                text: 'Cancel',
                variant: AppButtonVariant.secondary,
                borderRadius: 16,
                onPressed: () => Navigator.of(context).maybePop(),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const ExpensesBottomNav(),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Text(
      label,
      style: AppTypography.inputLabel.copyWith(
        color: AppColors.secondaryDark,
        fontSize: 13.5,
        fontWeight: FontWeight.w700,
      ),
    );
  }

  Widget _buildTextField({
    Key? key,
    required TextEditingController controller,
    required String hintText,
    String? prefixText,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.secondaryLight,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.secondaryDark, width: 1.8),
      ),
      child: TextField(
        key: key,
        controller: controller,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        style: AppTypography.inputText.copyWith(
          color: AppColors.secondaryDark,
          fontSize: 15,
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: AppTypography.inputHint,
          prefixText: prefixText,
          prefixStyle: AppTypography.inputText.copyWith(
            color: AppColors.secondaryDark,
            fontSize: 15,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 15,
          ),
        ),
      ),
    );
  }

  Widget _buildPaidByDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.secondaryLight,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.secondaryDark, width: 1.8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _paidByMemberId,
          isExpanded: true,
          icon: const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: AppColors.secondaryDark,
            size: 24,
          ),
          dropdownColor: AppColors.white,
          style: AppTypography.inputText.copyWith(
            color: AppColors.secondaryDark,
            fontSize: 14.5,
          ),
          items: _store.members
              .map(
                (member) => DropdownMenuItem<String>(
                  value: member.id,
                  child: Text(member.dropdownLabel),
                ),
              )
              .toList(),
          onChanged: (value) {
            if (value == null) return;
            setState(() => _paidByMemberId = value);
          },
        ),
      ),
    );
  }

  Widget _buildSplitAmongRow() {
    final selectedMembers =
        _selectedMemberIds.map(_store.findMember).toList();

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          ...selectedMembers.map(
            (member) => Padding(
              padding: const EdgeInsets.only(right: 12),
              child: GestureDetector(
                onTap: _openAddMembersSheet,
                child: Column(
                  children: [
                    Container(
                      width: 54,
                      height: 54,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: AppColors.semanticYellow,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.secondaryDark,
                          width: 2,
                        ),
                      ),
                      child: const AppIcon(
                        Iconsax.user5,
                        color: AppColors.secondaryDark,
                        size: 26,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      member.shortLabel,
                      style: AppTypography.caption.copyWith(
                        color: AppColors.secondaryDark,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // "+ Add" orange circle
          GestureDetector(
            key: const Key('add_members_button'),
            onTap: _openAddMembersSheet,
            child: Column(
              children: [
                Container(
                  width: 54,
                  height: 54,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.primaryOrange,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.secondaryDark,
                      width: 2,
                    ),
                  ),
                  child: const Icon(
                    Icons.add_rounded,
                    color: AppColors.secondaryDark,
                    size: 28,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Add',
                  style: AppTypography.caption.copyWith(
                    color: AppColors.secondaryDark,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSplitMethodToggle() {
    final isEqual = _splitMethod == SplitMethod.equal;
    return Container(
      height: 46,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.secondaryDark, width: 2),
        boxShadow: const [
          BoxShadow(
            color: AppColors.secondaryDark,
            offset: Offset(0, 3),
            blurRadius: 0,
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              key: const Key('split_equally_tab'),
              onTap: () => _switchSplitMethod(SplitMethod.equal),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isEqual ? AppColors.primaryNavy : AppColors.white,
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Text(
                  'Split Equally',
                  style: AppTypography.buttonMedium.copyWith(
                    color: isEqual ? AppColors.white : AppColors.secondaryDark,
                    fontWeight: FontWeight.w700,
                    fontSize: 13.5,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              key: const Key('custom_split_tab'),
              onTap: () => _switchSplitMethod(SplitMethod.custom),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: !isEqual ? AppColors.primaryNavy : AppColors.white,
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Text(
                  'Custom Split',
                  style: AppTypography.buttonMedium.copyWith(
                    color: !isEqual ? AppColors.white : AppColors.secondaryDark,
                    fontWeight: FontWeight.w700,
                    fontSize: 13.5,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSplitBreakdownCard(Map<String, double> equalShares) {
    final selectedMembers =
        _selectedMemberIds.map(_store.findMember).toList();

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
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
        children: [
          // Top yellow header bar matching Figma 10.05, 10.06, 10.09
          Container(
            height: 44,
            width: double.infinity,
            decoration: const BoxDecoration(
              color: AppColors.semanticYellow,
              border: Border(
                bottom: BorderSide(color: AppColors.secondaryDark, width: 2),
              ),
            ),
          ),
          // Member rows
          ...List.generate(selectedMembers.length, (index) {
            final member = selectedMembers[index];
            final isLast = index == selectedMembers.length - 1;
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                  const _MemberCircleAvatar(size: 40),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      member.listLabel,
                      style: AppTypography.titleMedium.copyWith(
                        color: AppColors.secondaryDark,
                        fontWeight: FontWeight.w700,
                        fontSize: 14.5,
                      ),
                    ),
                  ),
                  if (_splitMethod == SplitMethod.equal)
                    Text(
                      formatPeso(equalShares[member.id] ?? 0.0),
                      style: AppTypography.titleMedium.copyWith(
                        color: AppColors.secondaryDark,
                        fontWeight: FontWeight.w800,
                        fontSize: 14.5,
                      ),
                    )
                  else
                    SizedBox(
                      width: 108,
                      height: 38,
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.secondaryLight,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: AppColors.secondaryDark,
                            width: 1.6,
                          ),
                        ),
                        child: TextField(
                          key: Key('custom_split_input_${member.id}'),
                          controller: _ensureCustomController(member.id),
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                              RegExp(r'^\d*\.?\d{0,2}'),
                            ),
                          ],
                          onChanged: (_) => setState(() {}),
                          textAlign: TextAlign.center,
                          style: AppTypography.inputText.copyWith(
                            color: AppColors.secondaryDark,
                            fontSize: 13.5,
                          ),
                          decoration: InputDecoration(
                            prefixText: '₱',
                            prefixStyle: AppTypography.inputText.copyWith(
                              color: AppColors.secondaryDark,
                              fontSize: 13.5,
                            ),
                            hintText: '0.00',
                            hintStyle: AppTypography.inputHint.copyWith(
                              fontSize: 13,
                            ),
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 8,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildAssignedRemainingRow() {
    return Row(
      children: [
        Expanded(
          child: _SummaryTotalCard(
            label: 'Assigned',
            value: formatPeso(_assignedTotal),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _SummaryTotalCard(
            label: 'Remaining',
            value: formatPeso(_remainingAmount),
          ),
        ),
      ],
    );
  }
}

class _MemberCircleAvatar extends StatelessWidget {
  final double size;

  const _MemberCircleAvatar({this.size = 40});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        color: AppColors.semanticYellow,
        shape: BoxShape.circle,
      ),
      child: AppIcon(
        Iconsax.user5,
        color: AppColors.white,
        size: size * 0.52,
      ),
    );
  }
}

class _SummaryTotalCard extends StatelessWidget {
  final String label;
  final String value;

  const _SummaryTotalCard({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
      decoration: BoxDecoration(
        color: AppColors.primaryOrange,
        borderRadius: BorderRadius.circular(14),
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
          Text(
            label,
            style: AppTypography.caption.copyWith(
              color: AppColors.white,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 6),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: AppTypography.h2.copyWith(
                color: AppColors.white,
                fontWeight: FontWeight.w800,
                fontSize: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
