import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import '../../core/constants/app_colors.dart';
import '../atoms/app_icon.dart';

/// Horizontal pace option card molecule for Onboarding Step 5 matching Figma.
/// Features a 2px Dark Ink (#0F0331) border and hard drop shadow (0, 4).
/// Avoids red/orange pressed or selected fills (which look like error states),
/// using soft navy-blue pressed/selected feedback instead.
class AppPaceCard extends StatefulWidget {
  final String title;
  final String description;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;
  final Color activeColor;

  const AppPaceCard({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    required this.isSelected,
    required this.onTap,
    this.activeColor = AppColors.primaryNavy,
  });

  @override
  State<AppPaceCard> createState() => _AppPaceCardState();
}

class _AppPaceCardState extends State<AppPaceCard> {
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
    final Color cardFill = _isPressed
        ? const Color(0xFFC5D1E0)
        : (widget.isSelected
            ? AppColors.primaryNavyLight
            : AppColors.white);

    final Color badgeColor = _isPressed
        ? const Color(0xFF7D99BA)
        : (widget.isSelected
            ? AppColors.primaryNavy
            : AppColors.primaryOrange);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      child: AnimatedScale(
        scale: _isPressed ? 0.97 : 1.0,
        duration: Duration(milliseconds: _isPressed ? 90 : 240),
        curve: _isPressed ? Curves.easeOutQuad : Curves.elasticOut,
        child: AnimatedContainer(
          duration: Duration(milliseconds: _isPressed ? 80 : 200),
          curve: Curves.easeOutCubic,
          transform: Matrix4.translationValues(0, _isPressed ? 2.0 : 0.0, 0),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: cardFill,
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
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Left Icon Badge
              AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: badgeColor,
                  borderRadius: BorderRadius.circular(14.0),
                  border: Border.all(
                    color: AppColors.secondaryDark,
                    width: 1.5,
                  ),
                ),
                alignment: Alignment.center,
                child: AppIcon(
                  widget.icon,
                  color: AppColors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 14),

              // Title and Description
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      widget.title,
                      style: GoogleFonts.urbanist(
                        fontSize: 16.0,
                        fontWeight: FontWeight.w800,
                        color: AppColors.secondaryDark,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.description,
                      style: GoogleFonts.openSans(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w500,
                        color: AppColors.carla,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              // Right Arrow Chevron (Iconsax)
              AnimatedSlide(
                offset: Offset(_isPressed ? 0.12 : 0.0, 0),
                duration: const Duration(milliseconds: 150),
                child: const Icon(
                  Iconsax.arrow_right_3,
                  color: AppColors.secondaryDark,
                  size: 22,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
