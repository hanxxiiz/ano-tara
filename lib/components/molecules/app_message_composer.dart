import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import '../atoms/app_icon.dart';

/// M07 Message composer molecule:
/// Recipe: A04 Input + A01 Placeholder + A02 Send action.
class AppMessageComposer extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;
  final String hintText;

  const AppMessageComposer({
    super.key,
    required this.controller,
    required this.onSend,
    this.hintText = 'Type your message',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: AppColors.secondaryDark, width: 2.0),
        boxShadow: const [
          BoxShadow(
            color: AppColors.secondaryDark,
            offset: Offset(0, 3),
            blurRadius: 0,
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 2),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              style: AppTypography.bodyMedium.copyWith(color: AppColors.secondaryDark),
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: const TextStyle(color: AppColors.shayne, fontSize: 14),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
              onSubmitted: (_) => onSend(),
            ),
          ),
          IconButton(
            icon: const AppIcon(
              Iconsax.send_25,
              color: AppColors.secondaryDark,
              size: 22,
            ),
            onPressed: onSend,
          ),
        ],
      ),
    );
  }
}
