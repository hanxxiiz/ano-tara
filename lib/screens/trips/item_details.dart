import 'package:flutter/material.dart';

import '../../models/expense.dart';
import '../../models/trip.dart';
import '../../services/trips_repository.dart';
import '../../theme/app_theme.dart';
import '../../widgets/trip_widgets.dart';
import 'itinerary_screen.dart';

String _longDate(DateTime d) => '${formatTabMonth(d)} ${d.day}, ${d.year}';

/// Details for an itinerary activity. The organizer can edit or delete it.
Future<void> showActivityDetails(
  BuildContext context, {
  required Trip trip,
  required ItineraryItem item,
  required TripsRepository repository,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    backgroundColor: Colors.white,
    builder: (sheetContext) => _DetailsSheet(
      thumbnailColor: AppColors.navy,
      icon: item.category.icon,
      chip: CategoryChip(item.category.label),
      title: item.title,
      rows: [
        _InfoRow(icon: Icons.location_on_rounded, label: item.location),
        _InfoRow(
          icon: Icons.calendar_month_rounded,
          label: _longDate(item.start),
        ),
        _InfoRow(
          icon: Icons.timer_rounded,
          label: formatTimeRange(item.start, item.end),
        ),
      ],
      canEdit: trip.isOrganizer,
      lockedMessage: 'Only the organizer can change the itinerary.',
      editLabel: 'Edit',
      onEdit: () async {
        Navigator.of(sheetContext).pop();
        await showModalBottomSheet<bool>(
          context: context,
          isScrollControlled: true,
          showDragHandle: true,
          backgroundColor: Colors.white,
          builder: (_) => ActivityFormSheet(
            trip: trip,
            initialDay: item.start,
            repository: repository,
            existing: item,
          ),
        );
      },
      onDelete: () async {
        final confirmed = await confirmDelete(
          sheetContext,
          title: 'Delete activity?',
          message: '"${item.title}" will be removed from the itinerary.',
        );
        if (!confirmed || !sheetContext.mounted) return;
        repository.removeItineraryItem(trip, item);
        Navigator.of(sheetContext).pop();
      },
    ),
  );
}

/// Details for an expense, including each person's share. The organizer or
/// whoever paid can rename or delete it.
Future<void> showExpenseDetails(
  BuildContext context, {
  required Trip trip,
  required Expense expense,
  required TripsRepository repository,
}) {
  final payer = trip.group.memberById(expense.paidById);
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    backgroundColor: Colors.white,
    builder: (sheetContext) => _DetailsSheet(
      thumbnailColor: AppColors.accent,
      icon: expense.category.icon,
      chip: CategoryChip(expense.category.label, color: TripColors.expenseChip),
      title: expense.title,
      rows: [
        _InfoRow(
          icon: Icons.account_balance_wallet_rounded,
          label: formatPeso(expense.amountCents),
          color: AppColors.accent,
        ),
        _InfoRow(
          icon: Icons.person_rounded,
          label: 'Paid by: ${payer?.displayName ?? 'Unknown'}',
          color: AppColors.accent,
        ),
        _InfoRow(
          icon: Icons.calendar_month_rounded,
          label: _longDate(expense.occurredAt),
          color: AppColors.accent,
        ),
        _InfoRow(
          icon: Icons.call_split_rounded,
          label: expense.splitMethod.label,
          color: AppColors.accent,
        ),
      ],
      extra: _SharesList(trip: trip, expense: expense),
      canEdit: trip.isOrganizer || (payer?.isYou ?? false),
      lockedMessage:
          'Only the organizer or whoever paid can change this expense.',
      editLabel: 'Rename',
      onEdit: () async {
        final name = await _askName(sheetContext, expense.title);
        if (name == null || !sheetContext.mounted) return;
        try {
          await repository.renameExpense(trip, expense, name);
          if (sheetContext.mounted) Navigator.of(sheetContext).pop();
        } catch (_) {
          if (sheetContext.mounted) {
            _showError(sheetContext, "Couldn't rename the expense. Try again.");
          }
        }
      },
      onDelete: () async {
        final confirmed = await confirmDelete(
          sheetContext,
          title: 'Delete expense?',
          message:
              '"${expense.title}" (${formatPeso(expense.amountCents)}) and '
              'everyone\'s share of it will be removed.',
        );
        if (!confirmed || !sheetContext.mounted) return;
        try {
          await repository.deleteExpense(trip, expense);
          if (sheetContext.mounted) Navigator.of(sheetContext).pop();
        } catch (_) {
          if (sheetContext.mounted) {
            _showError(sheetContext, "Couldn't delete the expense. Try again.");
          }
        }
      },
    ),
  );
}

void _showError(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message)));
}

/// Confirmation in the same card style as the other pop-ups.
Future<bool> confirmDelete(
  BuildContext context, {
  required String title,
  required String message,
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (context) => _CardDialog(
      title: title,
      message: message,
      confirmLabel: 'Delete',
      confirmColor: AppColors.accent,
      onConfirm: () => Navigator.of(context).pop(true),
    ),
  );
  return result ?? false;
}

Future<String?> _askName(BuildContext context, String current) {
  return showDialog<String>(
    context: context,
    builder: (_) => _RenameExpenseDialog(current: current),
  );
}

class _CardDialog extends StatelessWidget {
  const _CardDialog({
    required this.title,
    required this.message,
    required this.confirmLabel,
    required this.confirmColor,
    required this.onConfirm,
    this.content,
  });

  final String title;
  final String message;
  final String confirmLabel;
  final Color confirmColor;
  final VoidCallback? onConfirm;
  final Widget? content;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: OutlinedCard(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SectionHeading(title),
              const SizedBox(height: 6),
              Text(
                message,
                style: const TextStyle(fontSize: 13, color: AppColors.ink),
              ),
              if (content != null) ...[const SizedBox(height: 16), content!],
              const SizedBox(height: 18),
              Row(
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(color: AppColors.ink),
                    ),
                  ),
                  const Spacer(),
                  FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: confirmColor,
                    ),
                    onPressed: onConfirm,
                    child: Text(confirmLabel),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RenameExpenseDialog extends StatefulWidget {
  const _RenameExpenseDialog({required this.current});

  final String current;

  @override
  State<_RenameExpenseDialog> createState() => _RenameExpenseDialogState();
}

class _RenameExpenseDialogState extends State<_RenameExpenseDialog> {
  late final _name = TextEditingController(text: widget.current)
    ..selection = TextSelection(
      baseOffset: 0,
      extentOffset: widget.current.length,
    );
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  void _save() {
    final name = _name.text.trim();
    if (name.isEmpty) {
      setState(() => _error = 'Enter a name.');
      return;
    }
    Navigator.of(context).pop(name == widget.current ? null : name);
  }

  @override
  Widget build(BuildContext context) {
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.ink, width: 2),
    );
    return _CardDialog(
      title: 'Rename expense',
      message: 'What do you want to call this expense?',
      confirmLabel: 'Save',
      confirmColor: AppColors.ink,
      onConfirm: _save,
      content: TextField(
        controller: _name,
        autofocus: true,
        textCapitalization: TextCapitalization.sentences,
        onSubmitted: (_) => _save(),
        decoration: InputDecoration(
          hintText: 'Expense name',
          errorText: _error,
          filled: true,
          fillColor: AppColors.field,
          border: border,
          enabledBorder: border,
          focusedBorder: border,
        ),
      ),
    );
  }
}

class _InfoRow {
  const _InfoRow({
    required this.icon,
    required this.label,
    this.color = AppColors.navy,
  });

  final IconData icon;
  final String label;
  final Color color;
}

class _DetailsSheet extends StatelessWidget {
  const _DetailsSheet({
    required this.thumbnailColor,
    required this.icon,
    required this.chip,
    required this.title,
    required this.rows,
    required this.canEdit,
    required this.lockedMessage,
    required this.editLabel,
    required this.onEdit,
    required this.onDelete,
    this.extra,
  });

  final Color thumbnailColor;
  final IconData icon;
  final Widget chip;
  final String title;
  final List<_InfoRow> rows;
  final Widget? extra;
  final bool canEdit;
  final String lockedMessage;
  final String editLabel;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        heightFactor: 1,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: thumbnailColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(icon, color: Colors.white, size: 28),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          chip,
                          const SizedBox(height: 6),
                          Text(
                            title,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: AppColors.ink,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                OutlinedCard(
                  color: AppColors.field,
                  radius: 12,
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                  child: Column(
                    children: [
                      for (var i = 0; i < rows.length; i++) ...[
                        if (i > 0) const SizedBox(height: 10),
                        IconLabel(
                          icon: rows[i].icon,
                          label: rows[i].label,
                          iconColor: rows[i].color,
                          fontSize: 13,
                        ),
                      ],
                    ],
                  ),
                ),
                if (extra != null) ...[const SizedBox(height: 18), extra!],
                const SizedBox(height: 24),
                if (canEdit) ...[
                  PrimaryButton(label: editLabel, onPressed: onEdit),
                  const SizedBox(height: 16),
                  _DeleteButton(onPressed: onDelete),
                ] else
                  Text(
                    lockedMessage,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 12,
                      color: TripColors.navIdle,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DeleteButton extends StatelessWidget {
  const _DeleteButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedCard(
      radius: 16,
      onTap: onPressed,
      child: const SizedBox(
        height: 50,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.delete_outline_rounded,
              color: AppColors.accent,
              size: 20,
            ),
            SizedBox(width: 8),
            Text(
              'Delete',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.accent,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SharesList extends StatelessWidget {
  const _SharesList({required this.trip, required this.expense});

  final Trip trip;
  final Expense expense;

  @override
  Widget build(BuildContext context) {
    final entries = expense.sharesCents.entries.toList();
    return OutlinedCard(
      radius: 12,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: const BoxDecoration(
              color: TripColors.yellow,
              border: Border(
                bottom: BorderSide(color: AppColors.ink, width: 2),
              ),
            ),
            child: const Text(
              'Split',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
            ),
          ),
          for (var i = 0; i < entries.length; i++) ...[
            if (i > 0)
              const Divider(height: 1, thickness: 1, color: AppColors.ink),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  const MemberAvatar(size: 32),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      trip.group.memberById(entries[i].key)?.displayName ??
                          'Member',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Text(
                    formatPeso(entries[i].value),
                    style: const TextStyle(fontSize: 14, color: AppColors.ink),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
