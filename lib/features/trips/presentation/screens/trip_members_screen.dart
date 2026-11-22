import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../components/atoms/app_avatar.dart';
import '../../../../components/atoms/app_icon.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../domain/trip_view_models.dart';
import '../widgets/trip_card_widgets.dart';

/// Read-only "View Trip Members" screen matching:
/// - Figma 11.07 (Completed trip — final RSVP responses): "members responded"
/// - Figma 11.16 (Cancelled trip — historical RSVP responses):
///   "members responded before trip was cancelled"
class TripMembersScreen extends StatefulWidget {
  final TripDetailData trip;

  const TripMembersScreen({
    super.key,
    required this.trip,
  });

  @override
  State<TripMembersScreen> createState() => _TripMembersScreenState();
}

class _TripMembersScreenState extends State<TripMembersScreen> {
  TripMemberRsvp? _activeFilter; // null = All

  void _openFilterSheet() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 28),
          decoration: const BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            border: Border(
              top: BorderSide(color: AppColors.secondaryDark, width: 2.0),
              left: BorderSide(color: AppColors.secondaryDark, width: 2.0),
              right: BorderSide(color: AppColors.secondaryDark, width: 2.0),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.secondaryDark,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Filter Invitation Responses',
                style: AppTypography.h4.copyWith(
                  color: AppColors.secondaryDark,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 12),
              _FilterOptionTile(
                label: 'All Responses',
                selected: _activeFilter == null,
                onTap: () {
                  setState(() => _activeFilter = null);
                  Navigator.of(ctx).pop();
                },
              ),
              const SizedBox(height: 8),
              for (final status in TripMemberRsvp.values) ...[
                _FilterOptionTile(
                  label: status.label,
                  selected: _activeFilter == status,
                  onTap: () {
                    setState(() => _activeFilter = status);
                    Navigator.of(ctx).pop();
                  },
                ),
                const SizedBox(height: 8),
              ],
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isCancelled = widget.trip.isCancelled;
    final filteredMembers = _activeFilter == null
        ? widget.trip.memberResponses
        : widget.trip.memberResponses
            .where((m) => m.status == _activeFilter)
            .toList();

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: const TripSubTopBar(title: 'View Trip Members'),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 28),
          children: [
            // Navy RSVP Summary Card (matches Figma 11.07 & 11.16)
            Container(
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
              decoration: BoxDecoration(
                color: AppColors.primaryNavy,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: AppColors.secondaryDark,
                  width: 2.0,
                ),
                boxShadow: kTripHardShadow,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.baseline,
                              textBaseline: TextBaseline.alphabetic,
                              children: [
                                Text(
                                  '${widget.trip.respondedCount}',
                                  style: AppTypography.h1.copyWith(
                                    color: AppColors.semanticYellow,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 38,
                                    height: 1.0,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'of ${widget.trip.totalInvitedCount}',
                                  style: AppTypography.h2.copyWith(
                                    color: AppColors.white,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 22,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            // Acceptance Criteria: Cancelled trips show
                            // "responded before trip was cancelled"
                            Text(
                              isCancelled
                                  ? 'members responded before trip was cancelled'
                                  : 'members responded',
                              style: AppTypography.bodySmall.copyWith(
                                color: AppColors.white.withValues(alpha: 0.92),
                                fontSize: 12.5,
                                height: 1.35,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      const DashedCircleIconBadge(
                        size: 58,
                        child: AppIcon(
                          Iconsax.profile_2user5,
                          color: AppColors.white,
                          size: 28,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),

                  // 3 stat columns: Going | Not Going | No Response
                  IntrinsicHeight(
                    child: Row(
                      children: [
                        Expanded(
                          child: _RsvpStatColumn(
                            label: 'Going',
                            value: '${widget.trip.goingCount}',
                            valueColor: AppColors.white,
                          ),
                        ),
                        Container(
                          width: 1,
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          color: AppColors.white.withValues(alpha: 0.35),
                        ),
                        Expanded(
                          child: _RsvpStatColumn(
                            label: 'Not Going',
                            value: '${widget.trip.notGoingCount}',
                            valueColor: AppColors.white,
                          ),
                        ),
                        Container(
                          width: 1,
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          color: AppColors.white.withValues(alpha: 0.35),
                        ),
                        Expanded(
                          child: _RsvpStatColumn(
                            label: 'No Response',
                            value: '${widget.trip.noResponseCount}',
                            valueColor: AppColors.semanticYellow,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 22),

            // Section Header + Filter Button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Invitation Responses',
                  style: AppTypography.h4.copyWith(
                    color: AppColors.secondaryDark,
                    fontWeight: FontWeight.w800,
                    fontSize: 17.5,
                  ),
                ),
                GestureDetector(
                  onTap: _openFilterSheet,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _activeFilter != null
                          ? AppColors.semanticYellow
                          : AppColors.secondaryLight,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: AppColors.secondaryDark,
                        width: 1.6,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Iconsax.setting_4,
                          color: AppColors.secondaryDark,
                          size: 15,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          _activeFilter?.label ?? 'Filter',
                          style: AppTypography.caption.copyWith(
                            color: AppColors.secondaryDark,
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            // Member Response Cards
            if (filteredMembers.isEmpty)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.secondaryDark,
                    width: 1.6,
                  ),
                ),
                child: Center(
                  child: Text(
                    'No members match this filter.',
                    style: AppTypography.bodyMedium,
                  ),
                ),
              )
            else
              ...filteredMembers.map(
                (member) => Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: _MemberResponseCard(member: member),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _RsvpStatColumn extends StatelessWidget {
  final String label;
  final String value;
  final Color valueColor;

  const _RsvpStatColumn({
    required this.label,
    required this.value,
    required this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: AppTypography.caption.copyWith(
            color: AppColors.white.withValues(alpha: 0.9),
            fontSize: 11.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppTypography.h1.copyWith(
            color: valueColor,
            fontWeight: FontWeight.w800,
            fontSize: 30,
            height: 1.05,
          ),
        ),
      ],
    );
  }
}

class _MemberResponseCard extends StatelessWidget {
  final TripMemberResponse member;

  const _MemberResponseCard({required this.member});

  Color _pillColor(TripMemberRsvp status) {
    switch (status) {
      case TripMemberRsvp.pending:
        return const Color(0xFFFDE486);
      case TripMemberRsvp.notGoing:
        return const Color(0xFFE87659);
      case TripMemberRsvp.going:
        return const Color(0xFF8EA2BC);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.secondaryDark,
          width: 2.0,
        ),
        boxShadow: kTripHardShadow,
      ),
      child: Row(
        children: [
          AppAvatar.singleUser(size: 52),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  member.fullName,
                  style: AppTypography.titleMedium.copyWith(
                    color: AppColors.secondaryDark,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
                Text(
                  member.username,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.carla,
                    fontSize: 12.5,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  constraints: const BoxConstraints(minWidth: 92),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: _pillColor(member.status),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    member.status.label,
                    textAlign: TextAlign.center,
                    style: AppTypography.caption.copyWith(
                      color: AppColors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterOptionTile extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterOptionTile({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: selected ? AppColors.primaryNavy : AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.secondaryDark, width: 1.6),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: AppTypography.titleMedium.copyWith(
                color: selected ? AppColors.white : AppColors.secondaryDark,
                fontWeight: FontWeight.w700,
              ),
            ),
            if (selected)
              const Icon(
                Icons.check_circle_rounded,
                color: AppColors.semanticYellow,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }
}
