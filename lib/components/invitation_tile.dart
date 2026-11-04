import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// InvitationTile component
///
/// Reusable card displaying an invitation:
/// - Invitation title in Urbanist ExtraBold on the top-left
/// - Pill-shaped status badge on the top-right (Pending, Accepted, Rejected)
/// - Description in Open Sans
/// - Timestamp below description in Open Sans
class InvitationTile extends StatelessWidget {
  const InvitationTile({
    super.key,
    required this.title,
    required this.description,
    required this.timestamp,
    required this.status,
    this.onTap,
  });

  final String title;
  final String description;
  final String timestamp;
  final String status;
  final VoidCallback? onTap;

  static const Color darkNavy = Color(0xFF10052F);
  static const Color textColor = Color(0xFF0F0331);

  // Status Badge Colors as specified in the Design System
  static const Color pendingBg = Color(0xFFFFEA87);
  static const Color acceptedBg = Color(0xFF89A3C1);
  static final Color rejectedBg = const Color(0xFFE24B27).withValues(alpha: 0.75);

  Color _getStatusBackgroundColor(String status) {
    switch (status.trim().toLowerCase()) {
      case 'accepted':
        return acceptedBg;
      case 'rejected':
        return rejectedBg;
      case 'pending':
      default:
        return pendingBg;
    }
  }

  @override
  Widget build(BuildContext context) {
    final badgeColor = _getStatusBackgroundColor(status);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: darkNavy,
            width: 2.0,
          ),
          boxShadow: const [
            BoxShadow(
              color: darkNavy,
              offset: Offset(0, 4),
              blurRadius: 0,
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: Title and Status Badge
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontFamily: AppFonts.urbanist,
                      color: textColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w800, // Urbanist ExtraBold
                      letterSpacing: -0.2,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Pill-shaped status badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  decoration: BoxDecoration(
                    color: badgeColor,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    status,
                    style: const TextStyle(
                      fontFamily: AppFonts.openSans,
                      color: Colors.white,
                      fontSize: 11.5,
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Description in Open Sans
            Text(
              description,
              style: const TextStyle(
                fontFamily: AppFonts.openSans,
                color: textColor,
                fontSize: 12.5,
                fontWeight: FontWeight.w400, // Open Sans Regular
                height: 1.35,
              ),
            ),
            const SizedBox(height: 8),

            // Timestamp in Open Sans
            Text(
              timestamp,
              style: const TextStyle(
                fontFamily: AppFonts.openSans,
                color: textColor,
                fontSize: 11.5,
                fontWeight: FontWeight.w400, // Open Sans Regular
              ),
            ),
          ],
        ),
      ),
    );
  }
}
