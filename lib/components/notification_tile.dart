import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// NotificationTile component
///
/// Reusable card displaying an activity notification:
/// - Blue vertical rectangle icon container on the left that naturally
///   stretches with card content height (no awkward empty space below it)
/// - Title in Urbanist ExtraBold
/// - Description and Timestamp in Open Sans
/// - Small circular unread badge (#F9CF09) in the top-right corner
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
  static const Color primaryBlue = Color(0xFF164D91);
  static const Color textColor = Color(0xFF0F0331);
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
                    // Blue vertical rectangle container on the left
                    Container(
                      width: 58,
                      constraints: const BoxConstraints(minHeight: 56),
                      decoration: BoxDecoration(
                        color: primaryBlue,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: darkNavy,
                          width: 1.5,
                        ),
                      ),
                      child: Center(
                        child: _buildIconWidget(),
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
                                fontWeight: FontWeight.w800, // Urbanist ExtraBold
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
                              fontWeight: FontWeight.w400, // Open Sans Regular
                              height: 1.35,
                            ),
                          ),
                          const SizedBox(height: 6),
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

  Widget _buildIconWidget() {
    return Icon(
      icon,
      color: Colors.white,
      size: 26,
    );
  }
}
