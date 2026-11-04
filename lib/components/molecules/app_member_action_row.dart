import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../../core/constants/app_colors.dart';
import '../atoms/app_avatar.dart';
import '../atoms/app_icon.dart';
import '../atoms/app_text.dart';

/// M04 Member action row molecule matching Figma "02 Molecules" and "03 Organisms (O05)":
/// Recipe: A06 Avatar + A01 Member name + A02 Action icon with interactive press transition.
class AppMemberActionRow extends StatefulWidget {
  final String name;
  final VoidCallback? onActionTap;

  const AppMemberActionRow({
    super.key,
    required this.name,
    this.onActionTap,
  });

  @override
  State<AppMemberActionRow> createState() => _AppMemberActionRowState();
}

class _AppMemberActionRowState extends State<AppMemberActionRow> {
  bool _isActionPressed = false;

  void _handleActionTapDown(TapDownDetails details) {
    setState(() => _isActionPressed = true);
  }

  void _handleActionTapCancel() {
    if (!_isActionPressed) return;
    setState(() => _isActionPressed = false);
  }

  Future<void> _handleActionTapUp(TapUpDetails details) async {
    if (!_isActionPressed) {
      setState(() => _isActionPressed = true);
    }
    await Future<void>.delayed(const Duration(milliseconds: 140));
    if (mounted) {
      setState(() => _isActionPressed = false);
    }
    widget.onActionTap?.call();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.secondaryDark, width: 2.0),
        boxShadow: const [
          BoxShadow(
            color: AppColors.secondaryDark,
            offset: Offset(0, 4),
            blurRadius: 0,
          ),
        ],
      ),
      child: Row(
        children: [
          AppAvatar.singleUser(size: 50),
          const SizedBox(width: 14),
          Expanded(
            child: AppText(
              widget.name,
              variant: AppTextVariant.titleMedium,
              color: AppColors.secondaryDark,
              fontWeight: FontWeight.w700,
              fontSize: 14.5,
            ),
          ),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapDown: _handleActionTapDown,
            onTapUp: _handleActionTapUp,
            onTapCancel: _handleActionTapCancel,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 44.0, minHeight: 44.0),
              child: AnimatedScale(
                scale: _isActionPressed ? 0.86 : 1.0,
                duration: Duration(milliseconds: _isActionPressed ? 90 : 240),
                curve: _isActionPressed ? Curves.easeOutQuad : Curves.elasticOut,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  curve: Curves.easeOutCubic,
                  width: 44,
                  height: 44,
                  transform: Matrix4.translationValues(
                    _isActionPressed ? 3.0 : 0.0,
                    0,
                    0,
                  ),
                  decoration: BoxDecoration(
                    color: _isActionPressed
                        ? AppColors.primaryNavyLight
                        : Colors.transparent,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: AppIcon(
                      Iconsax.login5,
                      color: _isActionPressed
                          ? AppColors.primaryNavy
                          : AppColors.primaryOrange,
                      size: 26,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
