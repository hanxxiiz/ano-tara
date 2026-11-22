import 'package:flutter/material.dart';
import '../../../../components/atoms/app_button.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../data/trip_repository.dart';

enum TripRoleFilter {
  allRoles,
  organizedByMe,
  joinedTrips,
}

enum TripSortOption {
  dateNewestFirst,
  dateOldestFirst,
  nameAZ,
  nameZA,
}

class TripFilterState {
  final TripStatus? status; // null = All Trips
  final TripRoleFilter role;
  final TripSortOption sortBy;

  const TripFilterState({
    this.status,
    this.role = TripRoleFilter.allRoles,
    this.sortBy = TripSortOption.dateNewestFirst,
  });

  bool get hasActiveFilters =>
      status != null ||
      role != TripRoleFilter.allRoles ||
      sortBy != TripSortOption.dateNewestFirst;

  TripFilterState copyWith({
    TripStatus? status,
    bool clearStatus = false,
    TripRoleFilter? role,
    TripSortOption? sortBy,
  }) {
    return TripFilterState(
      status: clearStatus ? null : (status ?? this.status),
      role: role ?? this.role,
      sortBy: sortBy ?? this.sortBy,
    );
  }
}

/// Filter Trips modal bottom sheet matching Figma 07.03.
class FilterTripsSheet extends StatefulWidget {
  final TripFilterState initialFilter;

  const FilterTripsSheet({
    super.key,
    required this.initialFilter,
  });

  static Future<TripFilterState?> show(
    BuildContext context, {
    required TripFilterState initialFilter,
  }) {
    return showModalBottomSheet<TripFilterState>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => FilterTripsSheet(initialFilter: initialFilter),
    );
  }

  @override
  State<FilterTripsSheet> createState() => _FilterTripsSheetState();
}

class _FilterTripsSheetState extends State<FilterTripsSheet> {
  late TripStatus? _selectedStatus;
  late TripRoleFilter _selectedRole;
  late TripSortOption _selectedSort;

  @override
  void initState() {
    super.initState();
    _selectedStatus = widget.initialFilter.status;
    _selectedRole = widget.initialFilter.role;
    _selectedSort = widget.initialFilter.sortBy;
  }

  void _reset() {
    setState(() {
      _selectedStatus = null;
      _selectedRole = TripRoleFilter.allRoles;
      _selectedSort = TripSortOption.dateNewestFirst;
    });
  }

  void _apply() {
    Navigator.of(context).pop(
      TripFilterState(
        status: _selectedStatus,
        role: _selectedRole,
        sortBy: _selectedSort,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.88,
      ),
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            // Drag Handle
            Container(
              width: 44,
              height: 4.5,
              decoration: BoxDecoration(
                color: AppColors.secondaryDark,
                borderRadius: BorderRadius.circular(99),
              ),
            ),
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'Filter Trips',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.h2.copyWith(
                        color: AppColors.secondaryDark,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  _SheetCloseButton(
                    onTap: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            // Scrollable Filter Sections
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. Trip Status
                    const _SectionTitle(title: 'Trip Status'),
                    const SizedBox(height: 10),
                    _RadioOptionTile(
                      label: 'All Trips',
                      isSelected: _selectedStatus == null,
                      onTap: () => setState(() => _selectedStatus = null),
                    ),
                    _RadioOptionTile(
                      label: 'Upcoming',
                      isSelected: _selectedStatus == TripStatus.upcoming,
                      onTap: () =>
                          setState(() => _selectedStatus = TripStatus.upcoming),
                    ),
                    _RadioOptionTile(
                      label: 'Ongoing',
                      isSelected: _selectedStatus == TripStatus.ongoing,
                      onTap: () =>
                          setState(() => _selectedStatus = TripStatus.ongoing),
                    ),
                    _RadioOptionTile(
                      label: 'Completed',
                      isSelected: _selectedStatus == TripStatus.completed,
                      onTap: () => setState(
                          () => _selectedStatus = TripStatus.completed),
                    ),
                    _RadioOptionTile(
                      label: 'Cancelled',
                      isSelected: _selectedStatus == TripStatus.cancelled,
                      onTap: () => setState(
                          () => _selectedStatus = TripStatus.cancelled),
                    ),

                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 14),
                      child: Divider(height: 1, color: AppColors.ann),
                    ),

                    // 2. Your Role
                    const _SectionTitle(title: 'Your Role'),
                    const SizedBox(height: 10),
                    _RadioOptionTile(
                      label: 'All Roles',
                      isSelected: _selectedRole == TripRoleFilter.allRoles,
                      onTap: () => setState(
                          () => _selectedRole = TripRoleFilter.allRoles),
                    ),
                    _RadioOptionTile(
                      label: 'Organized by Me',
                      isSelected:
                          _selectedRole == TripRoleFilter.organizedByMe,
                      onTap: () => setState(
                          () => _selectedRole = TripRoleFilter.organizedByMe),
                    ),
                    _RadioOptionTile(
                      label: 'Joined Trips',
                      isSelected: _selectedRole == TripRoleFilter.joinedTrips,
                      onTap: () => setState(
                          () => _selectedRole = TripRoleFilter.joinedTrips),
                    ),

                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 14),
                      child: Divider(height: 1, color: AppColors.ann),
                    ),

                    // 3. Sort By
                    const _SectionTitle(title: 'Sort By'),
                    const SizedBox(height: 10),
                    _RadioOptionTile(
                      label: 'Trip Date (Newest First)',
                      isSelected:
                          _selectedSort == TripSortOption.dateNewestFirst,
                      onTap: () => setState(() =>
                          _selectedSort = TripSortOption.dateNewestFirst),
                    ),
                    _RadioOptionTile(
                      label: 'Trip Date (Oldest First)',
                      isSelected:
                          _selectedSort == TripSortOption.dateOldestFirst,
                      onTap: () => setState(() =>
                          _selectedSort = TripSortOption.dateOldestFirst),
                    ),
                    _RadioOptionTile(
                      label: 'Trip Name (A–Z)',
                      isSelected: _selectedSort == TripSortOption.nameAZ,
                      onTap: () =>
                          setState(() => _selectedSort = TripSortOption.nameAZ),
                    ),
                    _RadioOptionTile(
                      label: 'Trip Name (Z–A)',
                      isSelected: _selectedSort == TripSortOption.nameZA,
                      onTap: () =>
                          setState(() => _selectedSort = TripSortOption.nameZA),
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),
            // Footer Buttons
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Divider(height: 1, color: AppColors.ann),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 18),
              child: Row(
                children: [
                  Expanded(
                    child: AppButton(
                      text: 'Reset',
                      variant: AppButtonVariant.secondary,
                      size: AppButtonSize.small,
                      customHeight: 48,
                      borderRadius: 14,
                      onPressed: _reset,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: AppButton(
                      text: 'Apply Filters',
                      variant: AppButtonVariant.primaryNavy,
                      size: AppButtonSize.small,
                      customHeight: 48,
                      borderRadius: 14,
                      onPressed: _apply,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 4.5,
          height: 18,
          decoration: BoxDecoration(
            color: AppColors.semanticYellow,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: AppColors.secondaryDark, width: 1.0),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: AppTypography.titleLarge.copyWith(
            color: AppColors.secondaryDark,
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

class _RadioOptionTile extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _RadioOptionTile({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        margin: const EdgeInsets.only(bottom: 4),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFDE88E) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: isSelected
              ? Border.all(color: AppColors.secondaryDark, width: 1.8)
              : Border.all(color: Colors.transparent, width: 1.8),
          boxShadow: isSelected
              ? const [
                  BoxShadow(
                    color: AppColors.secondaryDark,
                    offset: Offset(0, 2.5),
                    blurRadius: 0,
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: AppColors.white,
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.secondaryDark,
                  width: 1.8,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(
                          color: AppColors.secondaryDark,
                          shape: BoxShape.circle,
                        ),
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: AppTypography.titleMedium.copyWith(
                  color: AppColors.secondaryDark,
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SheetCloseButton extends StatelessWidget {
  final VoidCallback onTap;

  const _SheetCloseButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(10),
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
          child: Icon(
            Icons.close_rounded,
            size: 20,
            color: AppColors.secondaryDark,
          ),
        ),
      ),
    );
  }
}
