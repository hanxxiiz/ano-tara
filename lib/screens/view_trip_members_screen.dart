import 'package:flutter/material.dart';

import '../components/molecules/trip_participant_card.dart';
import '../components/organisms/nudge_members_sheet.dart';
import '../components/organisms/remove_participant_sheet.dart';
import '../components/organisms/response_filter_sheet.dart';
import '../components/organisms/trip_members_summary_card.dart';
import '../core/constants/app_colors.dart';
import '../models/trip_participant.dart';
import '../theme/app_theme.dart' show AppFonts;

/// View Trip Members screen displaying response summary counts,
/// Invitation Responses list, Filter By sheet, Nudge Members sheet,
/// and Organizer-only participant removal confirmation.
///
/// Matches Figma screens 07.07, 07.08, 07.09, and 07.10.
class ViewTripMembersScreen extends StatefulWidget {
  final List<TripParticipant>? initialParticipants;
  final bool isOrganizer;

  const ViewTripMembersScreen({
    super.key,
    this.initialParticipants,
    this.isOrganizer = true,
  });

  @override
  State<ViewTripMembersScreen> createState() => _ViewTripMembersScreenState();
}

class _ViewTripMembersScreenState extends State<ViewTripMembersScreen> {
  late List<TripParticipant> _participants;
  TripResponseFilter _activeFilter = TripResponseFilter.all;

  @override
  void initState() {
    super.initState();
    _participants = List<TripParticipant>.from(
      widget.initialParticipants ?? defaultTripParticipants,
    );
  }

  int get _goingCount => _participants
      .where((p) => p.status == TripResponseStatus.going)
      .length;

  int get _notGoingCount => _participants
      .where((p) => p.status == TripResponseStatus.notGoing)
      .length;

  int get _pendingCount => _participants
      .where((p) => p.status == TripResponseStatus.pending)
      .length;

  int get _respondedCount => _goingCount + _notGoingCount;

  List<TripParticipant> get _pendingParticipants => _participants
      .where((p) => p.status == TripResponseStatus.pending)
      .toList();

  List<TripParticipant> get _filteredParticipants => _participants
      .where((p) => _activeFilter.matches(p.status))
      .toList();

  Future<void> _openFilterSheet() async {
    final selected = await showResponseFilterSheet(
      context: context,
      currentFilter: _activeFilter,
    );
    if (!mounted || selected == null) return;
    setState(() {
      _activeFilter = selected;
    });
  }

  Future<void> _openNudgeSheet() async {
    await showNudgeMembersSheet(
      context: context,
      pendingParticipants: _pendingParticipants,
      onNudgeParticipant: _markParticipantNudged,
    );
  }

  void _markParticipantNudged(String participantId) {
    setState(() {
      _participants = _participants.map((p) {
        if (p.id == participantId) {
          return p.copyWith(isNudged: true);
        }
        return p;
      }).toList();
    });
  }

  Future<void> _handleRemoveParticipant(TripParticipant participant) async {
    // Organizer-only safeguard
    if (!widget.isOrganizer || participant.isOrganizer) return;

    final confirmed = await showRemoveParticipantDialog(
      context: context,
      participantName: participant.name,
    );

    if (!mounted || confirmed != true) return;

    setState(() {
      _participants.removeWhere((p) => p.id == participant.id);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${participant.name} removed from the trip'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final visibleParticipants = _filteredParticipants;

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(57),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppBar(
              backgroundColor: AppColors.white,
              elevation: 0,
              scrolledUnderElevation: 0,
              toolbarHeight: 56,
              leadingWidth: 52,
              titleSpacing: 0,
              leading: IconButton(
                tooltip: 'Back',
                onPressed: () => Navigator.of(context).maybePop(),
                icon: const Icon(
                  Icons.arrow_back_rounded,
                  color: AppColors.secondaryDark,
                  size: 24,
                ),
              ),
              title: const Text(
                'View Trip Members',
                style: TextStyle(
                  fontFamily: AppFonts.urbanist,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.secondaryDark,
                ),
              ),
            ),
            const Divider(
              height: 1,
              thickness: 1.2,
              color: AppColors.secondaryDark,
            ),
          ],
        ),
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
          children: [
            // Summary Card
            TripMembersSummaryCard(
              respondedCount: _respondedCount,
              totalCount: _participants.length,
              goingCount: _goingCount,
              notGoingCount: _notGoingCount,
              pendingCount: _pendingCount,
              onNudgeMembersTap: _openNudgeSheet,
            ),
            const SizedBox(height: 24),

            // Invitation Responses header + Filter button
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Invitation Responses',
                    style: TextStyle(
                      fontFamily: AppFonts.urbanist,
                      fontSize: 18.5,
                      fontWeight: FontWeight.w800,
                      color: AppColors.secondaryDark,
                    ),
                  ),
                ),
                _FilterTriggerButton(
                  hasActiveFilter: _activeFilter != TripResponseFilter.all,
                  onTap: _openFilterSheet,
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Participant list or empty state
            if (visibleParticipants.isEmpty)
              _EmptyResponsesCard(
                filter: _activeFilter,
                onResetFilter: _activeFilter != TripResponseFilter.all
                    ? () => setState(
                          () => _activeFilter = TripResponseFilter.all,
                        )
                    : null,
              )
            else
              for (int i = 0; i < visibleParticipants.length; i++) ...[
                TripParticipantCard(
                  participant: visibleParticipants[i],
                  canRemove:
                      widget.isOrganizer && !visibleParticipants[i].isOrganizer,
                  onRemoveTap: () =>
                      _handleRemoveParticipant(visibleParticipants[i]),
                ),
                if (i < visibleParticipants.length - 1)
                  const SizedBox(height: 14),
              ],
          ],
        ),
      ),
    );
  }
}

class _FilterTriggerButton extends StatelessWidget {
  final bool hasActiveFilter;
  final VoidCallback onTap;

  const _FilterTriggerButton({
    required this.hasActiveFilter,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(minHeight: 36),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
        decoration: BoxDecoration(
          color: AppColors.secondaryLight,
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
              Icons.tune_rounded,
              size: 16,
              color: AppColors.secondaryDark,
            ),
            const SizedBox(width: 8),
            const Text(
              'Filter',
              style: TextStyle(
                fontFamily: AppFonts.urbanist,
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.secondaryDark,
              ),
            ),
            if (hasActiveFilter) ...[
              const SizedBox(width: 6),
              Container(
                width: 7,
                height: 7,
                decoration: const BoxDecoration(
                  color: AppColors.primaryOrange,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _EmptyResponsesCard extends StatelessWidget {
  final TripResponseFilter filter;
  final VoidCallback? onResetFilter;

  const _EmptyResponsesCard({
    required this.filter,
    this.onResetFilter,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.secondaryDark, width: 1.8),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            filter == TripResponseFilter.all
                ? 'No trip members yet'
                : 'No ${filter.label.toLowerCase()} members',
            style: const TextStyle(
              fontFamily: AppFonts.urbanist,
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.secondaryDark,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            filter == TripResponseFilter.all
                ? 'Invited participants will appear here.'
                : 'Try selecting a different response filter.',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: AppFonts.openSans,
              fontSize: 13,
              color: AppColors.carla,
            ),
          ),
          if (onResetFilter != null) ...[
            const SizedBox(height: 12),
            TextButton(
              onPressed: onResetFilter,
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primaryNavy,
              ),
              child: const Text(
                'Show all responses',
                style: TextStyle(
                  fontFamily: AppFonts.urbanist,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
