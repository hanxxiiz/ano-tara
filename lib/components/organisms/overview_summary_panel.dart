import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_radii.dart';
import '../../core/constants/app_typography.dart';
import '../atoms/app_badge.dart';
import '../atoms/app_button.dart';

/// Overview Summary Panel organism matching Figma "Card #6.pdf".
/// Features AI Generation CTA, Plus tier badge, and customizable card summary.
class OverviewSummaryPanel extends StatelessWidget {
  final String title;
  final String description;
  final String? tierBadgeText;
  final VoidCallback? onGenerateAi;
  final VoidCallback? onViewDetails;
  final bool isAiLoading;

  const OverviewSummaryPanel({
    super.key,
    this.title = 'AI Trip Intelligence',
    this.description =
        'Get smart itinerary recommendations, budget splitting suggestions, and group schedule coordination optimized by AI.',
    this.tierBadgeText = 'Plus',
    this.onGenerateAi,
    this.onViewDetails,
    this.isAiLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF0F2647),
            AppColors.primaryNavy,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: AppRadii.radiusXl,
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryNavy.withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Title and Plus Tier Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                children: [
                  const Icon(
                    Iconsax.magicpen,
                    color: AppColors.semanticYellow,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    title,
                    style: AppTypography.titleLarge.copyWith(color: AppColors.white),
                  ),
                ],
              ),
              if (tierBadgeText != null)
                AppBadge(
                  label: tierBadgeText!,
                  variant: AppBadgeVariant.tierYellow,
                ),
            ],
          ),
          const SizedBox(height: 12),

          // Description Card
          Text(
            description,
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.white.withValues(alpha: 0.85),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 20),

          // Action Buttons Row
          Row(
            children: [
              Expanded(
                child: AppButton(
                  text: 'Generate with AI',
                  variant: AppButtonVariant.primaryOrange,
                  size: AppButtonSize.small,
                  isLoading: isAiLoading,
                  iconLeading: const Icon(
                    Iconsax.cpu_charge,
                    size: 16,
                    color: AppColors.white,
                  ),
                  onPressed: onGenerateAi,
                ),
              ),
              if (onViewDetails != null) ...[
                const SizedBox(width: 12),
                AppButton(
                  text: 'Details',
                  variant: AppButtonVariant.outline,
                  size: AppButtonSize.small,
                  isFullWidth: false,
                  onPressed: onViewDetails,
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
