import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import '../components/invitation_filter.dart';
import '../components/invitation_tile.dart';
import '../components/mark_all_as_read.dart';
import '../components/molecules/app_segmented_tabs.dart';
import '../components/notification_filter_modals.dart';
import '../components/notification_tile.dart';
import '../components/organisms/app_top_bar.dart';
import '../models/notification_models.dart';
import '../theme/app_theme.dart';
import 'group_invitation_screen.dart';
import 'trip_invitation_screen.dart';

/// Notifications Screen matching Figma `04.01 · Notifications — all activity`
/// and `04.02 · Notifications — invitation list`.
class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({
    super.key,
    this.initialTabIndex = 0,
  });

  /// 0 = Activity, 1 = Invitations
  final int initialTabIndex;

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  static const Color _darkNavy = Color(0xFF10052F);

  late int _activeTabIndex = widget.initialTabIndex;
  ActivityFilterState _activityFilter = ActivityFilterState.defaults;
  InvitationFilterState _invitationFilter = InvitationFilterState.defaults;

  late final List<ActivityNotificationItem> _notifications = [
    ActivityNotificationItem(
      id: '1',
      title: 'New expense added',
      description:
          'Mika added ₱1,200 for transportation to your Bohol Getaway.',
      timestamp: '2 hours ago',
      icon: Iconsax.wallet_25,
      isUnread: true,
      category: ActivityCategory.expenseUpdates,
      createdAt: DateTime(2026, 11, 27, 0, 0),
    ),
    ActivityNotificationItem(
      id: '2',
      title: 'Trip details updated',
      description:
          'The meeting time for your Cebu City Food Crawl has changed to 9:00 AM.',
      timestamp: 'Yesterday',
      icon: Iconsax.calendar5,
      isUnread: false,
      category: ActivityCategory.tripUpdates,
      createdAt: DateTime(2026, 11, 26, 12, 0),
    ),
  ];

  late final List<InvitationItem> _invitations = [
    InvitationItem(
      id: 'inv_1',
      title: 'Weekend Wanderers',
      inviterName: 'Louielyn Abella',
      inviterHandle: '@louielyn.abella',
      organizerName: 'Louielyn Abella',
      timestamp: '5 minutes ago',
      type: InvitationType.group,
      status: InvitationStatus.pending,
      summary:
          'A crew of weekend explorers planning spontaneous getaways, beach hops, and food crawls around Cebu and nearby islands.',
      memberCount: 8,
      plannedTripsCount: 2,
      memberNames: const [
        'Louielyn Abella',
        'Hannah S. Labandero',
        'Mika Santos',
        'Rico Tan',
        'Carla Reyes',
        'Jude Lim',
      ],
    ),
    InvitationItem(
      id: 'inv_2',
      title: 'Bantayan Trip',
      inviterName: 'Hannah S. Labandero',
      inviterHandle: '@hannah.labandero',
      organizerName: 'Hannah S. Labandero',
      timestamp: '10 minutes ago',
      type: InvitationType.trip,
      status: InvitationStatus.pending,
      summary:
          'Get ready to explore, make memories, and enjoy the adventure together.',
      location: 'Bantayan Island, Cebu',
      dateRange: 'June 8 - June 10',
      groupName: 'Weekend Wanderers (8 going)',
      estimatedBudget: '₱4,500 / person',
    ),
    InvitationItem(
      id: 'inv_3',
      title: 'Bantayan Trip',
      inviterName: 'Hannah S. Labandero',
      inviterHandle: '@hannah.labandero',
      organizerName: 'Hannah S. Labandero',
      timestamp: '20 minutes ago',
      type: InvitationType.trip,
      status: InvitationStatus.accepted,
      summary:
          'Get ready to explore, make memories, and enjoy the adventure together.',
      location: 'Bantayan Island, Cebu',
      dateRange: 'June 8 - June 10',
      groupName: 'Weekend Wanderers (8 going)',
      estimatedBudget: '₱4,500 / person',
    ),
    InvitationItem(
      id: 'inv_4',
      title: 'Bantayan Trip',
      inviterName: 'Hannah S. Labandero',
      inviterHandle: '@hannah.labandero',
      organizerName: 'Hannah S. Labandero',
      timestamp: '20 minutes ago',
      type: InvitationType.trip,
      status: InvitationStatus.declined,
      summary:
          'Get ready to explore, make memories, and enjoy the adventure together.',
      location: 'Bantayan Island, Cebu',
      dateRange: 'June 8 - June 10',
      groupName: 'Weekend Wanderers (8 going)',
      estimatedBudget: '₱4,500 / person',
    ),
  ];

  bool get _isAllRead => _notifications.every((n) => !n.isUnread);

  void _onToggleMarkAllAsRead(bool checked) {
    setState(() {
      for (final n in _notifications) {
        n.isUnread = !checked;
      }
    });
  }

  void _onTapNotification(String id) {
    setState(() {
      final notif = _notifications.firstWhere((n) => n.id == id);
      notif.isUnread = !notif.isUnread;
    });
  }

  Future<void> _openActivityFilterModal() async {
    final result = await showActivityFilterModal(
      context,
      initialState: _activityFilter,
    );
    if (result != null && mounted) {
      setState(() => _activityFilter = result);
    }
  }

  Future<void> _openInvitationFilterModal() async {
    final result = await showInvitationFilterModal(
      context,
      initialState: _invitationFilter,
    );
    if (result != null && mounted) {
      setState(() => _invitationFilter = result);
    }
  }

  void _openInvitation(InvitationItem invitation) {
    final Widget destination = invitation.type == InvitationType.group
        ? GroupInvitationScreen(
            invitation: invitation,
            onRespond: (newStatus) {
              setState(() {
                invitation.status = newStatus;
              });
            },
          )
        : TripInvitationScreen(
            invitation: invitation,
            onRespond: (newStatus) {
              setState(() {
                invitation.status = newStatus;
              });
            },
          );

    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => destination),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const AppTopBar(title: 'Notifications'),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Container(height: 1, color: _darkNavy),
            Expanded(
              child: ListView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 15, vertical: 16),
                children: [
                  // Segmented Tabs (Activity | Invitations)
                  AppSegmentedTabs<int>(
                    tabs: const [0, 1],
                    selectedTab: _activeTabIndex,
                    labelBuilder: (tab) =>
                        tab == 0 ? 'Activity' : 'Invitations',
                    onTabChanged: (tab) =>
                        setState(() => _activeTabIndex = tab),
                  ),
                  const SizedBox(height: 16),

                  if (_activeTabIndex == 0)
                    _buildActivityTabContent()
                  else
                    _buildInvitationsTabContent(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityTabContent() {
    final filteredNotifications = _notifications.where((notif) {
      // Read Status filter
      switch (_activityFilter.readStatus) {
        case 'Unread':
          if (!notif.isUnread) return false;
          break;
        case 'Read':
          if (notif.isUnread) return false;
          break;
        case 'All Notifications':
        default:
          break;
      }

      // Activity Type filter
      if (_activityFilter.activityType != 'All Activities' &&
          notif.category.label != _activityFilter.activityType) {
        return false;
      }

      return true;
    }).toList();

    // Sort By
    filteredNotifications.sort((a, b) {
      if (_activityFilter.sortBy == 'Oldest First') {
        return a.createdAt.compareTo(b.createdAt);
      }
      return b.createdAt.compareTo(a.createdAt);
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Mark all as read (left) + Filter (right) matching Figma 04.01
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: MarkAllAsRead(
                  checked: _isAllRead,
                  onChanged: _onToggleMarkAllAsRead,
                ),
              ),
            ),
            const SizedBox(width: 8),
            InvitationFilter(
              key: const Key('activity_filter'),
              hasActiveFilters: !_activityFilter.isDefault,
              onTap: _openActivityFilterModal,
            ),
          ],
        ),
        const SizedBox(height: 16),

        if (filteredNotifications.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 32),
            child: Center(
              child: Text(
                _activityFilter.isDefault
                    ? 'No activity notifications.'
                    : 'No matching activity notifications.',
                style: const TextStyle(
                  fontFamily: AppFonts.openSans,
                  color: Color(0xFF0F0331),
                  fontSize: 14,
                ),
              ),
            ),
          )
        else
          ...filteredNotifications.map((notif) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: NotificationTile(
                title: notif.title,
                description: notif.description,
                timestamp: notif.timestamp,
                icon: notif.icon,
                isUnread: notif.isUnread,
                onTap: () => _onTapNotification(notif.id),
              ),
            );
          }),
      ],
    );
  }

  Widget _buildInvitationsTabContent() {
    final filteredInvitations = _invitations.where((inv) {
      // Invitation Status filter
      if (_invitationFilter.status != 'All Statuses' &&
          inv.status.label.toLowerCase() !=
              _invitationFilter.status.toLowerCase()) {
        return false;
      }

      // Invitation Type filter
      if (_invitationFilter.type == 'Group Invitations' &&
          inv.type != InvitationType.group) {
        return false;
      }
      if (_invitationFilter.type == 'Trip Invitations' &&
          inv.type != InvitationType.trip) {
        return false;
      }

      return true;
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Right-aligned Filter matching Figma 04.02
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            InvitationFilter(
              key: const Key('invitation_filter'),
              hasActiveFilters: !_invitationFilter.isDefault,
              onTap: _openInvitationFilterModal,
            ),
          ],
        ),
        const SizedBox(height: 16),

        if (filteredInvitations.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 32),
            child: Center(
              child: Text(
                _invitationFilter.isDefault
                    ? 'No invitations.'
                    : 'No matching invitations.',
                style: const TextStyle(
                  fontFamily: AppFonts.openSans,
                  color: Color(0xFF0F0331),
                  fontSize: 14,
                ),
              ),
            ),
          )
        else
          ...filteredInvitations.map((inv) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: InvitationTile(
                title: inv.title,
                description: inv.cardDescription,
                timestamp: inv.timestamp,
                status: inv.status.label,
                onTap: () => _openInvitation(inv),
              ),
            );
          }),
      ],
    );
  }
}
