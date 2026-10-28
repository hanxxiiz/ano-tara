import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../components/atoms/app_button.dart';
import '../../../../components/molecules/app_availability_pill.dart';
import '../../../../components/molecules/app_budget_slider.dart';
import '../../../../components/molecules/app_option_card.dart';
import '../../../../components/molecules/app_pace_card.dart';
import '../../../../core/routes/app_routes.dart';

/// 7-Step Onboarding Preferences flow matching Figma design:
/// Activities -> Dietary Preferences -> Allergies -> Budget -> Pace -> Availability -> Getting Started.
class OnboardingFlowScreen extends StatefulWidget {
  const OnboardingFlowScreen({super.key});

  @override
  State<OnboardingFlowScreen> createState() => _OnboardingFlowScreenState();
}

class _OnboardingFlowScreenState extends State<OnboardingFlowScreen> {
  int _currentStep = 0; // 0 to 6 (Steps 1/7 to 7/7)
  final int _totalSteps = 7;

  // Step 1: Activities
  final Set<String> _selectedActivities = {'Hiking', 'Sightseeing'};
  final List<(String, IconData)> _activitiesList = const [
    ('Beaches', Icons.beach_access_rounded),
    ('Food Trips', Icons.restaurant_rounded),
    ('Sightseeing', Icons.visibility_rounded),
    ('Hiking', Icons.landscape_rounded),
    ('Museums', Icons.museum_rounded),
    ('Shopping', Icons.shopping_bag_rounded),
    ('Nightlife', Icons.local_bar_rounded),
    ('Beaches', Icons.beach_access_rounded),
    ('Others', Icons.add_circle_rounded),
  ];

  // Step 2: Dietary Preferences
  final Set<String> _selectedDiets = {'Gluten-free', 'Vegetarian'};
  final TextEditingController _dietSpecifyController = TextEditingController();
  final List<(String, IconData)> _dietsList = const [
    ('Gluten-free', Icons.grass_rounded),
    ('Vegan', Icons.eco_rounded),
    ('Pescatarian', Icons.set_meal_rounded),
    ('Keto', Icons.egg_alt_rounded),
    ('Vegetarian', Icons.spa_rounded),
    ('Others', Icons.add_circle_rounded),
  ];

  // Step 3: Allergies
  final Set<String> _selectedAllergies = {'Dairy', 'Gluten', 'Eggs', 'Sesame'};
  final TextEditingController _allergySpecifyController = TextEditingController();
  final List<(String, IconData)> _allergiesList = const [
    ('Seafood', Icons.set_meal_rounded),
    ('Peanuts', Icons.egg_rounded),
    ('Dairy', Icons.local_drink_rounded),
    ('Gluten', Icons.grass_rounded),
    ('Eggs', Icons.egg_rounded),
    ('Shellfish', Icons.water_drop_rounded),
    ('Soy', Icons.grain_rounded),
    ('Sesame', Icons.grain_rounded),
    ('Others', Icons.add_circle_rounded),
  ];

  // Step 4: Budget
  int _selectedBudgetIndex = 2; // P 2.000

  // Step 5: Pace
  String _selectedPace = 'Balanced';
  final List<(String, String, IconData)> _pacesList = const [
    (
      'Relaxed',
      'Slow mornings, spontaneous stops, and plenty of time to just vibe.',
      Icons.air_rounded,
    ),
    (
      'Balanced',
      'A little adventure, a little chill — the sweet spot for your trip.',
      Icons.hourglass_bottom_rounded,
    ),
    (
      'Packed',
      'Go, go, go! Max out the day and squeeze in as much fun as possible.',
      Icons.timer_rounded,
    ),
  ];

  // Step 6: Availability (matching Figma Step 6: Mon, Wed, Thu, Sat selected)
  final Set<String> _selectedDays = {'Monday', 'Wednesday', 'Thursday', 'Saturday'};

  // Step 7: Notes
  final TextEditingController _notesController = TextEditingController();
  bool _isFinishing = false;

  @override
  void dispose() {
    _dietSpecifyController.dispose();
    _allergySpecifyController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < _totalSteps - 1) {
      setState(() {
        _currentStep++;
      });
    } else {
      _finishOnboarding();
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
    } else {
      Navigator.of(context).maybePop();
    }
  }

  void _finishOnboarding() async {
    setState(() => _isFinishing = true);
    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;
    setState(() => _isFinishing = false);

    Navigator.of(context).pushReplacementNamed(AppRoutes.main);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header: Back Arrow (Steps 2..7) and Top Progress Capsule Indicator
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Back Arrow on Left
                  if (_currentStep > 0)
                    Align(
                      alignment: Alignment.centerLeft,
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        icon: const Icon(
                          Icons.arrow_back,
                          color: AppColors.secondaryDark,
                          size: 26,
                        ),
                        onPressed: _previousStep,
                      ),
                    ),

                  // 7 Capsule Pills Indicator
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(_totalSteps, (index) {
                          final bool isCurrent = index == _currentStep;
                          return Container(
                            width: 32,
                            height: 8,
                            margin: const EdgeInsets.symmetric(horizontal: 3),
                            decoration: BoxDecoration(
                              color: isCurrent ? AppColors.secondaryDark : Colors.transparent,
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(
                                color: AppColors.secondaryDark,
                                width: 1.5,
                              ),
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${_currentStep + 1}/$_totalSteps',
                        style: GoogleFonts.urbanist(
                          color: AppColors.secondaryDark,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Main Step Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 4.0),
                child: _buildCurrentStepContent(),
              ),
            ),

            // Bottom Navigation CTA
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: AppButton(
                text: _currentStep == _totalSteps - 1 ? 'Finish' : 'Next',
                variant: AppButtonVariant.primaryNavy,
                isLoading: _isFinishing,
                onPressed: _nextStep,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepHeader(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          title,
          textAlign: TextAlign.center,
          style: GoogleFonts.urbanist(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: AppColors.secondaryDark,
            height: 1.25,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: GoogleFonts.openSans(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: AppColors.secondaryDark,
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildCurrentStepContent() {
    switch (_currentStep) {
      case 0:
        return _buildActivitiesStep();
      case 1:
        return _buildDietaryStep();
      case 2:
        return _buildAllergiesStep();
      case 3:
        return _buildBudgetStep();
      case 4:
        return _buildPaceStep();
      case 5:
        return _buildAvailabilityStep();
      case 6:
        return _buildFinishStep();
      default:
        return const SizedBox.shrink();
    }
  }

  // Step 1: Activities (3x3 Grid)
  Widget _buildActivitiesStep() {
    return Column(
      children: [
        _buildStepHeader(
          'What kind of activities do you usually\nenjoy?',
          'Select all that apply.',
        ),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _activitiesList.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.95,
          ),
          itemBuilder: (context, index) {
            final item = _activitiesList[index];
            final isSelected = _selectedActivities.contains(item.$1);
            return AppOptionCard(
              label: item.$1,
              icon: item.$2,
              isSelected: isSelected,
              selectedColor: AppColors.secondaryDark,
              onTap: () {
                setState(() {
                  if (isSelected) {
                    _selectedActivities.remove(item.$1);
                  } else {
                    _selectedActivities.add(item.$1);
                  }
                });
              },
            );
          },
        ),
      ],
    );
  }

  // Step 2: Dietary Preferences (2x3 Grid + Specify box)
  Widget _buildDietaryStep() {
    return Column(
      children: [
        _buildStepHeader(
          'Do you have any dietary preferences?',
          'Select all that apply.',
        ),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _dietsList.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.95,
          ),
          itemBuilder: (context, index) {
            final item = _dietsList[index];
            final isSelected = _selectedDiets.contains(item.$1);
            return AppOptionCard(
              label: item.$1,
              icon: item.$2,
              isSelected: isSelected,
              selectedColor: AppColors.primaryNavy,
              onTap: () {
                setState(() {
                  if (isSelected) {
                    _selectedDiets.remove(item.$1);
                  } else {
                    _selectedDiets.add(item.$1);
                  }
                });
              },
            );
          },
        ),
        const SizedBox(height: 20),
        _buildSpecifyBox(
          controller: _dietSpecifyController,
          hint: 'Please specify',
        ),
      ],
    );
  }

  // Step 3: Allergies (3x3 Grid with Orange selection + Specify box)
  Widget _buildAllergiesStep() {
    return Column(
      children: [
        _buildStepHeader(
          'Do you have any food or other allergies we\nshould consider?',
          'Select all that apply.',
        ),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _allergiesList.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.95,
          ),
          itemBuilder: (context, index) {
            final item = _allergiesList[index];
            final isSelected = _selectedAllergies.contains(item.$1);
            return AppOptionCard(
              label: item.$1,
              icon: item.$2,
              isSelected: isSelected,
              selectedColor: AppColors.primaryOrange,
              onTap: () {
                setState(() {
                  if (isSelected) {
                    _selectedAllergies.remove(item.$1);
                  } else {
                    _selectedAllergies.add(item.$1);
                  }
                });
              },
            );
          },
        ),
        const SizedBox(height: 20),
        _buildSpecifyBox(
          controller: _allergySpecifyController,
          hint: 'Please specify',
        ),
      ],
    );
  }

  // Multi-line clean specify box matching Figma
  Widget _buildSpecifyBox({
    required TextEditingController controller,
    required String hint,
  }) {
    return Container(
      height: 180,
      decoration: BoxDecoration(
        color: AppColors.secondaryLight,
        borderRadius: BorderRadius.circular(20.0),
        border: Border.all(
          color: AppColors.secondaryDark.withValues(alpha: 0.5),
          width: 2.0,
        ),
      ),
      child: TextFormField(
        controller: controller,
        maxLines: null,
        expands: true,
        textAlignVertical: TextAlignVertical.top,
        style: GoogleFonts.urbanist(
          fontSize: 14.5,
          fontWeight: FontWeight.w600,
          color: AppColors.secondaryDark,
        ),
        cursorColor: AppColors.secondaryDark,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.openSans(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: AppColors.shayne,
          ),
          filled: false,
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding: const EdgeInsets.all(18),
        ),
      ),
    );
  }

  // Step 4: Budget
  Widget _buildBudgetStep() {
    return Column(
      children: [
        _buildStepHeader(
          'What’s your usual budget for a trip or\nhangout?',
          'Set your preferred budget.',
        ),
        const SizedBox(height: 16),
        AppBudgetSlider(
          selectedIndex: _selectedBudgetIndex,
          onIndexChanged: (index) {
            setState(() {
              _selectedBudgetIndex = index;
            });
          },
        ),
      ],
    );
  }

  // Step 5: Pace
  Widget _buildPaceStep() {
    return Column(
      children: [
        _buildStepHeader(
          'How do you like your trips planned?',
          'Choose the pace that suits you.',
        ),
        for (final item in _pacesList) ...[
          AppPaceCard(
            title: item.$1,
            description: item.$2,
            icon: item.$3,
            isSelected: _selectedPace == item.$1,
            onTap: () {
              setState(() {
                _selectedPace = item.$1;
              });
            },
          ),
          const SizedBox(height: 14),
        ],
      ],
    );
  }

  // Step 6: General Availability (2-column grid + Sunday centered)
  Widget _buildAvailabilityStep() {
    return Column(
      children: [
        _buildStepHeader(
          'When are you usually free?',
          "Set your general availability so your groups know\nwhen you’re likely free.",
        ),
        const SizedBox(height: 12),
        // Row 1: Monday, Tuesday
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AppAvailabilityPill(
              day: 'Monday',
              isSelected: _selectedDays.contains('Monday'),
              onTap: () => _toggleDay('Monday'),
            ),
            const SizedBox(width: 14),
            AppAvailabilityPill(
              day: 'Tuesday',
              isSelected: _selectedDays.contains('Tuesday'),
              onTap: () => _toggleDay('Tuesday'),
            ),
          ],
        ),
        const SizedBox(height: 14),
        // Row 2: Wednesday, Thursday
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AppAvailabilityPill(
              day: 'Wednesday',
              isSelected: _selectedDays.contains('Wednesday'),
              onTap: () => _toggleDay('Wednesday'),
            ),
            const SizedBox(width: 14),
            AppAvailabilityPill(
              day: 'Thursday',
              isSelected: _selectedDays.contains('Thursday'),
              onTap: () => _toggleDay('Thursday'),
            ),
          ],
        ),
        const SizedBox(height: 14),
        // Row 3: Friday, Saturday
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AppAvailabilityPill(
              day: 'Friday',
              isSelected: _selectedDays.contains('Friday'),
              onTap: () => _toggleDay('Friday'),
            ),
            const SizedBox(width: 14),
            AppAvailabilityPill(
              day: 'Saturday',
              isSelected: _selectedDays.contains('Saturday'),
              onTap: () => _toggleDay('Saturday'),
            ),
          ],
        ),
        const SizedBox(height: 14),
        // Row 4: Sunday (Centered)
        Center(
          child: AppAvailabilityPill(
            day: 'Sunday',
            isSelected: _selectedDays.contains('Sunday'),
            onTap: () => _toggleDay('Sunday'),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  void _toggleDay(String day) {
    setState(() {
      if (_selectedDays.contains(day)) {
        _selectedDays.remove(day);
      } else {
        _selectedDays.add(day);
      }
    });
  }

  // Step 7: Notes (Large multi-line box matching Figma Step 7)
  Widget _buildFinishStep() {
    return Column(
      children: [
        _buildStepHeader(
          'Anything else we should keep in mind when\nplanning for you?',
          'Optional notes for better suggestions.',
        ),
        Container(
          height: 400,
          decoration: BoxDecoration(
            color: AppColors.secondaryLight,
            borderRadius: BorderRadius.circular(20.0),
            border: Border.all(
              color: AppColors.secondaryDark.withValues(alpha: 0.5),
              width: 2.0,
            ),
          ),
          child: TextFormField(
            controller: _notesController,
            maxLines: null,
            expands: true,
            textAlignVertical: TextAlignVertical.top,
            style: GoogleFonts.urbanist(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.secondaryDark,
            ),
            cursorColor: AppColors.secondaryDark,
            decoration: InputDecoration(
              hintText: 'I prefer morning activities, and love cafes...',
              hintStyle: GoogleFonts.openSans(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: AppColors.shayne,
              ),
              filled: false,
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              contentPadding: const EdgeInsets.all(20),
            ),
          ),
        ),
      ],
    );
  }
}
