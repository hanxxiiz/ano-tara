import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../app_routes.dart';
import '../theme/app_theme.dart';
import '../widgets/hero_banner_trio.dart';
import '../widgets/home_placeholders.dart';

/// Home Screen UI
///
/// Responsive, mobile-first dashboard for Ano Tara group travel planning app.
/// Matches the visual reference layout, spacing, colors, and typography.
///
/// All 6 designated components (Topbar, Navbar, Button, Groups Tile,
/// Upcoming Trips Tile, Action Needed Tile) are isolated placeholders
/// ready for drop-in replacement by existing/in-progress components.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PageController _tripsPageController = PageController();
  int _currentTripIndex = 0;

  @override
  void dispose() {
    _tripsPageController.dispose();
    super.dispose();
  }

  /// Personalized greeting name from Supabase user session or default.
  String get _greetingName {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      final name = user?.userMetadata?['username'] ??
          user?.userMetadata?['first_name'] ??
          user?.email?.split('@').first;
      if (name != null && name.toString().trim().isNotEmpty) {
        return name.toString().trim();
      }
    } catch (_) {
      // Supabase uninitialized or offline fallback
    }
    return 'blackxswann';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBackground,

      // =======================================================================
      // A. TOPBAR
      // =======================================================================
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: SafeArea(
          bottom: false,
          // PLACEHOLDER: Replace with the existing Topbar component
          child: TopbarPlaceholder(
            onAvatarTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Avatar tapped')),
              );
            },
            onNotificationTap: () {
              Navigator.of(context).pushNamed(AppRoutes.notifications);
            },
            onSettingsTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Settings tapped')),
              );
            },
          ),
        ),
      ),

      // =======================================================================
      // MAIN SCROLLABLE CONTENT (Sections B through F)
      // =======================================================================
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppTokens.pagePaddingHorizontal,
            vertical: 12,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ---------------------------------------------------------------
              // B. GREETING SECTION
              // ---------------------------------------------------------------
              Text(
                'Good day, $_greetingName!',
                style: const TextStyle(
                  fontFamily: AppFonts.urbanist,
                  color: AppColors.primaryText,
                  fontSize: 21,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 16),

              // ---------------------------------------------------------------
              // C. PROMOTIONAL BANNER
              // ---------------------------------------------------------------
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.promotionalBanner,
                  borderRadius: BorderRadius.circular(AppTokens.cardRadius),
                  border: Border.all(
                    color: AppColors.primaryDarkAccent,
                    width: AppTokens.borderWidth,
                  ),
                  boxShadow: AppTokens.hardShadow,
                ),
                clipBehavior: Clip.antiAlias,
                child: Stack(
                  children: [
                    // Illustration of friends positioned on the right
                    const Positioned(
                      right: -2,
                      bottom: 0,
                      child: HeroBannerTrio(
                        width: 155,
                        height: 180,
                      ),
                    ),
                    // Banner Text and CTA Button on the left
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Tara? Let's\nmake it happen",
                            style: TextStyle(
                              fontFamily: AppFonts.urbanist,
                              color: Color(0xFF0F0331),
                              fontSize: 22,
                              fontWeight: FontWeight.w800, // Urbanist ExtraBold
                              height: 1.15,
                              letterSpacing: -0.4,
                            ),
                          ),
                          const SizedBox(height: 8),
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 175),
                            child: const Text(
                              "Get the group together and start planning what's next.",
                              style: TextStyle(
                                fontFamily: AppFonts.openSans,
                                color: Color(0xFF0F0331),
                                fontSize: 11.5,
                                fontWeight: FontWeight.normal, // Open Sans Regular
                                height: 1.35,
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),
                          // PLACEHOLDER: Replace with the existing Button component
                          ButtonPlaceholder(
                            label: 'Plan a Trip',
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Plan a Trip tapped')),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppTokens.sectionSpacing),

              // ---------------------------------------------------------------
              // D. GROUPS SECTION
              // ---------------------------------------------------------------
              _buildSectionHeading('Groups'),
              const SizedBox(height: 12),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: [
                    // PLACEHOLDER: Replace with the existing GroupsTile component
                    GroupsTilePlaceholder(
                      name: 'The Group',
                      onTap: () => _onGroupTap('The Group'),
                    ),
                    const SizedBox(width: 12),

                    // PLACEHOLDER: Replace with the existing GroupsTile component
                    GroupsTilePlaceholder(
                      name: 'Blackpink',
                      onTap: () => _onGroupTap('Blackpink'),
                    ),
                    const SizedBox(width: 12),

                    // PLACEHOLDER: Replace with the existing GroupsTile component
                    GroupsTilePlaceholder(
                      name: 'Twice',
                      onTap: () => _onGroupTap('Twice'),
                    ),
                    const SizedBox(width: 12),

                    // PLACEHOLDER: Replace with the existing GroupsTile component
                    GroupsTilePlaceholder(
                      name: 'Group 4',
                      onTap: () => _onGroupTap('Group 4'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppTokens.sectionSpacing),

              // ---------------------------------------------------------------
              // E. UPCOMING TRIPS SECTION
              // ---------------------------------------------------------------
              _buildSectionHeading('Upcoming Trips'),
              const SizedBox(height: 12),
              SizedBox(
                height: 240,
                child: PageView(
                  controller: _tripsPageController,
                  onPageChanged: (index) {
                    setState(() {
                      _currentTripIndex = index;
                    });
                  },
                  children: [
                    // Primary Upcoming Trip from reference
                    Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      // PLACEHOLDER: Replace with the existing UpcomingTripsTile component
                      child: UpcomingTripsTilePlaceholder(
                        destination: 'Bantayan Trip',
                        location: 'Bantayan, Philippines',
                        group: 'The Group (6 going)',
                        dates: 'Oct 10 - Oct 15',
                        imageUrl:
                            'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?auto=format&fit=crop&w=800&q=80',
                        onTap: () => _onTripTap('Bantayan Trip'),
                      ),
                    ),
                    // Carousel Slide 2 Placeholder
                    Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      // PLACEHOLDER: Replace with the existing UpcomingTripsTile component
                      child: UpcomingTripsTilePlaceholder(
                        destination: 'Siargao Island Getaway',
                        location: 'Siargao, Philippines',
                        group: 'Twice (5 going)',
                        dates: 'Nov 12 - Nov 18',
                        imageUrl:
                            'https://images.unsplash.com/photo-1544551763-46a013bb70d5?auto=format&fit=crop&w=800&q=80',
                        onTap: () => _onTripTap('Siargao Island Getaway'),
                      ),
                    ),
                    // Carousel Slide 3 Placeholder
                    Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      // PLACEHOLDER: Replace with the existing UpcomingTripsTile component
                      child: UpcomingTripsTilePlaceholder(
                        destination: 'Baguio Mountain Retreat',
                        location: 'Baguio, Philippines',
                        group: 'Blackpink (4 going)',
                        dates: 'Dec 01 - Dec 05',
                        imageUrl:
                            'https://images.unsplash.com/photo-1506744038136-46273834b3fb?auto=format&fit=crop&w=800&q=80',
                        onTap: () => _onTripTap('Baguio Mountain Retreat'),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),

              // Pagination Indicators beneath carousel
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(3, (index) {
                  final isActive = _currentTripIndex == index;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: isActive
                          ? AppColors.promotionalBanner
                          : AppColors.primaryBackground,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.primaryDarkAccent,
                        width: 1.5,
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: AppTokens.sectionSpacing),

              // ---------------------------------------------------------------
              // F. ACTION NEEDED SECTION
              // ---------------------------------------------------------------
              _buildSectionHeading('Action Needed'),
              const SizedBox(height: 12),

              // 1. Pending Invitations
              // PLACEHOLDER: Replace with the existing ActionNeededTile component
              ActionNeededTilePlaceholder(
                title: 'Pending Invitations',
                description: '5 pending invitations are waiting for your response.',
                badgeColor: AppColors.primaryBlue,
                icon: Icons.mark_email_unread_rounded,
                onTap: () => Navigator.of(context).pushNamed(AppRoutes.notifications),
              ),
              const SizedBox(height: 12),

              // 2. Unsettled Expenses
              // PLACEHOLDER: Replace with the existing ActionNeededTile component
              ActionNeededTilePlaceholder(
                title: 'Unsettled Expenses',
                description: 'You have an unpaid ₱420 balance for Bantayan Trip.',
                badgeColor: AppColors.promotionalBanner,
                icon: Icons.paid_rounded,
                onTap: () => _onActionTap('Unsettled Expenses'),
              ),
              const SizedBox(height: 12),

              // 3. Waiting for Responses
              // PLACEHOLDER: Replace with the existing ActionNeededTile component
              ActionNeededTilePlaceholder(
                title: 'Waiting for Responses',
                description: '3 members haven\'t confirmed Bantayan Trip.',
                badgeColor: AppColors.secondaryYellow,
                icon: Icons.mark_email_read_rounded,
                onTap: () => _onActionTap('Waiting for Responses'),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),

      // =======================================================================
      // G. BOTTOM NAVBAR
      // =======================================================================
      // PLACEHOLDER: Replace with the existing Navbar component
      bottomNavigationBar: NavbarPlaceholder(
        selectedIndex: 0,
        onItemSelected: (index) {
          // Navigation logic placeholder
        },
        onCreatePressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Create trip (+) tapped')),
          );
        },
      ),
    );
  }

  Widget _buildSectionHeading(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontFamily: AppFonts.urbanist,
        color: AppColors.primaryText,
        fontSize: 18,
        fontWeight: FontWeight.bold,
        letterSpacing: -0.2,
      ),
    );
  }

  void _onGroupTap(String groupName) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Group "$groupName" tapped')),
    );
  }

  void _onTripTap(String tripName) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Trip "$tripName" tapped')),
    );
  }

  void _onActionTap(String actionTitle) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Action "$actionTitle" tapped')),
    );
  }
}
