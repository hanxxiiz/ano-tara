import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../components/atoms/app_avatar.dart';
import '../../../../components/molecules/app_search_bar.dart';
import '../../../../components/organisms/app_top_bar.dart';
import '../../../../components/organisms/availability_panel.dart';
import '../../../../components/organisms/member_panel.dart';
import '../../../../components/organisms/overview_summary_panel.dart';
import '../../../../components/organisms/trip_summary_card.dart';

class HomeTab extends StatelessWidget {
  final VoidCallback? onNavigateToTrips;
  final VoidCallback? onNavigateToGroups;

  const HomeTab({
    super.key,
    this.onNavigateToTrips,
    this.onNavigateToGroups,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppTopBar(
        showBackButton: false,
        title: 'Ano Tara!',
        subtitle: 'Bantayan Island Escape',
        actions: [
          IconButton(
            icon: const Icon(Iconsax.notification, color: AppColors.chucky),
            onPressed: () {},
            splashRadius: 22,
          ),
          const Padding(
            padding: EdgeInsets.only(right: 12.0),
            child: AppAvatar(
              name: 'Louie Abella',
              size: 36,
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: AppSpacing.screenPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search Bar Molecule
              const AppSearchBar(
                hintText: 'Search destinations, itineraries...',
              ),
              const SizedBox(height: 20),

              // Overview Summary Panel Organism (AI suggestions & Plus Tier)
              OverviewSummaryPanel(
                title: 'Smart Itinerary Match',
                description:
                    'All 7 members are free this Friday and Saturday. Recommended destination: Bantayan Island Beach & Food Crawl.',
                onGenerateAi: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('AI is generating the optimal 3-day itinerary...'),
                      backgroundColor: AppColors.primaryNavy,
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),

              // Group Availability Panel Organism
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Group Availability',
                    style: AppTypography.titleLarge.copyWith(color: AppColors.chucky),
                  ),
                  TextButton(
                    onPressed: onNavigateToGroups,
                    child: Text(
                      'View All',
                      style: AppTypography.caption.copyWith(
                        color: AppColors.primaryOrange,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const AvailabilityPanel(),
              const SizedBox(height: 24),

              // Upcoming Trip Summary Card Organism
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Upcoming Trip',
                    style: AppTypography.titleLarge.copyWith(color: AppColors.chucky),
                  ),
                  TextButton(
                    onPressed: onNavigateToTrips,
                    child: Text(
                      'All Trips',
                      style: AppTypography.caption.copyWith(
                        color: AppColors.primaryNavy,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              TripSummaryCard(
                title: 'Bantayan Sandbar & Sunset Dinner',
                location: 'Santa Fe, Bantayan',
                dateRange: 'Nov 14 - Nov 16, 2026',
                type: 'Beach Trip',
                amount: 8500.0,
                paidByName: 'Louie Abella',
                onTap: () {},
              ),
              const SizedBox(height: 24),

              // Member Panel Organism
              Text(
                'Trip Organizer',
                style: AppTypography.titleLarge.copyWith(color: AppColors.chucky),
              ),
              const SizedBox(height: 10),
              const MemberPanel(
                member: MemberData(
                  id: '1',
                  name: 'Louie Abella',
                  role: 'Organizer',
                  availableDays: ['Fri', 'Sat', 'Sun'],
                  isCurrentUser: true,
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
