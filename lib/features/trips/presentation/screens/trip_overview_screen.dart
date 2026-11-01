import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../components/atoms/app_button.dart';

class TripOverviewScreen extends StatelessWidget {
  final String title;
  final String location;
  final String dates;
  final String groupName;

  const TripOverviewScreen({
    super.key,
    this.title = 'Bantayan Trip',
    this.location = 'Bantayan Island, Cebu, Philippines',
    this.dates = 'Oct 10 - Oct 15, 2026',
    this.groupName = 'The Group',
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_left, color: AppColors.chucky, size: 24),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Trip Details',
          style: AppTypography.titleLarge.copyWith(color: AppColors.chucky),
        ),
        actions: [
          IconButton(
            icon: const Icon(Iconsax.share, color: AppColors.chucky),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Iconsax.more, color: AppColors.chucky),
            onPressed: () {},
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hero Trip Card
              Container(
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.chucky, width: 2.0),
                  boxShadow: const [
                    BoxShadow(
                      color: AppColors.chucky,
                      offset: Offset(0, 4),
                      blurRadius: 0,
                    ),
                  ],
                ),
                clipBehavior: Clip.antiAlias,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Beach Image Header
                    SizedBox(
                      height: 160,
                      width: double.infinity,
                      child: Image.network(
                        'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=800&q=80',
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: const Color(0xFF64B5F6),
                          child: const Center(
                            child: Icon(Iconsax.sun_1, size: 48, color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                title,
                                style: AppTypography.h3.copyWith(
                                  color: AppColors.chucky,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryOrangeLight,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: AppColors.primaryOrange, width: 1.5),
                                ),
                                child: Text(
                                  'Confirmed',
                                  style: AppTypography.caption.copyWith(
                                    color: AppColors.primaryOrange,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              const Icon(Iconsax.location, size: 16, color: AppColors.primaryNavy),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  location,
                                  style: AppTypography.bodySmall.copyWith(
                                    color: AppColors.chucky,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Iconsax.calendar_1, size: 16, color: AppColors.primaryNavy),
                              const SizedBox(width: 8),
                              Text(
                                dates,
                                style: AppTypography.bodySmall.copyWith(
                                  color: AppColors.chucky,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Iconsax.profile_2user, size: 16, color: AppColors.primaryNavy),
                              const SizedBox(width: 8),
                              Text(
                                '$groupName (6 members going)',
                                style: AppTypography.bodySmall.copyWith(
                                  color: AppColors.chucky,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Itinerary Summary
              Text(
                'Itinerary Highlights',
                style: AppTypography.titleLarge.copyWith(color: AppColors.chucky),
              ),
              const SizedBox(height: 12),
              _buildItineraryCard(
                day: 'Day 1',
                title: 'Santa Fe Arrival & Camp Check-in',
                time: '10:00 AM - 6:00 PM',
                desc: 'Hagnaya Port Ferry to Santa Fe port, check in at Kota Beach, sunset hangout.',
              ),
              const SizedBox(height: 10),
              _buildItineraryCard(
                day: 'Day 2',
                title: 'Virgin Island Hopping & Cliff Jumping',
                time: '8:00 AM - 4:00 PM',
                desc: 'Private boat tour, snorkeling at fish sanctuary, Ogtong Cave tour.',
              ),
              const SizedBox(height: 10),
              _buildItineraryCard(
                day: 'Day 3',
                title: 'MJ Square Food Crawl & Departure',
                time: '9:00 AM - 2:00 PM',
                desc: 'Seafood brunch at MJ Square, souvenir shopping, ferry back to mainland.',
              ),
              const SizedBox(height: 24),

              // Budget Summary Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.chucky, width: 2.0),
                  boxShadow: const [
                    BoxShadow(
                      color: AppColors.chucky,
                      offset: Offset(0, 3),
                      blurRadius: 0,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Estimated Total Budget',
                          style: AppTypography.caption.copyWith(color: AppColors.shayne),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '₱8,500.00',
                          style: AppTypography.h3.copyWith(
                            color: AppColors.chucky,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                    AppButton(
                      text: 'View Split',
                      variant: AppButtonVariant.primaryNavy,
                      size: AppButtonSize.small,
                      isFullWidth: false,
                      onPressed: () {
                        Navigator.of(context).pushNamed('/expense-updates');
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Action Buttons
              AppButton(
                text: 'View Member Status',
                variant: AppButtonVariant.primaryOrange,
                iconLeading: const Icon(Iconsax.profile_2user, color: AppColors.white, size: 20),
                onPressed: () {
                  Navigator.of(context).pushNamed('/member-responses');
                },
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildItineraryCard({
    required String day,
    required String title,
    required String time,
    required String desc,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.chucky, width: 2.0),
        boxShadow: const [
          BoxShadow(
            color: AppColors.chucky,
            offset: Offset(0, 3),
            blurRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.primaryNavy,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  day,
                  style: AppTypography.caption.copyWith(
                    color: AppColors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Text(
                time,
                style: AppTypography.caption.copyWith(color: AppColors.shayne),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: AppTypography.titleMedium.copyWith(color: AppColors.chucky),
          ),
          const SizedBox(height: 4),
          Text(
            desc,
            style: AppTypography.bodySmall.copyWith(color: AppColors.carla),
          ),
        ],
      ),
    );
  }
}
