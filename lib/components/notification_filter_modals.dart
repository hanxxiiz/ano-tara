import 'package:flutter/material.dart';

import '../models/notification_models.dart';
import '../theme/app_theme.dart';
import 'atoms/app_button.dart';

const Color _modalNavy = Color(0xFF10052F);
const Color _selectedYellow = Color(0xFFFFE98A);
const Color _accentYellow = Color(0xFFFFCA05);
const Color _dividerColor = Color(0xFFD9D6E2);

/// Opens the "Filter Activity" bottom sheet modal matching the Figma design.
Future<ActivityFilterState?> showActivityFilterModal(
  BuildContext context, {
  required ActivityFilterState initialState,
}) {
  return showModalBottomSheet<ActivityFilterState>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: _modalNavy.withValues(alpha: 0.35),
    builder: (_) => _ActivityFilterModal(initialState: initialState),
  );
}

/// Opens the "Filter Invitations" bottom sheet modal matching the Figma design.
Future<InvitationFilterState?> showInvitationFilterModal(
  BuildContext context, {
  required InvitationFilterState initialState,
}) {
  return showModalBottomSheet<InvitationFilterState>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: _modalNavy.withValues(alpha: 0.35),
    builder: (_) => _InvitationFilterModal(initialState: initialState),
  );
}

class _ActivityFilterModal extends StatefulWidget {
  const _ActivityFilterModal({required this.initialState});

  final ActivityFilterState initialState;

  @override
  State<_ActivityFilterModal> createState() => _ActivityFilterModalState();
}

class _ActivityFilterModalState extends State<_ActivityFilterModal> {
  static const List<String> _readStatusOptions = [
    'All Notifications',
    'Unread',
    'Read',
  ];

  static const List<String> _activityTypeOptions = [
    'All Activities',
    'Trip Updates',
    'Expense Updates',
    'Member Responses',
    'Group Updates',
    'Itinerary Updates',
  ];

  static const List<String> _sortByOptions = [
    'Newest First',
    'Oldest First',
  ];

  late String _readStatus = widget.initialState.readStatus;
  late String _activityType = widget.initialState.activityType;
  late String _sortBy = widget.initialState.sortBy;

  void _reset() {
    setState(() {
      _readStatus = ActivityFilterState.defaults.readStatus;
      _activityType = ActivityFilterState.defaults.activityType;
      _sortBy = ActivityFilterState.defaults.sortBy;
    });
  }

  void _apply() {
    Navigator.of(context).pop(
      ActivityFilterState(
        readStatus: _readStatus,
        activityType: _activityType,
        sortBy: _sortBy,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _FilterModalShell(
      title: 'Filter Activity',
      onReset: _reset,
      onApply: _apply,
      children: [
        const _FilterSectionHeader(title: 'Read Status'),
        const SizedBox(height: 10),
        ..._readStatusOptions.map(
          (option) => _FilterRadioTile(
            label: option,
            selected: _readStatus == option,
            onTap: () => setState(() => _readStatus = option),
          ),
        ),
        const Divider(height: 24, thickness: 1, color: _dividerColor),
        const _FilterSectionHeader(title: 'Activity Type'),
        const SizedBox(height: 10),
        ..._activityTypeOptions.map(
          (option) => _FilterRadioTile(
            label: option,
            selected: _activityType == option,
            onTap: () => setState(() => _activityType = option),
          ),
        ),
        const Divider(height: 24, thickness: 1, color: _dividerColor),
        const _FilterSectionHeader(title: 'Sort By'),
        const SizedBox(height: 10),
        ..._sortByOptions.map(
          (option) => _FilterRadioTile(
            label: option,
            selected: _sortBy == option,
            onTap: () => setState(() => _sortBy = option),
          ),
        ),
      ],
    );
  }
}

class _InvitationFilterModal extends StatefulWidget {
  const _InvitationFilterModal({required this.initialState});

  final InvitationFilterState initialState;

  @override
  State<_InvitationFilterModal> createState() => _InvitationFilterModalState();
}

class _InvitationFilterModalState extends State<_InvitationFilterModal> {
  static const List<String> _statusOptions = [
    'All Statuses',
    'Pending',
    'Accepted',
    'Declined',
  ];

  static const List<String> _typeOptions = [
    'All Invitations',
    'Group Invitations',
    'Trip Invitations',
  ];

  late String _status = widget.initialState.status;
  late String _type = widget.initialState.type;

  void _reset() {
    setState(() {
      _status = InvitationFilterState.defaults.status;
      _type = InvitationFilterState.defaults.type;
    });
  }

  void _apply() {
    Navigator.of(context).pop(
      InvitationFilterState(
        status: _status,
        type: _type,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _FilterModalShell(
      title: 'Filter Invitations',
      onReset: _reset,
      onApply: _apply,
      children: [
        const _FilterSectionHeader(title: 'Invitation Status'),
        const SizedBox(height: 10),
        ..._statusOptions.map(
          (option) => _FilterRadioTile(
            label: option,
            selected: _status == option,
            onTap: () => setState(() => _status = option),
          ),
        ),
        const Divider(height: 24, thickness: 1, color: _dividerColor),
        const _FilterSectionHeader(title: 'Invitation Type'),
        const SizedBox(height: 10),
        ..._typeOptions.map(
          (option) => _FilterRadioTile(
            label: option,
            selected: _type == option,
            onTap: () => setState(() => _type = option),
          ),
        ),
      ],
    );
  }
}

class _FilterModalShell extends StatelessWidget {
  const _FilterModalShell({
    required this.title,
    required this.children,
    required this.onReset,
    required this.onApply,
  });

  final String title;
  final List<Widget> children;
  final VoidCallback onReset;
  final VoidCallback onApply;

  @override
  Widget build(BuildContext context) {
    final maxHeight = MediaQuery.of(context).size.height * 0.88;

    return Container(
      constraints: BoxConstraints(maxHeight: maxHeight),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(
          top: BorderSide(color: _modalNavy, width: 2),
          left: BorderSide(color: _modalNavy, width: 2),
          right: BorderSide(color: _modalNavy, width: 2),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
            Padding(
              padding: const EdgeInsets.only(top: 12, bottom: 10),
              child: Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: _modalNavy,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),

            // Header row: Title + Boxed Close Button
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontFamily: AppFonts.urbanist,
                        color: _modalNavy,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    behavior: HitTestBehavior.opaque,
                    child: Semantics(
                      button: true,
                      label: 'Close',
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: _modalNavy, width: 1.8),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.close_rounded,
                            size: 18,
                            color: _modalNavy,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Scrollable filter sections
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: children,
                ),
              ),
            ),

            // Bottom action buttons: Reset + Apply Filters
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 18),
              child: Row(
                children: [
                  Expanded(
                    child: AppButton(
                      text: 'Reset',
                      variant: AppButtonVariant.secondary,
                      size: AppButtonSize.small,
                      customHeight: 46,
                      borderRadius: 12,
                      onPressed: onReset,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: AppButton(
                      text: 'Apply Filters',
                      variant: AppButtonVariant.primaryNavy,
                      size: AppButtonSize.small,
                      customHeight: 46,
                      borderRadius: 12,
                      onPressed: onApply,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterSectionHeader extends StatelessWidget {
  const _FilterSectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 15,
          decoration: BoxDecoration(
            color: _accentYellow,
            borderRadius: BorderRadius.circular(2),
            border: Border.all(color: _modalNavy, width: 1),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontFamily: AppFonts.urbanist,
            color: _modalNavy,
            fontSize: 14.5,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _FilterRadioTile extends StatelessWidget {
  const _FilterRadioTile({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: 12,
            vertical: selected ? 10 : 8,
          ),
          decoration: selected
              ? BoxDecoration(
                  color: _selectedYellow,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: _modalNavy, width: 1.8),
                  boxShadow: const [
                    BoxShadow(
                      color: _modalNavy,
                      offset: Offset(0, 2.5),
                      blurRadius: 0,
                    ),
                  ],
                )
              : null,
          child: Row(
            children: [
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: _modalNavy,
                    width: selected ? 1.8 : 1.5,
                  ),
                ),
                child: selected
                    ? Center(
                        child: Container(
                          width: 10,
                          height: 10,
                          decoration: const BoxDecoration(
                            color: _modalNavy,
                            shape: BoxShape.circle,
                          ),
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontFamily: selected ? AppFonts.urbanist : AppFonts.openSans,
                    color: _modalNavy,
                    fontSize: 13.5,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
