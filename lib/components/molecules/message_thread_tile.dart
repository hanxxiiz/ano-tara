import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import '../../features/group_chat/models/group_chat_models.dart';
import 'group_chat_avatar.dart';

/// Group message thread card matching Figma "05.02 · Groups — message threads.png"
/// and "05.20 · Group messages — list shortcut.png".
class MessageThreadTile extends StatefulWidget {
  final GroupMessageThread thread;
  final VoidCallback onTap;

  const MessageThreadTile({
    super.key,
    required this.thread,
    required this.onTap,
  });

  @override
  State<MessageThreadTile> createState() => _MessageThreadTileState();
}

class _MessageThreadTileState extends State<MessageThreadTile> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final thread = widget.thread;
    final hasUnread = thread.hasUnread;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.985 : 1.0,
        duration: const Duration(milliseconds: 110),
        curve: Curves.easeOutCubic,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 140),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          decoration: BoxDecoration(
            color: _isPressed ? AppColors.surfaceLight : AppColors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: AppColors.secondaryDark,
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              GroupChatAvatar(
                size: 48,
                imageUrl: thread.avatarUrl,
                fallbackColor: thread.avatarColor,
                borderWidth: 1.4,
              ),
              const SizedBox(width: 14),
              // Group name + last message preview
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      thread.groupName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.titleLarge.copyWith(
                        color: AppColors.secondaryDark,
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      thread.previewText,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.bodySmall.copyWith(
                        color: hasUnread
                            ? AppColors.secondaryDark
                            : AppColors.carla,
                        fontWeight:
                            hasUnread ? FontWeight.w600 : FontWeight.w400,
                        fontSize: 12.5,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              // Yellow unread dot matching Figma
              if (hasUnread) ...[
                const SizedBox(width: 12),
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: AppColors.semanticYellow,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.secondaryDark,
                      width: 1.5,
                    ),
                  ),
                ),
                const SizedBox(width: 4),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Search group input matching Figma "05.02" and "05.20".
class GroupMessagesSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback? onClear;
  final String hintText;

  const GroupMessagesSearchBar({
    super.key,
    required this.controller,
    required this.onChanged,
    this.onClear,
    this.hintText = 'Search group',
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: controller,
      builder: (context, value, _) {
        final hasText = value.text.isNotEmpty;
        return Container(
          height: 48,
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.secondaryDark, width: 2.0),
          ),
          child: Center(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              textAlignVertical: TextAlignVertical.center,
              style: AppTypography.inputText.copyWith(
                fontSize: 14.5,
                fontWeight: FontWeight.w500,
              ),
              cursorColor: AppColors.primaryNavy,
              decoration: InputDecoration(
                isDense: true,
                filled: false,
                fillColor: Colors.transparent,
                hintText: hintText,
                hintStyle: AppTypography.inputHint.copyWith(
                  color: AppColors.shayne,
                  fontSize: 14,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                prefixIcon: const Padding(
                  padding: EdgeInsets.only(left: 14, right: 8),
                  child: Icon(
                    Iconsax.search_normal,
                    color: AppColors.secondaryDark,
                    size: 20,
                  ),
                ),
                prefixIconConstraints: const BoxConstraints(
                  minWidth: 44,
                  minHeight: 44,
                ),
                suffixIcon: hasText
                    ? IconButton(
                        tooltip: 'Clear search',
                        icon: const Icon(
                          Iconsax.close_circle,
                          color: AppColors.secondaryDark,
                          size: 18,
                        ),
                        onPressed: () {
                          controller.clear();
                          onChanged('');
                          onClear?.call();
                        },
                        splashRadius: 20,
                      )
                    : null,
                suffixIconConstraints: const BoxConstraints(
                  minWidth: 44,
                  minHeight: 44,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Pulsing skeleton card shown while message threads are loading.
class MessageThreadTileSkeleton extends StatefulWidget {
  const MessageThreadTileSkeleton({super.key});

  @override
  State<MessageThreadTileSkeleton> createState() =>
      _MessageThreadTileSkeletonState();
}

class _MessageThreadTileSkeletonState extends State<MessageThreadTileSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _opacity = Tween<double>(begin: 0.4, end: 0.9).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: AppColors.ann,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: const BoxDecoration(
                color: AppColors.secondaryLight,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 130,
                    height: 14,
                    decoration: BoxDecoration(
                      color: AppColors.secondaryLight,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: 190,
                    height: 11,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceMuted,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
