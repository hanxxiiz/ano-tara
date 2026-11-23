import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import '../components/invitation_filter.dart';
import '../components/invitation_tile.dart';
import '../components/mark_all_as_read.dart';
import '../components/molecules/app_segmented_tabs.dart';
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
  String _activityFilter = 'All';
  String _invitationFilter = 'All';

  late final List<ActivityNotificationItem> _notifications = [
    ActivityNotificationItem(
      id: '1',
      title: 'New expense added',
      description:
          'Mika added ₱1,200 for transportation to your Bohol Getaway.',
      timestamp: '2 hours ago',
      icon: Iconsax.wallet_25,
      isUnread: true,
    ),
    ActivityNotificationItem(
      id: '2',
      title: 'Trip details updated',
      description:
          'The meeting time for your Cebu City Food Crawl has changed to 9:00 AM.',
      timestamp: 'Yesterday',
      icon: Iconsax.calendar5,
      isUnread: false,
    ),
  ];

  late final List<InvitationItem> _invitations = [
    InvitationItem(
      id: 'inv_1',
      title: 'Weekend Wanderers',
      inviterName: 'Louielyn Abella',
      timestamp: '5 minutes ago',
      type: InvitationType.group,
      status: InvitationStatus.pending,
      summary:
          'A crew of weekend explorers planning spontaneous getaways, beach hops, and food crawls around Cebu and nearby islands.',
      memberCount: 6,
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
      timestamp: '10 minutes ago',
      type: InvitationType.trip,
      status: InvitationStatus.pending,
      summary:
          'Join us for a sunny island getaway to Bantayan! Expect white sand beaches, island hopping, and fresh seafood dinners.',
      location: 'Bantayan Island, Cebu',
      dateRange: 'Oct 10 – Oct 15, 2026',
      groupName: 'Weekend Wanderers (6 going)',
      estimatedBudget: '₱4,500 / person',
    ),
    InvitationItem(
      id: 'inv_3',
      title: 'Bantayan Trip',
      inviterName: 'Hannah S. Labandero',
      timestamp: '20 minutes ago',
      type: InvitationType.trip,
      status: InvitationStatus.accepted,
      summary:
          'Join us for a sunny island getaway to Bantayan! Expect white sand beaches, island hopping, and fresh seafood dinners.',
      location: 'Bantayan Island, Cebu',
      dateRange: 'Oct 10 – Oct 15, 2026',
      groupName: 'Weekend Wanderers (6 going)',
      estimatedBudget: '₱4,500 / person',
    ),
    InvitationItem(
      id: 'inv_4',
      title: 'Bantayan Trip',
      inviterName: 'Hannah S. Labandero',
      timestamp: '20 minutes ago',
      type: InvitationType.trip,
      status: InvitationStatus.declined,
      summary:
          'Join us for a sunny island getaway to Bantayan! Expect white sand beaches, island hopping, and fresh seafood dinners.',
      location: 'Bantayan Island, Cebu',
      dateRange: 'Oct 10 – Oct 15, 2026',
      groupName: 'Weekend Wanderers (6 going)',
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
      switch (_activityFilter.toLowerCase()) {
        case 'unread':
          return notif.isUnread;
        case 'read':
          return !notif.isUnread;
        case 'all':
        default:
          return true;
      }
    }).toList();

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
              selectedStatus: _activityFilter,
              options: InvitationFilter.activityOptions,
              onChanged: (newFilter) {
                setState(() {
                  _activityFilter = newFilter;
                });
              },
            ),
          ],
        ),
        const SizedBox(height: 16),

        if (filteredNotifications.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 32),
            child: Center(
              child: Text(
                _activityFilter.toLowerCase() == 'all'
                    ? 'No activity notifications.'
                    : 'No ${_activityFilter.toLowerCase()} notifications.',
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
    final isAll = _invitationFilter.toLowerCase() == 'all';
    final filteredInvitations = _invitations.where((inv) {
      if (isAll) return true;
      return inv.status.label.toLowerCase() == _invitationFilter.toLowerCase();
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
              selectedStatus: _invitationFilter,
              options: InvitationFilter.defaultOptions,
              onChanged: (newStatus) {
                setState(() {
                  _invitationFilter = newStatus;
                });
              },
            ),
          ],
        ),
        const SizedBox(height: 16),

        if (filteredInvitations.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 32),
            child: Center(
              child: Text(
                isAll
                    ? 'No invitations.'
                    : 'No $_invitationFilter invitations.',
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
