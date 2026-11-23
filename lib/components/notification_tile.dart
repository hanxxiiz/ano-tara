import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'atoms/app_icon.dart';

/// NotificationTile component matching Figma `04.01 · Notifications — all activity`.
///
/// Displays an activity notification card:
/// - Terracotta orange (`#E24B27`) rounded square icon container on the left
/// - Title in Urbanist ExtraBold
/// - Description and timestamp in Open Sans
/// - Circular yellow unread badge (`#F9CF09`) with dark navy outline in top-right
class NotificationTile extends StatelessWidget {
  const NotificationTile({
    super.key,
    required this.title,
    required this.description,
    required this.timestamp,
    required this.icon,
    this.isUnread = false,
    this.onTap,
  });

  final String title;
  final String description;
  final String timestamp;
  final IconData icon;
  final bool isUnread;
  final VoidCallback? onTap;

  static const Color darkNavy = Color(0xFF10052F);
  static const Color iconContainerColor = Color(0xFFE24B27);
  static const Color textColor = Color(0xFF0F0331);
  static const Color timestampColor = Color(0xFF4B4265);
  static const Color unreadIndicatorColor = Color(0xFFF9CF09);

  @override
  Widget build(BuildContext context) {
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
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(14),
              child: IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Terracotta orange rounded square icon container
                    Container(
                      width: 62,
                      constraints: const BoxConstraints(minHeight: 62),
                      decoration: BoxDecoration(
                        color: iconContainerColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: AppIcon(
                          icon,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),

                    // Notification Content (Title, Description, Timestamp)
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(right: 18),
                            child: Text(
                              title,
                              style: const TextStyle(
                                fontFamily: AppFonts.urbanist,
                                color: textColor,
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.2,
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            description,
                            style: const TextStyle(
                              fontFamily: AppFonts.openSans,
                              color: textColor,
                              fontSize: 12.5,
                              fontWeight: FontWeight.w400,
                              height: 1.35,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            timestamp,
                            style: const TextStyle(
                              fontFamily: AppFonts.openSans,
                              color: timestampColor,
                              fontSize: 11.5,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Top-right unread yellow indicator
            if (isUnread)
              Positioned(
                top: 14,
                right: 14,
                child: Container(
                  key: const Key('unread_dot'),
                  width: 11,
                  height: 11,
                  decoration: BoxDecoration(
                    color: unreadIndicatorColor,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: darkNavy,
                      width: 1.5,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
