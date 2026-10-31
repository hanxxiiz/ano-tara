import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../models/expense.dart';
import '../../models/trip.dart';
import '../../services/trips_repository.dart';
import '../../theme/app_theme.dart';
import '../../widgets/trip_widgets.dart';
import 'expenses_screen.dart';

/// Opens the add-expense flow for [trip]; the expense is dated on [day].
void startAddExpense(
  BuildContext context, {
  required Trip trip,
  required DateTime day,
  required TripsRepository repository,
}) {
  if (trip.group.members.isEmpty) {
    showComingSoon(context, 'Adding members to ${trip.group.name}');
    return;
  }
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (_) =>
          ExpenseCategoryScreen(trip: trip, day: day, repository: repository),
    ),
  );
}

/// Pops back to View Expenses (or the first route if it isn't in the stack).
void _backToExpenses(NavigatorState navigator) {
  navigator.popUntil(
    (route) => route.settings.name == ExpensesScreen.routeName || route.isFirst,
  );
}

// ---------------------------------------------------------------------------
// Step 1: category

class ExpenseCategoryScreen extends StatefulWidget {
  const ExpenseCategoryScreen({
    super.key,
    required this.trip,
    required this.day,
    required this.repository,
  });

  final Trip trip;
  final DateTime day;
  final TripsRepository repository;

  @override
  State<ExpenseCategoryScreen> createState() => _ExpenseCategoryScreenState();
}

class _ExpenseCategoryScreenState extends State<ExpenseCategoryScreen> {
  ExpenseCategory? _category;

  void _continue() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ExpenseDetailsScreen(
          trip: widget.trip,
          day: widget.day,
          category: _category!,
          repository: widget.repository,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const TitleBar(title: 'Add Expense'),
      body: SafeArea(
        top: false,
        child: Center(
          // Tiles are square, so cap the width (the design is 375 wide);
          // otherwise they grow taller than the screen on wide windows.
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.only(top: 32, bottom: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Text(
                            'Which category does this expense belong to?',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: AppColors.ink,
                            ),
                          ),
                          const SizedBox(height: 40),
                          GridView.count(
                            crossAxisCount: 3,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            mainAxisSpacing: 22,
                            crossAxisSpacing: 20,
                            children: [
                              for (final c in ExpenseCategory.values)
                                _CategoryTile(
                                  category: c,
                                  selected: c == _category,
                                  onTap: () => setState(() => _category = c),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  PrimaryButton(
                    label: 'Continue',
                    trailing: Icons.arrow_forward_rounded,
                    onPressed: _category == null ? null : _continue,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CategoryTile extends StatelessWidget {
  const _CategoryTile({
    required this.category,
    required this.selected,
    required this.onTap,
  });

  final ExpenseCategory category;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final fg = selected ? Colors.white : AppColors.ink;
    return Semantics(
      selected: selected,
      button: true,
      child: OutlinedCard(
        color: selected ? AppColors.accent : Colors.white,
        radius: 16,
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(category.icon, size: 40, color: fg),
            const SizedBox(height: 8),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                category.label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: fg,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Step 2: details and split

class ExpenseDetailsScreen extends StatefulWidget {
  const ExpenseDetailsScreen({
    super.key,
    required this.trip,
    required this.day,
    required this.category,
    required this.repository,
  });

  final Trip trip;
  final DateTime day;
  final ExpenseCategory category;
  final TripsRepository repository;

  @override
  State<ExpenseDetailsScreen> createState() => _ExpenseDetailsScreenState();
}

class _ExpenseDetailsScreenState extends State<ExpenseDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _amount = TextEditingController();
  late final List<TripMember> _members = widget.trip.group.members;
  late String _paidById = _initialPayer();
  late final List<String> _splitIds = [for (final m in _members) m.id];
  final Map<String, TextEditingController> _custom = {};
  var _method = SplitMethod.equal;
  var _saving = false;
  var _submitted = false;

  String _initialPayer() {
    for (final m in _members) {
      if (m.isYou) return m.id;
    }
    return _members.first.id;
  }

  @override
  void initState() {
    super.initState();
    _amount.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _title.dispose();
    _amount.dispose();
    for (final c in _custom.values) {
      c.dispose();
    }
    super.dispose();
  }

  int get _totalCents => parsePesoCents(_amount.text) ?? 0;

  TextEditingController _customFor(String memberId) =>
      _custom.putIfAbsent(memberId, () {
        final controller = TextEditingController();
        controller.addListener(() => setState(() {}));
        return controller;
      });

  Map<String, int> get _shares {
    if (_method == SplitMethod.equal) {
      return splitEqually(_totalCents, _splitIds);
    }
    return {
      for (final id in _splitIds) id: parsePesoCents(_customFor(id).text) ?? 0,
    };
  }

  int get _assignedCents => _shares.values.fold(0, (a, b) => a + b);
  int get _remainingCents => _totalCents - _assignedCents;

  String? get _splitError {
    if (_splitIds.isEmpty) return 'Choose at least one person to split with.';
    if (_method == SplitMethod.custom && _remainingCents != 0) {
      return _remainingCents > 0
          ? '${formatPeso(_remainingCents)} still needs to be assigned.'
          : 'Assigned amounts are ${formatPeso(-_remainingCents)} over the total.';
    }
    return null;
  }

  DateTime get _occurredAt {
    final now = DateTime.now();
    final d = widget.day;
    final isToday =
        d.year == now.year && d.month == now.month && d.day == now.day;
    return isToday ? now : DateTime(d.year, d.month, d.day, 12);
  }

  Future<void> _addMember() async {
    final remaining = [
      for (final m in _members)
        if (!_splitIds.contains(m.id)) m,
    ];
    if (remaining.isEmpty) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(content: Text('Everyone is already in this split.')),
        );
      return;
    }
    final picked = await showModalBottomSheet<TripMember>(
      context: context,
      showDragHandle: true,
      backgroundColor: Colors.white,
      builder: (context) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: [
            for (final m in remaining)
              ListTile(
                leading: const MemberAvatar(size: 36),
                title: Text(m.displayName),
                onTap: () => Navigator.of(context).pop(m),
              ),
          ],
        ),
      ),
    );
    if (picked != null) {
      setState(() {
        // Keep the group's order so the breakdown doesn't jump around.
        _splitIds
          ..add(picked.id)
          ..sort(
            (a, b) => _members
                .indexWhere((m) => m.id == a)
                .compareTo(_members.indexWhere((m) => m.id == b)),
          );
      });
    }
  }

  Future<void> _save() async {
    setState(() => _submitted = true);
    if (!_formKey.currentState!.validate() || _splitError != null) return;

    setState(() => _saving = true);
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    try {
      final savedOnline = await widget.repository.addExpense(
        widget.trip,
        title: _title.text.trim(),
        category: widget.category,
        amountCents: _totalCents,
        paidById: _paidById,
        splitMethod: _method,
        sharesCents: _shares,
        occurredAt: _occurredAt,
      );
      navigator.pushReplacement(
        MaterialPageRoute(
          builder: (_) => ExpenseAddedScreen(
            trip: widget.trip,
            day: widget.day,
            savedOnline: savedOnline,
            repository: widget.repository,
          ),
        ),
      );
    } catch (error) {
      if (!mounted) return;
      setState(() => _saving = false);
      messenger.showSnackBar(
        SnackBar(content: Text("Couldn't save the expense: $error")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(15),
      borderSide: const BorderSide(color: AppColors.ink, width: 2),
    );
    final deco = InputDecoration(
      filled: true,
      fillColor: AppColors.field,
      border: border,
      enabledBorder: border,
      focusedBorder: border,
    );
    const label = TextStyle(fontSize: 14, color: AppColors.ink);

    return Scaffold(
      appBar: const TitleBar(title: 'Add Expense'),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(15, 24, 15, 32),
          children: [
            const Text(
              'Expense Details',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: AppColors.ink,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Enter the expense details below or choose how you want to split it.',
              style: TextStyle(fontSize: 13, color: AppColors.ink),
            ),
            const SizedBox(height: 22),
            const Text('Title', style: label),
            const SizedBox(height: 6),
            TextFormField(
              controller: _title,
              decoration: deco,
              textCapitalization: TextCapitalization.sentences,
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Enter a title.' : null,
            ),
            const SizedBox(height: 18),
            const Text('Amount', style: label),
            const SizedBox(height: 6),
            TextFormField(
              controller: _amount,
              decoration: deco.copyWith(prefixText: '₱ '),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
              ],
              validator: (v) {
                final cents = parsePesoCents(v ?? '');
                return cents == null || cents == 0 ? 'Enter an amount.' : null;
              },
            ),
            const SizedBox(height: 18),
            const Text('Paid by', style: label),
            const SizedBox(height: 6),
            DropdownButtonFormField<String>(
              initialValue: _paidById,
              decoration: deco,
              icon: const Icon(
                Icons.keyboard_arrow_down_rounded,
                color: AppColors.ink,
              ),
              items: [
                for (final m in _members)
                  DropdownMenuItem(value: m.id, child: Text(m.displayName)),
              ],
              onChanged: (id) => setState(() => _paidById = id ?? _paidById),
            ),
            const SizedBox(height: 18),
            const Text('Split among', style: label),
            const SizedBox(height: 10),
            _SplitAmong(
              members: [
                for (final id in _splitIds)
                  _members.firstWhere((m) => m.id == id),
              ],
              onRemove: (m) => setState(() => _splitIds.remove(m.id)),
              onAdd: _addMember,
            ),
            const SizedBox(height: 22),
            const Text('Split method', style: label),
            const SizedBox(height: 10),
            _MethodToggle(
              value: _method,
              onChanged: (m) => setState(() => _method = m),
            ),
            if (_method == SplitMethod.custom) ...[
              const SizedBox(height: 22),
              Row(
                children: [
                  Expanded(
                    child: _TotalBox(label: 'Assigned', cents: _assignedCents),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _TotalBox(
                      label: 'Remaining',
                      cents: _remainingCents,
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 22),
            _Breakdown(
              members: [
                for (final id in _splitIds)
                  _members.firstWhere((m) => m.id == id),
              ],
              method: _method,
              shares: _shares,
              controllerFor: _customFor,
            ),
            if (_submitted && _splitError != null)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Text(
                  _splitError!,
                  style: const TextStyle(fontSize: 12, color: AppColors.accent),
                ),
              ),
            const SizedBox(height: 40),
            PrimaryButton(
              label: 'Add Expense',
              busy: _saving,
              onPressed: _save,
            ),
            const SizedBox(height: 24),
            SecondaryButton(
              label: 'Cancel',
              onPressed: () => _backToExpenses(Navigator.of(context)),
            ),
          ],
        ),
      ),
    );
  }
}

class _SplitAmong extends StatelessWidget {
  const _SplitAmong({
    required this.members,
    required this.onRemove,
    required this.onAdd,
  });

  final List<TripMember> members;
  final ValueChanged<TripMember> onRemove;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    Widget person(
      Widget circle,
      String name, {
      VoidCallback? onTap,
      String? semantics,
    }) {
      return Semantics(
        button: true,
        label: semantics,
        child: InkWell(
          onTap: onTap,
          customBorder: const CircleBorder(),
          child: SizedBox(
            width: 60,
            child: Column(
              children: [
                circle,
                const SizedBox(height: 6),
                ExcludeSemantics(
                  child: Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    Widget ringed(Color color, Widget child) => Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.ink, width: 2),
      ),
      child: child,
    );

    return SizedBox(
      height: 80,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          for (final m in members) ...[
            person(
              Stack(
                clipBehavior: Clip.none,
                children: [
                  ringed(
                    TripColors.avatar,
                    const Icon(
                      Icons.person_rounded,
                      color: AppColors.ink,
                      size: 24,
                    ),
                  ),
                  const Positioned(
                    right: -2,
                    top: -2,
                    child: CircleAvatar(
                      radius: 9,
                      backgroundColor: AppColors.ink,
                      child: Icon(
                        Icons.close_rounded,
                        size: 12,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              m.shortName,
              onTap: () => onRemove(m),
              semantics: 'Remove ${m.shortName} from split',
            ),
            const SizedBox(width: 8),
          ],
          person(
            ringed(
              AppColors.accent,
              const Icon(Icons.add_rounded, color: AppColors.ink),
            ),
            'Add',
            onTap: onAdd,
            semantics: 'Add person to split',
          ),
        ],
      ),
    );
  }
}

class _MethodToggle extends StatelessWidget {
  const _MethodToggle({required this.value, required this.onChanged});

  final SplitMethod value;
  final ValueChanged<SplitMethod> onChanged;

  @override
  Widget build(BuildContext context) {
    return OutlinedCard(
      radius: 12,
      child: SizedBox(
        height: 40,
        child: Row(
          children: [
            for (final m in SplitMethod.values)
              Expanded(
                child: Semantics(
                  selected: m == value,
                  button: true,
                  child: InkWell(
                    onTap: () => onChanged(m),
                    child: Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: m == value ? AppColors.navy : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        m.label,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: m == value ? Colors.white : AppColors.ink,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _TotalBox extends StatelessWidget {
  const _TotalBox({required this.label, required this.cents});

  final String label;
  final int cents;

  @override
  Widget build(BuildContext context) {
    return OutlinedCard(
      color: AppColors.accent,
      radius: 12,
      padding: const EdgeInsets.fromLTRB(16, 12, 12, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 6),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              formatPeso(cents),
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Per-person amounts: read-only pills when split equally, inputs otherwise.
class _Breakdown extends StatelessWidget {
  const _Breakdown({
    required this.members,
    required this.method,
    required this.shares,
    required this.controllerFor,
  });

  final List<TripMember> members;
  final SplitMethod method;
  final Map<String, int> shares;
  final TextEditingController Function(String memberId) controllerFor;

  @override
  Widget build(BuildContext context) {
    final rows = <Widget>[];
    for (var i = 0; i < members.length; i++) {
      final m = members[i];
      if (i > 0) {
        rows.add(const Divider(height: 1, thickness: 2, color: AppColors.ink));
      }
      rows.add(
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Row(
            children: [
              const MemberAvatar(),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  m.displayName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              SizedBox(
                width: 96,
                child: method == SplitMethod.equal
                    ? _AmountPill(text: formatPeso(shares[m.id] ?? 0))
                    : _AmountInput(
                        controller: controllerFor(m.id),
                        name: m.shortName,
                      ),
              ),
            ],
          ),
        ),
      );
    }

    return OutlinedCard(
      radius: 16,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            height: 56,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            alignment: Alignment.centerLeft,
            decoration: const BoxDecoration(
              color: TripColors.yellow,
              border: Border(
                bottom: BorderSide(color: AppColors.ink, width: 2),
              ),
            ),
            child: Text(
              method == SplitMethod.equal
                  ? 'Each person pays'
                  : 'Set each amount',
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
            ),
          ),
          if (members.isEmpty)
            const Padding(
              padding: EdgeInsets.all(20),
              child: Text(
                'No one is in this split yet.',
                style: TextStyle(fontSize: 13, color: TripColors.navIdle),
              ),
            )
          else
            ...rows,
        ],
      ),
    );
  }
}

class _AmountPill extends StatelessWidget {
  const _AmountPill({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 34,
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 6),
      decoration: BoxDecoration(
        color: AppColors.field,
        borderRadius: BorderRadius.circular(9),
        border: Border.all(color: AppColors.ink, width: 2),
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          text,
          style: const TextStyle(fontSize: 13, color: AppColors.ink),
        ),
      ),
    );
  }
}

class _AmountInput extends StatelessWidget {
  const _AmountInput({required this.controller, required this.name});

  final TextEditingController controller;
  final String name;

  @override
  Widget build(BuildContext context) {
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(9),
      borderSide: const BorderSide(color: AppColors.ink, width: 2),
    );
    return SizedBox(
      height: 34,
      child: Semantics(
        label: 'Amount for $name',
        child: TextField(
          controller: controller,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 13),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
          ],
          decoration: InputDecoration(
            hintText: '₱0.00',
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 6,
              vertical: 8,
            ),
            filled: true,
            fillColor: AppColors.field,
            border: border,
            enabledBorder: border,
            focusedBorder: border,
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Step 3: confirmation

class ExpenseAddedScreen extends StatelessWidget {
  const ExpenseAddedScreen({
    super.key,
    required this.trip,
    required this.day,
    required this.savedOnline,
    required this.repository,
  });

  final Trip trip;
  final DateTime day;
  final bool savedOnline;
  final TripsRepository repository;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Column(
            children: [
              const Spacer(flex: 3),
              Container(
                width: 173,
                height: 173,
                decoration: const BoxDecoration(
                  color: AppColors.accent,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.account_balance_wallet_rounded,
                  size: 86,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 36),
              const Text(
                'Expense Added!',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                savedOnline
                    ? 'Item has been added to your expenses.'
                    : 'Item has been added to your expenses on this device.',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14, color: Colors.black),
              ),
              const Spacer(flex: 2),
              PrimaryButton(
                label: 'Add More',
                onPressed: () {
                  final navigator = Navigator.of(context);
                  _backToExpenses(navigator);
                  navigator.push(
                    MaterialPageRoute(
                      builder: (_) => ExpenseCategoryScreen(
                        trip: trip,
                        day: day,
                        repository: repository,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 22),
              SecondaryButton(
                label: 'View Expenses',
                onPressed: () => _backToExpenses(Navigator.of(context)),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
