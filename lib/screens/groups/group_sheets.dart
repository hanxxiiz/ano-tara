import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iconsax/iconsax.dart';

import '../../components/atoms/app_avatar.dart';
import '../../components/atoms/app_button.dart';
import '../../components/atoms/app_input_field.dart';
import '../../components/molecules/app_bottom_sheet.dart';
import '../../components/molecules/app_radio_option.dart';
import '../../components/organisms/availability_calendar.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import '../../models/group_models.dart';

// =============================================================================
// 05.14 Filter Trips
// =============================================================================

/// Returns the chosen filter, or null if the sheet was dismissed.
Future<TripFilter?> showFilterTripsSheet(
  BuildContext context, {
  required TripFilter current,
}) async {
  final result = await showAppBottomSheet<(TripStatus?, TripSort)>(
    context,
    builder: (_) => _FilterSortSheet<TripStatus?, TripSort>(
      title: 'Filter Trips',
      filterTitle: 'Trip Status',
      filterOptions: [null, ...TripStatus.values],
      filterLabel: (status) => status?.label ?? 'All Trips',
      initialFilter: current.status,
      defaultFilter: null,
      sortOptions: TripSort.values,
      sortLabel: (sort) => sort.label,
      initialSort: current.sort,
      defaultSort: TripSort.dateNewest,
    ),
  );
  return result == null ? null : TripFilter(status: result.$1, sort: result.$2);
}

// =============================================================================
// 05.11 Filter Members
// =============================================================================

/// Returns the chosen filter, or null if the sheet was dismissed.
Future<MemberFilter?> showFilterMembersSheet(
  BuildContext context, {
  required MemberFilter current,
}) async {
  final result = await showAppBottomSheet<(MemberStatus?, MemberSort)>(
    context,
    builder: (_) => _FilterSortSheet<MemberStatus?, MemberSort>(
      title: 'Filter Members',
      filterTitle: 'Membership Status',
      filterOptions: [null, ...MemberStatus.values],
      filterLabel: (status) => status?.label ?? 'All Members',
      initialFilter: current.status,
      defaultFilter: null,
      sortOptions: MemberSort.values,
      sortLabel: (sort) => sort.label,
      initialSort: current.sort,
      defaultSort: MemberSort.nameAz,
    ),
  );
  return result == null
      ? null
      : MemberFilter(status: result.$1, sort: result.$2);
}

/// Shared layout for the filter sheets: a radio section for the filter,
/// a radio section for the sort order, and Reset / Apply Filters actions.
/// Pops with the selected `(filter, sort)` pair on apply.
class _FilterSortSheet<F, S> extends StatefulWidget {
  final String title;
  final String filterTitle;
  final List<F> filterOptions;
  final String Function(F) filterLabel;
  final F initialFilter;
  final F defaultFilter;
  final List<S> sortOptions;
  final String Function(S) sortLabel;
  final S initialSort;
  final S defaultSort;

  const _FilterSortSheet({
    required this.title,
    required this.filterTitle,
    required this.filterOptions,
    required this.filterLabel,
    required this.initialFilter,
    required this.defaultFilter,
    required this.sortOptions,
    required this.sortLabel,
    required this.initialSort,
    required this.defaultSort,
  });

  @override
  State<_FilterSortSheet<F, S>> createState() => _FilterSortSheetState<F, S>();
}

class _FilterSortSheetState<F, S> extends State<_FilterSortSheet<F, S>> {
  late F _filter = widget.initialFilter;
  late S _sort = widget.initialSort;

  @override
  Widget build(BuildContext context) {
    return AppBottomSheet(
      title: widget.title,
      showTitleMarker: false,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(top: 14, bottom: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AppSheetSectionTitle(widget.filterTitle),
                  const SizedBox(height: 10),
                  for (final option in widget.filterOptions)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: AppRadioOption(
                        label: widget.filterLabel(option),
                        isSelected: _filter == option,
                        onTap: () => setState(() => _filter = option),
                      ),
                    ),
                  const _SheetDivider(),
                  const AppSheetSectionTitle('Sort By'),
                  const SizedBox(height: 10),
                  for (final sort in widget.sortOptions)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: AppRadioOption(
                        label: widget.sortLabel(sort),
                        isSelected: _sort == sort,
                        onTap: () => setState(() => _sort = sort),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const _SheetDivider(),
          Row(
            children: [
              Expanded(
                child: AppButton(
                  text: 'Reset',
                  variant: AppButtonVariant.secondary,
                  borderRadius: 16,
                  customHeight: 50,
                  onPressed: () => setState(() {
                    _filter = widget.defaultFilter;
                    _sort = widget.defaultSort;
                  }),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: AppButton(
                  text: 'Apply Filters',
                  borderRadius: 16,
                  customHeight: 50,
                  onPressed: () => Navigator.of(context).pop((_filter, _sort)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// 05.10 Group Actions (organizer menu)
// =============================================================================

enum GroupAction { editGroup, inviteMembers, inviteCode, deleteGroup }

/// Organizer-only menu. Returns the tapped action, or null if dismissed.
Future<GroupAction?> showGroupActionsSheet(BuildContext context) {
  return showAppBottomSheet<GroupAction>(
    context,
    builder: (context) => AppBottomSheet(
      title: 'Group Actions',
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(top: 14),
        child: Column(
          children: const [
            _SheetDivider(spacing: 0),
            _GroupActionTile(
              action: GroupAction.editGroup,
              icon: Iconsax.edit_2,
              title: 'Edit Group',
              subtitle: 'Update the group name, photo, and description.',
            ),
            _SheetDivider(spacing: 0),
            _GroupActionTile(
              action: GroupAction.inviteMembers,
              icon: Iconsax.user_add,
              title: 'Invite Members',
              subtitle:
                  'Search for friends or send invites to add new members.',
            ),
            _SheetDivider(spacing: 0),
            _GroupActionTile(
              action: GroupAction.inviteCode,
              icon: Iconsax.link_2,
              title: 'Group Invite Code',
              subtitle:
                  "Share your group's unique code so friends can join instantly.",
            ),
            _SheetDivider(spacing: 0),
            _GroupActionTile(
              action: GroupAction.deleteGroup,
              icon: Iconsax.trash,
              title: 'Delete Group',
              subtitle: 'Permanently remove this group and all of its data.',
              isDestructive: true,
            ),
          ],
        ),
      ),
    ),
  );
}

class _GroupActionTile extends StatelessWidget {
  final GroupAction action;
  final IconData icon;
  final String title;
  final String subtitle;
  final bool isDestructive;

  const _GroupActionTile({
    required this.action,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = isDestructive
        ? AppColors.primaryOrange
        : AppColors.secondaryDark;

    return Semantics(
      button: true,
      child: InkWell(
        onTap: () => Navigator.of(context).pop(action),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Row(
            children: [
              SizedBox(width: 44, child: Icon(icon, size: 24, color: color)),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTypography.titleLarge.copyWith(color: color),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.slate,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              const Icon(
                Iconsax.arrow_right_3,
                size: 18,
                color: AppColors.secondaryDark,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// 05.13 My Availability
// =============================================================================

/// Lets the current user tap the dates they're free. Returns the full new
/// set of dates on "Update Availability", or null if dismissed.
Future<Set<DateTime>?> showMyAvailabilitySheet(
  BuildContext context, {
  required String groupName,
  required DateTime initialMonth,
  required Set<DateTime> selected,
}) {
  return showAppBottomSheet<Set<DateTime>>(
    context,
    builder: (_) => _MyAvailabilitySheet(
      groupName: groupName,
      initialMonth: initialMonth,
      initialSelected: selected,
    ),
  );
}

class _MyAvailabilitySheet extends StatefulWidget {
  final String groupName;
  final DateTime initialMonth;
  final Set<DateTime> initialSelected;

  const _MyAvailabilitySheet({
    required this.groupName,
    required this.initialMonth,
    required this.initialSelected,
  });

  @override
  State<_MyAvailabilitySheet> createState() => _MyAvailabilitySheetState();
}

class _MyAvailabilitySheetState extends State<_MyAvailabilitySheet> {
  late DateTime _month = widget.initialMonth;
  late final Set<DateTime> _selected = {...widget.initialSelected};

  void _toggle(DateTime day) {
    setState(() {
      if (!_selected.remove(day)) _selected.add(day);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppBottomSheet(
      title: 'My Availability',
      showTitleMarker: false,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              widget.groupName,
              style: AppTypography.bodySmall.copyWith(color: AppColors.slate),
            ),
            const _SheetDivider(),
            Align(
              alignment: Alignment.centerLeft,
              child: AvailabilityMonthNav(
                month: _month,
                onPrevious: () => setState(
                  () => _month = DateTime(_month.year, _month.month - 1),
                ),
                onNext: () => setState(
                  () => _month = DateTime(_month.year, _month.month + 1),
                ),
              ),
            ),
            const SizedBox(height: 14),
            AvailabilityCalendar(
              month: _month,
              onDayTap: _toggle,
              dayStyle: (day) => _selected.contains(day)
                  ? const AvailabilityDayStyle(
                      fill: AppColors.primaryOrange,
                      outlined: true,
                    )
                  : AvailabilityDayStyle.empty,
              dayLabel: (day) =>
                  _selected.contains(day) ? 'available' : 'not available',
            ),
            const SizedBox(height: 20),
            AppButton(
              text: 'Update Availability',
              variant: AppButtonVariant.primaryOrange,
              borderRadius: 16,
              customHeight: 50,
              onPressed: () => Navigator.of(context).pop(_selected),
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// 05.09 Invite Members
// =============================================================================

/// Search the directory and multi-select people to invite. Anyone whose id is
/// in [excludeIds] (already a member or invited) is hidden. Returns the
/// selection, or null if the sheet was dismissed.
Future<List<UserProfile>?> showInviteMembersSheet(
  BuildContext context, {
  required Set<String> excludeIds,
  List<UserProfile> directory = UserProfile.sampleDirectory,
}) {
  return showAppBottomSheet<List<UserProfile>>(
    context,
    builder: (_) => _InviteMembersSheet(
      candidates: [
        for (final person in directory)
          if (!excludeIds.contains(person.id)) person,
      ],
    ),
  );
}

class _InviteMembersSheet extends StatefulWidget {
  final List<UserProfile> candidates;

  const _InviteMembersSheet({required this.candidates});

  @override
  State<_InviteMembersSheet> createState() => _InviteMembersSheetState();
}

class _InviteMembersSheetState extends State<_InviteMembersSheet> {
  String _query = '';
  final Set<String> _selectedIds = {};

  void _toggle(UserProfile person) {
    setState(() {
      if (!_selectedIds.remove(person.id)) _selectedIds.add(person.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final results = [
      for (final person in widget.candidates)
        if (person.matches(_query)) person,
    ];

    return AppBottomSheet(
      title: 'Invite Members',
      showTitleMarker: false,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Find and select people to join the group.',
            style: AppTypography.bodySmall.copyWith(color: AppColors.slate),
          ),
          const _SheetDivider(),
          AppInputField(
            hint: 'Search name or username...',
            borderRadius: 15,
            onChanged: (value) => setState(() => _query = value),
            prefixIcon: const Icon(
              Iconsax.search_normal,
              size: 20,
              color: AppColors.secondaryDark,
            ),
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerLeft,
            child: _ResultCountPill(count: results.length),
          ),
          const SizedBox(height: 12),
          Flexible(
            child: results.isEmpty
                ? Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Text(
                      widget.candidates.isEmpty
                          ? 'Everyone in your directory is already in this group.'
                          : 'No people match your search.',
                      textAlign: TextAlign.center,
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.carla,
                      ),
                    ),
                  )
                : ListView.separated(
                    shrinkWrap: true,
                    itemCount: results.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 9),
                    itemBuilder: (_, index) {
                      final person = results[index];
                      return _InviteResultTile(
                        person: person,
                        isSelected: _selectedIds.contains(person.id),
                        onTap: () => _toggle(person),
                      );
                    },
                  ),
          ),
          const _SheetDivider(spacing: 18),
          Row(
            children: [
              Expanded(
                child: AppButton(
                  text: 'Cancel',
                  variant: AppButtonVariant.secondary,
                  borderRadius: 16,
                  customHeight: 50,
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: AppButton(
                  text: 'Add',
                  borderRadius: 16,
                  customHeight: 50,
                  isDisabled: _selectedIds.isEmpty,
                  onPressed: () => Navigator.of(context).pop([
                    for (final person in widget.candidates)
                      if (_selectedIds.contains(person.id)) person,
                  ]),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ResultCountPill extends StatelessWidget {
  final int count;

  const _ResultCountPill({required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 25,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.primaryNavy,
        borderRadius: BorderRadius.circular(12.5),
        border: Border.all(color: AppColors.secondaryDark),
      ),
      child: Text(
        count == 1 ? '1 result' : '$count results',
        style: AppTypography.badge.copyWith(
          color: AppColors.white,
          fontSize: 12,
          letterSpacing: 0,
        ),
      ),
    );
  }
}

class _InviteResultTile extends StatelessWidget {
  final UserProfile person;
  final bool isSelected;
  final VoidCallback onTap;

  const _InviteResultTile({
    required this.person,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: isSelected,
      label: '${isSelected ? 'Deselect' : 'Select'} ${person.name}',
      container: true,
      excludeSemantics: true,
      onTap: onTap,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          constraints: const BoxConstraints(minHeight: 67),
          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.selectedRowBlue : AppColors.white,
            borderRadius: BorderRadius.circular(11),
            border: Border.all(color: AppColors.secondaryDark, width: 2),
          ),
          child: Row(
            children: [
              AppAvatar.singleUser(size: 36),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      person.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.titleMedium.copyWith(
                        color: AppColors.secondaryDark,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      person.handle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.secondaryDark,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                isSelected ? Icons.check_circle : Icons.add_circle,
                size: 24,
                color: isSelected
                    ? AppColors.primaryNavy
                    : AppColors.secondaryDark,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// 05.17 Share Group Code
// =============================================================================

/// Shows the invite code. [onCodeChanged] is called after "Generate New Code".
Future<void> showShareGroupCodeSheet(
  BuildContext context, {
  required String code,
  ValueChanged<String>? onCodeChanged,
}) {
  return showAppBottomSheet<void>(
    context,
    builder: (_) =>
        _ShareGroupCodeSheet(initialCode: code, onCodeChanged: onCodeChanged),
  );
}

class _ShareGroupCodeSheet extends StatefulWidget {
  final String initialCode;
  final ValueChanged<String>? onCodeChanged;

  const _ShareGroupCodeSheet({required this.initialCode, this.onCodeChanged});

  @override
  State<_ShareGroupCodeSheet> createState() => _ShareGroupCodeSheetState();
}

class _ShareGroupCodeSheetState extends State<_ShareGroupCodeSheet> {
  static const _alphabet = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
  late String _code = widget.initialCode;

  void _generateNewCode() {
    final random = Random.secure();
    final code = List.generate(
      5,
      (_) => _alphabet[random.nextInt(_alphabet.length)],
    ).join();
    setState(() => _code = code);
    widget.onCodeChanged?.call(code);
  }

  Future<void> _copyCode() async {
    await Clipboard.setData(ClipboardData(text: _code));
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Group code $_code copied')));
  }

  @override
  Widget build(BuildContext context) {
    return AppBottomSheet(
      title: 'Share Group Code',
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const _SheetDivider(spacing: 12),
            Text(
              'Your Group Code',
              style: AppTypography.titleMedium.copyWith(
                color: AppColors.secondaryDark,
              ),
            ),
            const SizedBox(height: 16),
            Semantics(
              label: 'Group code ${_code.split('').join(' ')}',
              child: ExcludeSemantics(
                child: Row(
                  children: [
                    for (int i = 0; i < _code.length; i++) ...[
                      if (i > 0) const SizedBox(width: 4),
                      Expanded(child: _CodeCell(_code[i])),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 28),
            AppButton(
              text: 'Copy Code',
              borderRadius: 16,
              customHeight: 46,
              iconLeading: const Icon(
                Iconsax.copy,
                size: 20,
                color: AppColors.white,
              ),
              onPressed: _copyCode,
            ),
            const SizedBox(height: 14),
            AppButton(
              text: 'Generate New Code',
              variant: AppButtonVariant.secondary,
              borderRadius: 16,
              customHeight: 46,
              iconLeading: const Icon(
                Iconsax.repeat,
                size: 20,
                color: AppColors.secondaryDark,
              ),
              onPressed: _generateNewCode,
            ),
          ],
        ),
      ),
    );
  }
}

class _CodeCell extends StatelessWidget {
  final String character;

  const _CodeCell(this.character);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 66,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.secondaryLight,
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
      child: Text(
        character,
        style: AppTypography.h1.copyWith(
          color: AppColors.secondaryDark,
          fontSize: 32,
        ),
      ),
    );
  }
}

// =============================================================================
// 05.19 Delete Group confirmation
// =============================================================================

/// Resolves to true only when the organizer confirms deletion.
Future<bool> showDeleteGroupSheet(
  BuildContext context, {
  required String groupName,
}) {
  return _showDestructiveConfirmSheet(
    context,
    title: 'Delete Group',
    message:
        'Are you sure you want to delete "$groupName"? All trips, '
        'members, and availability in this group will be permanently '
        'removed. This action cannot be undone.',
    confirmLabel: 'Delete Group',
  );
}

// =============================================================================
// 05.15 Remove Group Member confirmation
// =============================================================================

/// Resolves to true only when the organizer confirms removal.
Future<bool> showRemoveMemberSheet(
  BuildContext context, {
  required String memberName,
}) {
  return _showDestructiveConfirmSheet(
    context,
    title: 'Remove Group Member',
    message:
        'Are you sure you want to remove $memberName from this group? '
        'They will lose access to all trips and plans shared with the group.',
    confirmLabel: 'Remove Member',
  );
}

/// Warning icon + title + message + destructive / Cancel actions.
Future<bool> _showDestructiveConfirmSheet(
  BuildContext context, {
  required String title,
  required String message,
  required String confirmLabel,
}) async {
  final confirmed = await showAppBottomSheet<bool>(
    context,
    builder: (context) => AppBottomSheet(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(
              Iconsax.warning_25,
              size: 78,
              color: AppColors.primaryOrange,
            ),
            const SizedBox(height: 18),
            Text(
              title,
              textAlign: TextAlign.center,
              style: AppTypography.h3.copyWith(
                fontWeight: FontWeight.w800,
                color: AppColors.secondaryDark,
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                message,
                textAlign: TextAlign.center,
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.slate,
                  fontSize: 12.5,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  AppButton(
                    text: confirmLabel,
                    variant: AppButtonVariant.destructive,
                    borderRadius: 16,
                    customHeight: 50,
                    onPressed: () => Navigator.of(context).pop(true),
                  ),
                  const SizedBox(height: 14),
                  AppButton(
                    text: 'Cancel',
                    variant: AppButtonVariant.secondary,
                    borderRadius: 16,
                    customHeight: 50,
                    onPressed: () => Navigator.of(context).pop(false),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
  return confirmed ?? false;
}

// =============================================================================

class _SheetDivider extends StatelessWidget {
  final double spacing;

  const _SheetDivider({this.spacing = 14});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: spacing),
      child: Container(height: 1, color: AppColors.ann),
    );
  }
}
