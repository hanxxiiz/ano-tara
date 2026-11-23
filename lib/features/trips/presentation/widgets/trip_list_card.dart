import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../data/trip_repository.dart';
import 'trip_map_banner.dart';
import 'trip_member_avatars.dart';

/// Trip Card for the Trips List screen matching Figma 07.01.
class TripListCard extends StatefulWidget {
  final TripModel trip;
  final VoidCallback onTap;

  const TripListCard({
    super.key,
    required this.trip,
    required this.onTap,
  });

  @override
  State<TripListCard> createState() => _TripListCardState();
}

class _TripListCardState extends State<TripListCard> {
  bool _isPressed = false;

  void _handleTapDown(TapDownDetails _) => setState(() => _isPressed = true);
  void _handleTapCancel() => setState(() => _isPressed = false);

  Future<void> _handleTapUp(TapUpDetails _) async {
    if (!_isPressed) setState(() => _isPressed = true);
    await Future<void>.delayed(const Duration(milliseconds: 90));
    if (mounted) setState(() => _isPressed = false);
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    final trip = widget.trip;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      child: AnimatedScale(
        scale: _isPressed ? 0.98 : 1.0,
        duration: Duration(milliseconds: _isPressed ? 80 : 200),
        curve: Curves.easeOutCubic,
        child: AnimatedContainer(
          duration: Duration(milliseconds: _isPressed ? 80 : 200),
          transform: Matrix4.translationValues(0, _isPressed ? 2.0 : 0.0, 0),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: AppColors.secondaryDark,
              width: 2.0,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.secondaryDark,
                offset: Offset(0, _isPressed ? 2 : 5),
                blurRadius: 0,
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top stylized map header + status pill
              TripMapBanner(
                status: trip.status,
                height: 100,
              ),
              Container(
                height: 1.8,
                width: double.infinity,
                color: AppColors.secondaryDark,
              ),
              // Card Details
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            trip.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.h3.copyWith(
                              color: AppColors.secondaryDark,
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Row(
                            children: [
                              const Icon(
                                Iconsax.location,
                                size: 15,
                                color: AppColors.primaryOrange,
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  trip.destination,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTypography.bodySmall.copyWith(
                                    color: AppColors.carla,
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(
                                Iconsax.calendar_1,
                                size: 15,
                                color: AppColors.secondaryDark,
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  trip.dateRangeLabel,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTypography.bodySmall.copyWith(
                                    color: AppColors.carla,
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          TripMemberAvatars(
                            members: trip.members,
                            maxVisible: 3,
                            size: 26,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Circular outlined right-arrow button
                    Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.secondaryDark,
                          width: 1.6,
                        ),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.arrow_forward_rounded,
                          size: 18,
                          color: AppColors.secondaryDark,
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
}
