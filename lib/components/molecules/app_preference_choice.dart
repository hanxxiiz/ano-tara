import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';

/// M06 Preference choice molecule:
/// Recipe: A02 Category icon + A01 Label + selection surface.
/// Includes smooth tactile bounce and animated press/selection transition.
class AppPreferenceChoice extends StatefulWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback? onTap;

  const AppPreferenceChoice({
    super.key,
    required this.label,
    required this.icon,
    this.isSelected = false,
    this.onTap,
  });

  @override
  State<AppPreferenceChoice> createState() => _AppPreferenceChoiceState();
}

class _AppPreferenceChoiceState extends State<AppPreferenceChoice> {
  bool _isPressed = false;

  void _handleTapDown(TapDownDetails details) {
    if (widget.onTap == null) return;
    setState(() => _isPressed = true);
  }

  void _handleTapCancel() {
    if (!_isPressed) return;
    setState(() => _isPressed = false);
  }

  Future<void> _handleTapUp(TapUpDetails details) async {
    if (widget.onTap == null) return;
    if (!_isPressed) {
      setState(() => _isPressed = true);
    }
    await Future<void>.delayed(const Duration(milliseconds: 110));
    if (mounted) {
      setState(() => _isPressed = false);
    }
    widget.onTap?.call();
  }

  @override
  Widget build(BuildContext context) {
    final Color bgColor = _isPressed
        ? const Color(0xFFC5D1E0)
        : (widget.isSelected ? AppColors.secondaryDark : AppColors.white);

    final Color fgColor = _isPressed
        ? AppColors.secondaryDark
        : (widget.isSelected ? AppColors.white : AppColors.secondaryDark);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: widget.onTap != null ? _handleTapDown : null,
      onTapUp: widget.onTap != null ? _handleTapUp : null,
      onTapCancel: widget.onTap != null ? _handleTapCancel : null,
      child: AnimatedScale(
        scale: _isPressed ? 0.94 : 1.0,
        duration: Duration(milliseconds: _isPressed ? 90 : 240),
        curve: _isPressed ? Curves.easeOutQuad : Curves.elasticOut,
        child: AnimatedContainer(
          duration: Duration(milliseconds: _isPressed ? 80 : 180),
          curve: Curves.easeOutCubic,
          transform: Matrix4.translationValues(0, _isPressed ? 2.0 : 0.0, 0),
          width: 84,
          height: 84,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.secondaryDark, width: 2.0),
            boxShadow: [
              BoxShadow(
                color: AppColors.secondaryDark,
                offset: Offset(0, _isPressed ? 2 : 4),
                blurRadius: 0,
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                widget.icon,
                color: fgColor,
                size: 28,
              ),
              const SizedBox(height: 6),
              Text(
                widget.label,
                textAlign: TextAlign.center,
                style: AppTypography.caption.copyWith(
                  color: fgColor,
                  fontWeight: FontWeight.w700,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
