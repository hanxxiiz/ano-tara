import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../data/trip_repository.dart';

/// Overlapping circular member initial avatars matching Figma 07.01 & 07.02:
/// Yellow, Orange, Navy, and optional 4th Light circle with 1.5px dark ink borders + "+N" text.
class TripMemberAvatars extends StatelessWidget {
  final List<TripMemberModel> members;
  final int maxVisible;
  final double size;

  const TripMemberAvatars({
    super.key,
    required this.members,
    this.maxVisible = 3,
    this.size = 26,
  });

  static const List<Color> _bgColors = [
    AppColors.semanticYellow,
    AppColors.primaryOrange,
    AppColors.primaryNavy,
    AppColors.white,
  ];

  static const List<Color> _textColors = [
    AppColors.secondaryDark,
    AppColors.secondaryDark,
    AppColors.secondaryDark,
    AppColors.secondaryDark,
  ];

  @override
  Widget build(BuildContext context) {
    final visible = members.take(maxVisible).toList();
    final overflow = members.length - visible.length;
    if (visible.isEmpty) return const SizedBox.shrink();

    final double overlapStep = size * 0.68;
    final double stackWidth = size + (visible.length - 1) * overlapStep;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: stackWidth,
          height: size,
          child: Stack(
            children: [
              for (int i = 0; i < visible.length; i++)
                Positioned(
                  left: i * overlapStep,
                  child: Container(
                    width: size,
                    height: size,
                    decoration: BoxDecoration(
                      color: _bgColors[i % _bgColors.length],
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.secondaryDark,
                        width: 1.5,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        visible[i].initials,
                        style: AppTypography.badge.copyWith(
                          color: i == 2
                              ? AppColors.white
                              : _textColors[i % _textColors.length],
                          fontSize: size * 0.36,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0,
                          height: 1.0,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        if (overflow > 0) ...[
          const SizedBox(width: 6),
          Text(
            '+$overflow',
            style: AppTypography.caption.copyWith(
              color: AppColors.secondaryDark,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ],
    );
  }
}
