import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import '../atoms/app_icon.dart';
import '../molecules/app_trip_metadata.dart';

/// O03 Trip summary card organism matching Figma "03 Organisms" board:
/// Recipe: Photo + title + M08 trip metadata + open-trip action.
/// Accepts data as parameters for reusability across Home, Group Detail, and Trips screens.
/// Supports loading, error states, and smooth pressed transition (scale, 2px Y-offset, shadow reduction, and color feedback).
class TripSummaryCard extends StatefulWidget {
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
    this.imageUrl =
        'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=800&q=80',
    this.onTap,
    this.isLoading = false,
    this.errorText,
  });

  @override
  State<TripSummaryCard> createState() => _TripSummaryCardState();
}

class _TripSummaryCardState extends State<TripSummaryCard> {
  bool _isPressed = false;

  void _handleTapDown(TapDownDetails details) {
    setState(() => _isPressed = true);
  }

  void _handleTapCancel() {
    if (!_isPressed) return;
    setState(() => _isPressed = false);
  }

  Future<void> _handleTapUp(TapUpDetails details) async {
    if (!_isPressed) {
      setState(() => _isPressed = true);
    }
    await Future<void>.delayed(const Duration(milliseconds: 120));
    if (mounted) {
      setState(() => _isPressed = false);
    }
    widget.onTap?.call();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isLoading) {
      return _buildLoadingState();
    }

    if (widget.errorText != null && widget.errorText!.isNotEmpty) {
      return _buildErrorState();
    }

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      child: AnimatedScale(
        scale: _isPressed ? 0.97 : 1.0,
        duration: Duration(milliseconds: _isPressed ? 90 : 250),
        curve: _isPressed ? Curves.easeOutQuad : Curves.elasticOut,
        child: AnimatedContainer(
          duration: Duration(milliseconds: _isPressed ? 80 : 200),
          curve: Curves.easeOutCubic,
          transform: Matrix4.translationValues(0, _isPressed ? 2.0 : 0.0, 0),
          decoration: BoxDecoration(
            color: _isPressed ? AppColors.primaryNavyLight : AppColors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.secondaryDark, width: 2.0),
            boxShadow: [
              BoxShadow(
                color: AppColors.secondaryDark,
                offset: Offset(0, _isPressed ? 2 : 4),
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
                  widget.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      _buildBeachFallback(),
                ),
              ),
              Container(
                height: 1.5,
                width: double.infinity,
                color: AppColors.secondaryDark,
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.title,
                            style: AppTypography.titleLarge.copyWith(
                              color: AppColors.secondaryDark,
                              fontWeight: FontWeight.w800,
                              fontSize: 16.5,
                            ),
                          ),
                          const SizedBox(height: 8),
                          // M08 Trip metadata molecule
                          AppTripMetadata(
                            location: widget.location,
                            groupName: widget.groupLabel,
                            dateRange: widget.dateRange,
                          ),
                        ],
                      ),
                    ),
                    ConstrainedBox(
                      constraints:
                          const BoxConstraints(minWidth: 44.0, minHeight: 44.0),
                      child: Center(
                        child: AnimatedSlide(
                          offset: Offset(_isPressed ? 0.15 : 0.0, 0),
                          duration: const Duration(milliseconds: 150),
                          child: Icon(
                            Iconsax.arrow_right_1,
                            color: _isPressed
                                ? AppColors.primaryNavy
                                : AppColors.secondaryDark,
                            size: 26,
                          ),
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
            const AppIcon(Iconsax.sun_15, color: AppColors.white, size: 36),
            const SizedBox(height: 4),
            Text(
              widget.title,
              style: AppTypography.caption.copyWith(
                color: AppColors.white,
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
        border: Border.all(color: AppColors.secondaryDark, width: 2.0),
      ),
      child: Row(
        children: [
          const AppIcon(
            Iconsax.warning_25,
            color: AppColors.primaryOrange,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              widget.errorText!,
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
