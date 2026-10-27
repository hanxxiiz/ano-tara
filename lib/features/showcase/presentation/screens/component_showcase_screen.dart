import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_radii.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../components/atoms/app_avatar.dart';
import '../../../../components/atoms/app_badge.dart';
import '../../../../components/atoms/app_button.dart';
import '../../../../components/atoms/app_checkbox.dart';
import '../../../../components/atoms/app_input_field.dart';
import '../../../../components/atoms/app_otp_field.dart';
import '../../../../components/atoms/app_switch.dart';
import '../../../../components/molecules/app_availability_pill.dart';
import '../../../../components/molecules/app_budget_slider.dart';
import '../../../../components/molecules/app_option_card.dart';
import '../../../../components/molecules/app_pace_card.dart';
import '../../../../components/molecules/app_search_bar.dart';
import '../../../../components/organisms/app_bottom_navigation.dart';
import '../../../../components/organisms/app_top_bar.dart';
import '../../../../components/organisms/availability_panel.dart';
import '../../../../components/organisms/member_panel.dart';
import '../../../../components/organisms/overview_summary_panel.dart';
import '../../../../components/organisms/trip_summary_card.dart';

/// Comprehensive Component Gallery & Design System Showcase.
/// Demonstrates every atom in default, disabled, and loading states,
/// every molecule, and every organism with live interactive state controls.
class ComponentShowcaseScreen extends StatefulWidget {
  const ComponentShowcaseScreen({super.key});

  @override
  State<ComponentShowcaseScreen> createState() => _ComponentShowcaseScreenState();
}

class _ComponentShowcaseScreenState extends State<ComponentShowcaseScreen> {
  bool _checkboxVal1 = true;
  bool _checkboxVal2 = false;
  bool _switchVal1 = true;
  bool _switchVal2 = false;
  bool _simulateLoading = false;
  int _sliderIndex = 2;
  bool _optionSelected = true;
  bool _pillSelected = true;
  String _paceSelected = 'Balanced';
  int _bottomNavIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const AppTopBar(
        title: 'Design System & Atoms',
        subtitle: 'Ano Tara! Atomic Components',
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: AppSpacing.screenPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Interactive State Toggle Banner
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.primaryNavyLight,
                  borderRadius: AppRadii.radiusMd,
                  border: Border.all(color: AppColors.primaryNavy, width: 1),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Toggle Atom Loading States:',
                      style: AppTypography.buttonMedium.copyWith(color: AppColors.primaryNavy),
                    ),
                    AppSwitch(
                      value: _simulateLoading,
                      activeColor: AppColors.primaryNavy,
                      onChanged: (val) => setState(() => _simulateLoading = val),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // SECTION 1: COLOR PALETTE
              _buildSectionHeader('1. Color Tokens'),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  _buildColorChip('Primary Orange', '#E24B27', AppColors.primaryOrange),
                  _buildColorChip('Primary Navy', '#144885', AppColors.primaryNavy),
                  _buildColorChip('Secondary Light', '#E8E6E3', AppColors.secondaryLight, textColor: AppColors.chucky),
                  _buildColorChip('Secondary Dark', '#0F0331', AppColors.secondaryDark),
                  _buildColorChip('Semantic Yellow', '#F9CF09', AppColors.semanticYellow, textColor: AppColors.chucky),
                  _buildColorChip('Semantic Red', '#F50506', AppColors.semanticRed),
                  _buildColorChip('Chucky (Neutral)', '#0F0331', AppColors.chucky),
                  _buildColorChip('Carla (Neutral)', '#4B4265', AppColors.carla),
                  _buildColorChip('Shayne (Neutral)', '#868097', AppColors.shayne),
                  _buildColorChip('Ann (Border)', '#C3C0CB', AppColors.ann, textColor: AppColors.chucky),
                ],
              ),
              const Divider(height: 48),

              // SECTION 2: BUTTON ATOMS (All variants & states)
              _buildSectionHeader('2. Button Atoms (Default, Loading, Disabled)'),
              const Text('• Primary Navy Button', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              AppButton(
                text: 'Primary Navy (Default)',
                variant: AppButtonVariant.primaryNavy,
                isLoading: _simulateLoading,
                onPressed: () {},
              ),
              const SizedBox(height: 10),
              const AppButton(
                text: 'Primary Navy (Disabled)',
                variant: AppButtonVariant.primaryNavy,
                isDisabled: true,
                onPressed: null,
              ),
              const SizedBox(height: 16),

              const Text('• Primary Orange Button', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              AppButton(
                text: 'Primary Orange (Default)',
                variant: AppButtonVariant.primaryOrange,
                isLoading: _simulateLoading,
                onPressed: () {},
              ),
              const SizedBox(height: 16),

              const Text('• Secondary Outline & Destructive', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: AppButton(
                      text: 'Outline',
                      variant: AppButtonVariant.outline,
                      isLoading: _simulateLoading,
                      onPressed: () {},
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: AppButton(
                      text: 'Destructive',
                      variant: AppButtonVariant.destructive,
                      isLoading: _simulateLoading,
                      onPressed: () {},
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              const Text('• Google Sign-In & Icon-Only Button', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              AppButton.google(
                isLoading: _simulateLoading,
                onPressed: () {},
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  AppButton.iconOnly(
                    icon: const Icon(Iconsax.heart, color: AppColors.white, size: 20),
                    variant: AppButtonVariant.primaryOrange,
                    onPressed: () {},
                  ),
                  const SizedBox(width: 12),
                  AppButton.iconOnly(
                    icon: const Icon(Iconsax.share, color: AppColors.white, size: 20),
                    variant: AppButtonVariant.primaryNavy,
                    onPressed: () {},
                  ),
                  const SizedBox(width: 12),
                  AppButton.iconOnly(
                    icon: const Icon(Iconsax.trash, color: AppColors.white, size: 20),
                    variant: AppButtonVariant.destructive,
                    onPressed: () {},
                  ),
                ],
              ),
              const Divider(height: 48),

              // SECTION 3: INPUT FIELD ATOMS
              _buildSectionHeader('3. Input Field Atoms (Default, Focused, Error, Disabled)'),
              const AppInputField(
                label: 'Default Input with Placeholder',
                hint: 'Type something...',
              ),
              const SizedBox(height: 14),
              const AppInputField(
                label: 'Input with Prefix Icon',
                hint: 'Search destination...',
                prefixIcon: Icon(Iconsax.location, color: AppColors.shayne, size: 20),
              ),
              const SizedBox(height: 14),
              const AppInputField(
                label: 'Password Input with Eye Toggle',
                hint: 'Enter secret code',
                isPassword: true,
              ),
              const SizedBox(height: 14),
              const AppInputField(
                label: 'Input with Error State',
                hint: 'user@domain.com',
                errorText: 'Please enter a valid email address.',
              ),
              const SizedBox(height: 14),
              const AppInputField(
                label: 'Disabled Input Field',
                hint: 'Cannot edit this field',
                isEnabled: false,
              ),
              const SizedBox(height: 14),
              const AppInputField(
                label: 'Multiline Input Field (Notes)',
                hint: 'Add custom trip instructions...',
                minLines: 3,
                maxLines: 4,
              ),
              const Divider(height: 48),

              // SECTION 4: OTP INPUT ATOM
              _buildSectionHeader('4. OTP Pin Verification Atom'),
              AppOtpField(
                length: 6,
                onCompleted: (val) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('OTP Entered: $val')),
                  );
                },
              ),
              const Divider(height: 48),

              // SECTION 5: BADGES, CHECKBOXES & SWITCHES
              _buildSectionHeader('5. Badges, Checkboxes & Switches'),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  AppBadge.tierPlus(),
                  const AppBadge(label: 'Trip Leader', variant: AppBadgeVariant.primaryNavy),
                  const AppBadge(label: '7 free', variant: AppBadgeVariant.primaryOrange),
                  const AppBadge(label: 'Pending', variant: AppBadgeVariant.tierYellow),
                  const AppBadge(label: 'Cancelled', variant: AppBadgeVariant.semanticRed),
                  const AppBadge(label: 'Confirmed', variant: AppBadgeVariant.semanticGreen),
                  AppBadge.counter('+3'),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: AppCheckbox(
                      value: _checkboxVal1,
                      label: 'Standard Checkbox',
                      onChanged: (val) => setState(() => _checkboxVal1 = val),
                    ),
                  ),
                  Expanded(
                    child: AppCheckbox(
                      value: _checkboxVal2,
                      isMini: true,
                      label: 'Mini Checkbox',
                      onChanged: (val) => setState(() => _checkboxVal2 = val),
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  const AppCheckbox(
                    value: true,
                    isDisabled: true,
                    label: 'Disabled Checked',
                    onChanged: null,
                  ),
                  const SizedBox(width: 16),
                  AppSwitch(
                    value: _switchVal1,
                    onChanged: (val) => setState(() => _switchVal1 = val),
                  ),
                  const SizedBox(width: 8),
                  const Text('Switch'),
                ],
              ),
              const Divider(height: 48),

              // SECTION 6: MOLECULES
              _buildSectionHeader('6. Molecules'),
              const Text('• Search Bar Molecule:'),
              const SizedBox(height: 8),
              const AppSearchBar(),
              const SizedBox(height: 20),

              const Text('• Option Cards (Square, Icon, Multi-select):'),
              const SizedBox(height: 8),
              Row(
                children: [
                  AppOptionCard(
                    label: 'Food Trips',
                    icon: Iconsax.coffee,
                    isSelected: _optionSelected,
                    selectedColor: AppColors.primaryNavy,
                    onTap: () => setState(() => _optionSelected = !_optionSelected),
                  ),
                  const SizedBox(width: 12),
                  AppOptionCard(
                    label: 'Beaches',
                    icon: Iconsax.sun_1,
                    isSelected: !_optionSelected,
                    selectedColor: AppColors.primaryOrange,
                    onTap: () => setState(() => _optionSelected = !_optionSelected),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              const Text('• Pace Card Molecule:'),
              const SizedBox(height: 8),
              AppPaceCard(
                title: 'Balanced',
                description: 'A little bit of both, a solid plan with the sweet spot for your trip.',
                icon: Iconsax.compass,
                isSelected: _paceSelected == 'Balanced',
                onTap: () => setState(() => _paceSelected = 'Balanced'),
              ),
              const SizedBox(height: 20),

              const Text('• Availability Pill Molecule:'),
              const SizedBox(height: 8),
              Row(
                children: [
                  AppAvailabilityPill(
                    day: 'Friday',
                    isSelected: _pillSelected,
                    onTap: () => setState(() => _pillSelected = !_pillSelected),
                  ),
                  const SizedBox(width: 12),
                  AppAvailabilityPill(
                    day: 'Saturday',
                    isSelected: !_pillSelected,
                    onTap: () => setState(() => _pillSelected = !_pillSelected),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              const Text('• Budget Slider Molecule:'),
              const SizedBox(height: 8),
              AppBudgetSlider(
                selectedIndex: _sliderIndex,
                onIndexChanged: (idx) => setState(() => _sliderIndex = idx),
              ),
              const Divider(height: 48),

              // SECTION 7: ORGANISMS
              _buildSectionHeader('7. Organisms (Reusable across screens)'),
              const Text('• Trip Summary Card Organism:'),
              const SizedBox(height: 8),
              TripSummaryCard(
                title: 'Bantayan Sandbar & Sunset Dinner',
                location: 'Santa Fe, Bantayan',
                dateRange: 'Nov 14 - Nov 16, 2026',
                type: 'Beach Trip',
                amount: 8500.0,
                paidByName: 'Louie Abella',
                onTap: () {},
              ),
              const SizedBox(height: 12),
              const Text('• Trip Summary Card (Loading Skeleton State):'),
              const SizedBox(height: 8),
              const TripSummaryCard(
                title: '',
                location: '',
                dateRange: '',
                type: '',
                amount: 0,
                paidByName: '',
                isLoading: true,
              ),
              const SizedBox(height: 20),

              const Text('• Overview Summary Panel Organism (AI & Plus Tier):'),
              const SizedBox(height: 8),
              OverviewSummaryPanel(
                onGenerateAi: () {},
                onViewDetails: () {},
              ),
              const SizedBox(height: 20),

              const Text('• Member Panel Organism:'),
              const SizedBox(height: 8),
              const MemberPanel(
                member: MemberData(
                  id: '1',
                  name: 'Louie Abella',
                  role: 'Organizer',
                  availableDays: ['Fri', 'Sat', 'Sun'],
                ),
              ),
              const SizedBox(height: 20),

              const Text('• Availability Panel Organism:'),
              const SizedBox(height: 8),
              const AvailabilityPanel(),
              const SizedBox(height: 20),

              const Text('• Bottom Navigation Organism:'),
              const SizedBox(height: 8),
              AppBottomNavigation(
                currentIndex: _bottomNavIndex,
                onTabSelected: (idx) => setState(() => _bottomNavIndex = idx),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Text(
        title,
        style: AppTypography.h3.copyWith(
          color: AppColors.chucky,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  Widget _buildColorChip(String name, String hex, Color color, {Color textColor = AppColors.white}) {
    return Container(
      width: 155,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color,
        borderRadius: AppRadii.radiusMd,
        border: Border.all(color: AppColors.borderLight, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            name,
            style: AppTypography.caption.copyWith(
              color: textColor,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            hex,
            style: AppTypography.caption.copyWith(
              color: textColor.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }
}
