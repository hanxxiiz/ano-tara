import 'package:flutter/material.dart';

/// Reusable atom for clickable items providing smooth scale and press transitions.
/// Enforces minimum 44x44px tap targets.
class AppPressable extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double pressedScale;
  final Duration duration;
  final Curve curve;
  final HitTestBehavior behavior;

  const AppPressable({
    super.key,
    required this.child,
    this.onTap,
    this.pressedScale = 0.965,
    this.duration = const Duration(milliseconds: 140),
    this.curve = Curves.easeOutCubic,
    this.behavior = HitTestBehavior.opaque,
  });

  @override
  State<AppPressable> createState() => _AppPressableState();
}

class _AppPressableState extends State<AppPressable> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final bool isInteractive = widget.onTap != null;

    return GestureDetector(
      behavior: widget.behavior,
      onTapDown: isInteractive ? (_) => setState(() => _isPressed = true) : null,
      onTapUp: isInteractive
          ? (_) {
              setState(() => _isPressed = false);
              widget.onTap?.call();
            }
          : null,
      onTapCancel:
          isInteractive ? () => setState(() => _isPressed = false) : null,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minWidth: 44.0, minHeight: 44.0),
        child: AnimatedScale(
          scale: _isPressed ? widget.pressedScale : 1.0,
          duration: widget.duration,
          curve: widget.curve,
          child: widget.child,
        ),
      ),
    );
  }
}
