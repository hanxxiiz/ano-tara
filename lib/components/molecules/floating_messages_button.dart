import 'dart:async';

import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../features/group_chat/presentation/state/group_messages_store.dart';
import '../organisms/messages_shortcut_sheet.dart';

/// Floating Messages button matching Figma "05.01 · Groups — group list.png".
/// Circular dark ink (#0F0331) FAB with a centered white mail icon and optional
/// yellow unread dot. Tapping opens the Group Messages shortcut overlay (05.20)
/// unless a custom [onPressed] callback is provided.
class FloatingMessagesButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final bool showUnreadIndicator;
  final double size;

  const FloatingMessagesButton({
    super.key,
    this.onPressed,
    this.showUnreadIndicator = true,
    this.size = 62.0,
  });

  @override
  State<FloatingMessagesButton> createState() => _FloatingMessagesButtonState();
}

class _FloatingMessagesButtonState extends State<FloatingMessagesButton> {
  final GroupMessagesStore _store = GroupMessagesStore.instance;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _store.addListener(_onStoreChanged);
    _store.watchThreads();
    unawaited(_store.loadThreads(silent: true).catchError((_) {}));
  }

  void _onStoreChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _store.removeListener(_onStoreChanged);
    super.dispose();
  }

  void _handleTap() {
    if (widget.onPressed != null) {
      widget.onPressed!();
    } else {
      showMessagesShortcutSheet(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasUnread = widget.showUnreadIndicator && _store.hasAnyUnread;

    return Semantics(
      button: true,
      label: 'Open group messages',
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) {
          setState(() => _isPressed = false);
          _handleTap();
        },
        onTapCancel: () => setState(() => _isPressed = false),
        child: AnimatedScale(
          scale: _isPressed ? 0.92 : 1.0,
          duration: const Duration(milliseconds: 130),
          curve: Curves.easeOutCubic,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: widget.size,
                height: widget.size,
                decoration: BoxDecoration(
                  color: _isPressed
                      ? AppColors.primaryNavy
                      : AppColors.secondaryDark,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.secondaryDark.withValues(alpha: 0.28),
                      blurRadius: 14,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: const Center(
                  child: Icon(
                    Icons.mail_rounded,
                    color: AppColors.white,
                    size: 28,
                  ),
                ),
              ),
              if (hasUnread)
                Positioned(
                  right: 3,
                  top: 3,
                  child: Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      color: AppColors.semanticYellow,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.secondaryDark,
                        width: 2.0,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
