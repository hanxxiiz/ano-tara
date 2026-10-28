import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import '../atoms/app_icon.dart';
import '../molecules/app_trip_metadata.dart';

/// O03 Trip summary card organism matching Figma "03 Organisms" board:
/// Recipe: Photo + title + M08 trip metadata + open-trip action.
/// Accepts data as parameters for reusability across Home, Group Detail, and Trips screens.
/// Supports loading and error states.
class TripSummaryCard extends StatelessWidget {
  final String title;
  final String location;
  final String groupLabel;
  final String dateRange;
  final String imageUrl;
  final VoidCallback? onTap;
  final bool isLoading;
  final String? errorText;

  const TripSummaryCard({
    super.key,
    this.title = 'Bantayan Trip',
    this.location = 'Bantayan, Philippines',
    this.groupLabel = 'The Group (6 going)',
    this.dateRange = 'Oct 10 - Oct 15',
    this.imageUrl = 'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=800&q=80',
    this.onTap,
    this.isLoading = false,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return _buildLoadingState();
    }

    if (errorText != null && errorText!.isNotEmpty) {
      return _buildErrorState();
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.secondaryDark, width: 2.0),
            boxShadow: const [
              BoxShadow(
                color: AppColors.secondaryDark,
                offset: Offset(0, 4),
                blurRadius: 0,
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Photo Header
              SizedBox(
                height: 125,
                width: double.infinity,
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => _buildBeachFallback(),
                ),
              ),
              Container(
                height: 1.5,
                width: double.infinity,
                color: AppColors.secondaryDark,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: AppTypography.titleLarge.copyWith(
                              color: AppColors.secondaryDark,
                              fontWeight: FontWeight.w800,
                              fontSize: 16.5,
                            ),
                          ),
                          const SizedBox(height: 8),
                          // M08 Trip metadata molecule
                          AppTripMetadata(
                            location: location,
                            groupName: groupLabel,
                            dateRange: dateRange,
                          ),
                        ],
                      ),
                    ),
                    ConstrainedBox(
                      constraints: const BoxConstraints(minWidth: 44.0, minHeight: 44.0),
                      child: const Center(
                        child: Icon(
                          Iconsax.arrow_right_1,
                          color: AppColors.secondaryDark,
                          size: 26,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBeachFallback() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF26A69A),
            Color(0xFF80CBC4),
            Color(0xFFFFE082),
          ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const AppIcon(Iconsax.sun_15, color: Colors.white, size: 36),
            const SizedBox(height: 4),
            Text(
              title,
              style: AppTypography.caption.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Container(
      height: 220,
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.secondaryDark, width: 2.0),
      ),
      child: const Center(
        child: CircularProgressIndicator(color: AppColors.primaryNavy),
      ),
    );
  }

  Widget _buildErrorState() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primaryOrangeLight,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primaryOrange, width: 2.0),
      ),
      child: Row(
        children: [
          const AppIcon(Iconsax.warning_25, color: AppColors.primaryOrange, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              errorText!,
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.secondaryDark,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
