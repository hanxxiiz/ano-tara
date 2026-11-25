import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import '../../app_routes.dart';
import '../../components/atoms/app_button.dart';
import '../../components/molecules/app_search_filter_bar.dart';
import '../../components/organisms/app_bottom_navigation.dart';
import '../../components/organisms/app_main_top_bar.dart';
import '../../components/organisms/group_list_card.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import '../../core/theme/smooth_page_route.dart';
import '../../models/group_models.dart';
import 'create_group_screen.dart';
import 'group_details_screen.dart';
import 'group_sheets.dart';

/// 05.01 Groups list, opened from the Groups item in the bottom nav.
class GroupsListScreen extends StatefulWidget {
  const GroupsListScreen({super.key});

  @override
  State<GroupsListScreen> createState() => _GroupsListScreenState();
}

class _GroupsListScreenState extends State<GroupsListScreen> {
  final List<GroupSummary> _groups = GroupSummary.sampleList();

  /// Groups created or joined in this session, so their details survive
  /// reopening.
  final Map<String, GroupDetails> _created = {};
  GroupFilter _filter = const GroupFilter();
  String _query = '';

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _openFilter() async {
    final filter = await showFilterGroupsSheet(context, current: _filter);
    if (!mounted || filter == null) return;
    setState(() => _filter = filter);
  }

  void _openGroup(GroupSummary group) {
    final details =
        _created[group.id] ?? GroupDetails.sample(group.name, role: group.role);
    Navigator.of(
      context,
    ).push(SmoothPageRoute(page: GroupDetailsScreen(group: details)));
  }

  Future<void> _createGroup() async {
    final group = await Navigator.of(
      context,
    ).push<GroupDetails>(SmoothPageRoute(page: const CreateGroupScreen()));
    if (!mounted || group == null) return;
    final summary = GroupSummary.fromDetails(group);
    setState(() {
      _created[group.id] = group;
      _groups.add(summary);
    });
    _openGroup(summary);
  }

  /// Enter code → success or invalid. Try Again on an invalid code reopens
  /// the code sheet; the joined group is added to the list.
  Future<void> _joinWithCode() async {
    while (true) {
      final code = await showJoinGroupSheet(context);
      if (!mounted || code == null) return;

      final match = GroupDetails.findByInviteCode(code);
      if (match == null) {
        final tryAgain = await showInvalidCodeSheet(context);
        if (!mounted || !tryAgain) return;
        continue;
      }

      final group = match.group;
      var summary = _groups.where((g) => g.id == group.id).firstOrNull;
      if (summary == null) {
        summary = GroupSummary.fromDetails(
          group,
          organizerName: match.organizerName,
        );
        setState(() {
          _created[group.id] = group;
          _groups.add(summary!);
        });
      }

      final viewGroup = await showJoinSuccessSheet(
        context,
        groupName: group.name,
      );
      if (!mounted || !viewGroup) return;
      _openGroup(summary);
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    final groups = _filter.apply(_groups, query: _query);

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppMainTopBar(
        onNotificationTap: () =>
            Navigator.of(context).pushNamed(AppRoutes.notifications),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 96),
        children: [
          AppSearchFilterBar(
            hintText: 'Search groups...',
            onChanged: (value) => setState(() => _query = value),
            onFilterTap: _openFilter,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: AppButton(
                  text: 'Create Group',
                  borderRadius: 16,
                  customHeight: 50,
                  iconLeading: const Icon(
                    Iconsax.people,
                    size: 18,
                    color: AppColors.white,
                  ),
                  onPressed: _createGroup,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: AppButton(
                  text: 'Join with Code',
                  variant: AppButtonVariant.secondary,
                  borderRadius: 16,
                  customHeight: 50,
                  iconLeading: const Icon(
                    Iconsax.key,
                    size: 18,
                    color: AppColors.secondaryDark,
                  ),
                  onPressed: _joinWithCode,
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          if (groups.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 40),
              child: Text(
                _groups.isEmpty
                    ? 'You are not in any groups yet.'
                    : 'No groups match your search or filters.',
                textAlign: TextAlign.center,
                style: AppTypography.bodySmall.copyWith(color: AppColors.carla),
              ),
            )
          else
            for (final group in groups)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: GroupListCard(
                  group: group,
                  onTap: () => _openGroup(group),
                ),
              ),
        ],
      ),
      floatingActionButton: Semantics(
        button: true,
        container: true,
        label: 'Group invitations',
        excludeSemantics: true,
        onTap: () => _showMessage('Group invitations are coming soon'),
        child: GestureDetector(
          onTap: () => _showMessage('Group invitations are coming soon'),
          child: Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: AppColors.primaryNavy,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.secondaryDark, width: 2),
              boxShadow: const [
                BoxShadow(
                  color: AppColors.secondaryDark,
                  offset: Offset(0, 4),
                  blurRadius: 0,
                ),
              ],
            ),
            child: const Icon(Iconsax.sms, color: AppColors.white, size: 24),
          ),
        ),
      ),
      bottomNavigationBar: AppBottomNavigation(
        currentIndex: 3,
        onTabSelected: (index) {
          switch (index) {
            case 0:
              Navigator.of(context).popUntil((route) => route.isFirst);
            case 1:
              Navigator.of(context).push(
                SmoothPageRoute(
                  page: GroupDetailsScreen(
                    group: GroupDetails.sample('The Group'),
                  ),
                ),
              );
            case 3:
              break;
            default:
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
}
