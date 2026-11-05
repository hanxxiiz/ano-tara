import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

/// Shared outlined surface for settings links, FAQs, and support panels.
class SettingsCard extends StatelessWidget {
  const SettingsCard({
    super.key,
    required this.child,
    this.onTap,
    this.color = Colors.white,
  });
  final Widget child;
  final VoidCallback? onTap;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: AppColors.secondaryDark),
      boxShadow: const [
        BoxShadow(color: AppColors.secondaryDark, offset: Offset(0, 4)),
      ],
    ),
    child: Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(padding: const EdgeInsets.all(14), child: child),
      ),
    ),
  );
}
