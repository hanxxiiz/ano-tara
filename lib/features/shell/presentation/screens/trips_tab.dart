import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../components/atoms/app_avatar.dart';
import '../../../../components/atoms/app_icon.dart';
import '../../../../components/molecules/app_search_filter_bar.dart';
import '../../../../components/organisms/app_main_top_bar.dart';
import '../../../../components/molecules/app_filter_popup.dart';

import '../../../../features/groups/presentation/data/group_role.dart';

class TripsTab extends StatefulWidget {
  final VoidCallback? onNavigateToProfile;

  const TripsTab({super.key, this.onNavigateToProfile});

  @override
  State<TripsTab> createState() => _TripsTabState();
}

class _TripsTabState extends State<TripsTab> {
  final _searchController = TextEditingController();
  String _query = '';
  GroupRole? _roleFilter;
  bool _filterOpen = false;

  List<Map<String, dynamic>> get _visibleGroups {
    final q = _query.trim().toLowerCase();
    if (_roleFilter == null) return _groups;
    return _groups.where((g) {
      final roleOk = _roleFilter == null || g['role'] == _roleFilter;
      final nameOk =
          q.isEmpty || (g['name'] as String).toLowerCase().contains(q);
      return roleOk && nameOk;
    }).toList();
  }

  void _toggleFilter() {
    FocusScope.of(context).unfocus();
    setState(() => _filterOpen = !_filterOpen);
  }

  void _selectFilter(GroupRole? role) {
    setState(() {
      _roleFilter = role;
      _filterOpen = false;
    });
  }

  final List<Map<String, dynamic>> _groups = [
    {
      'name': 'Trip to Bantayan',
      'organizer': 'Louie Abella',
      'nextTrip': 'Next: Bantayan Trip',
      'role': GroupRole.organizer,
    },
    {
      'name': 'The Group',
      'organizer': 'Carla Santos',
      'nextTrip': 'Next: Bantayan Trip',
      'role': GroupRole.member,
    },
    {
      'name': 'Weekend Wanderers',
      'organizer': 'You Organizer',
      'nextTrip': 'Next: Bantayan Trip',
      'role': GroupRole.organizer,
    },
    {
      'name': 'Blackpink',
      'organizer': 'Sarah Jenkins',
      'nextTrip': 'Next: Cebu Food Crawl',
      'role': GroupRole.member,
    },
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final visible = _visibleGroups;

    return Scaffold(
      backgroundColor: AppColors.white,
      // Fixed Non-Scrollable Top Bar
      appBar: AppMainTopBar(
        onProfileTap: widget.onNavigateToProfile,
        onNotificationTap: () =>
            Navigator.pushNamed(context, AppRoutes.invitations),
      ),
      body: SafeArea(
        top: false,
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // M02 Search & Filter Bar Molecule
                  AppSearchFilterBar(
                    hintText: 'Search trips...',
                    controller: _searchController,
                    onChanged: (val) =>
                        setState(() => _filterOpen = !_filterOpen),
                    onFilterTap: _toggleFilter,
                  ),
                  const SizedBox(height: 16),

                  // Create a Group Button
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        Navigator.pushNamed(context, AppRoutes.createGroup);
                      },
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        width: double.infinity,
                        height: 52,
                        decoration: BoxDecoration(
                          color: AppColors.primaryNavy,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: AppColors.secondaryDark,
                            width: 2.0,
                          ),
                          boxShadow: const [
                            BoxShadow(
                              color: AppColors.secondaryDark,
                              offset: Offset(0, 4),
                              blurRadius: 0,
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const AppIcon(
                              Iconsax.profile_2user5,
                              color: AppColors.white,
                              size: 24,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              'Create a Group',
                              style: AppTypography.buttonLarge.copyWith(
                                color: AppColors.white,
                                fontWeight: FontWeight.w800,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  if (_visibleGroups.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 32),
                      child: Center(
                        child: Text(
                          'No groups found.',
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.carla,
                          ),
                        ),
                      ),
                    )
                  else
                    // Group Cards List
                    for (final group in _visibleGroups) ...[
                      _buildGroupCard(
                        name: group['name'] as String,
                        organizer:
                            group['organizer'] as String, // organizer name
                        nextTrip: group['nextTrip'] as String,
                        role: group['role'] as GroupRole,
                      ),
                      const SizedBox(height: 16),
                    ],
                ],
              ),
            ),
            // Outside-tap barrier: closes the popup and blocks taps on cards
            if (_filterOpen)
              Positioned.fill(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => setState(() => _filterOpen = false),
                ),
              ),
            if (_filterOpen)
              Positioned(
                top: 48,
                right: 40,
                child: AppFilterPopup<GroupRole?>(
                  options: const [null, GroupRole.organizer, GroupRole.member],
                  selected: _roleFilter,
                  labelBuilder: (r) => r == null ? 'All Groups' : r.label,
                  onSelected: (role) {
                    setState(() {
                      _roleFilter = role;
                      _filterOpen = false;
                    });
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildGroupCard({
    required String name,
    required String organizer,
    required String nextTrip,
    required GroupRole role,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(
            context,
            AppRoutes.groupDetail,
            arguments: GroupDetailArgs(name, role),
          );
        },
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.secondaryDark, width: 2.0),
            boxShadow: const [
              BoxShadow(
                color: AppColors.secondaryDark,
                offset: Offset(0, 4),
                blurRadius: 0,
              ),
            ],
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Row(
                crossAxisAlignment:
                    CrossAxisAlignment.start, // fixes the top alignment
                children: [
                  // Orange square (unchanged)
                  Container(
                    width: 86,
                    height: 86,
                    decoration: BoxDecoration(
                      color: AppColors.primaryOrange,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Center(
                      child: AppIcon(
                        Iconsax.profile_2user5,
                        color: AppColors.white,
                        size: 38,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Only the text block is padded, so it clears the button
                        Padding(
                          padding: const EdgeInsets.only(right: 56),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTypography.titleLarge.copyWith(
                                  color: AppColors.secondaryDark,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 16,
                                  height: 1.1,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                organizer,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTypography.caption.copyWith(
                                  color: AppColors.carla,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                role.label,
                                style: AppTypography.caption.copyWith(
                                  color: AppColors.secondaryDark,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 11,
                                ),
                              ),
                              const SizedBox(height: 6),
                              const AppMemberTokenCluster(
                                extraCount: 3,
                                size: 16,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Next pill: full width of the text column, so it reaches the
                        // card's right inner padding
                        Container(
                          width: double.infinity,
                          alignment: Alignment.centerLeft,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFD4DEE8),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            nextTrip,
                            style: AppTypography.caption.copyWith(
                              color: AppColors.secondaryDark,
                              fontWeight: FontWeight.w600,
                              fontSize: 10.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              // Chat button pinned to the top-right corner
              Positioned(
                top: 0,
                right: 0,
                child: GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      AppRoutes.groupChat,
                      arguments: name,
                    );
                  },
                  child: Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: AppColors.primaryNavy,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.secondaryDark,
                        width: 2.0,
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color: AppColors.secondaryDark,
                          offset: Offset(0, 3),
                          blurRadius: 0,
                        ),
                      ],
                    ),
                    child: const Center(
                      child: AppIcon(
                        Iconsax.sms5,
                        color: AppColors.white,
                        size: 22,
                      ),
                    ),
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
