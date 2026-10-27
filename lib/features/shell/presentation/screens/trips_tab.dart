import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_radii.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../components/atoms/app_button.dart';
import '../../../../components/molecules/app_search_bar.dart';
import '../../../../components/organisms/app_top_bar.dart';
import '../../../../components/organisms/trip_summary_card.dart';

class TripsTab extends StatefulWidget {
  const TripsTab({super.key});

  @override
  State<TripsTab> createState() => _TripsTabState();
}

class _TripsTabState extends State<TripsTab> {
  int _selectedFilter = 0; // 0: All, 1: Upcoming, 2: Completed, 3: Loading Demo
  final List<String> _filters = ['All', 'Upcoming', 'Completed', 'Simulate Loading'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const AppTopBar(
        showBackButton: false,
        title: 'Trips & Hangouts',
        subtitle: 'Manage your group itineraries',
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: AppSearchBar(
                hintText: 'Search trips by title or location...',
                onChanged: (val) {},
              ),
            ),

            // Filter Pills
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: List.generate(_filters.length, (index) {
                    final isSelected = _selectedFilter == index;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: ChoiceChip(
                        label: Text(_filters[index]),
                        selected: isSelected,
                        onSelected: (_) => setState(() => _selectedFilter = index),
                        labelStyle: AppTypography.caption.copyWith(
                          color: isSelected ? AppColors.white : AppColors.chucky,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                        ),
                        selectedColor: AppColors.primaryNavy,
                        backgroundColor: AppColors.surfaceLight,
                        shape: RoundedRectangleBorder(
                          borderRadius: AppRadii.radiusPill,
                          side: BorderSide(
                            color: isSelected ? AppColors.primaryNavy : AppColors.borderLight,
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ),

            // Content List
            Expanded(
              child: _buildTripsList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTripsList() {
    if (_selectedFilter == 3) {
      // Loading State Demo
      return ListView.separated(
        padding: AppSpacing.screenPadding,
        itemCount: 3,
        separatorBuilder: (_, __) => const SizedBox(height: 16),
        itemBuilder: (_, __) => const TripSummaryCard(
          title: '',
          location: '',
          dateRange: '',
          type: '',
          amount: 0,
          paidByName: '',
          isLoading: true,
        ),
      );
    }

    if (_selectedFilter == 2) {
      // Empty State Demo
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: const BoxDecoration(
                  color: AppColors.surfaceLight,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Iconsax.archive_book,
                  size: 36,
                  color: AppColors.shayne,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'No Completed Trips Yet',
                style: AppTypography.titleLarge.copyWith(color: AppColors.chucky),
              ),
              const SizedBox(height: 6),
              Text(
                'Once your group finishes an adventure, trip records will appear here.',
                textAlign: TextAlign.center,
                style: AppTypography.bodySmall,
              ),
              const SizedBox(height: 20),
              AppButton(
                text: 'View Upcoming Trips',
                variant: AppButtonVariant.primaryOrange,
                size: AppButtonSize.small,
                isFullWidth: false,
                onPressed: () => setState(() => _selectedFilter = 1),
              ),
            ],
          ),
        ),
      );
    }

    final trips = [
      (
        title: 'Bantayan Island Beach & Sunset Camp',
        location: 'Santa Fe, Bantayan',
        dateRange: 'Nov 14 - Nov 16, 2026',
        type: 'Beach Trip',
        amount: 8500.0,
        paidByName: 'Louie Abella',
      ),
      (
        title: 'Cebu City Heritage & Food Crawl',
        location: 'Colon & IT Park, Cebu',
        dateRange: 'Dec 05 - Dec 06, 2026',
        type: 'Food Trips',
        amount: 3200.0,
        paidByName: 'Carla Santos',
      ),
      (
        title: 'Osmeña Peak Sunrise Trek',
        location: 'Dalaguete, Cebu',
        dateRange: 'Jan 10 - Jan 11, 2027',
        type: 'Hiking',
        amount: 4100.0,
        paidByName: 'Ann Reyes',
      ),
    ];

    return ListView.separated(
      padding: AppSpacing.screenPadding,
      itemCount: trips.length,
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final item = trips[index];
        return TripSummaryCard(
          title: item.title,
          location: item.location,
          dateRange: item.dateRange,
          type: item.type,
          amount: item.amount,
          paidByName: item.paidByName,
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Selected trip: ${item.title}'),
                backgroundColor: AppColors.primaryNavy,
              ),
            );
          },
        );
      },
    );
  }
}
