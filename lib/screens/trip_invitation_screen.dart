import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import '../components/atoms/app_button.dart';
import '../components/atoms/app_icon.dart';
import '../components/invitation_tile.dart';
import '../components/organisms/app_top_bar.dart';
import '../models/notification_models.dart';
import '../theme/app_theme.dart';
import 'invitation_result_screen.dart';

/// Trip Invitation detail screen allowing the user to review trip metadata
/// and Accept or Decline the invitation.
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
  static const Color mutedText = Color(0xFF4B4265);
  static const Color orangeAccent = Color(0xFFE24B27);

  Color _statusBadgeColor(InvitationStatus status) {
    switch (status) {
      case InvitationStatus.accepted:
        return InvitationTile.acceptedBg;
      case InvitationStatus.declined:
        return InvitationTile.declinedBg;
      case InvitationStatus.pending:
        return InvitationTile.pendingBg;
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Main Trip Invitation Card
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: darkNavy, width: 2),
                        boxShadow: const [
                          BoxShadow(
                            color: darkNavy,
                            offset: Offset(0, 4),
                            blurRadius: 0,
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Trip icon, name, status pill
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 58,
                                height: 58,
                                decoration: BoxDecoration(
                                  color: orangeAccent,
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: const Center(
                                  child: AppIcon(
                                    Iconsax.map_15,
                                    color: Colors.white,
                                    size: 28,
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
                                        fontSize: 20,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: -0.3,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 14,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color:
                                            _statusBadgeColor(invitation.status),
                                        borderRadius:
                                            BorderRadius.circular(999),
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
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Container(
                            height: 1.5,
                            color: darkNavy.withValues(alpha: 0.12),
                          ),
                          const SizedBox(height: 14),

                          // Inviter metadata
                          Row(
                            children: [
                              const AppIcon(
                                Iconsax.user5,
                                size: 17,
                                color: inkText,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Invited by ${invitation.inviterName}',
                                  style: const TextStyle(
                                    fontFamily: AppFonts.openSans,
                                    color: inkText,
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              Text(
                                invitation.timestamp,
                                style: const TextStyle(
                                  fontFamily: AppFonts.openSans,
                                  color: mutedText,
                                  fontSize: 11.5,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),

                          // Trip description
                          Text(
                            invitation.summary,
                            style: const TextStyle(
                              fontFamily: AppFonts.openSans,
                              color: inkText,
                              fontSize: 13.5,
                              height: 1.45,
                            ),
                          ),
                          const SizedBox(height: 18),

                          // Trip metadata rows
                          if (invitation.location != null)
                            _TripMetaRow(
                              icon: Iconsax.location5,
                              label: 'Destination',
                              value: invitation.location!,
                            ),
                          if (invitation.dateRange != null)
                            _TripMetaRow(
                              icon: Iconsax.calendar5,
                              label: 'Dates',
                              value: invitation.dateRange!,
                            ),
                          if (invitation.groupName != null)
                            _TripMetaRow(
                              icon: Iconsax.profile_2user5,
                              label: 'Group',
                              value: invitation.groupName!,
                            ),
                          if (invitation.estimatedBudget != null)
                            _TripMetaRow(
                              icon: Iconsax.wallet_25,
                              label: 'Estimated Budget',
                              value: invitation.estimatedBudget!,
                              isLast: true,
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Informational note
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8F8FA),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: darkNavy.withValues(alpha: 0.2),
                          width: 1.2,
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.info_outline_rounded,
                            size: 18,
                            color: mutedText,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              isPending
                                  ? 'Accepting confirms you as Going for ${invitation.title}. Declining updates your RSVP to Not Going.'
                                  : 'You have already ${invitation.status.label.toLowerCase()} this trip invitation.',
                              style: const TextStyle(
                                fontFamily: AppFonts.openSans,
                                color: mutedText,
                                fontSize: 12.5,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Bottom Actions
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
              child: isPending
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        AppButton(
                          text: 'Accept',
                          variant: AppButtonVariant.primaryNavy,
                          customHeight: 52,
                          borderRadius: 16,
                          onPressed: () =>
                              _handleRespond(context, InvitationStatus.accepted),
                        ),
                        const SizedBox(height: 12),
                        AppButton(
                          text: 'Decline',
                          variant: AppButtonVariant.secondary,
                          customHeight: 52,
                          borderRadius: 16,
                          onPressed: () =>
                              _handleRespond(context, InvitationStatus.declined),
                        ),
                      ],
                    )
                  : AppButton(
                      text: 'Back to Invitations',
                      variant: AppButtonVariant.primaryNavy,
                      customHeight: 52,
                      borderRadius: 16,
                      onPressed: () => Navigator.of(context).pop(),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TripMetaRow extends StatelessWidget {
  const _TripMetaRow({
    required this.icon,
    required this.label,
    required this.value,
    this.isLast = false,
  });

  final IconData icon;
  final String label;
  final String value;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 12),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: const Color(0xFFE8EEF5),
              borderRadius: BorderRadius.circular(9),
              border: Border.all(color: const Color(0xFF10052F), width: 1.2),
            ),
            child: Center(
              child: AppIcon(icon, size: 17, color: const Color(0xFF144885)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontFamily: AppFonts.openSans,
                    color: Color(0xFF868097),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontFamily: AppFonts.urbanist,
                    color: Color(0xFF0F0331),
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
