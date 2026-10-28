import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../components/atoms/app_avatar.dart';
import '../../../../components/atoms/app_badge.dart';
import '../../../../components/atoms/app_button.dart';
import '../../../../components/atoms/app_checkbox.dart';
import '../../../../components/atoms/app_icon.dart';
import '../../../../components/atoms/app_icon_button.dart';
import '../../../../components/atoms/app_input_field.dart';
import '../../../../components/atoms/app_text.dart';
import '../../../../components/molecules/app_availability_row.dart';
import '../../../../components/molecules/app_chat_message.dart';
import '../../../../components/molecules/app_dropdown_field.dart';
import '../../../../components/molecules/app_labeled_form_field.dart';
import '../../../../components/molecules/app_member_action_row.dart';
import '../../../../components/molecules/app_message_composer.dart';
import '../../../../components/molecules/app_preference_choice.dart';
import '../../../../components/molecules/app_search_filter_bar.dart';
import '../../../../components/molecules/app_segmented_tabs.dart';
import '../../../../components/molecules/app_trip_metadata.dart';
import '../../../../components/organisms/app_bottom_navigation.dart';
import '../../../../components/organisms/app_main_top_bar.dart';
import '../../../../components/organisms/availability_panel.dart';
import '../../../../components/organisms/group_header_organism.dart';
import '../../../../components/organisms/member_panel.dart';
import '../../../../components/organisms/overview_summary_panel.dart';
import '../../../../components/organisms/trip_summary_card.dart';

class ComponentShowcaseScreen extends StatefulWidget {
  const ComponentShowcaseScreen({super.key});

  @override
  State<ComponentShowcaseScreen> createState() => _ComponentShowcaseScreenState();
}

class _ComponentShowcaseScreenState extends State<ComponentShowcaseScreen> {
  bool _cbStandardUnchecked = false;
  bool _cbStandardChecked = true;
  bool _cbMiniUnchecked = false;
  bool _cbMiniChecked = true;

  String _segmentedTab = 'Overview';
  bool _prefChoiceSelected = false;
  int _demoNavIndex = 3; // Groups highlighted in #144885 matching O01 board
  final _msgController = TextEditingController();
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _msgController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEAE8E4),
      appBar: AppMainTopBar(
        showBackButton: true,
        onBackPressed: () => Navigator.of(context).pop(),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ==============================================================
              // 01 ATOMS BOARD
              // ==============================================================
              _buildBoardHeader(
                '01',
                'Atoms',
                'The smallest reusable UI elements used throughout Ano Tara.',
              ),
              const SizedBox(height: 14),

              // Brand Foundations Card
              _buildSectionCard(
                title: 'Brand foundations',
                subtitle: 'Colors, type, outlines & hard shadows',
                child: Row(
                  children: [
                    _buildColorSwatch('Blue', AppColors.primaryNavy),
                    const SizedBox(width: 8),
                    _buildColorSwatch('Orange', AppColors.primaryOrange),
                    const SizedBox(width: 8),
                    _buildColorSwatch('Neutral', AppColors.secondaryLight),
                    const SizedBox(width: 8),
                    _buildColorSwatch('Ink', AppColors.secondaryDark),
                    const SizedBox(width: 8),
                    _buildColorSwatch('Yellow', AppColors.semanticYellow),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // A01 Text & Icons
              _buildSectionCard(
                title: 'A01 Text',
                subtitle: 'Labels, headings and body text • Urbanist + Open Sans',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText.heading('Trip to Bantayan', fontSize: 20),
                    const SizedBox(height: 6),
                    AppText.label('Group Name*'),
                    const SizedBox(height: 6),
                    AppText.body('Plan together. Travel together.'),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              _buildSectionCard(
                title: 'Icons',
                subtitle: 'Single action or meaning • reused Iconsax components',
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    AppIcon(Iconsax.search_normal, label: 'Search'),
                    AppIcon(Iconsax.location5, label: 'Location'),
                    AppIcon(Iconsax.calendar5, label: 'Calendar'),
                    AppIcon(Iconsax.profile_2user5, label: 'Members'),
                    AppIcon(Iconsax.wallet_25, label: 'Wallet'),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // Buttons
              _buildSectionCard(
                title: 'Buttons',
                subtitle: 'A single action • primary, secondary, destructive, disabled, loading',
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: AppButton(
                            text: 'Continue',
                            variant: AppButtonVariant.primaryNavy,
                            size: AppButtonSize.small,
                            onPressed: () {},
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: AppButton(
                            text: 'Cancel',
                            variant: AppButtonVariant.secondary,
                            size: AppButtonSize.small,
                            onPressed: () {},
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: AppButton(
                            text: 'Delete',
                            variant: AppButtonVariant.destructive,
                            size: AppButtonSize.small,
                            onPressed: () {},
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: AppButton(
                            text: 'Continue',
                            variant: AppButtonVariant.primaryNavy,
                            isDisabled: true,
                            size: AppButtonSize.small,
                            onPressed: () {},
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: AppButton(
                            text: 'Loading',
                            variant: AppButtonVariant.primaryNavy,
                            isLoading: true,
                            size: AppButtonSize.small,
                            onPressed: () {},
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // Text inputs
              _buildSectionCard(
                title: 'Text inputs',
                subtitle: 'Standalone input controls • placeholder and error states',
                child: const Column(
                  children: [
                    AppInputField(hint: 'Enter a group name'),
                    SizedBox(height: 10),
                    AppInputField(
                      hint: 'Enter a group name',
                      errorText: 'Required field',
                      showErrorCaption: false,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // Checkboxes & Avatars
              _buildSectionCard(
                title: 'Checkboxes',
                subtitle: 'Single selection control • default and checked sizes',
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      children: [
                        AppCheckbox(
                          value: _cbStandardUnchecked,
                          onChanged: (v) => setState(() => _cbStandardUnchecked = v),
                        ),
                        const SizedBox(height: 2),
                        Text('Unchecked', style: AppTypography.caption),
                      ],
                    ),
                    Column(
                      children: [
                        AppCheckbox(
                          value: _cbStandardChecked,
                          onChanged: (v) => setState(() => _cbStandardChecked = v),
                        ),
                        const SizedBox(height: 2),
                        Text('Checked', style: AppTypography.caption),
                      ],
                    ),
                    Column(
                      children: [
                        AppCheckbox(
                          size: AppCheckboxSize.mini,
                          value: _cbMiniUnchecked,
                          onChanged: (v) => setState(() => _cbMiniUnchecked = v),
                        ),
                        const SizedBox(height: 2),
                        Text('Mini unchecked', style: AppTypography.caption),
                      ],
                    ),
                    Column(
                      children: [
                        AppCheckbox(
                          size: AppCheckboxSize.mini,
                          value: _cbMiniChecked,
                          onChanged: (v) => setState(() => _cbMiniChecked = v),
                        ),
                        const SizedBox(height: 2),
                        Text('Mini checked', style: AppTypography.caption),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              _buildSectionCard(
                title: 'Avatars',
                subtitle: 'A single member or group identity • reused visual tokens',
                child: Row(
                  children: [
                    AppAvatar.group(size: 52),
                    const SizedBox(width: 12),
                    AppAvatar.singleUser(size: 44),
                    const SizedBox(width: 16),
                    const AppMemberTokenCluster(extraCount: 0, size: 18),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // Badges & status
              _buildSectionCard(
                title: 'Badges & status',
                subtitle: 'A compact role or state • organizer and RSVP statuses',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppBadge.organizer(),
                    const SizedBox(height: 12),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        AppRsvpStatusTile(status: RsvpStatus.going),
                        AppRsvpStatusTile(status: RsvpStatus.maybe),
                        AppRsvpStatusTile(status: RsvpStatus.notGoing),
                        AppRsvpStatusTile(status: RsvpStatus.pending),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // Icon buttons
              _buildSectionCard(
                title: 'Icon buttons',
                subtitle: 'One action in an icon-only control • three visual variants',
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    AppIconButton(
                      icon: Iconsax.user5,
                      variant: AppIconButtonVariant.primary,
                      label: 'Primary',
                    ),
                    AppIconButton(
                      icon: Iconsax.user5,
                      variant: AppIconButtonVariant.secondary,
                      label: 'Secondary',
                    ),
                    AppIconButton(
                      icon: Iconsax.user5,
                      variant: AppIconButtonVariant.destructive,
                      label: 'Destructive',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // ==============================================================
              // 02 MOLECULES BOARD
              // ==============================================================
              _buildBoardHeader(
                '02',
                'Molecules',
                'Small combinations of atoms that work together for one purpose.',
              ),
              const SizedBox(height: 14),

              _buildSectionCard(
                title: 'M01 Labeled form field',
                subtitle: 'A01 Label + A04 Input + A01 Helper text',
                child: const AppLabeledFormField(
                  label: 'Group Name*',
                  helperText: 'Choose a name your members will recognize.',
                ),
              ),
              const SizedBox(height: 14),

              _buildSectionCard(
                title: 'M02 Search & filter',
                subtitle: 'A02 Search icon + A04 Input + A08 Filter action',
                child: AppSearchFilterBar(controller: _searchController),
              ),
              const SizedBox(height: 14),

              _buildSectionCard(
                title: 'M03 Dropdown field',
                subtitle: 'A01 Label + A04 Input + A02 Dropdown icon',
                child: const AppDropdownField(label: 'Expense Type'),
              ),
              const SizedBox(height: 14),

              _buildSectionCard(
                title: 'M04 Member action row',
                subtitle: 'A06 Avatar + A01 Member name + A02 Action icon',
                child: const AppMemberActionRow(name: 'Hannah S. Labandero'),
              ),
              const SizedBox(height: 14),

              _buildSectionCard(
                title: 'M05 Segmented tabs',
                subtitle: 'A01 Labels + selectable tab controls',
                child: AppSegmentedTabs<String>(
                  tabs: const ['Overview', 'Trips', 'Availability', 'Members'],
                  selectedTab: _segmentedTab,
                  labelBuilder: (t) => t,
                  onTabChanged: (t) => setState(() => _segmentedTab = t),
                ),
              ),
              const SizedBox(height: 14),

              _buildSectionCard(
                title: 'M06 Preference choice',
                subtitle: 'A02 Category icon + A01 Label + selection surface',
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AppPreferenceChoice(
                      label: 'Food Trips',
                      icon: Iconsax.cup5,
                      isSelected: !_prefChoiceSelected,
                      onTap: () => setState(() => _prefChoiceSelected = false),
                    ),
                    const SizedBox(width: 14),
                    AppPreferenceChoice(
                      label: 'Food Trips',
                      icon: Iconsax.cup5,
                      isSelected: _prefChoiceSelected,
                      onTap: () => setState(() => _prefChoiceSelected = true),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              _buildSectionCard(
                title: 'M07 Message composer',
                subtitle: 'A04 Input + A01 Placeholder + A02 Send action',
                child: AppMessageComposer(
                  controller: _msgController,
                  onSend: () {},
                ),
              ),
              const SizedBox(height: 14),

              _buildSectionCard(
                title: 'M08 Trip metadata',
                subtitle: 'A02 Location / Calendar icons + A01 Detail text',
                child: const AppTripMetadata(
                  location: 'Bantayan, Philippines',
                  dateRange: 'Oct 10 - Oct 15',
                ),
              ),
              const SizedBox(height: 14),

              _buildSectionCard(
                title: 'M09 Availability row',
                subtitle: 'A01 Day + A07 Availability badge + A06 Member tokens',
                child: const AppAvailabilityRow(day: 'Monday'),
              ),
              const SizedBox(height: 14),

              _buildSectionCard(
                title: 'M10 Chat message',
                subtitle: 'A06 Sender avatar + A01 Message + bubble surface',
                child: const AppChatMessage(text: 'Hello'),
              ),
              const SizedBox(height: 28),

              // ==============================================================
              // 03 ORGANISMS BOARD
              // ==============================================================
              _buildBoardHeader(
                '03',
                'Organisms',
                'Larger sections built from atoms and molecules to complete a distinct part of the interface.',
              ),
              const SizedBox(height: 14),

              // O01 App navigation
              _buildSectionCard(
                title: 'O01 App navigation',
                subtitle: 'Icons + navigation items + notification/settings actions',
                child: Column(
                  children: [
                    const AppMainTopBar(),
                    const Divider(color: AppColors.secondaryDark, thickness: 1.2),
                    AppBottomNavigation(
                      currentIndex: _demoNavIndex,
                      onTabSelected: (idx) => setState(() => _demoNavIndex = idx),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // O02 Group header
              _buildSectionCard(
                title: 'O02 Group header',
                subtitle: 'Avatar + identity + organizer badge + member count + CTA',
                child: const GroupHeaderOrganism(
                  groupName: 'Trip to Bantayan',
                  roleLabel: 'Organizer',
                  memberCount: 7,
                  showMemberTokens: false,
                ),
              ),
              const SizedBox(height: 14),

              // O03 Trip summary card
              _buildSectionCard(
                title: 'O03 Trip summary card',
                subtitle: 'Photo + title + M08 trip metadata + open-trip action',
                child: const TripSummaryCard(
                  title: 'Bantayan Trip',
                  location: 'Bantayan, Philippines',
                  groupLabel: 'The Group (6 going)',
                  dateRange: 'Oct 10 - Oct 15',
                ),
              ),
              const SizedBox(height: 14),

              // O04 Overview summary panel
              _buildSectionCard(
                title: 'O04 Overview summary panel',
                subtitle: 'A set of metric molecules: icon + value + label',
                child: const OverviewSummaryPanel(
                  availableToday: '5/7',
                  upcomingTrips: '3',
                  totalExpenses: 'P50,000',
                  destinations: '4',
                ),
              ),
              const SizedBox(height: 14),

              // O05 Member panel
              _buildSectionCard(
                title: 'O05 Member panel',
                subtitle: 'Search molecule + repeated M04 member action rows',
                child: const MemberPanel(
                  memberNames: [
                    'Hannah S. Labandero',
                    'Louielyn Abella',
                    'Ellle Bernante',
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // O06 Availability panel
              _buildSectionCard(
                title: 'O06 Availability panel',
                subtitle: 'Repeated M09 day rows + available counts + member tokens',
                child: const AvailabilityPanel(),
              ),
              const SizedBox(height: 28),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBoardHeader(String numStr, String board, String desc) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.primaryNavy,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ANO TARA / ATOMIC DESIGN / $numStr',
            style: AppTypography.caption.copyWith(
              color: Colors.white70,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            board,
            style: AppTypography.h2.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            desc,
            style: AppTypography.bodySmall.copyWith(color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required String subtitle,
    required Widget child,
  }) {
    return Container(
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTypography.titleLarge.copyWith(
              fontWeight: FontWeight.w800,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 12),
          child,
          const SizedBox(height: 12),
          Text(
            subtitle,
            style: AppTypography.caption.copyWith(
              fontSize: 10.5,
              color: AppColors.primaryNavy,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildColorSwatch(String name, Color color) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 28,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            name,
            style: AppTypography.caption.copyWith(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: AppColors.secondaryDark,
            ),
          ),
        ],
      ),
    );
  }
}
