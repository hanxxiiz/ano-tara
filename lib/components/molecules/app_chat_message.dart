import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import '../atoms/app_avatar.dart';

/// M10 Chat message molecule:
/// Recipe: A06 Sender avatar + A01 Message + bubble surface.
class AppChatMessage extends StatelessWidget {
  final String text;
  final bool isMe;

  const AppChatMessage({
    super.key,
    required this.text,
    this.isMe = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isMe) ...[
            const AppAvatar(
              size: 44,
              type: AppAvatarType.singleUser,
            ),
            const SizedBox(width: 10),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.secondaryLight,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.secondaryDark, width: 2.0),
                boxShadow: const [
                  BoxShadow(
                    color: AppColors.secondaryDark,
                    offset: Offset(0, 3),
                    blurRadius: 0,
                  ),
                ],
              ),
              child: Text(
                text,
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.secondaryDark,
                  fontWeight: FontWeight.w600,
                  fontSize: 13.5,
                  height: 1.3,
                ),
              ),
            ),
          ),
          if (isMe) ...[
            const SizedBox(width: 10),
            const AppAvatar(
              size: 44,
              type: AppAvatarType.singleUser,
            ),
          ],
        ],
      ),
    );
  }
}
