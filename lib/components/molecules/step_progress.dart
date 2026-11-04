import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';

/// Reusable StepProgress molecule for multi-step flows (Onboarding, Create Group, Create Trip, etc.).
/// Uses #0F0331 (AppColors.secondaryDark) for borders, active segment fill, and typography.
class StepProgress extends StatelessWidget {
  final int current;
  final int total;

  const StepProgress({
    super.key,
    required this.current,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    final int safeTotal = total < 1 ? 1 : total;
    final int safeCurrent = current.clamp(1, safeTotal);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '$safeCurrent/$safeTotal',
          textAlign: TextAlign.right,
          style: AppTypography.bodySmall.copyWith(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            color: AppColors.secondaryDark,
          ),
        ),
        const SizedBox(height: 6),
        Row(
          children: List.generate(safeTotal, (index) {
            final bool filled = index < safeCurrent;
            return Expanded(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutCubic,
                height: 11,
                margin: EdgeInsets.only(right: index == safeTotal - 1 ? 0 : 8),
                decoration: BoxDecoration(
                  color: filled
                      ? AppColors.secondaryDark
                      : AppColors.secondaryLight,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: AppColors.secondaryDark,
                    width: 1.5,
                  ),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}
