import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../core/constants/app_colors.dart';
import '../atoms/app_icon.dart';

/// Selectable option card molecule used in Onboarding (Activities, Dietary Preferences, Allergies).
/// Adheres to Ano Tara Atomic Design: 2px solid Dark Ink (#0F0331) border and hard drop shadow (0, 4).
/// Features smooth animated selection and press transitions.
class AppOptionCard extends StatefulWidget {
  final String label;
  final IconData? icon;
  final Widget? customIcon;
  final String? iconAsset;
  final bool isSelected;
  final VoidCallback onTap;
  final Color selectedColor;
  final double? size;

  const AppOptionCard({
    super.key,
    required this.label,
    this.icon,
    this.customIcon,
    this.iconAsset,
    required this.isSelected,
    required this.onTap,
    this.selectedColor = AppColors.primaryNavy,
    this.size,
  });

  @override
  State<AppOptionCard> createState() => _AppOptionCardState();
}

class _AppOptionCardState extends State<AppOptionCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final Color bgColor = widget.isSelected
        ? widget.selectedColor
        : AppColors.white;
    final Color fgColor = widget.isSelected
        ? AppColors.white
        : AppColors.secondaryDark;

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOutCubic,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          width: widget.size,
          height: widget.size,
          transform: Matrix4.translationValues(0, _isPressed ? 2.0 : 0.0, 0),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(18.0),
            border: Border.all(color: AppColors.secondaryDark, width: 2.0),
            boxShadow: [
              BoxShadow(
                color: AppColors.secondaryDark,
                offset: Offset(0, _isPressed ? 2.0 : 4.0),
                blurRadius: 0,
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (widget.customIcon != null)
                Flexible(child: widget.customIcon!)
              else if (widget.iconAsset != null)
                Flexible(
                  child: SvgPicture.asset(
                    widget.iconAsset!,
                    width: 44,
                    height: 44,
                    colorFilter: ColorFilter.mode(fgColor, BlendMode.srcIn),
                    excludeFromSemantics: true,
                  ),
                )
              else if (widget.icon != null)
                Flexible(child: AppIcon(widget.icon!, size: 30, color: fgColor)),
              const SizedBox(height: 6),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: GoogleFonts.urbanist(
                  color: fgColor,
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                ),
                child: Text(
                  widget.label,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
