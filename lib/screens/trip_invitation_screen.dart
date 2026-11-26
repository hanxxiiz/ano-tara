import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import '../components/atoms/app_button.dart';
import '../components/invitation_hero_avatar.dart';
import '../components/invitation_tile.dart';
import '../components/organisms/app_top_bar.dart';
import '../models/notification_models.dart';
import '../theme/app_theme.dart';
import 'invitation_result_screen.dart';

/// Trip Invitation detail screen matching the Figma design.
class TripInvitationScreen extends StatelessWidget {
  const TripInvitationScreen({
    super.key,
    required this.invitation,
    this.onRespond,
  });

  final InvitationItem invitation;
  final ValueChanged<InvitationStatus>? onRespond;

  static const Color darkNavy = Color(0xFF10052F);
  static const Color inkText = Color(0xFF0F0331);
  static const Color mutedText = Color(0xFF6E6880);
  static const Color yellowAccent = Color(0xFFFFD633);
  static const Color yellowPending = Color(0xFFFAD94E);

  Color _statusBadgeColor(InvitationStatus status) {
    switch (status) {
      case InvitationStatus.accepted:
        return InvitationTile.acceptedBg;
      case InvitationStatus.declined:
        return InvitationTile.declinedBg;
      case InvitationStatus.pending:
        return yellowPending;
    }
  }

  void _handleRespond(BuildContext context, InvitationStatus decision) {
    onRespond?.call(decision);
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => InvitationResultScreen(
          invitationType: InvitationType.trip,
          accepted: decision == InvitationStatus.accepted,
          targetName: invitation.title,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isPending = invitation.status == InvitationStatus.pending;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const AppTopBar(title: 'Trip Invitation'),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Container(height: 1, color: darkNavy),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Centered Hero Avatar + Paper-Plane Badge
                    const Center(
                      child: InvitationHeroAvatar(
                        badgeIcon: Icons.near_me_rounded,
                        size: 98,
                      ),
                    ),
                    const SizedBox(height: 14),

                    // "You're invited!" Heading
                    const Text(
                      "You're invited!",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: AppFonts.urbanist,
                        color: inkText,
                        fontSize: 25,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.4,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Centered rich-text subtitle
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: Text.rich(
                        TextSpan(
                          style: const TextStyle(
                            fontFamily: AppFonts.openSans,
                            color: Color(0xFF3E3752),
                            fontSize: 13,
                            height: 1.4,
                          ),
                          children: [
                            TextSpan(
                              text: invitation.inviterName,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                color: inkText,
                              ),
                            ),
                            TextSpan(
                              text:
                                  ' (${invitation.displayHandle}) invited you to join ${invitation.title}! Get ready to explore, make memories, and enjoy the adventure together.',
                            ),
                          ],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Trip Details Card
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: darkNavy, width: 2),
                        boxShadow: const [
                          BoxShadow(
                            color: darkNavy,
                            offset: Offset(0, 4),
                            blurRadius: 0,
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Card Header: Yellow Calendar-Check Icon + Trip Name + "TRIP DETAILS"
                          Row(
                            children: [
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: yellowAccent,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Center(
                                  child: Icon(
                                    Iconsax.calendar_tick,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      invitation.title,
                                      style: const TextStyle(
                                        fontFamily: AppFonts.urbanist,
                                        color: inkText,
                                        fontSize: 18,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: -0.2,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    const Text(
                                      'TRIP DETAILS',
                                      style: TextStyle(
                                        fontFamily: AppFonts.openSans,
                                        color: mutedText,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: 0.4,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          const Divider(
                            height: 1,
                            thickness: 1,
                            color: Color(0xFFE4E2EC),
                          ),
                          const SizedBox(height: 12),

                          // Key-Value Metadata Rows
                          _TripDetailRow(
                            label: 'Organizer',
                            value: invitation.displayOrganizer,
                          ),
                          const SizedBox(height: 10),
                          _TripDetailRow(
                            label: 'Destination',
                            value: invitation.location ?? 'TBD',
                          ),
                          const SizedBox(height: 10),
                          _TripDetailRow(
                            label: 'Dates',
                            value: invitation.dateRange ?? 'TBD',
                          ),
                          const SizedBox(height: 10),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const SizedBox(
                                width: 105,
                                child: Text(
                                  'Your status',
                                  style: TextStyle(
                                    fontFamily: AppFonts.openSans,
                                    color: mutedText,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              Container(
                                constraints: const BoxConstraints(minWidth: 84),
                                alignment: Alignment.center,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: _statusBadgeColor(invitation.status),
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: Text(
                                  invitation.status.label,
                                  style: const TextStyle(
                                    fontFamily: AppFonts.openSans,
                                    color: Colors.white,
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Action Buttons
                    if (isPending) ...[
                      AppButton(
                        text: 'Accept Invitation',
                        variant: AppButtonVariant.primaryNavy,
                        customHeight: 48,
                        borderRadius: 14,
                        onPressed: () =>
                            _handleRespond(context, InvitationStatus.accepted),
                      ),
                      const SizedBox(height: 10),
                      AppButton(
                        text: 'Decline',
                        variant: AppButtonVariant.secondary,
                        customHeight: 48,
                        borderRadius: 14,
                        onPressed: () =>
                            _handleRespond(context, InvitationStatus.declined),
                      ),
                    ] else
                      AppButton(
                        text: 'Back to Invitations',
                        variant: AppButtonVariant.primaryNavy,
                        customHeight: 48,
                        borderRadius: 14,
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TripDetailRow extends StatelessWidget {
  const _TripDetailRow({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 105,
          child: Text(
            label,
            style: const TextStyle(
              fontFamily: AppFonts.openSans,
              color: Color(0xFF6E6880),
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontFamily: AppFonts.urbanist,
              color: Color(0xFF0F0331),
              fontSize: 13.5,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}
