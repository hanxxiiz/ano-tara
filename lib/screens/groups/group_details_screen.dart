import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import '../../app_routes.dart';
import '../../components/molecules/app_segmented_tabs.dart';
import '../../components/organisms/app_bottom_navigation.dart';
import '../../components/atoms/app_button.dart';
import '../../components/organisms/app_main_top_bar.dart';
import '../../components/organisms/availability_calendar.dart';
import '../../components/organisms/group_header_organism.dart';
import '../../components/organisms/group_trip_card.dart';
import '../../components/molecules/app_search_filter_bar.dart';
import '../../components/organisms/group_member_card.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import '../../core/theme/smooth_page_route.dart';
import '../../models/group_models.dart';
import 'edit_group_screen.dart';
import 'group_sheets.dart';
import 'groups_list_screen.dart';

enum GroupTab { trips, availability, members }

/// 05.03 Group details: header card plus Trips / Availability / Members tabs.
/// Tabs are sibling destinations that swap content in place.
class GroupDetailsScreen extends StatefulWidget {
  final GroupDetails group;
  final GroupTab initialTab;

  /// Trip shown in the header, e.g. the trip tapped on Home.
  final String? focusedTripId;

  const GroupDetailsScreen({
    super.key,
    required this.group,
    this.initialTab = GroupTab.trips,
    this.focusedTripId,
  });

  @override
  State<GroupDetailsScreen> createState() => _GroupDetailsScreenState();
}

class _GroupDetailsScreenState extends State<GroupDetailsScreen> {
  late GroupDetails _group = widget.group;
  late GroupTab _tab = widget.initialTab;
  late String? _focusedTripId = widget.focusedTripId;

  /// Trip shown in the header, chosen on Home or by tapping a trip card.
  GroupTrip? get _focusedTrip {
    for (final trip in _group.trips) {
      if (trip.id == _focusedTripId) return trip;
    }
    return null;
  }

  TripFilter _tripFilter = const TripFilter();
  MemberFilter _memberFilter = const MemberFilter();
  final _memberSearchController = TextEditingController();
  String _memberQuery = '';
  DateTime _availabilityMonth = DateTime(
    DateTime.now().year,
    DateTime.now().month,
  );

  @override
  void dispose() {
    _memberSearchController.dispose();
    super.dispose();
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _openTripFilter() async {
    final filter = await showFilterTripsSheet(context, current: _tripFilter);
    if (filter != null) setState(() => _tripFilter = filter);
  }

  Future<void> _openMemberFilter() async {
    final filter = await showFilterMembersSheet(
      context,
      current: _memberFilter,
    );
    if (filter != null) setState(() => _memberFilter = filter);
  }

  Future<void> _editMyAvailability() async {
    final dates = await showMyAvailabilitySheet(
      context,
      groupName: _group.name,
      initialMonth: _availabilityMonth,
      selected: _group.myAvailability,
    );
    if (!mounted || dates == null) return;
    setState(() => _group = _group.withMyAvailability(dates));
    _showMessage('Your availability was updated');
  }

  Future<void> _confirmRemoveMember(GroupMember member) async {
    if (!_group.isOrganizer) return;
    final confirmed = await showRemoveMemberSheet(
      context,
      memberName: member.name,
    );
    if (!mounted || !confirmed) return;
    setState(() {
      _group = _group.copyWith(
        members: [
          for (final m in _group.members)
            if (m.id != member.id) m,
        ],
      );
    });
    _showMessage('${member.name} was removed from the group');
  }

  Future<void> _openGroupActions() async {
    if (!_group.isOrganizer) return;
    final action = await showGroupActionsSheet(context);
    if (!mounted || action == null) return;

    switch (action) {
      case GroupAction.editGroup:
        final updated = await Navigator.of(context).push<GroupDetails>(
          SmoothPageRoute(page: EditGroupScreen(group: _group)),
        );
        if (!mounted || updated == null) return;
        setState(() => _group = updated);
        _showMessage('Group details updated');
      case GroupAction.inviteMembers:
        final people = await showInviteMembersSheet(
          context,
          excludeIds: {for (final m in _group.members) m.id},
        );
        if (!mounted || people == null || people.isEmpty) return;
        setState(() => _group = _group.withInvited(people));
        _showMessage(
          people.length == 1
              ? 'Invitation sent to ${people.single.name}'
              : 'Invitations sent to ${people.length} people',
        );
      case GroupAction.inviteCode:
        await showShareGroupCodeSheet(
          context,
          code: _group.inviteCode,
          onCodeChanged: (code) =>
              setState(() => _group = _group.copyWith(inviteCode: code)),
        );
      case GroupAction.deleteGroup:
        final confirmed = await showDeleteGroupSheet(
          context,
          groupName: _group.name,
        );
        if (!mounted || !confirmed) return;
        _showMessage('"${_group.name}" was deleted');
        Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppMainTopBar(
        onNotificationTap: () =>
            Navigator.of(context).pushNamed(AppRoutes.notifications),
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 13, 16, 24),
          children: [
            GroupHeaderOrganism(
              // The selected trip takes over the header; otherwise the group.
              groupName: _focusedTrip?.title ?? _group.name,
              isOrganizer: _group.isOrganizer,
              memberNames: _focusedTrip?.memberNames ?? _group.memberNames,
              onPlanTripTap: () => _showMessage('Plan a Trip is coming soon'),
              onMenuTap: _openGroupActions,
            ),
            const SizedBox(height: 18),
            AppSegmentedTabs<GroupTab>(
              tabs: GroupTab.values,
              selectedTab: _tab,
              labelBuilder: (tab) => switch (tab) {
                GroupTab.trips => 'Trips',
                GroupTab.availability => 'Availability',
                GroupTab.members => 'Members',
              },
              onTabChanged: (tab) => setState(() => _tab = tab),
            ),
            const SizedBox(height: 18),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: KeyedSubtree(
                key: ValueKey(_tab),
                child: switch (_tab) {
                  GroupTab.trips => _buildTripsTab(),
                  GroupTab.availability => _buildAvailabilityTab(),
                  GroupTab.members => _buildMembersTab(),
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: AppBottomNavigation(
        // Matches the design: group pages sit under the Trips tab.
        currentIndex: 1,
        onTabSelected: (index) {
          if (index == 0) {
            Navigator.of(context).popUntil((route) => route.isFirst);
          } else if (index == 3) {
            Navigator.of(
              context,
            ).push(SmoothPageRoute(page: const GroupsListScreen()));
          } else if (index != 1) {
            const destinations = [
              'Home',
              'Trips',
              'Create trip',
              'Groups',
              'Profile',
            ];
            _showMessage('${destinations[index]} tapped');
          }
        },
      ),
    );
  }

  Widget _buildMembersTab() {
    final members = _memberFilter.apply(_group.members, query: _memberQuery);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 4),
        AppSearchFilterBar(
          hintText: 'Search members...',
          controller: _memberSearchController,
          onChanged: (value) => setState(() => _memberQuery = value),
          onFilterTap: _openMemberFilter,
        ),
        const SizedBox(height: 24),
        if (members.isEmpty)
          _EmptyState(
            message: _group.members.isEmpty
                ? 'No members in this group yet.'
                : 'No members match your search or filters.',
          )
        else
          for (final member in members)
            Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: GroupMemberCard(
                member: member,
                // Organizer-only; organizers cannot remove themselves.
                onRemove: _group.isOrganizer && !member.isCurrentUser
                    ? () => _confirmRemoveMember(member)
                    : null,
              ),
            ),
      ],
    );
  }

  Widget _buildAvailabilityTab() {
    // Pending invitees can't mark dates yet, so they don't count.
    final total = _group.members.where((m) => !m.isPending).length;
    final bestDates = _group.bestDates(_availabilityMonth);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            AvailabilityMonthNav(
              month: _availabilityMonth,
              onPrevious: () => setState(
                () => _availabilityMonth = DateTime(
                  _availabilityMonth.year,
                  _availabilityMonth.month - 1,
                ),
              ),
              onNext: () => setState(
                () => _availabilityMonth = DateTime(
                  _availabilityMonth.year,
                  _availabilityMonth.month + 1,
                ),
              ),
            ),
            const Spacer(),
            _FilterChipButton(
              isActive: false,
              semanticLabel: 'Filter availability',
              onTap: () => _showMessage('Availability filters are coming soon'),
            ),
          ],
        ),
        const SizedBox(height: 10),
        AvailabilityCalendar(
          month: _availabilityMonth,
          dayStyle: (day) =>
              AvailabilityDayStyle.heat(_group.availableOn(day).length, total),
          dayLabel: (day) =>
              '${_group.availableOn(day).length} of $total available',
        ),
        const SizedBox(height: 18),
        AppButton(
          text: 'Edit Availability',
          variant: AppButtonVariant.primaryOrange,
          borderRadius: 16,
          customHeight: 50,
          onPressed: _editMyAvailability,
        ),
        const SizedBox(height: 28),
        Text(
          'Best Dates',
          style: AppTypography.h3.copyWith(
            color: AppColors.secondaryDark,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 14),
        if (bestDates.isEmpty)
          const _EmptyState(
            message: 'No one has marked their availability this month yet.',
          )
        else
          for (final date in bestDates)
            Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: BestDateCard(
                date: date,
                availableNames: [
                  for (final m in _group.availableOn(date)) m.name,
                ],
                totalMembers: total,
              ),
            ),
      ],
    );
  }

  Widget _buildTripsTab() {
    final trips = _tripFilter.apply(_group.trips);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: _FilterChipButton(
            isActive: !_tripFilter.isDefault,
            onTap: _openTripFilter,
          ),
        ),
        const SizedBox(height: 14),
        if (trips.isEmpty)
          _EmptyState(
            message: _group.trips.isEmpty
                ? 'No trips planned for this group yet.'
                : 'No trips match these filters.',
          )
        else
          for (final trip in trips)
            Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: GroupTripCard(
                trip: trip,
                onTap: () => setState(() => _focusedTripId = trip.id),
                onArrowTap: _group.isOrganizer ? _openGroupActions : null,
              ),
            ),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String message;

  const _EmptyState({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.secondaryDark, width: 1.5),
      ),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: AppTypography.bodySmall.copyWith(color: AppColors.carla),
      ),
    );
  }
}

class _FilterChipButton extends StatelessWidget {
  final bool isActive;
  final String semanticLabel;
  final VoidCallback onTap;

  const _FilterChipButton({
    required this.isActive,
    required this.onTap,
    this.semanticLabel = 'Filter trips',
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: isActive ? '$semanticLabel, filters applied' : semanticLabel,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Container(
            constraints: const BoxConstraints(minWidth: 102, minHeight: 28),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 3),
            decoration: BoxDecoration(
              color: AppColors.secondaryLight,
              borderRadius: BorderRadius.circular(9),
              border: Border.all(color: AppColors.secondaryDark, width: 2),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Iconsax.setting_4,
                  size: 15,
                  color: AppColors.secondaryDark,
                ),
                const SizedBox(width: 8),
                Text(
                  'Filter',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.secondaryDark,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
                if (isActive) ...[
                  const SizedBox(width: 6),
                  Container(
                    width: 7,
                    height: 7,
                    decoration: const BoxDecoration(
                      color: AppColors.primaryOrange,
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
