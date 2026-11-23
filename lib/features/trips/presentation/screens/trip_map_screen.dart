import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../components/atoms/app_icon.dart';
import '../../../../components/atoms/app_switch.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../domain/trip_view_models.dart';
import '../widgets/styled_map_canvas.dart';
import '../widgets/trip_card_widgets.dart';

/// Trip Map screen featuring:
/// - Interactive member markers on stylized map canvas
/// - Highlighted meeting point marker with dashed ring & label
/// - Bottom location sharing card with meeting point summary & live members list
/// - Location sharing toggle (disabled in read-only Completed/Cancelled trips)
class TripMapScreen extends StatefulWidget {
  final TripDetailData trip;

  const TripMapScreen({
    super.key,
    required this.trip,
  });

  @override
  State<TripMapScreen> createState() => _TripMapScreenState();
}

class _TripMapScreenState extends State<TripMapScreen> {
  final TransformationController _mapController = TransformationController();
  late List<TripMapMember> _members;
  late bool _isSharingMyLocation;
  String? _selectedMarkerId; // 'meeting_point' or member.id

  @override
  void initState() {
    super.initState();
    _members = List<TripMapMember>.from(widget.trip.mapMembers);
    final currentUser = _members.where((m) => m.isCurrentUser).firstOrNull;
    _isSharingMyLocation =
        !widget.trip.isReadOnly && (currentUser?.isSharingLocation ?? true);
    if (widget.trip.isReadOnly) {
      _members = _members
          .map(
            (m) => m.copyWith(
              isSharingLocation: false,
              statusSubtitle: widget.trip.isCancelled
                  ? 'Sharing ended when trip was cancelled'
                  : 'Sharing ended after trip completion',
            ),
          )
          .toList();
    }
    _selectedMarkerId = 'meeting_point';
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  void _toggleLocationSharing(bool nextValue) {
    if (widget.trip.isReadOnly) return;
    setState(() {
      _isSharingMyLocation = nextValue;
      _members = _members.map((m) {
        if (!m.isCurrentUser) return m;
        return m.copyWith(
          isSharingLocation: nextValue,
          statusSubtitle: nextValue
              ? 'Sharing live • Just now'
              : 'Location sharing paused',
        );
      }).toList();
    });
  }

  void _recenterMap() {
    _mapController.value = Matrix4.identity();
    setState(() => _selectedMarkerId = 'meeting_point');
  }

  void _focusMember(TripMapMember member) {
    setState(() => _selectedMarkerId = member.id);
  }

  int get _activeSharingCount =>
      _members.where((m) => m.isSharingLocation).length;

  @override
  Widget build(BuildContext context) {
    final isReadOnly = widget.trip.isReadOnly;
    final selectedMember = _members
        .where((m) => m.id == _selectedMarkerId)
        .firstOrNull;

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: TripSubTopBar(
        title: 'Trip Map',
        actions: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: isReadOnly
                  ? (widget.trip.isCancelled
                      ? AppColors.primaryOrange
                      : AppColors.semanticYellow)
                  : AppColors.semanticGreenLight,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: AppColors.secondaryDark,
                width: 1.4,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!isReadOnly) ...[
                  Container(
                    width: 7,
                    height: 7,
                    decoration: const BoxDecoration(
                      color: AppColors.semanticGreen,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 5),
                ],
                Text(
                  isReadOnly
                      ? (widget.trip.isCancelled ? 'Cancelled' : 'Completed')
                      : 'Live • $_activeSharingCount active',
                  style: AppTypography.badge.copyWith(
                    fontSize: 11,
                    color: widget.trip.isCancelled
                        ? AppColors.white
                        : AppColors.secondaryDark,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Interactive Map Area
          Expanded(
            child: Stack(
              children: [
                Positioned.fill(
                  child: InteractiveViewer(
                    transformationController: _mapController,
                    minScale: 0.9,
                    maxScale: 2.5,
                    boundaryMargin: const EdgeInsets.all(60),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final w = constraints.maxWidth;
                        final h = constraints.maxHeight;
                        return StyledMapCanvas(
                          child: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              // Meeting Point Marker
                              Positioned(
                                left: (w * widget.trip.meetingPointPosition.dx) -
                                    64,
                                top: (h * widget.trip.meetingPointPosition.dy) -
                                    44,
                                child: _MeetingPointMarker(
                                  label: 'Meeting Point',
                                  isSelected:
                                      _selectedMarkerId == 'meeting_point',
                                  onTap: () => setState(
                                    () => _selectedMarkerId = 'meeting_point',
                                  ),
                                ),
                              ),

                              // Member Markers (only members sharing location)
                              for (final member in _members)
                                if (member.isSharingLocation)
                                  Positioned(
                                    left: (w * member.normalizedPosition.dx) -
                                        34,
                                    top: (h * member.normalizedPosition.dy) -
                                        34,
                                    child: _MemberMapMarker(
                                      member: member,
                                      isSelected:
                                          _selectedMarkerId == member.id,
                                      onTap: () => _focusMember(member),
                                    ),
                                  ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),

                // Top floating info banner when a member is tapped or read-only
                if (isReadOnly)
                  Positioned(
                    top: 12,
                    left: 16,
                    right: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: AppColors.secondaryDark,
                          width: 1.8,
                        ),
                        boxShadow: kTripSmallHardShadow,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_rounded,
                            color: widget.trip.isCancelled
                                ? AppColors.primaryOrange
                                : AppColors.primaryNavy,
                            size: 20,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              widget.trip.isCancelled
                                  ? 'Live location sharing is unavailable because this trip was cancelled.'
                                  : 'Live location sharing ended when this trip was completed.',
                              style: AppTypography.bodySmall.copyWith(
                                color: AppColors.secondaryDark,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else if (selectedMember != null)
                  Positioned(
                    top: 12,
                    left: 16,
                    right: 72,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 9,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: AppColors.secondaryDark,
                          width: 1.8,
                        ),
                        boxShadow: kTripSmallHardShadow,
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              color: selectedMember.avatarColor,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColors.secondaryDark,
                                width: 1.5,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                selectedMember.initials,
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.white,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  selectedMember.name,
                                  style: AppTypography.titleMedium.copyWith(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w800,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  '${selectedMember.distanceFromMeetingPoint} • ${selectedMember.statusSubtitle}',
                                  style: AppTypography.caption.copyWith(
                                    color: AppColors.carla,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                // Floating Right Map Controls (Recenter & Meeting Point Focus)
                Positioned(
                  right: 14,
                  bottom: 16,
                  child: Column(
                    children: [
                      _MapControlButton(
                        icon: Iconsax.gps,
                        tooltip: 'Recenter on Meeting Point',
                        onTap: _recenterMap,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Bottom Location Sharing Card
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              border: Border(
                top: BorderSide(color: AppColors.secondaryDark, width: 2.0),
                left: BorderSide(color: AppColors.secondaryDark, width: 2.0),
                right: BorderSide(color: AppColors.secondaryDark, width: 2.0),
              ),
            ),
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(18, 10, 18, 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Drag handle pill
                    Center(
                      child: Container(
                        width: 44,
                        height: 4.5,
                        decoration: BoxDecoration(
                          color: AppColors.secondaryDark,
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Meeting Point Summary Card
                    GestureDetector(
                      onTap: _recenterMap,
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: AppColors.secondaryDark,
                            width: 1.8,
                          ),
                          boxShadow: kTripHardShadow,
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: AppColors.primaryNavy,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Center(
                                child: AppIcon(
                                  Iconsax.routing_25,
                                  color: AppColors.white,
                                  size: 24,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 7,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppColors.semanticYellow,
                                          borderRadius:
                                              BorderRadius.circular(999),
                                          border: Border.all(
                                            color: AppColors.secondaryDark,
                                            width: 1.0,
                                          ),
                                        ),
                                        child: Text(
                                          'MEETING POINT',
                                          style: AppTypography.badge.copyWith(
                                            fontSize: 9.5,
                                            color: AppColors.secondaryDark,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    widget.trip.meetingPointName,
                                    style: AppTypography.titleMedium.copyWith(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 15,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 2),
                                  Row(
                                    children: [
                                      const AppIcon(
                                        Iconsax.location5,
                                        color: AppColors.primaryOrange,
                                        size: 13,
                                      ),
                                      const SizedBox(width: 4),
                                      Expanded(
                                        child: Text(
                                          widget.trip.meetingPointAddress,
                                          style: AppTypography.bodySmall.copyWith(
                                            color: AppColors.shayne,
                                            fontSize: 12,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
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
                    ),
                    const SizedBox(height: 14),

                    // Location Sharing Toggle Card
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceLight,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: AppColors.secondaryDark,
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: _isSharingMyLocation
                                  ? AppColors.primaryOrange
                                  : AppColors.ann,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: AppColors.secondaryDark,
                                width: 1.4,
                              ),
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.my_location_rounded,
                                color: AppColors.white,
                                size: 18,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Share My Live Location',
                                  style: AppTypography.titleMedium.copyWith(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                Text(
                                  isReadOnly
                                      ? 'Disabled for ${widget.trip.status.badgeLabel.toLowerCase()} trips'
                                      : (_isSharingMyLocation
                                          ? 'Visible to your trip group'
                                          : 'Your marker is hidden from the map'),
                                  style: AppTypography.caption.copyWith(
                                    color: AppColors.carla,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          AppSwitch(
                            value: _isSharingMyLocation,
                            isDisabled: isReadOnly,
                            onChanged: _toggleLocationSharing,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Members Sharing Strip
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Group Members',
                          style: AppTypography.titleMedium.copyWith(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(
                          '$_activeSharingCount of ${_members.length} sharing',
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.carla,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 44,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: _members.length,
                        separatorBuilder: (_, _) => const SizedBox(width: 8),
                        itemBuilder: (context, index) {
                          final member = _members[index];
                          final isSelected = _selectedMarkerId == member.id;
                          return GestureDetector(
                            onTap: member.isSharingLocation
                                ? () => _focusMember(member)
                                : null,
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 180),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.primaryNavy
                                    : (member.isSharingLocation
                                        ? AppColors.white
                                        : AppColors.surfaceMuted),
                                borderRadius: BorderRadius.circular(999),
                                border: Border.all(
                                  color: AppColors.secondaryDark,
                                  width: 1.5,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 24,
                                    height: 24,
                                    decoration: BoxDecoration(
                                      color: member.avatarColor,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: AppColors.secondaryDark,
                                        width: 1.2,
                                      ),
                                    ),
                                    child: Center(
                                      child: Text(
                                        member.initials,
                                        style: const TextStyle(
                                          fontSize: 9.5,
                                          fontWeight: FontWeight.w800,
                                          color: AppColors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    member.name.split(' ').first,
                                    style: AppTypography.bodySmall.copyWith(
                                      fontWeight: FontWeight.w700,
                                      color: isSelected
                                          ? AppColors.white
                                          : (member.isSharingLocation
                                              ? AppColors.secondaryDark
                                              : AppColors.shayne),
                                    ),
                                  ),
                                  const SizedBox(width: 5),
                                  Container(
                                    width: 7,
                                    height: 7,
                                    decoration: BoxDecoration(
                                      color: member.isSharingLocation
                                          ? AppColors.semanticGreen
                                          : AppColors.ann,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MeetingPointMarker extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _MeetingPointMarker({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.primaryNavy
                  : AppColors.secondaryDark,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: AppColors.white, width: 1.5),
              boxShadow: kTripSmallHardShadow,
            ),
            child: Text(
              label,
              style: AppTypography.badge.copyWith(
                color: AppColors.white,
                fontSize: 10.5,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.primaryOrange,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.secondaryDark, width: 2.2),
              boxShadow: kTripSmallHardShadow,
            ),
            child: const Center(
              child: Icon(
                Icons.flag_rounded,
                color: AppColors.white,
                size: 22,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MemberMapMarker extends StatelessWidget {
  final TripMapMember member;
  final bool isSelected;
  final VoidCallback onTap;

  const _MemberMapMarker({
    required this.member,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedScale(
        scale: isSelected ? 1.14 : 1.0,
        duration: const Duration(milliseconds: 180),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: member.avatarColor,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primaryOrange
                          : AppColors.secondaryDark,
                      width: isSelected ? 2.6 : 2.0,
                    ),
                    boxShadow: kTripSmallHardShadow,
                  ),
                  child: Center(
                    child: Text(
                      member.initials,
                      style: const TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w800,
                        color: AppColors.white,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  right: -1,
                  bottom: -1,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: AppColors.semanticGreen,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.white, width: 1.8),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 3),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppColors.secondaryDark,
                  width: 1.2,
                ),
              ),
              child: Text(
                member.isCurrentUser ? 'You' : member.name.split(' ').first,
                style: AppTypography.caption.copyWith(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: AppColors.secondaryDark,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MapControlButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  const _MapControlButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.secondaryDark, width: 1.8),
            boxShadow: kTripSmallHardShadow,
          ),
          child: Center(
            child: Icon(
              icon,
              color: AppColors.secondaryDark,
              size: 20,
            ),
          ),
        ),
      ),
    );
  }
}
