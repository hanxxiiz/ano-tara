import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';

/// Availability pill molecule matching Figma Step 6:
/// Wide rounded button with 2px Dark Ink (#0F0331) border and hard drop shadow (0, 4).
/// Selected: solid Orange (#E24B27) with white text.
/// Unselected: peach/coral (#F1A591) with white text.
/// Includes smooth tactile press and selection animations.
class AppAvailabilityPill extends StatefulWidget {
  final String day;
  final bool isSelected;
  final VoidCallback onTap;

  const AppAvailabilityPill({
    super.key,
    required this.day,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<AppAvailabilityPill> createState() => _AppAvailabilityPillState();
}

class _AppAvailabilityPillState extends State<AppAvailabilityPill> {
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
    await Future<void>.delayed(const Duration(milliseconds: 110));
    if (mounted) {
      setState(() => _isPressed = false);
    }
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    final Color bgColor = _isPressed
        ? const Color(0xFFC73D1C)
        : (widget.isSelected
            ? AppColors.primaryOrange
            : const Color(0xFFF1A591));

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      child: AnimatedScale(
        scale: _isPressed ? 0.96 : 1.0,
        duration: Duration(milliseconds: _isPressed ? 90 : 240),
        curve: _isPressed ? Curves.easeOutQuad : Curves.elasticOut,
        child: AnimatedContainer(
          duration: Duration(milliseconds: _isPressed ? 80 : 180),
          curve: Curves.easeOutCubic,
          transform: Matrix4.translationValues(0, _isPressed ? 2.0 : 0.0, 0),
          width: 154.0,
          height: 60.0,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(20.0),
            border: Border.all(
              color: AppColors.secondaryDark,
              width: 2.0,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.secondaryDark,
                offset: Offset(0, _isPressed ? 2 : 4),
                blurRadius: 0,
              ),
            ],
          ),
          alignment: Alignment.center,
          child: Text(
            widget.day,
            style: GoogleFonts.urbanist(
              color: AppColors.white,
              fontWeight: FontWeight.w800,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }
}
