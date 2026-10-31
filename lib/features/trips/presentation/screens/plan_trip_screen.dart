import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../components/atoms/app_button.dart';
import '../../../../components/atoms/app_icon.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/utils/app_responsive.dart';
import '../../data/trip_repository.dart';

enum PlanTripStep {
  essentials, // Plan a Trip - 1.png
  whosComing, // Plan a Trip - 2.png
  buildMethod, // Plan a Trip - 3.png
  aiLoading, // Plan a Trip - AI Loading.png
  itineraryEmpty, // Plan a Trip - Itinerary Empty State.png
  addCategory, // Plan a Trip - Itinerary Empty State-1.png
  addRecommend, // Plan a Trip - Itinerary Empty State-2.png
  addDetails, // Plan a Trip - Itinerary Empty State-3.png
  viewInMap, // Plan a Trip - View in Map.png
  addedSuccess, // Plan a Trip - Added to Itinerary.png
  itineraryPopulated, // Trips Screen - View Itinerary.png
}

class _RecommendedPlace {
  final String name;
  final String stars;
  final String location;
  final String distance;

  const _RecommendedPlace({
    required this.name,
    required this.stars,
    required this.location,
    required this.distance,
  });
}

class _ItineraryEntry {
  final String category;
  final String title;
  final String location;
  final String timeRange;

  const _ItineraryEntry({
    required this.category,
    required this.title,
    required this.location,
    required this.timeRange,
  });
}

class PlanTripScreen extends StatefulWidget {
  final String? initialGroupName;
  final PlanTripStep initialStep;
  final VoidCallback? onCompleted;

  const PlanTripScreen({
    super.key,
    this.initialGroupName,
    this.initialStep = PlanTripStep.essentials,
    this.onCompleted,
  });

  @override
  State<PlanTripScreen> createState() => _PlanTripScreenState();
}

class _PlanTripScreenState extends State<PlanTripScreen> {
  late PlanTripStep _step;
  final List<PlanTripStep> _history = [];

  // Step 1: Essentials controllers
  final _tripNameController = TextEditingController();
  final _destinationController = TextEditingController();
  final _startDateController = TextEditingController();
  final _endDateController = TextEditingController();
  final _meetingPlaceController = TextEditingController();
  final _descriptionController = TextEditingController();

  // Step 2: Who's coming state
  final _memberSearchController = TextEditingController();
  bool _selectAllMembers = true;
  final List<bool> _selectedMembers = [false, false, false];
  final List<Map<String, String>> _members = const [
    {'role': '[Member]', 'name': '[Name]'},
    {'role': '[Member]', 'name': '[Name]'},
    {'role': '[Member]', 'name': '[Name]'},
  ];

  // Step 3: Build method selection (0 = Orange AI card, 1 = Navy Manual/Brush card)
  int _selectedBuildOption = 0;

  // Step 4: Calendar & Itinerary state
  int _selectedDayNumber = 19;
  final List<int> _septDays = const [19, 20, 21, 22, 23];

  // Step 5: Add Itinerary controllers & selected place
  final _placeSearchController = TextEditingController();
  final _itemTitleController = TextEditingController();
  final _startTimeController = TextEditingController();
  final _endTimeController = TextEditingController();
  final _notesController = TextEditingController();

  String _selectedCategory = 'Activity';
  _RecommendedPlace _selectedPlace = const _RecommendedPlace(
    name: 'Hannah’s Beach Resort',
    stars: '4.8 stars',
    location: 'Santa Fe, Bantayan',
    distance: '1.8 km away',
  );

  final List<_RecommendedPlace> _recommendedPlaces = const [
    _RecommendedPlace(
      name: 'Hannah’s Beach Resort',
      stars: '4.8 stars',
      location: 'Santa Fe, Bantayan',
      distance: '1.8 km away',
    ),
    _RecommendedPlace(
      name: 'Coral Bay Suites',
      stars: '4.5 stars',
      location: 'Malapascua Island',
      distance: '3.4 km away',
    ),
    _RecommendedPlace(
      name: 'Sunset Palms Hotel',
      stars: '4.7 stars',
      location: 'Moalboal',
      distance: '2.1 km away',
    ),
  ];

  final List<_ItineraryEntry> _itineraryEntries = [
    const _ItineraryEntry(
      category: 'Activity',
      title: 'Island Hopping',
      location: 'Hannah’s Beach....',
      timeRange: '9:00 AM - 10:00 AM',
    ),
    const _ItineraryEntry(
      category: 'Activity',
      title: 'Island Hopping',
      location: 'Hannah’s Beach....',
      timeRange: '9:00 AM - 10:00 AM',
    ),
    const _ItineraryEntry(
      category: 'Activity',
      title: 'Island Hopping',
      location: 'Hannah’s Beach....',
      timeRange: '9:00 AM - 10:00 AM',
    ),
    const _ItineraryEntry(
      category: 'Activity',
      title: 'Island Hopping',
      location: 'Hannah’s Beach....',
      timeRange: '9:00 AM - 10:00 AM',
    ),
  ];

  Timer? _aiTimer;

  @override
  void initState() {
    super.initState();
    _step = widget.initialStep;
  }

  @override
  void dispose() {
    _aiTimer?.cancel();
    _tripNameController.dispose();
    _destinationController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    _meetingPlaceController.dispose();
    _descriptionController.dispose();
    _memberSearchController.dispose();
    _placeSearchController.dispose();
    _itemTitleController.dispose();
    _startTimeController.dispose();
    _endTimeController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _goToStep(PlanTripStep next) {
    _aiTimer?.cancel();
    setState(() {
      _history.add(_step);
      _step = next;
    });

    if (next == PlanTripStep.aiLoading) {
      _aiTimer = Timer(const Duration(milliseconds: 2200), () {
        if (!mounted) return;
        setState(() {
          _step = PlanTripStep.itineraryPopulated;
        });
      });
    }
  }

  void _goBack() {
    _aiTimer?.cancel();
    if (_history.isNotEmpty) {
      setState(() {
        _step = _history.removeLast();
      });
    } else if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    } else {
      widget.onCompleted?.call();
    }
  }

  Future<void> _finishFlow() async {
    final selectedMemberModels = <TripMemberModel>[];
    for (int i = 0; i < _members.length; i++) {
      if (_selectedMembers[i] || _selectAllMembers) {
        selectedMemberModels.add(
          TripMemberModel(
            name: _members[i]['name']!,
            role: _members[i]['role']!,
          ),
        );
      }
    }

    final itineraryModels = _itineraryEntries
        .map(
          (entry) => ItineraryItemModel(
            id: 'item-${entry.title.hashCode}-${DateTime.now().microsecondsSinceEpoch}',
            category: entry.category,
            placeName: entry.location,
            location: entry.location,
            title: entry.title,
            startTime: entry.timeRange.split(' - ').first,
            endTime: entry.timeRange.split(' - ').last,
            dayNumber: _selectedDayNumber,
          ),
        )
        .toList();

    final createdTrip = await TripRepository.instance.saveTrip(
      groupName: widget.initialGroupName ?? 'Trip to Bantayan',
      name: _tripNameController.text,
      destination: _destinationController.text,
      startDate: _startDateController.text,
      endDate: _endDateController.text,
      meetingPlace: _meetingPlaceController.text,
      description: _descriptionController.text,
      isAiGenerated: _selectedBuildOption == 0,
      members: selectedMemberModels,
      itineraryItems: itineraryModels,
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Itinerary saved!'),
        backgroundColor: AppColors.primaryNavy,
        duration: Duration(milliseconds: 1400),
      ),
    );
    if (widget.onCompleted != null) {
      widget.onCompleted!();
    } else if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop(createdTrip);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_step == PlanTripStep.viewInMap) {
      return _buildViewInMapScreen();
    }
    if (_step == PlanTripStep.addedSuccess) {
      return _buildAddedToItineraryScreen();
    }

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: _buildStepAppBar(),
      body: SafeArea(
        child: _buildCurrentStepBody(),
      ),
    );
  }

  // ===========================================================================
  // TOP BAR (Matches Figma: Back arrow + bold title + bottom 1.5px border)
  // ===========================================================================
  PreferredSizeWidget _buildStepAppBar() {
    String title;
    bool showAddAction = false;

    switch (_step) {
      case PlanTripStep.essentials:
      case PlanTripStep.whosComing:
      case PlanTripStep.buildMethod:
        title = 'Plan Trip';
        break;
      case PlanTripStep.aiLoading:
      case PlanTripStep.itineraryPopulated:
        title = 'Create Itinerary';
        break;
      case PlanTripStep.itineraryEmpty:
        title = 'View Itinerary';
        showAddAction = true;
        break;
      case PlanTripStep.addCategory:
      case PlanTripStep.addRecommend:
      case PlanTripStep.addDetails:
        title = 'Add Itinerary';
        break;
      case PlanTripStep.viewInMap:
      case PlanTripStep.addedSuccess:
        title = 'Plan Trip';
        break;
    }

    return PreferredSize(
      preferredSize: const Size.fromHeight(68),
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.white,
          border: Border(
            bottom: BorderSide(color: AppColors.secondaryDark, width: 1.5),
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: SizedBox(
            height: 66,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: _goBack,
                    child: const SizedBox(
                      width: 44,
                      height: 44,
                      child: Center(
                        child: Icon(
                          Iconsax.arrow_left,
                          color: AppColors.secondaryDark,
                          size: 24,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      title,
                      style: AppTypography.h3.copyWith(
                        color: AppColors.secondaryDark,
                        fontWeight: FontWeight.w800,
                        fontSize: 20,
                      ),
                    ),
                  ),
                  if (showAddAction)
                    GestureDetector(
                      onTap: () => _goToStep(PlanTripStep.addCategory),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
                        decoration: BoxDecoration(
                          color: const Color(0xFFC5D1E0),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.secondaryDark, width: 1.5),
                          boxShadow: const [
                            BoxShadow(
                              color: AppColors.secondaryDark,
                              offset: Offset(0, 3),
                              blurRadius: 0,
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Iconsax.add,
                              color: AppColors.secondaryDark,
                              size: 20,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Add',
                              style: AppTypography.titleMedium.copyWith(
                                color: AppColors.secondaryDark,
                                fontWeight: FontWeight.w800,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentStepBody() {
    switch (_step) {
      case PlanTripStep.essentials:
        return _buildStep1Essentials();
      case PlanTripStep.whosComing:
        return _buildStep2WhosComing();
      case PlanTripStep.buildMethod:
        return _buildStep3BuildMethod();
      case PlanTripStep.aiLoading:
        return _buildStepAiLoading();
      case PlanTripStep.itineraryEmpty:
        return _buildStepItineraryEmpty();
      case PlanTripStep.addCategory:
        return _buildStepAddCategory();
      case PlanTripStep.addRecommend:
        return _buildStepAddRecommend();
      case PlanTripStep.addDetails:
        return _buildStepAddDetails();
      case PlanTripStep.itineraryPopulated:
        return _buildStepItineraryPopulated();
      case PlanTripStep.viewInMap:
      case PlanTripStep.addedSuccess:
        return const SizedBox.shrink();
    }
  }

  // ===========================================================================
  // 1. PLAN A TRIP - 1.PNG ("Set up your trip essentials")
  // ===========================================================================
  Widget _buildStep1Essentials() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Set up your trip essentials',
            style: AppTypography.titleLarge.copyWith(
              color: AppColors.secondaryDark,
              fontWeight: FontWeight.w800,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Give your trip a name and fill in a few key details to get started.',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.secondaryDark,
              fontSize: 13.5,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 18),

          _buildFigmaFormField(
            label: 'Trip Name',
            isRequired: true,
            controller: _tripNameController,
          ),
          const SizedBox(height: 16),

          _buildFigmaFormField(
            label: 'Destination',
            isRequired: true,
            controller: _destinationController,
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: _buildFigmaFormField(
                  label: 'Start Date',
                  isRequired: true,
                  controller: _startDateController,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _buildFigmaFormField(
                  label: 'End Date',
                  isRequired: true,
                  controller: _endDateController,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          _buildFigmaFormField(
            label: 'Meeting Place',
            isRequired: true,
            controller: _meetingPlaceController,
          ),
          const SizedBox(height: 16),

          _buildFigmaFormField(
            label: 'Description',
            isRequired: false,
            controller: _descriptionController,
          ),
          const SizedBox(height: 36),

          _buildPrimaryNavyButton(
            label: 'Continue',
            showRightArrow: true,
            onTap: () => _goToStep(PlanTripStep.whosComing),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // 2. PLAN A TRIP - 2.PNG ("Who's coming?")
  // ===========================================================================
  Widget _buildStep2WhosComing() {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Who’s coming?',
                  style: AppTypography.titleLarge.copyWith(
                    color: AppColors.secondaryDark,
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Invite members and check their availability to find the best dates.',
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.secondaryDark,
                    fontSize: 13.5,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 16),

                // Search members bar (no double border)
                _buildSearchInputBox(
                  controller: _memberSearchController,
                  hintText: 'Search members...',
                ),
                const SizedBox(height: 12),

                // "Select all members" pill button
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectAllMembers = !_selectAllMembers;
                      for (int i = 0; i < _selectedMembers.length; i++) {
                        _selectedMembers[i] = _selectAllMembers;
                      }
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                    decoration: BoxDecoration(
                      color: const Color(0xFFC5D1E0),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.secondaryDark, width: 1.4),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 22,
                          height: 22,
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(5),
                            border: Border.all(color: AppColors.secondaryDark, width: 2.0),
                          ),
                          child: _selectAllMembers
                              ? const Icon(
                                  Icons.check_rounded,
                                  size: 16,
                                  color: AppColors.secondaryDark,
                                )
                              : null,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Select all members',
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.secondaryDark,
                            fontWeight: FontWeight.w600,
                            fontSize: 12.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Member availability cards
                for (int i = 0; i < _members.length; i++)
                  if (_memberSearchController.text.trim().isEmpty ||
                      _members[i]['role']!
                          .toLowerCase()
                          .contains(_memberSearchController.text.trim().toLowerCase()) ||
                      _members[i]['name']!
                          .toLowerCase()
                          .contains(_memberSearchController.text.trim().toLowerCase())) ...[
                    _buildMemberAvailabilityCard(i),
                    if (i < _members.length - 1) const SizedBox(height: 12),
                  ],
              ],
            ),
          ),
        ),

        // Pinned Bottom Bar with top border
        Container(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 18),
          decoration: const BoxDecoration(
            color: AppColors.white,
            border: Border(
              top: BorderSide(color: AppColors.secondaryDark, width: 1.5),
            ),
          ),
          child: _buildPrimaryNavyButton(
            label: 'Continue',
            showRightArrow: true,
            onTap: () => _goToStep(PlanTripStep.buildMethod),
          ),
        ),
      ],
    );
  }

  Widget _buildMemberAvailabilityCard(int index) {
    final isChecked = _selectedMembers[index];
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedMembers[index] = !isChecked;
          _selectAllMembers = _selectedMembers.every((v) => v);
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Yellow circle avatar with vector Iconsax.user5 so it renders on Android
                Container(
                  width: 46,
                  height: 46,
                  decoration: const BoxDecoration(
                    color: AppColors.semanticYellow,
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: AppIcon(
                      Iconsax.user5,
                      color: AppColors.white,
                      size: 25,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _members[index]['role']!,
                          style: AppTypography.titleMedium.copyWith(
                            color: AppColors.secondaryDark,
                            fontWeight: FontWeight.w800,
                            fontSize: 14.5,
                          ),
                        ),
                        const SizedBox(height: 1),
                        Text(
                          _members[index]['name']!,
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.secondaryDark,
                            fontSize: 12.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  width: 28,
                  height: 28,
                  margin: const EdgeInsets.only(top: 2),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(7),
                    border: Border.all(
                      color: isChecked ? AppColors.secondaryDark : const Color(0xFF8A8894),
                      width: isChecked ? 2.4 : 2.2,
                    ),
                  ),
                  child: isChecked
                      ? const Icon(Icons.check_rounded, size: 19, color: AppColors.secondaryDark)
                      : null,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'General Availability',
              style: AppTypography.caption.copyWith(
                color: AppColors.secondaryDark,
                fontWeight: FontWeight.w700,
                fontSize: 11.5,
              ),
            ),
            const SizedBox(height: 5),
            Row(
              children: [
                _buildAvailabilityDayChip('Mon'),
                const SizedBox(width: 8),
                _buildAvailabilityDayChip('Tue'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvailabilityDayChip(String day) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFF8FA6C3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        day,
        style: AppTypography.caption.copyWith(
          color: AppColors.white,
          fontWeight: FontWeight.w600,
          fontSize: 11,
        ),
      ),
    );
  }

  // ===========================================================================
  // 3. PLAN A TRIP - 3.PNG ("How would you like to build your itinerary?")
  // ===========================================================================
  Widget _buildStep3BuildMethod() {
    return AppScrollableFillBody(
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'How would you like to build your itinerary?',
            style: AppTypography.titleLarge.copyWith(
              color: AppColors.secondaryDark,
              fontWeight: FontWeight.w800,
              fontSize: 17.5,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Choose whether to plan it yourself or let AI create a starting itinerary for your group.',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.secondaryDark,
              fontSize: 13.5,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 22),

          // Option 1: Orange AI Magic Wand Card
          _buildItineraryMethodCard(
            index: 0,
            iconBgColor: AppColors.primaryOrange,
            iconWidget: const AppIcon(
              Iconsax.magicpen5,
              color: AppColors.white,
              size: 34,
            ),
            title: 'Generate with AI',
            showPlusBadge: true,
            subtitle: 'Generate a group itinerary based on your preferences.',
          ),
          const SizedBox(height: 18),

          // Option 2: Navy Brush Card (centered vector brush_25)
          _buildItineraryMethodCard(
            index: 1,
            iconBgColor: AppColors.primaryNavy,
            iconWidget: const AppIcon(
              Iconsax.brush_25,
              color: AppColors.white,
              size: 34,
            ),
            title: 'Generate with AI',
            showPlusBadge: false,
            subtitle: 'Generate a group itinerary based on your preferences.',
          ),

          const SizedBox(height: 24),
          const Spacer(),

          _buildPrimaryNavyButton(
            label: 'Continue',
            showRightArrow: true,
            onTap: () {
              if (_selectedBuildOption == 0) {
                _goToStep(PlanTripStep.aiLoading);
              } else {
                _goToStep(PlanTripStep.itineraryEmpty);
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildItineraryMethodCard({
    required int index,
    required Color iconBgColor,
    required Widget iconWidget,
    required String title,
    required bool showPlusBadge,
    required String subtitle,
  }) {
    final isSelected = _selectedBuildOption == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedBuildOption = index),
      child: Container(
        padding: const EdgeInsets.all(16),
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 68,
              height: 68,
              decoration: BoxDecoration(
                color: iconBgColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(child: iconWidget),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.titleMedium.copyWith(
                              color: AppColors.secondaryDark,
                              fontWeight: FontWeight.w800,
                              fontSize: 15,
                            ),
                          ),
                        ),
                        if (showPlusBadge) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEA9A86),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              'Plus',
                              style: AppTypography.caption.copyWith(
                                color: AppColors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 10,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.secondaryDark,
                        fontSize: 12,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(7),
                border: Border.all(
                  color: isSelected ? AppColors.secondaryDark : const Color(0xFF8A8894),
                  width: isSelected ? 2.4 : 2.2,
                ),
              ),
              child: isSelected
                  ? const Icon(Icons.check_rounded, size: 19, color: AppColors.secondaryDark)
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // 4. PLAN A TRIP - AI LOADING.PNG ("Creating your itinerary...")
  // ===========================================================================
  Widget _buildStepAiLoading() {
    const checklist = [
      {
        'title': 'Checking group preferences',
        'subtitle': 'Analyzing your group’s interests.',
      },
      {
        'title': 'Checking availability',
        'subtitle': 'Finding the best options',
      },
      {
        'title': 'Planning activities',
        'subtitle': 'Curating top experiences.',
      },
      {
        'title': 'Organizing schedule',
        'subtitle': 'Arranging your day to day plan.',
      },
      {
        'title': 'Building itinerary',
        'subtitle': 'Putting it all together.',
      },
    ];

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _goToStep(PlanTripStep.itineraryPopulated),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(32, 36, 32, 28),
        child: Column(
          children: [
            // Large Navy Circle with White Map Icon
            Container(
              width: 186,
              height: 186,
              decoration: const BoxDecoration(
                color: AppColors.primaryNavy,
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: AppIcon(
                  Iconsax.map_15,
                  color: AppColors.white,
                  size: 90,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Creating your itinerary...',
              textAlign: TextAlign.center,
              style: AppTypography.h3.copyWith(
                color: AppColors.secondaryDark,
                fontWeight: FontWeight.w800,
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Our AI is putting together the best options for\nyour group.',
              textAlign: TextAlign.center,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.secondaryDark,
                fontSize: 13.5,
                height: 1.35,
              ),
            ),
            const SizedBox(height: 28),

            // 5 Checklist Rows with outlined checkmark inside #8FA6C3 circle
            for (int i = 0; i < checklist.length; i++) ...[
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: const Color(0xFF8FA6C3),
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.secondaryDark, width: 2.0),
                    ),
                    child: const Center(
                      child: CustomPaint(
                        size: Size(20, 20),
                        painter: _OutlinedCheckPainter(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          checklist[i]['title']!,
                          style: AppTypography.titleMedium.copyWith(
                            color: AppColors.secondaryDark,
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                          ),
                        ),
                        Text(
                          checklist[i]['subtitle']!,
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.secondaryDark,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (i < checklist.length - 1) const SizedBox(height: 20),
            ],
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // 5. PLAN A TRIP - ITINERARY EMPTY STATE.PNG ("View Itinerary" - No itinerary yet)
  // ===========================================================================
  Widget _buildStepItineraryEmpty() {
    return AppScrollableFillBody(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 22),
      child: Column(
        children: [
          _buildYellowDateStrip(),
          const SizedBox(height: 24),
          const Spacer(),

          // Large Orange Circle with Centered 2-Pin Route Icon (Iconsax.routing5)
          GestureDetector(
            onTap: () => _goToStep(PlanTripStep.addCategory),
            child: Container(
              width: 186,
              height: 186,
              decoration: const BoxDecoration(
                color: AppColors.primaryOrange,
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: AppIcon(
                  Iconsax.routing5,
                  color: AppColors.white,
                  size: 94,
                ),
              ),
            ),
          ),
          const SizedBox(height: 22),
          Text(
            'No itinerary yet',
            style: AppTypography.h3.copyWith(
              color: AppColors.secondaryDark,
              fontWeight: FontWeight.w800,
              fontSize: 19,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Add places, activities, and times to start\nbuilding your trip.',
            textAlign: TextAlign.center,
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.secondaryDark,
              fontSize: 13.5,
              height: 1.35,
            ),
          ),

          const SizedBox(height: 24),
          const Spacer(),

          _buildPrimaryNavyButton(
            label: 'Save Itinerary',
            showRightArrow: false,
            height: 48,
            onTap: _finishFlow,
          ),
          const SizedBox(height: 12),
          _buildSecondaryButton(
            label: 'Cancel',
            height: 48,
            onTap: _goBack,
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // 6. PLAN A TRIP - ITINERARY EMPTY STATE-1.PNG ("Add Itinerary" - Categories)
  // ===========================================================================
  Widget _buildStepAddCategory() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'What would you like to add to your itinerary?',
            style: AppTypography.titleLarge.copyWith(
              color: AppColors.secondaryDark,
              fontWeight: FontWeight.w800,
              fontSize: 17,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Choose an item to start building your trip.',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.secondaryDark,
              fontSize: 13.5,
            ),
          ),
          const SizedBox(height: 22),

          _buildCategoryOptionCard(
            title: 'Place/Check-in',
            subtitle: 'Add a destination, landmark, or\naccomodation.',
            icon: const AppIcon(
              Iconsax.home_15,
              color: AppColors.white,
              size: 32,
            ),
            onTap: () {
              _selectedCategory = 'Place';
              _goToStep(PlanTripStep.addRecommend);
            },
          ),
          const SizedBox(height: 16),

          _buildCategoryOptionCard(
            title: 'Activity',
            subtitle: 'Add an experience, attraction, or\nplanned activity.',
            icon: const AppIcon(
              Iconsax.sun_fog5,
              color: AppColors.white,
              size: 34,
            ),
            onTap: () {
              _selectedCategory = 'Activity';
              _goToStep(PlanTripStep.addRecommend);
            },
          ),
          const SizedBox(height: 16),

          _buildCategoryOptionCard(
            title: 'Food/Dining',
            subtitle: 'Add a restaurant, café, or food\nstop.',
            icon: const SizedBox(
              width: 32,
              height: 32,
              child: CustomPaint(
                painter: _CrossedForkSpoonPainter(),
              ),
            ),
            onTap: () {
              _selectedCategory = 'Food';
              _goToStep(PlanTripStep.addRecommend);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryOptionCard({
    required String title,
    required String subtitle,
    required Widget icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
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
              width: 68,
              height: 68,
              decoration: BoxDecoration(
                color: AppColors.primaryNavy,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(child: icon),
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
                      color: AppColors.secondaryDark,
                      fontSize: 12,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(
              Iconsax.arrow_right_3,
              color: AppColors.secondaryDark,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // 7. PLAN A TRIP - ITINERARY EMPTY STATE-2.PNG ("Recommended for your trip")
  // ===========================================================================
  Widget _buildStepAddRecommend() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search + Yellow Filter Row
          Row(
            children: [
              Expanded(
                child: _buildSearchInputBox(
                  controller: _placeSearchController,
                  hintText: 'Search for a place...',
                  height: 54,
                ),
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: () {},
                child: Container(
                  width: 72,
                  height: 54,
                  decoration: BoxDecoration(
                    color: AppColors.semanticYellow,
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
                  child: const Center(
                    child: AppIcon(
                      Iconsax.filter_search5,
                      color: AppColors.secondaryDark,
                      size: 24,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),

          Text(
            'Recommended for your trip',
            style: AppTypography.titleLarge.copyWith(
              color: AppColors.secondaryDark,
              fontWeight: FontWeight.w800,
              fontSize: 17.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Choose an item to start building your trip.',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.secondaryDark,
              fontSize: 13.5,
            ),
          ),
          const SizedBox(height: 18),

          for (int i = 0; i < _recommendedPlaces.length; i++)
            if (_placeSearchController.text.trim().isEmpty ||
                _recommendedPlaces[i]
                    .name
                    .toLowerCase()
                    .contains(_placeSearchController.text.trim().toLowerCase()) ||
                _recommendedPlaces[i]
                    .location
                    .toLowerCase()
                    .contains(_placeSearchController.text.trim().toLowerCase())) ...[
              _buildRecommendedPlaceCard(_recommendedPlaces[i]),
              if (i < _recommendedPlaces.length - 1) const SizedBox(height: 16),
            ],
        ],
      ),
    );
  }

  Widget _buildRecommendedPlaceCard(_RecommendedPlace place) {
    return GestureDetector(
      onTap: () {
        _selectedPlace = place;
        _goToStep(PlanTripStep.addDetails);
      },
      child: Container(
        padding: const EdgeInsets.all(14),
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
              width: 86,
              height: 86,
              decoration: BoxDecoration(
                color: AppColors.primaryNavy,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: AppIcon(
                  Iconsax.picture_frame5,
                  color: AppColors.white,
                  size: 38,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    place.name,
                    style: AppTypography.titleMedium.copyWith(
                      color: AppColors.secondaryDark,
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const AppIcon(
                        Iconsax.magic_star5,
                        color: AppColors.primaryNavy,
                        size: 14,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        place.stars,
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.secondaryDark,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      const AppIcon(
                        Iconsax.location5,
                        color: AppColors.primaryNavy,
                        size: 14,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          place.location,
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.secondaryDark,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    place.distance,
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.secondaryDark,
                      fontSize: 12,
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

  // ===========================================================================
  // 8. PLAN A TRIP - ITINERARY EMPTY STATE-3.PNG ("Add Itinerary" Details Form)
  // ===========================================================================
  Widget _buildStepAddDetails() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Place Summary Card with "View in Map" button
          Container(
            padding: const EdgeInsets.all(16),
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
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 88,
                      height: 88,
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _selectedPlace.name,
                            style: AppTypography.titleMedium.copyWith(
                              color: AppColors.secondaryDark,
                              fontWeight: FontWeight.w800,
                              fontSize: 15.5,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Row(
                            children: [
                              const AppIcon(
                                Iconsax.magic_star5,
                                color: AppColors.primaryNavy,
                                size: 14,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                _selectedPlace.stars,
                                style: AppTypography.bodySmall.copyWith(
                                  color: AppColors.secondaryDark,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 3),
                          Row(
                            children: [
                              const AppIcon(
                                Iconsax.location5,
                                color: AppColors.primaryNavy,
                                size: 14,
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  _selectedPlace.location,
                                  style: AppTypography.bodySmall.copyWith(
                                    color: AppColors.secondaryDark,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _selectedPlace.distance,
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.secondaryDark,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: () => _goToStep(PlanTripStep.viewInMap),
                  child: Container(
                    width: double.infinity,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.primaryNavy,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.secondaryDark, width: 2.0),
                      boxShadow: const [
                        BoxShadow(
                          color: AppColors.secondaryDark,
                          offset: Offset(0, 3),
                          blurRadius: 0,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        'View in Map',
                        style: AppTypography.buttonMedium.copyWith(
                          color: AppColors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),

          _buildFigmaFormField(
            label: 'Title',
            isRequired: true,
            controller: _itemTitleController,
          ),
          const SizedBox(height: 18),

          Row(
            children: [
              Expanded(
                child: _buildFigmaFormField(
                  label: 'Start Time',
                  isRequired: true,
                  controller: _startTimeController,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _buildFigmaFormField(
                  label: 'End Time',
                  isRequired: true,
                  controller: _endTimeController,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          _buildFigmaFormField(
            label: 'Notes',
            isRequired: false,
            controller: _notesController,
            maxLines: 4,
            height: 120,
          ),
          const SizedBox(height: 28),

          _buildPrimaryNavyButton(
            label: 'Add',
            showLeadingPlus: true,
            showRightArrow: false,
            onTap: () async {
              final title = _itemTitleController.text.trim().isNotEmpty
                  ? _itemTitleController.text.trim()
                  : 'Island Hopping';
              final start = _startTimeController.text.trim().isNotEmpty
                  ? _startTimeController.text.trim()
                  : '9:00 AM';
              final end = _endTimeController.text.trim().isNotEmpty
                  ? _endTimeController.text.trim()
                  : '10:00 AM';
              final notes = _notesController.text.trim();

              await TripRepository.instance.saveManualItineraryItem(
                category: _selectedCategory,
                placeName: _selectedPlace.name,
                location: _selectedPlace.location,
                title: title,
                startTime: start,
                endTime: end,
                notes: notes,
                dayNumber: _selectedDayNumber,
              );

              _itineraryEntries.insert(
                0,
                _ItineraryEntry(
                  category: _selectedCategory,
                  title: title,
                  location: _selectedPlace.name,
                  timeRange: '$start - $end',
                ),
              );
              if (!mounted) return;
              _goToStep(PlanTripStep.addedSuccess);
            },
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // 9. PLAN A TRIP - VIEW IN MAP.PNG (Full-screen Map View)
  // ===========================================================================
  Widget _buildViewInMapScreen() {
    return Scaffold(
      backgroundColor: const Color(0xFFEAEBFF),
      body: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: _FigmaMapBackgroundPainter(),
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(14),
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
                          width: 84,
                          height: 84,
                          decoration: BoxDecoration(
                            color: AppColors.primaryNavy,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Center(
                            child: AppIcon(
                              Iconsax.picture_frame5,
                              color: AppColors.white,
                              size: 38,
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _selectedPlace.name,
                                style: AppTypography.titleMedium.copyWith(
                                  color: AppColors.secondaryDark,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 15,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const AppIcon(
                                    Iconsax.magic_star5,
                                    color: AppColors.primaryNavy,
                                    size: 14,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    _selectedPlace.stars,
                                    style: AppTypography.bodySmall.copyWith(
                                      color: AppColors.secondaryDark,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 3),
                              Row(
                                children: [
                                  const AppIcon(
                                    Iconsax.location5,
                                    color: AppColors.primaryNavy,
                                    size: 14,
                                  ),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      _selectedPlace.location,
                                      style: AppTypography.bodySmall.copyWith(
                                        color: AppColors.secondaryDark,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(
                                _selectedPlace.distance,
                                style: AppTypography.bodySmall.copyWith(
                                  color: AppColors.secondaryDark,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  _buildPrimaryNavyButton(
                    label: 'Go Back',
                    showRightArrow: true,
                    onTap: _goBack,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // 10. PLAN A TRIP - ADDED TO ITINERARY.PNG ("Added to Itinerary!")
  // ===========================================================================
  Widget _buildAddedToItineraryScreen() {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: AppScrollableFillBody(
          padding: const EdgeInsets.fromLTRB(20, 40, 20, 32),
          child: Column(
            children: [
              const Spacer(),
              Container(
                width: 190,
                height: 190,
                decoration: const BoxDecoration(
                  color: AppColors.primaryOrange,
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: AppIcon(
                    Iconsax.routing5,
                    color: AppColors.white,
                    size: 96,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Added to Itinerary!',
                style: AppTypography.h3.copyWith(
                  color: AppColors.secondaryDark,
                  fontWeight: FontWeight.w800,
                  fontSize: 20,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Hiking has been added to your plans for the\nday.',
                textAlign: TextAlign.center,
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.secondaryDark,
                  fontSize: 13.5,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 24),
              const Spacer(),

              _buildPrimaryNavyButton(
                label: 'Add More',
                showRightArrow: false,
                height: 50,
                onTap: () => _goToStep(PlanTripStep.addCategory),
              ),
              const SizedBox(height: 14),
              _buildSecondaryButton(
                label: 'Review Itinerary',
                height: 50,
                onTap: () => _goToStep(PlanTripStep.itineraryPopulated),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // 11. TRIPS SCREEN - VIEW ITINERARY.PNG ("Create Itinerary" Populated List)
  // ===========================================================================
  Widget _buildStepItineraryPopulated() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      child: Column(
        children: [
          _buildYellowDateStrip(),
          const SizedBox(height: 12),

          for (int i = 0; i < _itineraryEntries.length; i++) ...[
            _buildItineraryEntryCard(_itineraryEntries[i]),
            const SizedBox(height: 11),
          ],

          const SizedBox(height: 4),
          _buildPrimaryNavyButton(
            label: 'Save Itinerary',
            showRightArrow: false,
            height: 46,
            onTap: _finishFlow,
          ),
          const SizedBox(height: 10),
          _buildSecondaryButton(
            label: 'Cancel',
            height: 46,
            onTap: _goBack,
          ),
        ],
      ),
    );
  }

  Widget _buildItineraryEntryCard(_ItineraryEntry entry) {
    return GestureDetector(
      onTap: () => _goToStep(PlanTripStep.addDetails),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
              width: 74,
              height: 74,
              decoration: BoxDecoration(
                color: AppColors.primaryNavy,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: AppIcon(
                  Iconsax.home_15,
                  color: AppColors.white,
                  size: 34,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFF8FA6C3),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      entry.category,
                      style: AppTypography.caption.copyWith(
                        color: AppColors.white,
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.w600,
                        fontSize: 10.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    entry.title,
                    style: AppTypography.titleMedium.copyWith(
                      color: AppColors.secondaryDark,
                      fontWeight: FontWeight.w800,
                      fontSize: 14.5,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      const AppIcon(
                        Iconsax.location5,
                        color: AppColors.primaryNavy,
                        size: 13.5,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          entry.location,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.secondaryDark,
                            fontSize: 11.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      const AppIcon(
                        Iconsax.timer_15,
                        color: AppColors.primaryNavy,
                        size: 13.5,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          entry.timeRange,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.secondaryDark,
                            fontSize: 11.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Icon(
              Iconsax.arrow_right_3,
              color: AppColors.secondaryDark,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // SHARED REUSABLE UI HELPERS FOR PLAN A TRIP (NO DOUBLE BORDERS)
  // ===========================================================================
  Widget _buildYellowDateStrip() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.semanticYellow,
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
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: _septDays.map((day) {
          final isSelected = _selectedDayNumber == day;
          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => setState(() => _selectedDayNumber = day),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'SEPT',
                  style: AppTypography.caption.copyWith(
                    color: AppColors.secondaryDark,
                    fontWeight: FontWeight.w600,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 2),
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primaryOrange : Colors.transparent,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '$day',
                      style: AppTypography.titleLarge.copyWith(
                        color: AppColors.secondaryDark,
                        fontWeight: FontWeight.w800,
                        fontSize: 16.5,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildFigmaFormField({
    required String label,
    required bool isRequired,
    required TextEditingController controller,
    int maxLines = 1,
    double height = 52,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: label,
            style: AppTypography.titleMedium.copyWith(
              color: AppColors.secondaryDark,
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
            children: [
              if (isRequired)
                const TextSpan(
                  text: '*',
                  style: TextStyle(
                    color: AppColors.primaryOrange,
                    fontWeight: FontWeight.w800,
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        Container(
          height: height,
          decoration: BoxDecoration(
            color: AppColors.secondaryLight,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.secondaryDark, width: 2.0),
          ),
          alignment: maxLines == 1 ? Alignment.centerLeft : Alignment.topLeft,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          child: TextField(
            controller: controller,
            maxLines: maxLines,
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.secondaryDark,
              fontWeight: FontWeight.w600,
            ),
            decoration: const InputDecoration(
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              disabledBorder: InputBorder.none,
              errorBorder: InputBorder.none,
              focusedErrorBorder: InputBorder.none,
              filled: false,
              isDense: true,
              contentPadding: EdgeInsets.symmetric(vertical: 8),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchInputBox({
    required TextEditingController controller,
    required String hintText,
    double height = 52,
  }) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: AppColors.secondaryLight,
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
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          const Icon(
            Iconsax.search_normal_1,
            color: AppColors.secondaryDark,
            size: 22,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: (_) => setState(() {}),
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.secondaryDark,
              ),
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: AppTypography.bodyMedium.copyWith(
                  color: AppColors.secondaryDark.withValues(alpha: 0.75),
                  fontSize: 13.5,
                ),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                disabledBorder: InputBorder.none,
                errorBorder: InputBorder.none,
                focusedErrorBorder: InputBorder.none,
                filled: false,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrimaryNavyButton({
    required String label,
    required VoidCallback onTap,
    bool showRightArrow = false,
    bool showLeadingPlus = false,
    double height = 52,
  }) {
    return AppButton(
      text: label,
      variant: AppButtonVariant.primaryNavy,
      customHeight: height,
      borderRadius: 16.0,
      onPressed: onTap,
      iconLeading: showLeadingPlus
          ? const Icon(
              Iconsax.add,
              color: AppColors.white,
              size: 22,
            )
          : null,
      iconTrailing: showRightArrow
          ? const Icon(
              Iconsax.arrow_right_1,
              color: AppColors.white,
              size: 20,
            )
          : null,
    );
  }

  Widget _buildSecondaryButton({
    required String label,
    required VoidCallback onTap,
    double height = 48,
  }) {
    return AppButton(
      text: label,
      variant: AppButtonVariant.secondary,
      customHeight: height,
      borderRadius: 16.0,
      onPressed: onTap,
    );
  }
}

/// Outlined Checkmark Painter matching the 5 checklist circles in `Plan a Trip - AI Loading.png`
class _OutlinedCheckPainter extends CustomPainter {
  const _OutlinedCheckPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(size.width * 0.18, size.height * 0.52)
      ..lineTo(size.width * 0.42, size.height * 0.74)
      ..lineTo(size.width * 0.84, size.height * 0.30);

    // Outer dark ink stroke
    final outerStroke = Paint()
      ..color = AppColors.secondaryDark
      ..strokeWidth = 4.6
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // Inner white fill stroke
    final innerStroke = Paint()
      ..color = AppColors.white
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.drawPath(path, outerStroke);
    canvas.drawPath(path, innerStroke);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Exact Crossed Fork and Spoon vector painter matching `Food/Dining` in
/// `Plan a Trip - Itinerary Empty State-1.png`.
class _CrossedForkSpoonPainter extends CustomPainter {
  const _CrossedForkSpoonPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final fillPaint = Paint()
      ..color = AppColors.white
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;
    final strokePaint = Paint()
      ..color = AppColors.white
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..isAntiAlias = true;

    // 1. Spoon: diagonally from top-right (0.76, 0.24) to bottom-left (0.16, 0.84)
    canvas.save();
    canvas.translate(w * 0.5, h * 0.5);
    canvas.rotate(math.pi / 4); // +45 deg: top is top-right, bottom is bottom-left
    // Oval spoon bowl at top (y = -0.30 * h)
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(0, -h * 0.27),
        width: w * 0.25,
        height: h * 0.33,
      ),
      fillPaint,
    );
    // Upper neck of spoon (above crossing gap)
    canvas.drawLine(
      Offset(0, -h * 0.12),
      Offset(0, -h * 0.07),
      strokePaint..strokeWidth = w * 0.085,
    );
    // Lower handle of spoon (below crossing gap)
    final spoonHandle = Path()
      ..moveTo(-w * 0.04, h * 0.09)
      ..lineTo(w * 0.04, h * 0.09)
      ..lineTo(w * 0.065, h * 0.43)
      ..quadraticBezierTo(0, h * 0.48, -w * 0.065, h * 0.43)
      ..close();
    canvas.drawPath(spoonHandle, fillPaint);
    canvas.restore();

    // 2. Fork: diagonally from top-left (0.24, 0.24) to bottom-right (0.84, 0.84)
    canvas.save();
    canvas.translate(w * 0.5, h * 0.5);
    canvas.rotate(-math.pi / 4); // -45 deg: top is top-left, bottom is bottom-right
    // Fork handle going continuously from neck to bottom
    final forkHandle = Path()
      ..moveTo(-w * 0.04, -h * 0.14)
      ..lineTo(w * 0.04, -h * 0.14)
      ..lineTo(w * 0.065, h * 0.43)
      ..quadraticBezierTo(0, h * 0.48, -w * 0.065, h * 0.43)
      ..close();
    canvas.drawPath(forkHandle, fillPaint);

    // Fork head base curve
    final forkBase = Path()
      ..moveTo(-w * 0.12, -h * 0.22)
      ..quadraticBezierTo(-w * 0.12, -h * 0.12, 0, -h * 0.12)
      ..quadraticBezierTo(w * 0.12, -h * 0.12, w * 0.12, -h * 0.22)
      ..close();
    canvas.drawPath(forkBase, fillPaint);

    // 3 Prongs at top
    final prongPaint = Paint()
      ..color = AppColors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.055
      ..strokeCap = StrokeCap.round
      ..isAntiAlias = true;
    canvas.drawLine(Offset(-w * 0.095, -h * 0.20), Offset(-w * 0.095, -h * 0.42), prongPaint);
    canvas.drawLine(Offset(0, -h * 0.20), Offset(0, -h * 0.42), prongPaint);
    canvas.drawLine(Offset(w * 0.095, -h * 0.20), Offset(w * 0.095, -h * 0.42), prongPaint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Custom Painter rendering the illustrated periwinkle/blue street map from
/// `Plan a Trip - View in Map.png`.
class _FigmaMapBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final highwayPaint = Paint()
      ..color = const Color(0xFF7B93FF)
      ..strokeWidth = 14
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final secondaryRoadPaint = Paint()
      ..color = const Color(0xFF8CA2FF)
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Main diagonal avenue
    final mainRoad = Path()
      ..moveTo(w * 0.46, 0)
      ..lineTo(w * 0.99, h * 0.34)
      ..lineTo(w * 0.99, h * 0.42)
      ..lineTo(w * 0.40, h * 0.57)
      ..lineTo(0, h * 0.88);
    canvas.drawPath(mainRoad, highwayPaint);

    final bottomCross = Path()
      ..moveTo(0, h * 0.81)
      ..lineTo(w * 0.25, h);
    canvas.drawPath(bottomCross, highwayPaint);

    final streets = <List<Offset>>[
      [Offset(0, h * 0.06), Offset(w * 0.30, h * 0.10)],
      [Offset(w * 0.27, 0), Offset(w * 0.43, h * 0.48)],
      [Offset(0, h * 0.20), Offset(w * 0.40, h * 0.38)],
      [Offset(0, h * 0.46), Offset(w * 0.98, h * 0.34)],
      [Offset(w * 0.14, h * 0.54), Offset(w * 0.98, h * 0.38)],
      [Offset(w * 0.36, h * 0.34), Offset(w * 0.72, h * 0.10)],
      [Offset(w * 0.45, h * 0.22), Offset(w * 0.74, h * 0.29)],
      [Offset(w * 0.33, h * 0.74), Offset(w * 0.55, h * 0.72)],
      [Offset(w * 0.55, h * 0.72), Offset(w * 0.73, h * 0.74)],
      [Offset(w * 0.65, h * 0.57), Offset(w * 0.71, h * 0.88)],
      [Offset(w * 0.68, h * 0.88), Offset(w, h * 0.82)],
      [Offset(w * 0.42, h * 0.68), Offset(w * 0.50, h * 0.55)],
      [Offset(w * 0.50, h * 0.55), Offset(w * 0.71, h * 0.58)],
      [Offset(w * 0.76, h * 0.48), Offset(w * 0.86, h * 0.60)],
      [Offset(w * 0.86, h * 0.60), Offset(w, h * 0.59)],
    ];

    for (final line in streets) {
      canvas.drawLine(line[0], line[1], secondaryRoadPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
