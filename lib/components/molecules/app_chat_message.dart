import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import '../atoms/app_icon.dart';

/// M10 Chat message molecule.
/// Clearly distinguishes sent (`isMe == true`) and received (`isMe == false`) messages:
/// - Sent: right-aligned, deep navy bubble (`#144885`) with white text, bottom-right sharp tail
///   on the last bubble in a sender run, and no profile icon.
/// - Received: left-aligned, warm light grey bubble (`#E8E6E3`) with dark ink text, sender name
///   aligned above the first bubble in a sender run, and sender avatar aligned with the last
///   bubble in the sender run.
class AppChatMessage extends StatelessWidget {
  final String text;
  final bool isMe;
  final String? senderName;
  final Color? avatarColor;
  final bool showAvatar;
  final bool showSenderName;
  final bool isFirstInGroup;
  final bool isLastInGroup;

  const AppChatMessage({
    super.key,
    required this.text,
    this.isMe = false,
    this.senderName,
    this.avatarColor,
    this.showAvatar = true,
    this.showSenderName = true,
    this.isFirstInGroup = true,
    this.isLastInGroup = true,
  });

  static const double _avatarSize = 42.0;
  static const double _avatarGap = 10.0;

  @override
  Widget build(BuildContext context) {
    final bubbleColor = isMe ? AppColors.primaryNavy : AppColors.secondaryLight;
    final textColor = isMe ? AppColors.white : AppColors.secondaryDark;
    final resolvedAvatarColor = avatarColor ?? AppColors.semanticYellow;

    final shouldShowAvatar = !isMe && showAvatar;
    final shouldShowSenderName =
        !isMe && showSenderName && senderName != null && senderName!.isNotEmpty;

    final borderRadius = BorderRadius.only(
      topLeft: const Radius.circular(16),
      topRight: const Radius.circular(16),
      bottomLeft: Radius.circular(!isMe && isLastInGroup ? 6 : 16),
      bottomRight: Radius.circular(isMe && isLastInGroup ? 6 : 16),
    );

    final bubble = ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.68,
        minWidth: 68,
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: bubbleColor,
          borderRadius: borderRadius,
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
            color: textColor,
            fontWeight: FontWeight.w600,
            fontSize: 13.5,
            height: 1.35,
          ),
        ),
      ),
    );

    return Padding(
      padding: EdgeInsets.only(
        top: isFirstInGroup ? 10.0 : 3.0,
        bottom: isLastInGroup ? 4.0 : 2.0,
      ),
      child: Column(
        crossAxisAlignment:
            isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          if (shouldShowSenderName)
            Padding(
              padding: const EdgeInsets.only(
                left: _avatarSize + _avatarGap + 4,
                bottom: 4,
              ),
              child: Text(
                senderName!,
                style: AppTypography.caption.copyWith(
                  color: AppColors.shayne,
                  fontWeight: FontWeight.w600,
                  fontSize: 11.5,
                ),
              ),
            ),
          Row(
            mainAxisAlignment:
                isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (!isMe) ...[
                if (shouldShowAvatar)
                  _ChatSenderAvatar(
                    size: _avatarSize,
                    backgroundColor: resolvedAvatarColor,
                  )
                else
                  const SizedBox(width: _avatarSize),
                const SizedBox(width: _avatarGap),
              ],
              Flexible(child: bubble),
            ],
          ),
        ],
      ),
    );
  }
}

class _ChatSenderAvatar extends StatelessWidget {
  final double size;
  final Color backgroundColor;

  const _ChatSenderAvatar({
    required this.size,
    required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.secondaryDark, width: 2.0),
        boxShadow: const [
          BoxShadow(
            color: AppColors.secondaryDark,
            offset: Offset(0, 3),
            blurRadius: 0,
          ),
        ],
      ),
      child: Center(
        child: AppIcon(
          Iconsax.user5,
          color: AppColors.secondaryDark,
          size: size * 0.48,
        ),
      ),
    );
  }
}
