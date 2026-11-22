import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import '../atoms/app_icon.dart';

/// M10 Chat message molecule matching Figma "05.06 · Group chat — conversation.png".
/// Clearly distinguishes sent (`isMe == true`) and received (`isMe == false`) messages:
/// - Sent: right-aligned, deep navy bubble (`#144885`) with white text, top-right sharp tail,
///   navy avatar with dark outline & hard shadow on the right.
/// - Received: left-aligned, warm light grey bubble (`#E8E6E3`) with dark ink text, top-left
///   sharp tail, yellow/orange sender avatar with dark outline & hard shadow on the left.
class AppChatMessage extends StatelessWidget {
  final String text;
  final bool isMe;
  final String? senderName;
  final Color? avatarColor;
  final bool showAvatar;

  const AppChatMessage({
    super.key,
    required this.text,
    this.isMe = false,
    this.senderName,
    this.avatarColor,
    this.showAvatar = true,
  });

  static const double _avatarSize = 42.0;
  static const double _avatarGap = 10.0;

  @override
  Widget build(BuildContext context) {
    final bubbleColor = isMe ? AppColors.primaryNavy : AppColors.secondaryLight;
    final textColor = isMe ? AppColors.white : AppColors.secondaryDark;
    final resolvedAvatarColor = avatarColor ??
        (isMe ? AppColors.primaryNavy : AppColors.semanticYellow);

    final borderRadius = BorderRadius.only(
      topLeft: Radius.circular(!isMe && showAvatar ? 6 : 16),
      topRight: Radius.circular(isMe && showAvatar ? 6 : 16),
      bottomLeft: const Radius.circular(16),
      bottomRight: const Radius.circular(16),
    );

    final bubble = Column(
      crossAxisAlignment:
          isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        if (!isMe && showAvatar && senderName != null && senderName!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 4),
            child: Text(
              senderName!,
              style: AppTypography.caption.copyWith(
                color: AppColors.shayne,
                fontWeight: FontWeight.w600,
                fontSize: 11.5,
              ),
            ),
          ),
        ConstrainedBox(
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
        ),
      ],
    );

    return Padding(
      padding: EdgeInsets.only(
        top: showAvatar ? 8.0 : 4.0,
        bottom: 4.0,
      ),
      child: Row(
        mainAxisAlignment:
            isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isMe) ...[
            if (showAvatar)
              _ChatSenderAvatar(
                size: _avatarSize,
                backgroundColor: resolvedAvatarColor,
              )
            else
              const SizedBox(width: _avatarSize),
            const SizedBox(width: _avatarGap),
          ],
          Flexible(child: bubble),
          if (isMe) ...[
            const SizedBox(width: _avatarGap),
            if (showAvatar)
              _ChatSenderAvatar(
                size: _avatarSize,
                backgroundColor: resolvedAvatarColor,
              )
            else
              const SizedBox(width: _avatarSize),
          ],
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
