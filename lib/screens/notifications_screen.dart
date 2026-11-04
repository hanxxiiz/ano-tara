import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import '../components/invitation_filter.dart';
import '../components/invitation_tile.dart';
import '../components/mark_all_as_read.dart';
import '../components/notification_tile.dart';
import '../theme/app_theme.dart';

/// Activity notification data model
class _ActivityNotificationData {
  _ActivityNotificationData({
    required this.id,
    required this.title,
    required this.description,
    required this.timestamp,
    required this.icon,
    required this.isUnread,
  });

  final String id;
  final String title;
  final String description;
  final String timestamp;
  final IconData icon;
  bool isUnread;
}

/// Invitation data model
class _InvitationData {
  const _InvitationData({
    required this.id,
    required this.title,
    required this.description,
    required this.timestamp,
    required this.status,
  });

  final String id;
  final String title;
  final String description;
  final String timestamp;
  final String status;
}

/// Notifications Screen
///
/// Implements Activity and Invitations tabs matching Wireframe.png, Wireframe-1.png,
/// and Wireframe-2.png.
class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  int _activeTabIndex = 0; // 0: Activity, 1: Invitations
  String _selectedFilterStatus = 'Pending';

  // Sample activity notifications
  late final List<_ActivityNotificationData> _notifications = [
    _ActivityNotificationData(
      id: '1',
      title: 'New expense added',
      description: 'Mika added ₱1,200 for transportation to your Bohol Getaway.',
      timestamp: '2 hours ago',
      icon: Iconsax.wallet_2,
      isUnread: true,
    ),
    _ActivityNotificationData(
      id: '2',
      title: 'Trip details updated',
      description: 'The meeting time for your Cebu City Food Crawl has changed to 9:00 AM.',
      timestamp: 'Yesterday',
      icon: Iconsax.calendar_1,
      isUnread: false,
    ),
  ];

  // Sample invitations data
  final List<_InvitationData> _invitations = const [
    _InvitationData(
      id: 'inv_1',
      title: 'Weekend Wanderers',
      description: 'Group invitation from Louielyn Abella.',
      timestamp: '5 minutes ago',
      status: 'Pending',
    ),
    _InvitationData(
      id: 'inv_2',
      title: 'Bantayan Trip',
      description: 'Trip invitation from Hannah S. Labandero.',
      timestamp: '20 minutes ago',
      status: 'Accepted',
    ),
    _InvitationData(
      id: 'inv_3',
      title: 'Bantayan Trip',
      description: 'Trip invitation from Hannah S. Labandero.',
      timestamp: '20 minutes ago',
      status: 'Rejected',
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

  void _onToggleIndividualNotification(String id) {
    setState(() {
      final notif = _notifications.firstWhere((n) => n.id == id);
      notif.isUnread = !notif.isUnread;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      // =======================================================================
      // A. TOPBAR (Placeholder Only)
      // =======================================================================
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: SafeArea(
          bottom: false,
          // PLACEHOLDER: Replace with the existing Topbar widget.
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(
                bottom: BorderSide(
                  color: Color(0xFF10052F),
                  width: 1.5,
                ),
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 10),
            height: 60,
            child: Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.of(context).maybePop(),
                  icon: const Icon(
                    Icons.arrow_back,
                    color: Color(0xFF0F0331),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 4),
                const Text(
                  'Notifications',
                  style: TextStyle(
                    fontFamily: AppFonts.urbanist,
                    color: Color(0xFF0F0331),
                    fontSize: 20,
                    fontWeight: FontWeight.w800, // Urbanist ExtraBold
                    letterSpacing: -0.3,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),

      // =======================================================================
      // MAIN SCREEN CONTENT
      // =======================================================================
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.symmetric(
            horizontal: 15,
            vertical: 16,
          ),
          children: [
            // =================================================================
            // B. TOGGLE TAB (Placeholder Only)
            // =================================================================
            // PLACEHOLDER: Replace with the existing ToggleTab widget.
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: const Color(0xFF10052F),
                  width: 2.0,
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0xFF10052F),
                    offset: Offset(0, 4),
                    blurRadius: 0,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Row(
                  children: [
                    // Activity Tab Segment
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _activeTabIndex = 0),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 11),
                          color: _activeTabIndex == 0
                              ? const Color(0xFF164D91)
                              : Colors.white,
                          alignment: Alignment.center,
                          child: Text(
                            'Activity',
                            style: TextStyle(
                              fontFamily: AppFonts.urbanist,
                              color: _activeTabIndex == 0
                                  ? Colors.white
                                  : const Color(0xFF0F0331),
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ),
                    // Invitations Tab Segment
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _activeTabIndex = 1),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 11),
                          color: _activeTabIndex == 1
                              ? const Color(0xFF164D91)
                              : Colors.white,
                          alignment: Alignment.center,
                          child: Text(
                            'Invitations',
                            style: TextStyle(
                              fontFamily: AppFonts.urbanist,
                              color: _activeTabIndex == 1
                                  ? Colors.white
                                  : const Color(0xFF0F0331),
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // =================================================================
            // TAB VIEW CONTENT
            // =================================================================
            if (_activeTabIndex == 0)
              _buildActivityTabContent()
            else
              _buildInvitationsTabContent(),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 3. Activity Tab Content
  // ---------------------------------------------------------------------------
  Widget _buildActivityTabContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // A. Mark All as Read
        MarkAllAsRead(
          checked: _isAllRead,
          onChanged: _onToggleMarkAllAsRead,
        ),
        const SizedBox(height: 16),

        // B. Notification Tiles List
        ..._notifications.map((notif) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: NotificationTile(
              title: notif.title,
              description: notif.description,
              timestamp: notif.timestamp,
              icon: notif.icon,
              isUnread: notif.isUnread,
              onTap: () => _onToggleIndividualNotification(notif.id),
            ),
          );
        }),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // 4. Invitations Tab Content
  // ---------------------------------------------------------------------------
  Widget _buildInvitationsTabContent() {
    // Filter invitations matching selected status, or all items if 'All' is selected
    final isAll = _selectedFilterStatus.toLowerCase() == 'all';
    final filteredInvitations = _invitations.where((inv) {
      if (isAll) return true;
      return inv.status.toLowerCase() == _selectedFilterStatus.toLowerCase();
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // A. InvitationFilter Component
        InvitationFilter(
          selectedStatus: _selectedFilterStatus,
          onChanged: (newStatus) {
            setState(() {
              _selectedFilterStatus = newStatus;
            });
          },
        ),
        const SizedBox(height: 16),

        // B. Invitation Tiles List
        if (filteredInvitations.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 32),
            child: Center(
              child: Text(
                isAll ? 'No invitations.' : 'No $_selectedFilterStatus invitations.',
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
                description: inv.description,
                timestamp: inv.timestamp,
                status: inv.status,
              ),
            );
          }),
      ],
    );
  }
}
