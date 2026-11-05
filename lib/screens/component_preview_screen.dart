// ============================================================================
// COMPONENT PREVIEW SCREEN — TABLE OF CONTENTS
// ============================================================================
// Jump to any section by searching its banner comment:
//
// --- 01. ATOMS (lib/components/atoms/) ---
//  1. _AppAvatarSection              (lib/components/atoms/app_avatar.dart)
//  2. _AppMemberTokenClusterSection  (lib/components/atoms/app_avatar.dart)
//  3. _AppAvatarGroupSection         (lib/components/atoms/app_avatar.dart)
//  4. _AppBadgeSection               (lib/components/atoms/app_badge.dart)
//  5. _AppRsvpStatusTileSection      (lib/components/atoms/app_badge.dart)
//  6. _AppButtonSection              (lib/components/atoms/app_button.dart)
//  7. _AppCheckboxSection            (lib/components/atoms/app_checkbox.dart)
//  8. _AppIconSection                (lib/components/atoms/app_icon.dart)
//  9. _AppIconButtonSection          (lib/components/atoms/app_icon_button.dart)
// 10. _AppInputFieldSection          (lib/components/atoms/app_input_field.dart)
// 11. _AppOtpFieldSection            (lib/components/atoms/app_otp_field.dart)
// 12. _AppSwitchSection              (lib/components/atoms/app_switch.dart)
// 13. _AppTextSection                (lib/components/atoms/app_text.dart)
//
// --- 02. MOLECULES (lib/components/molecules/) ---
// 14. _AppAvailabilityPillSection    (lib/components/molecules/app_availability_pill.dart)
// 15. _AppAvailabilityRowSection     (lib/components/molecules/app_availability_row.dart)
// 16. _AppBudgetSliderSection        (lib/components/molecules/app_budget_slider.dart)
// 17. _AppChatMessageSection         (lib/components/molecules/app_chat_message.dart)
// 18. _AppDropdownFieldSection       (lib/components/molecules/app_dropdown_field.dart)
// 19. _AppLabeledFormFieldSection    (lib/components/molecules/app_labeled_form_field.dart)
// 20. _AppMemberActionRowSection     (lib/components/molecules/app_member_action_row.dart)
// 21. _AppMessageComposerSection     (lib/components/molecules/app_message_composer.dart)
// 22. _AppNavigationItemSection      (lib/components/molecules/app_navigation_item.dart)
// 23. _AppOptionCardSection          (lib/components/molecules/app_option_card.dart)
// 24. _AppPaceCardSection            (lib/components/molecules/app_pace_card.dart)
// 25. _AppPreferenceChoiceSection    (lib/components/molecules/app_preference_choice.dart)
// 26. _AppSearchBarSection           (lib/components/molecules/app_search_bar.dart)
// 27. _AppSearchFilterBarSection     (lib/components/molecules/app_search_filter_bar.dart)
// 28. _AppSegmentedTabsSection       (lib/components/molecules/app_segmented_tabs.dart)
// 29. _AppTripMetadataSection        (lib/components/molecules/app_trip_metadata.dart)
// 30. _StepProgressSection           (lib/components/molecules/step_progress.dart)
//
// --- 03. ORGANISMS (lib/components/organisms/) ---
// 31. _AppBottomNavigationSection    (lib/components/organisms/app_bottom_navigation.dart)
// 32. _AppMainTopBarSection          (lib/components/organisms/app_main_top_bar.dart)
// 33. _AppTopBarSection              (lib/components/organisms/app_top_bar.dart)
// 34. _AvailabilityPanelSection      (lib/components/organisms/availability_panel.dart)
// 35. _GroupHeaderOrganismSection    (lib/components/organisms/group_header_organism.dart)
// 36. _MemberPanelSection            (lib/components/organisms/member_panel.dart)
// 37. _OverviewSummaryPanelSection   (lib/components/organisms/overview_summary_panel.dart)
// 38. _TripSummaryCardSection        (lib/components/organisms/trip_summary_card.dart)
// ============================================================================

import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

// Core constants
import '../core/constants/app_colors.dart';
import '../core/constants/app_typography.dart';

// 01. Atoms
import '../components/atoms/app_avatar.dart';
import '../components/atoms/app_badge.dart';
import '../components/atoms/app_button.dart';
import '../components/atoms/app_checkbox.dart';
import '../components/atoms/app_icon.dart';
import '../components/atoms/app_icon_button.dart';
import '../components/atoms/app_input_field.dart';
import '../components/atoms/app_otp_field.dart';
import '../components/atoms/app_switch.dart';
import '../components/atoms/app_text.dart';

// 02. Molecules
import '../components/molecules/app_availability_pill.dart';
import '../components/molecules/app_availability_row.dart';
import '../components/molecules/app_budget_slider.dart';
import '../components/molecules/app_chat_message.dart';
import '../components/molecules/app_dropdown_field.dart';
import '../components/molecules/app_labeled_form_field.dart';
import '../components/molecules/app_member_action_row.dart';
import '../components/molecules/app_message_composer.dart';
import '../components/molecules/app_navigation_item.dart';
import '../components/molecules/app_option_card.dart';
import '../components/molecules/app_pace_card.dart';
import '../components/molecules/app_preference_choice.dart';
import '../components/molecules/app_search_bar.dart';
import '../components/molecules/app_search_filter_bar.dart';
import '../components/molecules/app_segmented_tabs.dart';
import '../components/molecules/app_trip_metadata.dart';
import '../components/molecules/step_progress.dart';

// 03. Organisms
import '../components/organisms/app_bottom_navigation.dart';
import '../components/organisms/app_main_top_bar.dart';
import '../components/organisms/app_top_bar.dart';
import '../components/organisms/availability_panel.dart';
import '../components/organisms/group_header_organism.dart';
import '../components/organisms/member_panel.dart';
import '../components/organisms/overview_summary_panel.dart';
import '../components/organisms/trip_summary_card.dart';

/// Helper to show quick SnackBar + console feedback when an interactive widget responds.
void _notifyInteraction(BuildContext context, String message) {
  debugPrint('[ComponentPreview] $message');
  final messenger = ScaffoldMessenger.maybeOf(context);
  if (messenger == null) return;
  messenger.hideCurrentSnackBar();
  messenger.showSnackBar(
    SnackBar(
      content: Text(
        message,
        style: AppTypography.bodySmall.copyWith(
          color: AppColors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
      backgroundColor: AppColors.secondaryDark,
      behavior: SnackBarBehavior.floating,
      duration: const Duration(milliseconds: 1400),
    ),
  );
}

class ComponentPreviewScreen extends StatelessWidget {
  const ComponentPreviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceLight,
      appBar: AppBar(
        backgroundColor: AppColors.secondaryDark,
        foregroundColor: AppColors.white,
        elevation: 0,
        title: Text(
          'Ano Tara • Component Preview',
          style: AppTypography.titleLarge.copyWith(color: AppColors.white),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          children: const [
            _CategoryBanner(
              title: '01. Atoms',
              subtitle: 'lib/components/atoms/',
            ),
            _AppAvatarSection(),
            _AppMemberTokenClusterSection(),
            _AppAvatarGroupSection(),
            _AppBadgeSection(),
            _AppRsvpStatusTileSection(),
            _AppButtonSection(),
            _AppCheckboxSection(),
            _AppIconSection(),
            _AppIconButtonSection(),
            _AppInputFieldSection(),
            _AppOtpFieldSection(),
            _AppSwitchSection(),
            _AppTextSection(),

            SizedBox(height: 12),
            _CategoryBanner(
              title: '02. Molecules',
              subtitle: 'lib/components/molecules/',
            ),
            _AppAvailabilityPillSection(),
            _AppAvailabilityRowSection(),
            _AppBudgetSliderSection(),
            _AppChatMessageSection(),
            _AppDropdownFieldSection(),
            _AppLabeledFormFieldSection(),
            _AppMemberActionRowSection(),
            _AppMessageComposerSection(),
            _AppNavigationItemSection(),
            _AppOptionCardSection(),
            _AppPaceCardSection(),
            _AppPreferenceChoiceSection(),
            _AppSearchBarSection(),
            _AppSearchFilterBarSection(),
            _AppSegmentedTabsSection(),
            _AppTripMetadataSection(),
            _StepProgressSection(),

            SizedBox(height: 12),
            _CategoryBanner(
              title: '03. Organisms',
              subtitle: 'lib/components/organisms/',
            ),
            _AppBottomNavigationSection(),
            _AppMainTopBarSection(),
            _AppTopBarSection(),
            _AvailabilityPanelSection(),
            _GroupHeaderOrganismSection(),
            _MemberPanelSection(),
            _OverviewSummaryPanelSection(),
            _TripSummaryCardSection(),
            SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

/// Visual banner separating major component groups.
class _CategoryBanner extends StatelessWidget {
  final String title;
  final String subtitle;

  const _CategoryBanner({
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.primaryNavy,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.secondaryDark, width: 2),
        boxShadow: const [
          BoxShadow(
            color: AppColors.secondaryDark,
            offset: Offset(0, 3),
            blurRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTypography.h3.copyWith(color: AppColors.white),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: AppTypography.caption.copyWith(color: AppColors.secondaryLight),
          ),
        ],
      ),
    );
  }
}

/// Standard card wrapper for each individual component preview section.
class _PreviewSectionCard extends StatelessWidget {
  final String widgetName;
  final String sourcePath;
  final Widget child;

  const _PreviewSectionCard({
    required this.widgetName,
    required this.sourcePath,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.secondaryDark, width: 2),
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
          Wrap(
            spacing: 8,
            runSpacing: 6,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.semanticYellow,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.secondaryDark, width: 1.5),
                ),
                child: Text(
                  widgetName,
                  style: AppTypography.titleMedium.copyWith(
                    fontWeight: FontWeight.w800,
                    color: AppColors.secondaryDark,
                  ),
                ),
              ),
              Text(
                sourcePath,
                style: AppTypography.caption.copyWith(color: AppColors.carla),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
          const Divider(height: 24, thickness: 1.2, color: AppColors.borderLight),
          child,
        ],
      ),
    );
  }
}

class _VariantLabel extends StatelessWidget {
  final String text;
  const _VariantLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 4),
      child: Text(
        text,
        style: AppTypography.caption.copyWith(
          color: AppColors.carla,
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
      ),
    );
  }
}

// ============================================================================
// 01. ATOMS
// ============================================================================

// ===== AppAvatar =====  (source: lib/components/atoms/app_avatar.dart)
class _AppAvatarSection extends StatelessWidget {
  const _AppAvatarSection();

  @override
  Widget build(BuildContext context) {
    return _PreviewSectionCard(
      widgetName: 'AppAvatar',
      sourcePath: 'lib/components/atoms/app_avatar.dart',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _VariantLabel('Variants: singleUser, group (bordered), initials (custom colors & sizes)'),
          Wrap(
            spacing: 16,
            runSpacing: 12,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              AppAvatar.singleUser(size: 44),
              AppAvatar.group(size: 56),
              const AppAvatar(
                name: 'Hannah',
                type: AppAvatarType.initials,
                size: 44,
                backgroundColor: AppColors.primaryNavy,
              ),
              const AppAvatar(
                name: 'Louie',
                type: AppAvatarType.initials,
                size: 52,
                hasBorder: true,
                backgroundColor: AppColors.primaryOrange,
              ),
              const AppAvatar(
                name: '',
                type: AppAvatarType.initials,
                size: 36,
                backgroundColor: AppColors.carla,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ===== AppMemberTokenCluster =====  (source: lib/components/atoms/app_avatar.dart)
class _AppMemberTokenClusterSection extends StatelessWidget {
  const _AppMemberTokenClusterSection();

  @override
  Widget build(BuildContext context) {
    return const _PreviewSectionCard(
      widgetName: 'AppMemberTokenCluster',
      sourcePath: 'lib/components/atoms/app_avatar.dart',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _VariantLabel('With overflow (+3, +5) & without overflow (0)'),
          Wrap(
            spacing: 24,
            runSpacing: 12,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              AppMemberTokenCluster(extraCount: 3, size: 18),
              AppMemberTokenCluster(extraCount: 5, size: 24),
              AppMemberTokenCluster(extraCount: 0, size: 20),
            ],
          ),
        ],
      ),
    );
  }
}

// ===== AppAvatarGroup =====  (source: lib/components/atoms/app_avatar.dart)
class _AppAvatarGroupSection extends StatelessWidget {
  const _AppAvatarGroupSection();

  @override
  Widget build(BuildContext context) {
    return const _PreviewSectionCard(
      widgetName: 'AppAvatarGroup',
      sourcePath: 'lib/components/atoms/app_avatar.dart',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _VariantLabel('Overlapping stack with +N overflow (similar to AppMemberTokenCluster)'),
          Wrap(
            spacing: 24,
            runSpacing: 12,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              AppAvatarGroup(
                names: ['Hannah', 'Louie', 'Carla', 'Shayne', 'Ann'],
                maxVisible: 3,
                avatarSize: 34,
              ),
              AppAvatarGroup(
                names: ['Hannah', 'Louie'],
                maxVisible: 3,
                avatarSize: 34,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ===== AppBadge =====  (source: lib/components/atoms/app_badge.dart)
class _AppBadgeSection extends StatelessWidget {
  const _AppBadgeSection();

  @override
  Widget build(BuildContext context) {
    return _PreviewSectionCard(
      widgetName: 'AppBadge',
      sourcePath: 'lib/components/atoms/app_badge.dart',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _VariantLabel('AppBadgeVariant values (primaryNavy, primaryOrange, tierYellow) + interactive badge'),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              AppBadge.tierPlus(),
              AppBadge.counter('12'),
              const AppBadge(
                label: 'Primary Navy',
                variant: AppBadgeVariant.primaryNavy,
              ),
              const AppBadge(
                label: 'Primary Orange',
                variant: AppBadgeVariant.primaryOrange,
              ),
              const AppBadge(
                label: 'Tier Yellow',
                variant: AppBadgeVariant.tierYellow,
              ),
              AppBadge(
                label: 'Tap Me (With Icon)',
                variant: AppBadgeVariant.primaryNavy,
                icon: const Icon(Iconsax.magic_star5, size: 14, color: AppColors.white),
                onTap: () => _notifyInteraction(context, 'AppBadge tapped!'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ===== AppRsvpStatusTile =====  (source: lib/components/atoms/app_badge.dart)
class _AppRsvpStatusTileSection extends StatefulWidget {
  const _AppRsvpStatusTileSection();

  @override
  State<_AppRsvpStatusTileSection> createState() => _AppRsvpStatusTileSectionState();
}

class _AppRsvpStatusTileSectionState extends State<_AppRsvpStatusTileSection> {
  RsvpStatus _selected = RsvpStatus.going;

  @override
  Widget build(BuildContext context) {
    return _PreviewSectionCard(
      widgetName: 'AppRsvpStatusTile',
      sourcePath: 'lib/components/atoms/app_badge.dart',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _VariantLabel('Tap a tile to select RSVP status (Active: ${_selected.name})'),
          Wrap(
            spacing: 16,
            runSpacing: 12,
            children: RsvpStatus.values.map((status) {
              return AppRsvpStatusTile(
                status: status,
                onTap: () {
                  setState(() => _selected = status);
                  _notifyInteraction(context, 'Selected RSVP: ${status.name}');
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

// ===== AppButton =====  (source: lib/components/atoms/app_button.dart)
class _AppButtonSection extends StatefulWidget {
  const _AppButtonSection();

  @override
  State<_AppButtonSection> createState() => _AppButtonSectionState();
}

class _AppButtonSectionState extends State<_AppButtonSection> {
  bool _simulatingLoad = false;

  @override
  Widget build(BuildContext context) {
    return _PreviewSectionCard(
      widgetName: 'AppButton',
      sourcePath: 'lib/components/atoms/app_button.dart',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _VariantLabel('Variants (Medium 52px)'),
          AppButton(
            text: 'Primary Navy Button',
            variant: AppButtonVariant.primaryNavy,
            onPressed: () => _notifyInteraction(context, 'Primary Navy AppButton pressed'),
          ),
          const SizedBox(height: 10),
          AppButton(
            text: 'Secondary Button',
            variant: AppButtonVariant.secondary,
            onPressed: () => _notifyInteraction(context, 'Secondary AppButton pressed'),
          ),
          const SizedBox(height: 10),
          AppButton(
            text: 'Primary Orange / Destructive',
            variant: AppButtonVariant.primaryOrange,
            onPressed: () => _notifyInteraction(context, 'Primary Orange AppButton pressed'),
          ),
          const SizedBox(height: 10),
          AppButton(
            text: 'Outline Variant',
            variant: AppButtonVariant.outline,
            iconLeading: const Icon(Iconsax.map_15, size: 18, color: AppColors.secondaryDark),
            iconTrailing: const Icon(Iconsax.arrow_right_3, size: 18, color: AppColors.secondaryDark),
            onPressed: () => _notifyInteraction(context, 'Outline AppButton pressed'),
          ),
          const SizedBox(height: 10),
          AppButton.google(
            onPressed: () => _notifyInteraction(context, 'Google AppButton pressed'),
          ),
          const SizedBox(height: 10),
          AppButton(
            text: 'Ghost Button Variant',
            variant: AppButtonVariant.ghost,
            onPressed: () => _notifyInteraction(context, 'Ghost AppButton pressed'),
          ),
          const SizedBox(height: 14),
          const _VariantLabel('Small Size (44px), Icon-Only, Loading, and Disabled States'),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              AppButton(
                text: 'Small Button',
                size: AppButtonSize.small,
                isFullWidth: false,
                onPressed: () => _notifyInteraction(context, 'Small AppButton pressed'),
              ),
              AppButton.iconOnly(
                icon: const Icon(Iconsax.add, color: AppColors.white, size: 20),
                onPressed: () => _notifyInteraction(context, 'Icon-only AppButton pressed'),
              ),
              AppButton(
                text: _simulatingLoad ? 'Loading...' : 'Tap to Test Loading',
                size: AppButtonSize.small,
                isFullWidth: false,
                isLoading: _simulatingLoad,
                onPressed: () async {
                  setState(() => _simulatingLoad = true);
                  _notifyInteraction(context, 'AppButton loading started');
                  await Future<void>.delayed(const Duration(seconds: 1));
                  if (mounted) setState(() => _simulatingLoad = false);
                },
              ),
              const AppButton(
                text: 'Disabled Navy',
                size: AppButtonSize.small,
                isFullWidth: false,
                isDisabled: true,
              ),
              const AppButton(
                text: 'Disabled Orange',
                variant: AppButtonVariant.primaryOrange,
                size: AppButtonSize.small,
                isFullWidth: false,
                isDisabled: true,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ===== AppCheckbox =====  (source: lib/components/atoms/app_checkbox.dart)
class _AppCheckboxSection extends StatefulWidget {
  const _AppCheckboxSection();

  @override
  State<_AppCheckboxSection> createState() => _AppCheckboxSectionState();
}

class _AppCheckboxSectionState extends State<_AppCheckboxSection> {
  bool _standardChecked = true;
  bool _miniChecked = false;
  bool _unlabeledChecked = true;

  @override
  Widget build(BuildContext context) {
    return _PreviewSectionCard(
      widgetName: 'AppCheckbox',
      sourcePath: 'lib/components/atoms/app_checkbox.dart',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _VariantLabel('Interactive Standard, Mini, Unlabeled & Disabled States'),
          Wrap(
            spacing: 20,
            runSpacing: 12,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              AppCheckbox(
                value: _standardChecked,
                label: 'Standard (${_standardChecked ? "Checked" : "Unchecked"})',
                onChanged: (v) {
                  setState(() => _standardChecked = v);
                  _notifyInteraction(context, 'Standard AppCheckbox: $v');
                },
              ),
              AppCheckbox(
                value: _miniChecked,
                size: AppCheckboxSize.mini,
                label: 'Mini size',
                onChanged: (v) {
                  setState(() => _miniChecked = v);
                  _notifyInteraction(context, 'Mini AppCheckbox: $v');
                },
              ),
              AppCheckbox(
                value: _unlabeledChecked,
                onChanged: (v) {
                  setState(() => _unlabeledChecked = v);
                  _notifyInteraction(context, 'Unlabeled AppCheckbox: $v');
                },
              ),
              const AppCheckbox(
                value: true,
                isEnabled: false,
                label: 'Disabled Checked',
              ),
              const AppCheckbox(
                value: false,
                isEnabled: false,
                label: 'Disabled Empty',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ===== AppIcon =====  (source: lib/components/atoms/app_icon.dart)
class _AppIconSection extends StatelessWidget {
  const _AppIconSection();

  @override
  Widget build(BuildContext context) {
    return const _PreviewSectionCard(
      widgetName: 'AppIcon',
      sourcePath: 'lib/components/atoms/app_icon.dart',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _VariantLabel('Custom-painted solid Iconsax glyphs with & without labels'),
          Wrap(
            spacing: 18,
            runSpacing: 14,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              AppIcon(Iconsax.home_15, label: 'Home'),
              AppIcon(Iconsax.send_25, color: AppColors.primaryNavy, label: 'Trips'),
              AppIcon(Iconsax.profile_2user5, color: AppColors.primaryOrange, label: 'Groups'),
              AppIcon(Iconsax.calendar5, color: AppColors.primaryNavy, label: 'Calendar'),
              AppIcon(Iconsax.location5, color: AppColors.primaryOrange, label: 'Location'),
              AppIcon(Iconsax.wallet_25, color: AppColors.secondaryDark, label: 'Wallet'),
              AppIcon(Iconsax.notification5, label: 'Alerts'),
              AppIcon(Iconsax.setting_25, label: 'Settings'),
              AppIcon(Iconsax.sun_15, color: AppColors.semanticYellow, size: 28),
            ],
          ),
        ],
      ),
    );
  }
}

// ===== AppIconButton =====  (source: lib/components/atoms/app_icon_button.dart)
class _AppIconButtonSection extends StatelessWidget {
  const _AppIconButtonSection();

  @override
  Widget build(BuildContext context) {
    return _PreviewSectionCard(
      widgetName: 'AppIconButton',
      sourcePath: 'lib/components/atoms/app_icon_button.dart',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _VariantLabel('Primary, Secondary, Destructive, Loading, and Disabled (with pressed transition)'),
          Wrap(
            spacing: 16,
            runSpacing: 12,
            children: [
              AppIconButton(
                icon: Iconsax.add,
                variant: AppIconButtonVariant.primary,
                label: 'Primary',
                onPressed: () => _notifyInteraction(context, 'Primary AppIconButton tapped'),
              ),
              AppIconButton(
                icon: Iconsax.edit_2,
                variant: AppIconButtonVariant.secondary,
                label: 'Secondary',
                onPressed: () => _notifyInteraction(context, 'Secondary AppIconButton tapped'),
              ),
              AppIconButton(
                icon: Iconsax.trash,
                variant: AppIconButtonVariant.destructive,
                label: 'Destructive',
                onPressed: () => _notifyInteraction(context, 'Destructive AppIconButton tapped'),
              ),
              const AppIconButton(
                icon: Iconsax.refresh,
                variant: AppIconButtonVariant.primary,
                isLoading: true,
                label: 'Loading',
              ),
              const AppIconButton(
                icon: Iconsax.lock,
                variant: AppIconButtonVariant.secondary,
                isDisabled: true,
                label: 'Disabled',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ===== AppInputField =====  (source: lib/components/atoms/app_input_field.dart)
class _AppInputFieldSection extends StatefulWidget {
  const _AppInputFieldSection();

  @override
  State<_AppInputFieldSection> createState() => _AppInputFieldSectionState();
}

class _AppInputFieldSectionState extends State<_AppInputFieldSection> {
  final _defaultCtrl = TextEditingController();
  final _filledCtrl = TextEditingController(text: 'Bantayan Island Adventure');
  String _liveText = '';

  @override
  void dispose() {
    _defaultCtrl.dispose();
    _filledCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _PreviewSectionCard(
      widgetName: 'AppInputField',
      sourcePath: 'lib/components/atoms/app_input_field.dart',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppInputField(
            label: 'Interactive Input (Empty / Default)',
            hint: 'Type destination name...',
            helperText: _liveText.isEmpty ? 'Helper text: Try typing above' : 'Typed: $_liveText',
            controller: _defaultCtrl,
            prefixIcon: const Icon(Iconsax.location, color: AppColors.secondaryDark, size: 20),
            onChanged: (v) => setState(() => _liveText = v),
          ),
          const SizedBox(height: 12),
          AppInputField(
            label: 'Filled State',
            controller: _filledCtrl,
          ),
          const SizedBox(height: 12),
          const AppInputField(
            label: 'Error State',
            hint: 'Enter email',
            errorText: 'Please enter a valid email address.',
          ),
          const SizedBox(height: 12),
          const AppInputField(
            label: 'Loading State',
            hint: 'Checking availability...',
            isLoading: true,
          ),
          const SizedBox(height: 12),
          const AppInputField(
            label: 'Disabled State',
            hint: 'Cannot edit this field',
            isEnabled: false,
          ),
        ],
      ),
    );
  }
}

// ===== AppOtpField =====  (source: lib/components/atoms/app_otp_field.dart)
class _AppOtpFieldSection extends StatefulWidget {
  const _AppOtpFieldSection();

  @override
  State<_AppOtpFieldSection> createState() => _AppOtpFieldSectionState();
}

class _AppOtpFieldSectionState extends State<_AppOtpFieldSection> {
  bool _hasError = false;
  String _currentCode = '';

  @override
  Widget build(BuildContext context) {
    return _PreviewSectionCard(
      widgetName: 'AppOtpField',
      sourcePath: 'lib/components/atoms/app_otp_field.dart',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 4,
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              _VariantLabel(
                'Code: "${_currentCode.isEmpty ? "------" : _currentCode}" (${_hasError ? "Error" : "Default"})',
              ),
              TextButton(
                onPressed: () => setState(() => _hasError = !_hasError),
                child: Text(_hasError ? 'Clear Error' : 'Simulate Error'),
              ),
            ],
          ),
          AppOtpField(
            hasError: _hasError,
            onChanged: (code) => setState(() => _currentCode = code),
            onCompleted: (code) => _notifyInteraction(context, 'OTP Completed: $code'),
          ),
        ],
      ),
    );
  }
}

// ===== AppSwitch =====  (source: lib/components/atoms/app_switch.dart)
class _AppSwitchSection extends StatefulWidget {
  const _AppSwitchSection();

  @override
  State<_AppSwitchSection> createState() => _AppSwitchSectionState();
}

class _AppSwitchSectionState extends State<_AppSwitchSection> {
  bool _orangeOn = true;
  bool _navyOn = false;

  @override
  Widget build(BuildContext context) {
    return _PreviewSectionCard(
      widgetName: 'AppSwitch',
      sourcePath: 'lib/components/atoms/app_switch.dart',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _VariantLabel('Active Orange, Active Navy, and Disabled States'),
          Wrap(
            spacing: 20,
            runSpacing: 12,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AppSwitch(
                    value: _orangeOn,
                    onChanged: (v) {
                      setState(() => _orangeOn = v);
                      _notifyInteraction(context, 'Orange AppSwitch: $v');
                    },
                  ),
                  const SizedBox(width: 6),
                  Text(_orangeOn ? 'On' : 'Off', style: AppTypography.bodySmall),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AppSwitch(
                    value: _navyOn,
                    activeColor: AppColors.primaryNavy,
                    onChanged: (v) {
                      setState(() => _navyOn = v);
                      _notifyInteraction(context, 'Navy AppSwitch: $v');
                    },
                  ),
                  const SizedBox(width: 6),
                  Text('Navy (${_navyOn ? "On" : "Off"})', style: AppTypography.bodySmall),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AppSwitch(
                    value: true,
                    isDisabled: true,
                    onChanged: (_) {},
                  ),
                  const SizedBox(width: 6),
                  Text('Disabled On', style: AppTypography.bodySmall),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AppSwitch(
                    value: false,
                    isDisabled: true,
                    onChanged: (_) {},
                  ),
                  const SizedBox(width: 6),
                  Text('Disabled Off', style: AppTypography.bodySmall),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ===== AppText =====  (source: lib/components/atoms/app_text.dart)
class _AppTextSection extends StatelessWidget {
  const _AppTextSection();

  @override
  Widget build(BuildContext context) {
    return _PreviewSectionCard(
      widgetName: 'AppText',
      sourcePath: 'lib/components/atoms/app_text.dart',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _VariantLabel('All AppTextVariant values & factory constructors'),
          const AppText('H1 Heading (28px Bold)', variant: AppTextVariant.h1),
          const SizedBox(height: 4),
          const AppText('H2 Heading (24px Bold)', variant: AppTextVariant.h2),
          const SizedBox(height: 4),
          const AppText('H3 Heading (20px Bold)', variant: AppTextVariant.h3),
          const SizedBox(height: 4),
          const AppText('Title Large (16px Bold)', variant: AppTextVariant.titleLarge),
          const SizedBox(height: 4),
          const AppText('Title Medium (15px SemiBold)', variant: AppTextVariant.titleMedium),
          const SizedBox(height: 4),
          const AppText('Input Label (14px Bold)', variant: AppTextVariant.inputLabel),
          const SizedBox(height: 4),
          const AppText('Body Medium (14px Open Sans)', variant: AppTextVariant.bodyMedium),
          const SizedBox(height: 4),
          const AppText('Body Small (12px Open Sans)', variant: AppTextVariant.bodySmall),
          const SizedBox(height: 4),
          const AppText('Caption (11px Medium)', variant: AppTextVariant.caption),
          const SizedBox(height: 4),
          const AppText('BADGE TEXT (12px Bold)', variant: AppTextVariant.badge),
          const Divider(height: 16),
          AppText.heading('AppText.heading() Factory'),
          AppText.label('AppText.label() Factory'),
          AppText.body('AppText.body() Factory'),
        ],
      ),
    );
  }
}

// ============================================================================
// 02. MOLECULES
// ============================================================================

// ===== AppAvailabilityPill =====  (source: lib/components/molecules/app_availability_pill.dart)
class _AppAvailabilityPillSection extends StatefulWidget {
  const _AppAvailabilityPillSection();

  @override
  State<_AppAvailabilityPillSection> createState() => _AppAvailabilityPillSectionState();
}

class _AppAvailabilityPillSectionState extends State<_AppAvailabilityPillSection> {
  final Set<String> _selectedDays = {'Saturday'};

  @override
  Widget build(BuildContext context) {
    const days = ['Friday', 'Saturday', 'Sunday'];
    return _PreviewSectionCard(
      widgetName: 'AppAvailabilityPill',
      sourcePath: 'lib/components/molecules/app_availability_pill.dart',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _VariantLabel('Tap pills to toggle Selected (Orange) vs Unselected (Peach)'),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: days.map((day) {
              final isSelected = _selectedDays.contains(day);
              return AppAvailabilityPill(
                day: day,
                isSelected: isSelected,
                onTap: () {
                  setState(() {
                    if (isSelected) {
                      _selectedDays.remove(day);
                    } else {
                      _selectedDays.add(day);
                    }
                  });
                  _notifyInteraction(context, 'Toggled $day pill');
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

// ===== AppAvailabilityRow =====  (source: lib/components/molecules/app_availability_row.dart)
class _AppAvailabilityRowSection extends StatelessWidget {
  const _AppAvailabilityRowSection();

  @override
  Widget build(BuildContext context) {
    return const _PreviewSectionCard(
      widgetName: 'AppAvailabilityRow',
      sourcePath: 'lib/components/molecules/app_availability_row.dart',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _VariantLabel('Day + free badge + member token cluster'),
          AppAvailabilityRow(day: 'Saturday', freeCount: 7, extraMemberCount: 3),
          SizedBox(height: 8),
          AppAvailabilityRow(day: 'Sunday', freeCount: 5, extraMemberCount: 1),
        ],
      ),
    );
  }
}

// ===== AppBudgetSlider =====  (source: lib/components/molecules/app_budget_slider.dart)
class _AppBudgetSliderSection extends StatefulWidget {
  const _AppBudgetSliderSection();

  @override
  State<_AppBudgetSliderSection> createState() => _AppBudgetSliderSectionState();
}

class _AppBudgetSliderSectionState extends State<_AppBudgetSliderSection> {
  int _selectedIndex = 2;

  @override
  Widget build(BuildContext context) {
    return _PreviewSectionCard(
      widgetName: 'AppBudgetSlider',
      sourcePath: 'lib/components/molecules/app_budget_slider.dart',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _VariantLabel('Drag the slider or tap a stop to change budget (#0F0331 aligned with field)'),
          AppBudgetSlider(
            selectedIndex: _selectedIndex,
            onIndexChanged: (idx) {
              setState(() => _selectedIndex = idx);
              _notifyInteraction(
                context,
                'Budget set to P${AppBudgetSlider.budgetLabels[idx]}',
              );
            },
          ),
        ],
      ),
    );
  }
}

// ===== AppChatMessage =====  (source: lib/components/molecules/app_chat_message.dart)
class _AppChatMessageSection extends StatelessWidget {
  const _AppChatMessageSection();

  @override
  Widget build(BuildContext context) {
    return const _PreviewSectionCard(
      widgetName: 'AppChatMessage',
      sourcePath: 'lib/components/molecules/app_chat_message.dart',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _VariantLabel('Incoming (isMe: false) & Outgoing (isMe: true)'),
          AppChatMessage(
            text: 'Hey everyone! Are we still good for Bantayan on Oct 10?',
            isMe: false,
          ),
          AppChatMessage(
            text: 'Yes! Already packed and ready to go!',
            isMe: true,
          ),
        ],
      ),
    );
  }
}

// ===== AppDropdownField =====  (source: lib/components/molecules/app_dropdown_field.dart)
class _AppDropdownFieldSection extends StatefulWidget {
  const _AppDropdownFieldSection();

  @override
  State<_AppDropdownFieldSection> createState() => _AppDropdownFieldSectionState();
}

class _AppDropdownFieldSectionState extends State<_AppDropdownFieldSection> {
  String? _selectedCategory;

  @override
  Widget build(BuildContext context) {
    return _PreviewSectionCard(
      widgetName: 'AppDropdownField',
      sourcePath: 'lib/components/molecules/app_dropdown_field.dart',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _VariantLabel('Interactive dropdown (Empty hint state -> Selected state)'),
          AppDropdownField(
            label: 'Expense Category',
            selectedValue: _selectedCategory,
            onChanged: (val) {
              setState(() => _selectedCategory = val);
              _notifyInteraction(context, 'Dropdown selected: $val');
            },
          ),
        ],
      ),
    );
  }
}

// ===== AppLabeledFormField =====  (source: lib/components/molecules/app_labeled_form_field.dart)
class _AppLabeledFormFieldSection extends StatelessWidget {
  const _AppLabeledFormFieldSection();

  @override
  Widget build(BuildContext context) {
    return _PreviewSectionCard(
      widgetName: 'AppLabeledFormField',
      sourcePath: 'lib/components/molecules/app_labeled_form_field.dart',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppLabeledFormField(
            label: 'Trip Title (Default with Helper)',
            hint: 'e.g., Siargao Surf Week',
            helperText: 'Visible to all group members',
            onChanged: (v) => debugPrint('LabeledFormField changed: $v'),
          ),
          const SizedBox(height: 12),
          const AppLabeledFormField(
            label: 'Trip Title (Error State)',
            hint: 'e.g., Siargao Surf Week',
            errorText: 'Trip title is required',
          ),
        ],
      ),
    );
  }
}

// ===== AppMemberActionRow =====  (source: lib/components/molecules/app_member_action_row.dart)
class _AppMemberActionRowSection extends StatelessWidget {
  const _AppMemberActionRowSection();

  @override
  Widget build(BuildContext context) {
    return _PreviewSectionCard(
      widgetName: 'AppMemberActionRow',
      sourcePath: 'lib/components/molecules/app_member_action_row.dart',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _VariantLabel('Tap the orange action icon on the right (with press transition)'),
          AppMemberActionRow(
            name: 'Hannah S. Labandero',
            onActionTap: () => _notifyInteraction(context, 'Action tapped for Hannah S. Labandero'),
          ),
        ],
      ),
    );
  }
}

// ===== AppMessageComposer =====  (source: lib/components/molecules/app_message_composer.dart)
class _AppMessageComposerSection extends StatefulWidget {
  const _AppMessageComposerSection();

  @override
  State<_AppMessageComposerSection> createState() => _AppMessageComposerSectionState();
}

class _AppMessageComposerSectionState extends State<_AppMessageComposerSection> {
  final _composerCtrl = TextEditingController();
  String _lastSent = '';

  @override
  void dispose() {
    _composerCtrl.dispose();
    super.dispose();
  }

  void _send() {
    final text = _composerCtrl.text.trim();
    if (text.isEmpty) {
      _notifyInteraction(context, 'Type a message first!');
      return;
    }
    setState(() {
      _lastSent = text;
      _composerCtrl.clear();
    });
    _notifyInteraction(context, 'Message sent: "$text"');
  }

  @override
  Widget build(BuildContext context) {
    return _PreviewSectionCard(
      widgetName: 'AppMessageComposer',
      sourcePath: 'lib/components/molecules/app_message_composer.dart',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _VariantLabel(
            _lastSent.isEmpty ? 'Type and press send' : 'Last sent: "$_lastSent"',
          ),
          AppMessageComposer(
            controller: _composerCtrl,
            onSend: _send,
          ),
        ],
      ),
    );
  }
}

// ===== AppNavigationItem =====  (source: lib/components/molecules/app_navigation_item.dart)
class _AppNavigationItemSection extends StatefulWidget {
  const _AppNavigationItemSection();

  @override
  State<_AppNavigationItemSection> createState() => _AppNavigationItemSectionState();
}

class _AppNavigationItemSectionState extends State<_AppNavigationItemSection> {
  int _activeIndex = 0;

  @override
  Widget build(BuildContext context) {
    return _PreviewSectionCard(
      widgetName: 'AppNavigationItem',
      sourcePath: 'lib/components/molecules/app_navigation_item.dart',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _VariantLabel('Selected (#144885) vs Unselected (#868097) inside a Row'),
          SizedBox(
            height: 60,
            child: Row(
              children: [
                AppNavigationItem(
                  icon: Iconsax.home_15,
                  label: 'Home',
                  isSelected: _activeIndex == 0,
                  onTap: () {
                    setState(() => _activeIndex = 0);
                    _notifyInteraction(context, 'AppNavigationItem: Home');
                  },
                ),
                AppNavigationItem(
                  icon: Iconsax.send_25,
                  label: 'Trips',
                  isSelected: _activeIndex == 1,
                  onTap: () {
                    setState(() => _activeIndex = 1);
                    _notifyInteraction(context, 'AppNavigationItem: Trips');
                  },
                ),
                AppNavigationItem(
                  icon: Iconsax.profile_2user5,
                  label: 'Groups',
                  isSelected: _activeIndex == 2,
                  onTap: () {
                    setState(() => _activeIndex = 2);
                    _notifyInteraction(context, 'AppNavigationItem: Groups');
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ===== AppOptionCard =====  (source: lib/components/molecules/app_option_card.dart)
class _AppOptionCardSection extends StatefulWidget {
  const _AppOptionCardSection();

  @override
  State<_AppOptionCardSection> createState() => _AppOptionCardSectionState();
}

class _AppOptionCardSectionState extends State<_AppOptionCardSection> {
  final Set<String> _selected = {'Beaches', 'Seafood'};

  @override
  Widget build(BuildContext context) {
    final items = [
      ('Beaches', Iconsax.sun_1, AppColors.secondaryDark),
      ('Vegetarian', Iconsax.tree, AppColors.primaryNavy),
      ('Seafood', Iconsax.drop, AppColors.primaryOrange),
    ];

    return _PreviewSectionCard(
      widgetName: 'AppOptionCard',
      sourcePath: 'lib/components/molecules/app_option_card.dart',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _VariantLabel('Tap cards to toggle selection (Dark Ink, Navy, Orange variants)'),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: items.map((item) {
              final isSelected = _selected.contains(item.$1);
              return AppOptionCard(
                label: item.$1,
                icon: item.$2,
                selectedColor: item.$3,
                size: 98,
                isSelected: isSelected,
                onTap: () {
                  setState(() {
                    if (isSelected) {
                      _selected.remove(item.$1);
                    } else {
                      _selected.add(item.$1);
                    }
                  });
                  _notifyInteraction(context, 'AppOptionCard toggled: ${item.$1}');
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

// ===== AppPaceCard =====  (source: lib/components/molecules/app_pace_card.dart)
class _AppPaceCardSection extends StatefulWidget {
  const _AppPaceCardSection();

  @override
  State<_AppPaceCardSection> createState() => _AppPaceCardSectionState();
}

class _AppPaceCardSectionState extends State<_AppPaceCardSection> {
  String _selectedPace = 'Relaxed';

  @override
  Widget build(BuildContext context) {
    return _PreviewSectionCard(
      widgetName: 'AppPaceCard',
      sourcePath: 'lib/components/molecules/app_pace_card.dart',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _VariantLabel('Tap to switch between Selected & Unselected pace cards (non-red pressed/selected colors)'),
          AppPaceCard(
            title: 'Relaxed',
            description: 'Slow mornings, spontaneous stops, and plenty of time to just vibe.',
            icon: Iconsax.wind_2,
            isSelected: _selectedPace == 'Relaxed',
            onTap: () {
              setState(() => _selectedPace = 'Relaxed');
              _notifyInteraction(context, 'Selected pace: Relaxed');
            },
          ),
          const SizedBox(height: 12),
          AppPaceCard(
            title: 'Balanced',
            description: 'A little adventure, a little chill — the sweet spot for your trip.',
            icon: Iconsax.timer_pause,
            isSelected: _selectedPace == 'Balanced',
            onTap: () {
              setState(() => _selectedPace = 'Balanced');
              _notifyInteraction(context, 'Selected pace: Balanced');
            },
          ),
          const SizedBox(height: 12),
          AppPaceCard(
            title: 'Packed',
            description: 'Go, go, go! Max out the day and squeeze in as much fun as possible.',
            icon: Iconsax.timer_1,
            isSelected: _selectedPace == 'Packed',
            onTap: () {
              setState(() => _selectedPace = 'Packed');
              _notifyInteraction(context, 'Selected pace: Packed');
            },
          ),
        ],
      ),
    );
  }
}

// ===== AppPreferenceChoice =====  (source: lib/components/molecules/app_preference_choice.dart)
class _AppPreferenceChoiceSection extends StatefulWidget {
  const _AppPreferenceChoiceSection();

  @override
  State<_AppPreferenceChoiceSection> createState() => _AppPreferenceChoiceSectionState();
}

class _AppPreferenceChoiceSectionState extends State<_AppPreferenceChoiceSection> {
  final Set<String> _selected = {'Nature'};

  @override
  Widget build(BuildContext context) {
    const items = [
      ('Nature', Iconsax.tree),
      ('Dining', Iconsax.coffee),
      ('Museums', Iconsax.courthouse),
    ];

    return _PreviewSectionCard(
      widgetName: 'AppPreferenceChoice',
      sourcePath: 'lib/components/molecules/app_preference_choice.dart',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _VariantLabel('Tap square choice tiles to toggle Selected vs Unselected'),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: items.map((item) {
              final isSelected = _selected.contains(item.$1);
              return AppPreferenceChoice(
                label: item.$1,
                icon: item.$2,
                isSelected: isSelected,
                onTap: () {
                  setState(() {
                    if (isSelected) {
                      _selected.remove(item.$1);
                    } else {
                      _selected.add(item.$1);
                    }
                  });
                  _notifyInteraction(context, 'AppPreferenceChoice: ${item.$1}');
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

// ===== AppSearchBar =====  (source: lib/components/molecules/app_search_bar.dart)
class _AppSearchBarSection extends StatefulWidget {
  const _AppSearchBarSection();

  @override
  State<_AppSearchBarSection> createState() => _AppSearchBarSectionState();
}

class _AppSearchBarSectionState extends State<_AppSearchBarSection> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    return _PreviewSectionCard(
      widgetName: 'AppSearchBar',
      sourcePath: 'lib/components/molecules/app_search_bar.dart',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _VariantLabel(
            _query.isEmpty ? 'Enabled (type to reveal clear button)' : 'Searching: "$_query"',
          ),
          AppSearchBar(
            onChanged: (v) => setState(() => _query = v),
            onClear: () => _notifyInteraction(context, 'AppSearchBar cleared'),
          ),
          const SizedBox(height: 12),
          const _VariantLabel('Disabled State'),
          const AppSearchBar(
            hintText: 'Search disabled...',
            isEnabled: false,
          ),
        ],
      ),
    );
  }
}

// ===== AppSearchFilterBar =====  (source: lib/components/molecules/app_search_filter_bar.dart)
class _AppSearchFilterBarSection extends StatelessWidget {
  const _AppSearchFilterBarSection();

  @override
  Widget build(BuildContext context) {
    return _PreviewSectionCard(
      widgetName: 'AppSearchFilterBar',
      sourcePath: 'lib/components/molecules/app_search_filter_bar.dart',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _VariantLabel('With Filter Button (showFilterButton: true)'),
          AppSearchFilterBar(
            hintText: 'Search trips...',
            onFilterTap: () => _notifyInteraction(context, 'Filter button tapped!'),
          ),
          const SizedBox(height: 12),
          const _VariantLabel('Search Only (showFilterButton: false)'),
          const AppSearchFilterBar(
            hintText: 'Search members...',
            showFilterButton: false,
          ),
        ],
      ),
    );
  }
}

// ===== AppSegmentedTabs =====  (source: lib/components/molecules/app_segmented_tabs.dart)
class _AppSegmentedTabsSection extends StatefulWidget {
  const _AppSegmentedTabsSection();

  @override
  State<_AppSegmentedTabsSection> createState() => _AppSegmentedTabsSectionState();
}

class _AppSegmentedTabsSectionState extends State<_AppSegmentedTabsSection> {
  String _selected4Tab = 'Overview';
  String _selected3Tab = 'Upcoming';
  String _selected2Tab = 'Trips';

  @override
  Widget build(BuildContext context) {
    return _PreviewSectionCard(
      widgetName: 'AppSegmentedTabs',
      sourcePath: 'lib/components/molecules/app_segmented_tabs.dart',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _VariantLabel('4 Items (Sliding Pill • Active: $_selected4Tab)'),
          AppSegmentedTabs<String>(
            tabs: const ['Overview', 'Availability', 'Members', 'Chat'],
            selectedTab: _selected4Tab,
            labelBuilder: (t) => t,
            onTabChanged: (t) {
              setState(() => _selected4Tab = t);
              _notifyInteraction(context, 'Switched 4-tab to $t');
            },
          ),
          const SizedBox(height: 14),
          _VariantLabel('3 Items (Sliding Pill • Active: $_selected3Tab)'),
          AppSegmentedTabs<String>(
            tabs: const ['Upcoming', 'Past', 'Drafts'],
            selectedTab: _selected3Tab,
            labelBuilder: (t) => t,
            onTabChanged: (t) {
              setState(() => _selected3Tab = t);
              _notifyInteraction(context, 'Switched 3-tab to $t');
            },
          ),
          const SizedBox(height: 14),
          _VariantLabel('2 Items (Sliding Pill • Active: $_selected2Tab)'),
          AppSegmentedTabs<String>(
            tabs: const ['Trips', 'Expenses'],
            selectedTab: _selected2Tab,
            labelBuilder: (t) => t,
            onTabChanged: (t) {
              setState(() => _selected2Tab = t);
              _notifyInteraction(context, 'Switched 2-tab to $t');
            },
          ),
        ],
      ),
    );
  }
}

// ===== AppTripMetadata =====  (source: lib/components/molecules/app_trip_metadata.dart)
class _AppTripMetadataSection extends StatelessWidget {
  const _AppTripMetadataSection();

  @override
  Widget build(BuildContext context) {
    return const _PreviewSectionCard(
      widgetName: 'AppTripMetadata',
      sourcePath: 'lib/components/molecules/app_trip_metadata.dart',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _VariantLabel('With groupName & without groupName'),
          AppTripMetadata(
            location: 'Bantayan, Philippines',
            groupName: 'The Barkada (6 going)',
            dateRange: 'Oct 10 - Oct 15',
          ),
          Divider(height: 20),
          AppTripMetadata(
            location: 'El Nido, Palawan',
            dateRange: 'Nov 02 - Nov 06',
          ),
        ],
      ),
    );
  }
}

// ===== StepProgress =====  (source: lib/components/molecules/step_progress.dart)
class _StepProgressSection extends StatefulWidget {
  const _StepProgressSection();

  @override
  State<_StepProgressSection> createState() => _StepProgressSectionState();
}

class _StepProgressSectionState extends State<_StepProgressSection> {
  int _step = 3;

  @override
  Widget build(BuildContext context) {
    return _PreviewSectionCard(
      widgetName: 'StepProgress',
      sourcePath: 'lib/components/molecules/step_progress.dart',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 4,
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              _VariantLabel('Step $_step of 7'),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Iconsax.minus_cirlce, size: 20, color: AppColors.secondaryDark),
                    onPressed: _step > 1 ? () => setState(() => _step--) : null,
                  ),
                  IconButton(
                    icon: const Icon(Iconsax.add_circle, size: 20, color: AppColors.secondaryDark),
                    onPressed: _step < 7 ? () => setState(() => _step++) : null,
                  ),
                ],
              ),
            ],
          ),
          StepProgress(current: _step, total: 7),
        ],
      ),
    );
  }
}

// ============================================================================
// 03. ORGANISMS
// ============================================================================

// ===== AppBottomNavigation =====  (source: lib/components/organisms/app_bottom_navigation.dart)
class _AppBottomNavigationSection extends StatefulWidget {
  const _AppBottomNavigationSection();

  @override
  State<_AppBottomNavigationSection> createState() => _AppBottomNavigationSectionState();
}

class _AppBottomNavigationSectionState extends State<_AppBottomNavigationSection> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return _PreviewSectionCard(
      widgetName: 'AppBottomNavigation',
      sourcePath: 'lib/components/organisms/app_bottom_navigation.dart',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _VariantLabel('Interactive 5-tab bar (Selected index: $_currentIndex)'),
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: AppBottomNavigation(
              currentIndex: _currentIndex,
              onTabSelected: (index) {
                setState(() => _currentIndex = index);
                _notifyInteraction(context, 'Bottom Navigation tab $index selected');
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ===== AppMainTopBar =====  (source: lib/components/organisms/app_main_top_bar.dart)
class _AppMainTopBarSection extends StatelessWidget {
  const _AppMainTopBarSection();

  @override
  Widget build(BuildContext context) {
    return _PreviewSectionCard(
      widgetName: 'AppMainTopBar',
      sourcePath: 'lib/components/organisms/app_main_top_bar.dart',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _VariantLabel('Default (Profile dot + unread notification dot with navbar-matching transitions)'),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.borderLight),
              borderRadius: BorderRadius.circular(12),
            ),
            clipBehavior: Clip.antiAlias,
            child: MediaQuery.removePadding(
              context: context,
              removeTop: true,
              child: AppMainTopBar(
                hasUnreadNotifications: true,
                onProfileTap: () => _notifyInteraction(context, 'Profile circle tapped'),
                onNotificationTap: () => _notifyInteraction(context, 'Notifications tapped'),
                onSettingsTap: () => _notifyInteraction(context, 'Settings gear tapped'),
              ),
            ),
          ),
          const SizedBox(height: 12),
          const _VariantLabel('With Back Button (showBackButton: true • press transition on back arrow)'),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.borderLight),
              borderRadius: BorderRadius.circular(12),
            ),
            clipBehavior: Clip.antiAlias,
            child: MediaQuery.removePadding(
              context: context,
              removeTop: true,
              child: AppMainTopBar(
                showBackButton: true,
                onBackPressed: () => _notifyInteraction(context, 'Back arrow tapped'),
                onNotificationTap: () => _notifyInteraction(context, 'Notifications tapped'),
                onSettingsTap: () => _notifyInteraction(context, 'Settings gear tapped'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ===== AppTopBar =====  (source: lib/components/organisms/app_top_bar.dart)
class _AppTopBarSection extends StatelessWidget {
  const _AppTopBarSection();

  @override
  Widget build(BuildContext context) {
    return _PreviewSectionCard(
      widgetName: 'AppTopBar',
      sourcePath: 'lib/components/organisms/app_top_bar.dart',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _VariantLabel('With Title, Subtitle, Back Button & Action Icon'),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.borderLight),
              borderRadius: BorderRadius.circular(12),
            ),
            clipBehavior: Clip.antiAlias,
            child: MediaQuery.removePadding(
              context: context,
              removeTop: true,
              child: AppTopBar(
                title: 'Trip Overview',
                subtitle: 'Bantayan Island • 6 Members',
                onBackPressed: () => _notifyInteraction(context, 'AppTopBar back pressed'),
                actions: [
                  IconButton(
                    icon: const Icon(Iconsax.more, color: AppColors.secondaryDark),
                    onPressed: () => _notifyInteraction(context, 'AppTopBar action pressed'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ===== AvailabilityPanel =====  (source: lib/components/organisms/availability_panel.dart)
class _AvailabilityPanelSection extends StatefulWidget {
  const _AvailabilityPanelSection();

  @override
  State<_AvailabilityPanelSection> createState() => _AvailabilityPanelSectionState();
}

class _AvailabilityPanelSectionState extends State<_AvailabilityPanelSection> {
  String _mode = 'Populated';

  @override
  Widget build(BuildContext context) {
    return _PreviewSectionCard(
      widgetName: 'AvailabilityPanel',
      sourcePath: 'lib/components/organisms/availability_panel.dart',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _VariantLabel('Switch state: Populated, Loading, Empty'),
          AppSegmentedTabs<String>(
            tabs: const ['Populated', 'Loading', 'Empty'],
            selectedTab: _mode,
            labelBuilder: (m) => m,
            onTabChanged: (m) => setState(() => _mode = m),
          ),
          const SizedBox(height: 14),
          if (_mode == 'Populated')
            AvailabilityPanel(
              dailyFreeCounts: const {
                'Friday': 6,
                'Saturday': 7,
                'Sunday': 7,
              },
              onDaySelected: (day) => _notifyInteraction(context, 'AvailabilityPanel day tapped: $day'),
            )
          else if (_mode == 'Loading')
            const AvailabilityPanel(isLoading: true)
          else
            const AvailabilityPanel(dailyFreeCounts: {}),
        ],
      ),
    );
  }
}

// ===== GroupHeaderOrganism =====  (source: lib/components/organisms/group_header_organism.dart)
class _GroupHeaderOrganismSection extends StatelessWidget {
  const _GroupHeaderOrganismSection();

  @override
  Widget build(BuildContext context) {
    return _PreviewSectionCard(
      widgetName: 'GroupHeaderOrganism',
      sourcePath: 'lib/components/organisms/group_header_organism.dart',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _VariantLabel('Default Organizer Header with Plan a Trip CTA'),
          GroupHeaderOrganism(
            groupName: 'The Barkada',
            roleLabel: 'Organizer',
            memberCount: 7,
            onPlanTripTap: () => _notifyInteraction(context, 'Plan a Trip CTA tapped!'),
          ),
        ],
      ),
    );
  }
}

// ===== MemberPanel =====  (source: lib/components/organisms/member_panel.dart)
class _MemberPanelSection extends StatefulWidget {
  const _MemberPanelSection();

  @override
  State<_MemberPanelSection> createState() => _MemberPanelSectionState();
}

class _MemberPanelSectionState extends State<_MemberPanelSection> {
  String _stateMode = 'List';

  @override
  Widget build(BuildContext context) {
    return _PreviewSectionCard(
      widgetName: 'MemberPanel',
      sourcePath: 'lib/components/organisms/member_panel.dart',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _VariantLabel('States: Searchable List, Single Member, Loading, Empty'),
          AppSegmentedTabs<String>(
            tabs: const ['List', 'Single', 'Loading', 'Empty'],
            selectedTab: _stateMode,
            labelBuilder: (s) => s,
            onTabChanged: (s) => setState(() => _stateMode = s),
          ),
          const SizedBox(height: 14),
          if (_stateMode == 'List')
            MemberPanel(
              onMemberActionTap: (name) =>
                  _notifyInteraction(context, 'MemberPanel action tapped: $name'),
            )
          else if (_stateMode == 'Single')
            MemberPanel(
              member: const MemberData(id: '1', name: 'Hannah S. Labandero'),
              onTap: () => _notifyInteraction(context, 'Single MemberData row tapped'),
            )
          else if (_stateMode == 'Loading')
            const MemberPanel(isLoading: true)
          else
            const MemberPanel(memberNames: [], showSearch: false),
        ],
      ),
    );
  }
}

// ===== OverviewSummaryPanel =====  (source: lib/components/organisms/overview_summary_panel.dart)
class _OverviewSummaryPanelSection extends StatefulWidget {
  const _OverviewSummaryPanelSection();

  @override
  State<_OverviewSummaryPanelSection> createState() => _OverviewSummaryPanelSectionState();
}

class _OverviewSummaryPanelSectionState extends State<_OverviewSummaryPanelSection> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return _PreviewSectionCard(
      widgetName: 'OverviewSummaryPanel',
      sourcePath: 'lib/components/organisms/overview_summary_panel.dart',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 4,
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              const _VariantLabel('2x2 Metric Summary Grid'),
              TextButton(
                onPressed: () => setState(() => _isLoading = !_isLoading),
                child: Text(_isLoading ? 'Show Data' : 'Simulate Loading'),
              ),
            ],
          ),
          OverviewSummaryPanel(isLoading: _isLoading),
        ],
      ),
    );
  }
}

// ===== TripSummaryCard =====  (source: lib/components/organisms/trip_summary_card.dart)
class _TripSummaryCardSection extends StatefulWidget {
  const _TripSummaryCardSection();

  @override
  State<_TripSummaryCardSection> createState() => _TripSummaryCardSectionState();
}

class _TripSummaryCardSectionState extends State<_TripSummaryCardSection> {
  String _cardState = 'Default';

  @override
  Widget build(BuildContext context) {
    return _PreviewSectionCard(
      widgetName: 'TripSummaryCard',
      sourcePath: 'lib/components/organisms/trip_summary_card.dart',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _VariantLabel('States: Default (with pressed transition), Loading, Error'),
          AppSegmentedTabs<String>(
            tabs: const ['Default', 'Loading', 'Error'],
            selectedTab: _cardState,
            labelBuilder: (s) => s,
            onTabChanged: (s) => setState(() => _cardState = s),
          ),
          const SizedBox(height: 14),
          if (_cardState == 'Default')
            TripSummaryCard(
              onTap: () => _notifyInteraction(context, 'TripSummaryCard tapped!'),
            )
          else if (_cardState == 'Loading')
            const TripSummaryCard(isLoading: true)
          else
            const TripSummaryCard(
              errorText: 'Failed to load trip details. Tap retry.',
            ),
        ],
      ),
    );
  }
}
