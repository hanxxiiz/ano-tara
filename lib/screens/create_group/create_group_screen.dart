import 'dart:io';

import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import '../../components/edit_attached_group_photo.dart';
import '../../components/edit_button.dart';
import '../../components/group_members_tile.dart';
import '../../components/group_photo_picker.dart';
import '../../components/selected_people_tile.dart';
import '../../theme/app_theme.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Mock data
// ─────────────────────────────────────────────────────────────────────────────

const _mockSelectedPeople = [
  {'name': 'Jane Doe', 'subtitle': '@blackxswann'},
  {'name': 'John Doe', 'subtitle': '@blackxswann'},
];

const _mockGroupMembers = [
  {'name': 'Louelyn Abella', 'subtitle': null},
  {'name': 'Louelyn Abella', 'subtitle': '@blackxswann'},
];

// ─────────────────────────────────────────────────────────────────────────────
// CreateGroupScreen
// ─────────────────────────────────────────────────────────────────────────────

/// 4-step flow: Group Details → Invite Members → Review → Created.
class CreateGroupScreen extends StatefulWidget {
  const CreateGroupScreen({super.key});

  @override
  State<CreateGroupScreen> createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends State<CreateGroupScreen> {
  int _step = 0; // 0 = Details, 1 = Invite, 2 = Review, 3 = Created
  File? _groupPhoto;

  void _next() => setState(() => _step = (_step + 1).clamp(0, 3));
  void _back() {
    if (_step == 0) {
      Navigator.of(context).maybePop();
    } else {
      setState(() => _step -= 1);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          child: KeyedSubtree(
            key: ValueKey(_step),
            child: switch (_step) {
              0 => _StepGroupDetails(
                  groupPhoto: _groupPhoto,
                  onAddPhoto: () {
                    // Photo picking is deferred — no image_picker dependency.
                    // Replace this stub with an actual file picker when ready.
                  },
                  onBack: _back,
                  onContinue: _next,
                ),
              1 => _StepInviteMembers(onBack: _back, onContinue: _next),
              2 => _StepReview(
                  groupPhoto: _groupPhoto,
                  onBack: _back,
                  onCreateGroup: _next,
                ),
              3 => _StepCreated(onViewGroup: () {}, onGoBack: _back),
              _ => const SizedBox.shrink(),
            },
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Step 0 – Group Details
// ─────────────────────────────────────────────────────────────────────────────

class _StepGroupDetails extends StatelessWidget {
  const _StepGroupDetails({
    required this.groupPhoto,
    required this.onAddPhoto,
    required this.onBack,
    required this.onContinue,
  });

  final File? groupPhoto;
  final VoidCallback onAddPhoto;
  final VoidCallback onBack;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: AppTokens.pagePadding),
      children: [
        const SizedBox(height: 16),

        // ── Topbar placeholder ──────────────────────────────────────────
        // PLACEHOLDER: Replace with the existing Topbar widget.
        _TopbarPlaceholder(onBack: onBack, title: null),

        const SizedBox(height: 20),

        // ── Progress bar placeholder ────────────────────────────────────
        // PLACEHOLDER: Replace with the existing ProgressBar widget.
        _ProgressBarPlaceholder(totalSteps: 3, currentStep: 1),

        const SizedBox(height: 28),

        // ── Heading ─────────────────────────────────────────────────────
        const Text(
          'Every adventure\nstarts here!',
          style: TextStyle(
            fontFamily: AppFonts.urbanist,
            fontWeight: FontWeight.w800,
            fontSize: 24,
            color: AppColors.primaryText,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Add a few details to get your group started.',
          style: TextStyle(
            fontFamily: AppFonts.openSans,
            fontWeight: FontWeight.w400,
            fontSize: 14,
            color: AppColors.primaryText,
          ),
        ),

        const SizedBox(height: 24),

        // ── Group photo ──────────────────────────────────────────────────
        const Text(
          'Group photo',
          style: TextStyle(
            fontFamily: AppFonts.urbanist,
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: AppColors.primaryText,
          ),
        ),
        const SizedBox(height: 10),
        GroupPhotoPicker(
          imageFile: groupPhoto,
          onAddPhoto: onAddPhoto,
        ),

        const SizedBox(height: 20),

        // ── Group Name input placeholder ─────────────────────────────────
        const Text(
          'Group Name',
          style: TextStyle(
            fontFamily: AppFonts.urbanist,
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: AppColors.primaryText,
          ),
        ),
        const SizedBox(height: 8),
        // PLACEHOLDER: Replace with the existing InputBox widget.
        _InputBoxPlaceholder(hint: 'e.g. Weekend Wanderers'),

        const SizedBox(height: 16),

        // ── Description input placeholder ───────────────────────────────
        const Text(
          'Description',
          style: TextStyle(
            fontFamily: AppFonts.urbanist,
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: AppColors.primaryText,
          ),
        ),
        const SizedBox(height: 8),
        // PLACEHOLDER: Replace with the existing InputBox widget.
        _InputBoxPlaceholder(
          hint: 'Add a short description...',
          minLines: 4,
          maxLines: 6,
        ),

        const SizedBox(height: 32),

        // ── Continue button placeholder ─────────────────────────────────
        // PLACEHOLDER: Replace with the existing Button widget.
        _ButtonPlaceholder(label: 'Continue', onTap: onContinue),

        const SizedBox(height: 32),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Step 1 – Invite Members (Optional)
// ─────────────────────────────────────────────────────────────────────────────

class _StepInviteMembers extends StatelessWidget {
  const _StepInviteMembers({
    required this.onBack,
    required this.onContinue,
  });

  final VoidCallback onBack;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: AppTokens.pagePadding),
      children: [
        const SizedBox(height: 16),

        // ── Topbar placeholder ──────────────────────────────────────────
        // PLACEHOLDER: Replace with the existing Topbar widget.
        _TopbarPlaceholder(onBack: onBack, title: null),

        const SizedBox(height: 20),

        // ── Progress bar placeholder ────────────────────────────────────
        // PLACEHOLDER: Replace with the existing ProgressBar widget.
        _ProgressBarPlaceholder(totalSteps: 3, currentStep: 2),

        const SizedBox(height: 28),

        // ── Heading ─────────────────────────────────────────────────────
        const Text(
          "Who's in your travel crew?",
          style: TextStyle(
            fontFamily: AppFonts.urbanist,
            fontWeight: FontWeight.w800,
            fontSize: 24,
            color: AppColors.primaryText,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Search by username or email and select the people you want to invite.',
          style: TextStyle(
            fontFamily: AppFonts.openSans,
            fontWeight: FontWeight.w400,
            fontSize: 14,
            color: AppColors.primaryText,
          ),
        ),

        const SizedBox(height: 20),

        // ── Search bar placeholder ───────────────────────────────────────
        // PLACEHOLDER: Replace with the existing SearchBar widget.
        _SearchBarPlaceholder(hint: 'Search username or email...'),

        const SizedBox(height: 16),

        // ── Selection count ──────────────────────────────────────────────
        Text(
          '${_mockSelectedPeople.length} people selected',
          style: const TextStyle(
            fontFamily: AppFonts.urbanist,
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: AppColors.primaryText,
          ),
        ),

        const SizedBox(height: 10),

        // ── Selected people list ─────────────────────────────────────────
        ..._mockSelectedPeople.map(
          (p) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: SelectedPeopleTile(
              name: p['name']!,
              subtitle: p['subtitle'],
            ),
          ),
        ),

        const SizedBox(height: 24),

        // ── Continue button placeholder ─────────────────────────────────
        // PLACEHOLDER: Replace with the existing Button widget.
        _ButtonPlaceholder(label: 'Continue', onTap: onContinue),

        const SizedBox(height: 12),

        // ── Skip for now button placeholder ────────────────────────────
        // PLACEHOLDER: Replace with the existing Button widget.
        _ButtonPlaceholder(
          label: 'Skip for now',
          onTap: onContinue,
          outlined: true,
        ),

        const SizedBox(height: 32),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Step 2 – Review Before Creating
// ─────────────────────────────────────────────────────────────────────────────

class _StepReview extends StatelessWidget {
  const _StepReview({
    required this.groupPhoto,
    required this.onBack,
    required this.onCreateGroup,
  });

  final File? groupPhoto;
  final VoidCallback onBack;
  final VoidCallback onCreateGroup;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: AppTokens.pagePadding),
      children: [
        const SizedBox(height: 16),

        // ── Topbar placeholder ──────────────────────────────────────────
        // PLACEHOLDER: Replace with the existing Topbar widget.
        _TopbarPlaceholder(onBack: onBack, title: null),

        const SizedBox(height: 20),

        // ── Progress bar placeholder ────────────────────────────────────
        // PLACEHOLDER: Replace with the existing ProgressBar widget.
        _ProgressBarPlaceholder(totalSteps: 3, currentStep: 3),

        const SizedBox(height: 28),

        // ── Heading ─────────────────────────────────────────────────────
        const Text(
          'Ready to make it official?',
          style: TextStyle(
            fontFamily: AppFonts.urbanist,
            fontWeight: FontWeight.w800,
            fontSize: 24,
            color: AppColors.primaryText,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Check your group details before creating it.',
          style: TextStyle(
            fontFamily: AppFonts.openSans,
            fontWeight: FontWeight.w400,
            fontSize: 14,
            color: AppColors.primaryText,
          ),
        ),

        const SizedBox(height: 20),

        // ── Group Name card ──────────────────────────────────────────────
        Container(
          decoration: AppTokens.cardDecoration(),
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Photo with edit badge overlay
              Stack(
                children: [
                  SizedBox(
                    width: AppTokens.groupPhotoSize,
                    height: AppTokens.groupPhotoSize,
                    child: ClipOval(
                      child: groupPhoto != null
                          ? Image.file(
                              groupPhoto!,
                              fit: BoxFit.cover,
                              width: AppTokens.groupPhotoSize,
                              height: AppTokens.groupPhotoSize,
                            )
                          : Container(
                              color: AppColors.yellow,
                              child: const Icon(
                                Iconsax.profile_2user,
                                size: 32,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: EditAttachedGroupPhoto(onTap: () {}),
                  ),
                ],
              ),

              const SizedBox(width: 12),

              // Name display
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Group Name',
                          style: TextStyle(
                            fontFamily: AppFonts.urbanist,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                            color: AppColors.primaryText,
                          ),
                        ),
                        EditButton(onTap: () {}),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.field,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'AnoTara?',
                        style: TextStyle(
                          fontFamily: AppFonts.urbanist,
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                          color: AppColors.primaryText,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // ── Description card ─────────────────────────────────────────────
        Container(
          decoration: AppTokens.cardDecoration(),
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Description',
                    style: TextStyle(
                      fontFamily: AppFonts.urbanist,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                      color: AppColors.primaryText,
                    ),
                  ),
                  EditButton(onTap: () {}),
                ],
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                constraints: const BoxConstraints(minHeight: 60),
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.field,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Pasasara mi pls.',
                  style: TextStyle(
                    fontFamily: AppFonts.urbanist,
                    fontWeight: FontWeight.w400,
                    fontSize: 14,
                    color: AppColors.primaryText,
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // ── Group Members section ─────────────────────────────────────────
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Group Members',
              style: TextStyle(
                fontFamily: AppFonts.urbanist,
                fontWeight: FontWeight.w700,
                fontSize: 16,
                color: AppColors.primaryText,
              ),
            ),
            GestureDetector(
              onTap: () {},
              child: Row(
                children: const [
                  Icon(Icons.add, size: 16, color: AppColors.primaryBlue),
                  SizedBox(width: 4),
                  Text(
                    'Add',
                    style: TextStyle(
                      fontFamily: AppFonts.urbanist,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: AppColors.primaryBlue,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 10),

        ..._mockGroupMembers.map(
          (m) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: GroupMembersTile(
              name: m['name']!,
              subtitle: m['subtitle'],
            ),
          ),
        ),

        const SizedBox(height: 24),

        // ── Create Group button placeholder ─────────────────────────────
        // PLACEHOLDER: Replace with the existing Button widget.
        _ButtonPlaceholder(
          label: 'Create Group',
          onTap: onCreateGroup,
          icon: Iconsax.profile_2user,
        ),

        const SizedBox(height: 32),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Step 3 – Group Created
// ─────────────────────────────────────────────────────────────────────────────

class _StepCreated extends StatelessWidget {
  const _StepCreated({
    required this.onViewGroup,
    required this.onGoBack,
  });

  final VoidCallback onViewGroup;
  final VoidCallback onGoBack;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          const EdgeInsets.symmetric(horizontal: AppTokens.pagePadding),
      child: Column(
        children: [
          const Spacer(flex: 2),

          // ── Checkmark circle ─────────────────────────────────────────
          Container(
            width: 110,
            height: 110,
            decoration: const BoxDecoration(
              color: AppColors.orange,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_rounded,
              size: 60,
              color: Colors.white,
            ),
          ),

          const SizedBox(height: 28),

          const Text(
            'Your group is ready!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: AppFonts.urbanist,
              fontWeight: FontWeight.w800,
              fontSize: 26,
              color: AppColors.primaryText,
            ),
          ),

          const SizedBox(height: 10),

          const Text(
            'Weekend Wanderers has been created.\nInvitations were sent to 2 people.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: AppFonts.openSans,
              fontWeight: FontWeight.w400,
              fontSize: 14,
              color: AppColors.primaryText,
            ),
          ),

          const Spacer(flex: 3),

          // ── View Group button placeholder ────────────────────────────
          // PLACEHOLDER: Replace with the existing Button widget.
          _ButtonPlaceholder(label: 'View Group', onTap: onViewGroup),

          const SizedBox(height: 12),

          // ── Go Back button placeholder ───────────────────────────────
          // PLACEHOLDER: Replace with the existing Button widget.
          _ButtonPlaceholder(label: 'Go Back', onTap: onGoBack, outlined: true),

          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Local placeholder widgets
// ─────────────────────────────────────────────────────────────────────────────

/// PLACEHOLDER: Replace with the existing Topbar widget.
class _TopbarPlaceholder extends StatelessWidget {
  const _TopbarPlaceholder({this.onBack, this.title});

  final VoidCallback? onBack;
  final String? title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onTap: onBack ?? () => Navigator.of(context).maybePop(),
          behavior: HitTestBehavior.opaque,
          child: const Padding(
            padding: EdgeInsets.all(4),
            child: Icon(
              Icons.arrow_back,
              size: 24,
              color: AppColors.primaryText,
            ),
          ),
        ),
        if (title != null) ...[
          const SizedBox(width: 12),
          Text(
            title!,
            style: const TextStyle(
              fontFamily: AppFonts.urbanist,
              fontWeight: FontWeight.w700,
              fontSize: 18,
              color: AppColors.primaryText,
            ),
          ),
        ],
      ],
    );
  }
}

/// PLACEHOLDER: Replace with the existing ProgressBar widget.
class _ProgressBarPlaceholder extends StatelessWidget {
  const _ProgressBarPlaceholder({
    required this.totalSteps,
    required this.currentStep,
  });

  final int totalSteps;
  final int currentStep;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(totalSteps, (i) {
        final isActive = i < currentStep;
        return Expanded(
          child: Container(
            margin: EdgeInsets.only(left: i == 0 ? 0 : 4),
            height: 6,
            decoration: BoxDecoration(
              color: isActive ? AppColors.primaryBlue : AppColors.field,
              borderRadius: BorderRadius.circular(99),
            ),
          ),
        );
      }),
    );
  }
}

/// PLACEHOLDER: Replace with the existing InputBox widget.
class _InputBoxPlaceholder extends StatelessWidget {
  const _InputBoxPlaceholder({
    required this.hint,
    this.minLines = 1,
    this.maxLines = 1,
  });

  final String hint;
  final int minLines;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppTokens.cardDecoration(),
      child: TextField(
        minLines: minLines,
        maxLines: maxLines,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(
            fontFamily: AppFonts.urbanist,
            fontWeight: FontWeight.w400,
            fontSize: 14,
            color: Color(0xFFAAAAAA),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          border: InputBorder.none,
        ),
        style: const TextStyle(
          fontFamily: AppFonts.urbanist,
          fontWeight: FontWeight.w400,
          fontSize: 14,
          color: AppColors.primaryText,
        ),
      ),
    );
  }
}

/// PLACEHOLDER: Replace with the existing SearchBar widget.
class _SearchBarPlaceholder extends StatelessWidget {
  const _SearchBarPlaceholder({required this.hint});

  final String hint;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppTokens.cardDecoration(),
      child: TextField(
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(
            fontFamily: AppFonts.urbanist,
            fontWeight: FontWeight.w400,
            fontSize: 14,
            color: Color(0xFFAAAAAA),
          ),
          prefixIcon: const Icon(
            Iconsax.search_normal_1,
            size: 20,
            color: AppColors.primaryText,
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          border: InputBorder.none,
        ),
        style: const TextStyle(
          fontFamily: AppFonts.urbanist,
          fontWeight: FontWeight.w400,
          fontSize: 14,
          color: AppColors.primaryText,
        ),
      ),
    );
  }
}

/// PLACEHOLDER: Replace with the existing Button widget.
class _ButtonPlaceholder extends StatelessWidget {
  const _ButtonPlaceholder({
    required this.label,
    required this.onTap,
    this.outlined = false,
    this.icon,
  });

  final String label;
  final VoidCallback onTap;
  final bool outlined;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final bg = outlined ? Colors.white : AppColors.primaryBlue;
    final fg = outlined ? AppColors.primaryText : Colors.white;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 52,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(AppTokens.cardRadius),
          border: Border.all(
            color: AppColors.primaryDark,
            width: AppTokens.cardBorderWidth,
          ),
          boxShadow: const [
            BoxShadow(
              color: AppColors.primaryDark,
              offset: Offset(0, AppTokens.cardShadowOffset),
              blurRadius: 0,
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 18, color: fg),
              const SizedBox(width: 8),
            ],
            Text(
              label,
              style: TextStyle(
                fontFamily: AppFonts.urbanist,
                fontWeight: FontWeight.w700,
                fontSize: 16,
                color: fg,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
