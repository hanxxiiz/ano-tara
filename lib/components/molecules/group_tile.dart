import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import '../atoms/app_icon.dart';

/// Compact group entry with the same press feedback as AppButton.
class GroupTile extends StatefulWidget {
  const GroupTile({super.key, required this.name, this.onTap});
  final String name;
  final VoidCallback? onTap;

  @override
  State<GroupTile> createState() => _GroupTileState();
}

class _GroupTileState extends State<GroupTile> {
  bool _isPressed = false;

  Future<void> _handleTapUp(TapUpDetails details) async {
    setState(() => _isPressed = true);
    await Future<void>.delayed(const Duration(milliseconds: 110));
    if (!mounted) return;
    setState(() => _isPressed = false);
    widget.onTap?.call();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      enabled: widget.onTap != null,
      label: widget.name,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: widget.onTap == null
            ? null
            : (_) => setState(() => _isPressed = true),
        onTapUp: widget.onTap == null ? null : _handleTapUp,
        onTapCancel: () => setState(() => _isPressed = false),
        child: SizedBox(
          width: 90,
          child: Column(
            children: [
              AnimatedScale(
                scale: _isPressed ? 0.965 : 1,
                duration: Duration(milliseconds: _isPressed ? 90 : 260),
                curve: _isPressed ? Curves.easeOutQuad : Curves.elasticOut,
                child: AnimatedContainer(
                  duration: Duration(milliseconds: _isPressed ? 80 : 220),
                  curve: Curves.easeOutBack,
                  transform: Matrix4.translationValues(
                    0,
                    _isPressed ? 2 : 0,
                    0,
                  ),
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    color: _isPressed
                        ? const Color(0xFFF9CF09)
                        : const Color(0xFFFFEA87),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.secondaryDark,
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.secondaryDark,
                        offset: Offset(0, _isPressed ? 2 : 4),
                        blurRadius: 0,
                      ),
                    ],
                  ),
                  child: const Center(
                    child: AppIcon(
                      Iconsax.profile_2user5,
                      size: 30,
                      color: Color(0xFFF4773D),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                widget.name,
                style: AppTypography.buttonMedium.copyWith(
                  fontSize: 12,
                  color: AppColors.secondaryDark,
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
