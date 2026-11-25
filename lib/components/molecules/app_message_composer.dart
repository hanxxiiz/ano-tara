import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';

/// M07 Message composer molecule matching Figma "05.06 · Group chat — conversation.png":
/// Pill-shaped input with 2px dark ink outline, hard bottom shadow, and send action button.
class AppMessageComposer extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;
  final String hintText;
  final bool enabled;
  final FocusNode? focusNode;

  const AppMessageComposer({
    super.key,
    required this.controller,
    required this.onSend,
    this.hintText = 'Type your message',
    this.enabled = true,
    this.focusNode,
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
      padding: const EdgeInsets.fromLTRB(18, 2, 8, 2),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              enabled: enabled,
              textInputAction: TextInputAction.send,
              textCapitalization: TextCapitalization.sentences,
              textAlignVertical: TextAlignVertical.center,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.secondaryDark,
                fontWeight: FontWeight.w500,
              ),
              decoration: InputDecoration(
                isDense: true,
                filled: false,
                fillColor: Colors.transparent,
                hintText: hintText,
                hintStyle: const TextStyle(
                  color: AppColors.shayne,
                  fontSize: 14,
                ),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                errorBorder: InputBorder.none,
                disabledBorder: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
              onSubmitted: (_) => enabled ? onSend() : null,
            ),
          ),
          ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
            child: IconButton(
              tooltip: 'Send message',
              icon: Icon(
                Iconsax.send_1,
                color: enabled ? AppColors.secondaryDark : AppColors.ann,
                size: 23,
              ),
              onPressed: enabled ? onSend : null,
              splashRadius: 22,
            ),
          ),
        ],
      ),
    );
  }
}
