import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../components/atoms/app_avatar.dart';
import '../../../../components/atoms/app_icon.dart';
import '../../../../components/molecules/app_search_filter_bar.dart';
import '../../../../components/organisms/app_main_top_bar.dart';

class TripsTab extends StatefulWidget {
  final VoidCallback? onNavigateToProfile;

  const TripsTab({super.key, this.onNavigateToProfile});

  @override
  State<TripsTab> createState() => _TripsTabState();
}

class _TripsTabState extends State<TripsTab> {
  final _searchController = TextEditingController();

  final List<Map<String, dynamic>> _groups = [
    {
      'name': 'Trip to Bantayan',
      'organizer': 'Louie Abella',
      'nextTrip': 'Next: Bantayan Trip',
    },
    {
      'name': 'The Group',
      'organizer': 'Carla Santos',
      'nextTrip': 'Next: Bantayan Trip',
    },
    {
      'name': 'Weekend Wanderers',
      'organizer': 'You · Organizer',
      'nextTrip': 'Next: Bantayan Trip',
    },
    {
      'name': 'Blackpink',
      'organizer': 'Sarah Jenkins',
      'nextTrip': 'Next: Cebu Food Crawl',
    },
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      // Fixed Non-Scrollable Top Bar
      appBar: AppMainTopBar(
        onProfileTap: widget.onNavigateToProfile,
        onNotificationTap: () => Navigator.pushNamed(context, AppRoutes.invitations),
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // M02 Search & Filter Bar Molecule
              AppSearchFilterBar(
                hintText: 'Search trips...',
                controller: _searchController,
                onFilterTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Filter options opened'),
                      backgroundColor: AppColors.primaryNavy,
                      duration: Duration(milliseconds: 1200),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),

              // Create a Group Button
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    Navigator.pushNamed(context, AppRoutes.createGroup);
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    width: double.infinity,
                    height: 52,
                    decoration: BoxDecoration(
                      color: AppColors.primaryNavy,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.secondaryDark, width: 2.0),
                      boxShadow: const [
                        BoxShadow(
                          color: AppColors.secondaryDark,
                          offset: Offset(0, 4),
                          blurRadius: 0,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const AppIcon(
                          Iconsax.profile_2user5,
                          color: AppColors.white,
                          size: 24,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'Create a Group',
                          style: AppTypography.buttonLarge.copyWith(
                            color: AppColors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Group Cards List
              for (final group in _groups) ...[
                _buildGroupCard(
                  name: group['name'] as String,
                  organizer: group['organizer'] as String,
                  nextTrip: group['nextTrip'] as String,
                ),
                const SizedBox(height: 16),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGroupCard({
    required String name,
    required String organizer,
    required String nextTrip,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(
            context,
            AppRoutes.groupDetail,
            arguments: name,
          );
        },
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(14),
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
          child: Row(
            children: [
              // Terracotta/Orange Large Rounded Square
              Container(
                width: 86,
                height: 86,
                decoration: BoxDecoration(
                  color: AppColors.primaryOrange,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Center(
                  child: AppIcon(
                    Iconsax.profile_2user5,
                    color: AppColors.white,
                    size: 38,
                  ),
                ),
              ),
              const SizedBox(width: 14),

              // Details Column
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: AppTypography.titleLarge.copyWith(
                        color: AppColors.secondaryDark,
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      organizer,
                      style: AppTypography.caption.copyWith(
                        color: AppColors.carla,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 6),

                    // Avatars row (reusable A06 Member token cluster)
                    const AppMemberTokenCluster(extraCount: 3, size: 16),
                    const SizedBox(height: 8),

                    // Next Trip Pill
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFD4DEE8),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        nextTrip,
                        style: AppTypography.caption.copyWith(
                          color: AppColors.secondaryDark,
                          fontWeight: FontWeight.w600,
                          fontSize: 10.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Circular Message / Chat Button on Right
              GestureDetector(
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    AppRoutes.groupChat,
                    arguments: name,
                  );
                },
                child: Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: AppColors.primaryNavy,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.secondaryDark, width: 2.0),
                    boxShadow: const [
                      BoxShadow(
                        color: AppColors.secondaryDark,
                        offset: Offset(0, 3),
                        blurRadius: 0,
                      ),
                    ],
                  ),
                  child: const Center(
                    child: AppIcon(
                      Iconsax.sms5,
                      color: AppColors.white,
                      size: 22,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
