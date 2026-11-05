import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../atoms/app_icon.dart';
import '../atoms/app_text.dart';

/// Reusable Navigation Item molecule built from shared atoms (AppIcon + AppText).
/// Enforces >= 44x44px tap target, highlights the active/pressed tab in #144885 (AppColors.primaryNavy),
/// and includes smooth scale and color transitions.
class AppNavigationItem extends StatefulWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const AppNavigationItem({
    super.key,
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<AppNavigationItem> createState() => _AppNavigationItemState();
}

class _AppNavigationItemState extends State<AppNavigationItem> {
  bool _isPressed = false;

  void _handleTapDown(TapDownDetails details) {
    setState(() => _isPressed = true);
  }

  void _handleTapCancel() {
    if (!_isPressed) return;
    setState(() => _isPressed = false);
  }

  Future<void> _handleTapUp(TapUpDetails details) async {
    if (!_isPressed) {
      setState(() => _isPressed = true);
    }
    widget.onTap();
    await Future<void>.delayed(const Duration(milliseconds: 120));
    if (mounted) {
      setState(() => _isPressed = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isHighlighted = widget.isSelected || _isPressed;
    final Color color = isHighlighted ? AppColors.primaryNavy : AppColors.shayne;

    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: _handleTapDown,
        onTapUp: _handleTapUp,
        onTapCancel: _handleTapCancel,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minWidth: 44.0, minHeight: 44.0),
          child: AnimatedScale(
            scale: _isPressed ? 0.92 : (widget.isSelected ? 1.06 : 1.0),
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOutCubic,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  transitionBuilder: (child, animation) => ScaleTransition(
                    scale: Tween<double>(begin: 0.88, end: 1.0)
                        .animate(animation),
                    child: FadeTransition(opacity: animation, child: child),
                  ),
                  child: AppIcon(
                    widget.icon,
                    key: ValueKey('nav_item_${widget.label}_$isHighlighted'),
                    color: color,
                    size: 25,
                  ),
                ),
                const SizedBox(height: 4),
                AppText(
                  widget.label,
                  variant: AppTextVariant.caption,
                  color: color,
                  fontWeight:
                      isHighlighted ? FontWeight.w800 : FontWeight.w600,
                  fontSize: 11,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
