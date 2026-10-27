import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_radii.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../components/atoms/app_button.dart';
import '../../../../components/atoms/app_input_field.dart';
import '../../../../components/molecules/app_availability_pill.dart';
import '../../../../components/molecules/app_budget_slider.dart';
import '../../../../components/molecules/app_option_card.dart';
import '../../../../components/molecules/app_pace_card.dart';
import '../../../../components/organisms/app_top_bar.dart';
import '../../../../core/routes/app_routes.dart';

/// 7-Step Onboarding Preferences flow matching Figma design:
/// Activities -> Dietary Preferences -> Allergies -> Budget -> Pace -> Availability -> Notes -> Home.
class OnboardingFlowScreen extends StatefulWidget {
  const OnboardingFlowScreen({super.key});

  @override
  State<OnboardingFlowScreen> createState() => _OnboardingFlowScreenState();
}

class _OnboardingFlowScreenState extends State<OnboardingFlowScreen> {
  int _currentStep = 0; // 0 to 6 (Steps 1/7 to 7/7)
  final int _totalSteps = 7;

  // Step 1: Activities
  final Set<String> _selectedActivities = {'Food Trips', 'Beaches'};
  final List<(String, IconData)> _activitiesList = const [
    ('Beaches', Iconsax.sun_1),
    ('Food Trips', Iconsax.coffee),
    ('Sightseeing', Iconsax.camera),
    ('Hiking', Iconsax.routing_2),
    ('Museums', Iconsax.building_3),
    ('Shopping', Iconsax.shopping_bag),
    ('Nightlife', Iconsax.music),
    ('Road Trips', Iconsax.car),
    ('Others', Iconsax.add),
  ];

  // Step 2: Dietary Preferences
  final Set<String> _selectedDiets = {'Gluten-free'};
  final TextEditingController _dietSpecifyController = TextEditingController();
  final List<(String, IconData)> _dietsList = const [
    ('Gluten-free', Iconsax.health),
    ('Vegan', Iconsax.tree),
    ('Pescatarian', Iconsax.activity),
    ('Keto', Iconsax.flash_1),
    ('Vegetarian', Iconsax.cup),
    ('Others', Iconsax.add),
  ];

  // Step 3: Allergies
  final Set<String> _selectedAllergies = {'Dairy', 'Gluten', 'Eggs'};
  final TextEditingController _allergySpecifyController = TextEditingController();
  final List<(String, IconData)> _allergiesList = const [
    ('Seafood', Iconsax.warning_2),
    ('Peanuts', Iconsax.shield_cross),
    ('Dairy', Iconsax.milk),
    ('Gluten', Iconsax.health),
    ('Eggs', Iconsax.danger),
    ('Shellfish', Iconsax.info_circle),
    ('Soy', Iconsax.drop),
    ('Sesame', Iconsax.star_1),
    ('Others', Iconsax.add),
  ];

  // Step 4: Budget
  int _selectedBudgetIndex = 2; // ₱ 2,000

  // Step 5: Pace
  String _selectedPace = 'Balanced';
  final List<(String, String, IconData)> _pacesList = const [
    (
      'Relaxed',
      'Slow mornings, couple of main stops, and plenty of free time just to vibe.',
      Iconsax.cup,
    ),
    (
      'Balanced',
      'A little bit of both, a solid plan with the sweet spot for your trip.',
      Iconsax.compass,
    ),
    (
      'Packed',
      'Go, go, go! Max out the day and see/do as much healthily as possible.',
      Iconsax.flash_1,
    ),
  ];

  // Step 6: Availability
  final Set<String> _selectedDays = {'Monday', 'Friday', 'Saturday', 'Sunday'};
  final List<String> _weekDays = const [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

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
    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    setState(() => _isFinishing = false);

    Navigator.of(context).pushReplacementNamed(AppRoutes.main);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppTopBar(
        onBackPressed: _previousStep,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Top Progress Bar & Counter (e.g. "1/7")
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Column(
                children: [
                  Row(
                    children: List.generate(_totalSteps, (index) {
                      final bool isDone = index <= _currentStep;
                      return Expanded(
                        child: Container(
                          height: 4,
                          margin: EdgeInsets.only(right: index < _totalSteps - 1 ? 6 : 0),
                          decoration: BoxDecoration(
                            color: isDone ? AppColors.chucky : AppColors.ann.withValues(alpha: 0.4),
                            borderRadius: AppRadii.radiusPill,
                          ),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${_currentStep + 1}/$_totalSteps',
                    style: AppTypography.caption.copyWith(
                      color: AppColors.shayne,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            // Step Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                child: _buildCurrentStepContent(),
              ),
            ),

            // Bottom Navigation CTA
            Padding(
              padding: const EdgeInsets.all(24.0),
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
          style: AppTypography.h3.copyWith(color: AppColors.chucky),
        ),
        const SizedBox(height: 6),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: AppTypography.bodyMedium,
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
        return _buildNotesStep();
      default:
        return const SizedBox.shrink();
    }
  }

  // Step 1: Activities
  Widget _buildActivitiesStep() {
    return Column(
      children: [
        _buildStepHeader(
          'What kind of activities do you usually enjoy?',
          'Select all that apply.',
        ),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          alignment: WrapAlignment.center,
          children: _activitiesList.map((item) {
            final isSelected = _selectedActivities.contains(item.$1);
            return AppOptionCard(
              label: item.$1,
              icon: item.$2,
              isSelected: isSelected,
              selectedColor: AppColors.primaryNavy,
              size: 96,
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
          }).toList(),
        ),
      ],
    );
  }

  // Step 2: Dietary Preferences
  Widget _buildDietaryStep() {
    return Column(
      children: [
        _buildStepHeader(
          'Do you have any dietary preferences?',
          'Select all that apply.',
        ),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          alignment: WrapAlignment.center,
          children: _dietsList.map((item) {
            final isSelected = _selectedDiets.contains(item.$1);
            return AppOptionCard(
              label: item.$1,
              icon: item.$2,
              isSelected: isSelected,
              selectedColor: AppColors.primaryNavy,
              size: 100,
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
          }).toList(),
        ),
        const SizedBox(height: 24),
        AppInputField(
          hint: 'Please specify other dietary preferences...',
          controller: _dietSpecifyController,
        ),
      ],
    );
  }

  // Step 3: Allergies
  Widget _buildAllergiesStep() {
    return Column(
      children: [
        _buildStepHeader(
          'Do you have any food or other allergies we should consider?',
          'Select all that apply.',
        ),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          alignment: WrapAlignment.center,
          children: _allergiesList.map((item) {
            final isSelected = _selectedAllergies.contains(item.$1);
            return AppOptionCard(
              label: item.$1,
              icon: item.$2,
              isSelected: isSelected,
              selectedColor: AppColors.primaryOrange,
              size: 96,
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
          }).toList(),
        ),
        const SizedBox(height: 24),
        AppInputField(
          hint: 'Please specify other allergies...',
          controller: _allergySpecifyController,
        ),
      ],
    );
  }

  // Step 4: Budget
  Widget _buildBudgetStep() {
    return Column(
      children: [
        _buildStepHeader(
          "What's your usual budget for a trip or hangout?",
          'Select your preferred budget.',
        ),
        const SizedBox(height: 20),
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
            activeColor: AppColors.primaryOrange,
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

  // Step 6: General Availability
  Widget _buildAvailabilityStep() {
    return Column(
      children: [
        _buildStepHeader(
          'When are you usually free?',
          "Set your general availability for your group to know when you're likely free.",
        ),
        Wrap(
          spacing: 12,
          runSpacing: 14,
          alignment: WrapAlignment.center,
          children: _weekDays.map((day) {
            final isSelected = _selectedDays.contains(day);
            return AppAvailabilityPill(
              day: day,
              isSelected: isSelected,
              activeColor: AppColors.primaryOrange,
              onTap: () {
                setState(() {
                  if (isSelected) {
                    _selectedDays.remove(day);
                  } else {
                    _selectedDays.add(day);
                  }
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  // Step 7: Notes
  Widget _buildNotesStep() {
    return Column(
      children: [
        _buildStepHeader(
          'Anything else we should keep in mind when planning for you?',
          'Optional notes for better suggestions.',
        ),
        AppInputField(
          hint: 'e.g. prefer morning activities, strict budget rest, love cozy cafes...',
          controller: _notesController,
          minLines: 8,
          maxLines: 12,
        ),
      ],
    );
  }
}
