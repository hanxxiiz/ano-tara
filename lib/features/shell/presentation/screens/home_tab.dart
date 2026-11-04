import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../main.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../components/atoms/app_button.dart';
import '../../../../components/atoms/app_icon.dart';
import '../../../../components/organisms/app_main_top_bar.dart';
import '../../../../components/organisms/trip_summary_card.dart';

class HomeTab extends StatefulWidget {
  final VoidCallback? onNavigateToTrips;
  final VoidCallback? onNavigateToGroups;
  final VoidCallback? onNavigateToProfile;

  const HomeTab({
    super.key,
    this.onNavigateToTrips,
    this.onNavigateToGroups,
    this.onNavigateToProfile,
  });

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  String get _username {
    final user = supabase.auth.currentUser;
    final name = user?.userMetadata?['username'] ??
        user?.userMetadata?['first_name'] ??
        user?.email?.split('@').first;
    if (name != null && name.toString().isNotEmpty) {
      return name.toString();
    }
    return 'blackxswann';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      // Fixed Non-Scrollable Top Bar
      appBar: AppMainTopBar(
        onProfileTap: widget.onNavigateToProfile,
        onNotificationTap: () =>
            Navigator.pushNamed(context, AppRoutes.invitations),
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Greeting
              Text(
                'Good day, $_username!',
                style: AppTypography.h3.copyWith(
                  color: AppColors.secondaryDark,
                  fontWeight: FontWeight.w800,
                  fontSize: 21,
                ),
              ),
              const SizedBox(height: 16),

              // Hero Banner: Orange container with 2px border and hard shadow
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.primaryOrange,
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
                child: Stack(
                  children: [
                    Positioned(
                      right: 4,
                      bottom: 0,
                      top: 0,
                      child: SizedBox(
                        width: 145,
                        height: 150,
                        child: CustomPaint(
                          painter: _TrioIllustrationPainter(),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 18, vertical: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Tara? Let's\nmake it happen",
                            style: AppTypography.h2.copyWith(
                              color: AppColors.secondaryDark,
                              fontWeight: FontWeight.w900,
                              height: 1.15,
                              fontSize: 22,
                            ),
                          ),
                          const SizedBox(height: 8),
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 210),
                            child: FractionallySizedBox(
                              widthFactor: 0.54,
                              child: Text(
                                "Get the group together and start planning what's next.",
                                style: AppTypography.bodySmall.copyWith(
                                  color: AppColors.secondaryDark
                                      .withValues(alpha: 0.9),
                                  fontWeight: FontWeight.w600,
                                  fontSize: 11.5,
                                  height: 1.3,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          AppButton(
                            text: 'Plan a Trip',
                            onPressed: () =>
                                Navigator.pushNamed(context, AppRoutes.planTrip),
                            isFullWidth: false,
                            customHeight: 38,
                            borderRadius: 12,
                            variant: AppButtonVariant.primaryNavy,
                            size: AppButtonSize.small,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Groups Section
              Text(
                'Groups',
                style: AppTypography.titleLarge.copyWith(
                  color: AppColors.secondaryDark,
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 14),

              // Horizontal Groups List
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: [
                    _buildGroupItem(
                      name: 'The Group',
                      color: AppColors.semanticYellow,
                      onTap: () {
                        Navigator.pushNamed(context, AppRoutes.groupDetail,
                            arguments: 'The Group');
                      },
                    ),
                    const SizedBox(width: 14),
                    _buildGroupItem(
                      name: 'Blackpink',
                      color: AppColors.creamYellow,
                      onTap: () {
                        Navigator.pushNamed(context, AppRoutes.groupDetail,
                            arguments: 'Blackpink');
                      },
                    ),
                    const SizedBox(width: 14),
                    _buildGroupItem(
                      name: 'Twice',
                      color: AppColors.semanticYellow,
                      onTap: () {
                        Navigator.pushNamed(context, AppRoutes.groupDetail,
                            arguments: 'Twice');
                      },
                    ),
                    const SizedBox(width: 14),
                    _buildGroupItem(
                      name: 'Barkada',
                      color: AppColors.creamYellow,
                      onTap: () {
                        Navigator.pushNamed(context, AppRoutes.groupDetail,
                            arguments: 'Barkada');
                      },
                    ),
                    const SizedBox(width: 14),
                    _buildAddGroupItem(
                      onTap: () {
                        Navigator.pushNamed(context, AppRoutes.createGroup);
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 26),

              // Upcoming Trips Section
              Text(
                'Upcoming Trips',
                style: AppTypography.titleLarge.copyWith(
                  color: AppColors.secondaryDark,
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 14),

              // Upcoming Trip Card (Reusable O03 TripSummaryCard Organism)
              TripSummaryCard(
                title: 'Bantayan Trip',
                location: 'Bantayan, Philippines',
                groupLabel: 'The Group (6 going)',
                dateRange: 'Oct 10 - Oct 15',
                onTap: () {
                  Navigator.pushNamed(context, AppRoutes.tripOverview);
                },
              ),
              const SizedBox(height: 12),

              // Carousel 3-dot indicator
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 7,
                    height: 7,
                    decoration: const BoxDecoration(
                      color: AppColors.semanticRed,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    width: 7,
                    height: 7,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: AppColors.secondaryDark, width: 1.4),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    width: 7,
                    height: 7,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: AppColors.secondaryDark, width: 1.4),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Action Needed Section
              Text(
                'Action Needed',
                style: AppTypography.titleLarge.copyWith(
                  color: AppColors.secondaryDark,
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 14),

              // Card 1: Pending Invitations
              _buildActionNeededCard(
                title: 'Pending Invitations',
                subtitle:
                    '5 pending invitations are waiting for your response.',
                badgeColor: AppColors.primaryNavy,
                badgeIcon: Iconsax.sms_star5,
                onTap: () {
                  Navigator.pushNamed(context, AppRoutes.invitations);
                },
              ),
              const SizedBox(height: 14),

              // Card 2: Unsettled Expenses
              _buildActionNeededCard(
                title: 'Unsettled Expenses',
                subtitle: 'You have an unpaid ₱420 balance for Bantayan Trip.',
                badgeColor: AppColors.primaryOrange,
                badgeIcon: Iconsax.moneys5,
                onTap: () {
                  Navigator.pushNamed(context, AppRoutes.expenseUpdates);
                },
              ),
              const SizedBox(height: 14),

              // Card 3: Waiting for Responses
              _buildActionNeededCard(
                title: 'Waiting for Responses',
                subtitle: "3 members haven't confirmed Bantayan Trip.",
                badgeColor: AppColors.semanticYellow,
                badgeIcon: Iconsax.sms_star5,
                onTap: () {
                  Navigator.pushNamed(context, AppRoutes.memberResponses);
                },
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGroupItem({
    required String name,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        children: [
          Container(
            width: 82,
            height: 82,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.secondaryDark, width: 2.0),
              boxShadow: const [
                BoxShadow(
                  color: AppColors.secondaryDark,
                  offset: Offset(0, 4),
                  blurRadius: 0,
                ),
              ],
            ),
            child: const Center(
              child: AppIcon(
                Iconsax.profile_2user5,
                color: AppColors.primaryOrange,
                size: 34,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            name,
            style: AppTypography.caption.copyWith(
              color: AppColors.secondaryDark,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddGroupItem({required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        children: [
          Container(
            width: 82,
            height: 82,
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.secondaryDark, width: 2.0),
              boxShadow: const [
                BoxShadow(
                  color: AppColors.secondaryDark,
                  offset: Offset(0, 4),
                  blurRadius: 0,
                ),
              ],
            ),
            child: const Center(
              child: Icon(
                Iconsax.add,
                color: AppColors.secondaryDark,
                size: 30,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'New Group',
            style: AppTypography.caption.copyWith(
              color: AppColors.secondaryDark,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionNeededCard({
    required String title,
    required String subtitle,
    required Color badgeColor,
    required IconData badgeIcon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(18),
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
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: badgeColor,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.secondaryDark, width: 1.5),
              ),
              child: Center(
                child: AppIcon(
                  badgeIcon,
                  color: AppColors.white,
                  size: 26,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTypography.titleMedium.copyWith(
                      color: AppColors.secondaryDark,
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.carla,
                      fontSize: 12,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Iconsax.arrow_right_3,
              color: AppColors.secondaryDark,
              size: 22,
            ),
          ],
        ),
      ),
    );
  }
}

class _TrioIllustrationPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final stroke = Paint()
      ..color = AppColors.secondaryDark
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final yellowFill = Paint()..color = AppColors.semanticYellow;
    final creamFill = Paint()..color = AppColors.creamYellow;
    final navyFill = Paint()..color = AppColors.primaryNavy;
    final whiteFill = Paint()..color = AppColors.white;
    final darkFill = Paint()..color = AppColors.secondaryDark;

    final leftBody = RRect.fromRectAndCorners(
      Rect.fromLTWH(size.width * 0.12, size.height * 0.44, 34, 48),
      topLeft: const Radius.circular(16),
      topRight: const Radius.circular(16),
    );
    canvas.drawRRect(leftBody, creamFill);
    canvas.drawRRect(leftBody, stroke);
    canvas.drawCircle(
        Offset(size.width * 0.24, size.height * 0.34), 12, creamFill);
    canvas.drawCircle(
        Offset(size.width * 0.24, size.height * 0.34), 12, stroke);

    final rightBody = RRect.fromRectAndCorners(
      Rect.fromLTWH(size.width * 0.62, size.height * 0.46, 36, 48),
      topLeft: const Radius.circular(16),
      topRight: const Radius.circular(16),
    );
    canvas.drawRRect(rightBody, navyFill);
    canvas.drawRRect(rightBody, stroke);
    canvas.drawCircle(
        Offset(size.width * 0.74, size.height * 0.36), 12, whiteFill);
    canvas.drawCircle(
        Offset(size.width * 0.74, size.height * 0.36), 12, stroke);

    final centerBody = RRect.fromRectAndCorners(
      Rect.fromLTWH(size.width * 0.33, size.height * 0.40, 44, 56),
      topLeft: const Radius.circular(20),
      topRight: const Radius.circular(20),
    );
    canvas.drawRRect(centerBody, yellowFill);
    canvas.drawRRect(centerBody, stroke);
    canvas.drawCircle(
        Offset(size.width * 0.49, size.height * 0.28), 14, whiteFill);
    canvas.drawCircle(
        Offset(size.width * 0.49, size.height * 0.28), 14, stroke);

    final glassL = RRect.fromRectAndRadius(
      Rect.fromCenter(
          center: Offset(size.width * 0.45, size.height * 0.27),
          width: 7,
          height: 5),
      const Radius.circular(1.5),
    );
    final glassR = RRect.fromRectAndRadius(
      Rect.fromCenter(
          center: Offset(size.width * 0.53, size.height * 0.27),
          width: 7,
          height: 5),
      const Radius.circular(1.5),
    );
    canvas.drawRRect(glassL, darkFill);
    canvas.drawRRect(glassR, darkFill);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
