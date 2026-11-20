import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import '../../components/atoms/app_avatar.dart';
import '../../components/atoms/app_button.dart';
import '../../components/atoms/app_input_field.dart';
import '../../components/organisms/app_top_bar.dart';
import '../../components/organisms/group_member_card.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import '../../models/group_models.dart';
import 'group_sheets.dart';

/// 3-step Create Group flow: details, invite members, review, then the
/// "Your group is ready!" screen. Pops with the new [GroupDetails] from
/// View Group, or null if the user backs out before creating it.
class CreateGroupScreen extends StatefulWidget {
  const CreateGroupScreen({super.key});

  @override
  State<CreateGroupScreen> createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends State<CreateGroupScreen> {
  static const _stepCount = 3;

  int _step = 0;
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  String? _nameError;
  List<UserProfile> _invited = [];

  /// Set once Create Group is tapped; the success screen is showing.
  GroupDetails? _created;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  void _back() {
    if (_created != null) {
      Navigator.of(context).pop(_created);
    } else if (_step > 0) {
      setState(() => _step--);
    } else {
      Navigator.of(context).pop();
    }
  }

  void _goTo(int step) {
    FocusScope.of(context).unfocus();
    setState(() => _step = step);
  }

  void _continueFromDetails() {
    if (_nameController.text.trim().isEmpty) {
      setState(() => _nameError = 'Group name is required');
      return;
    }
    _goTo(1);
  }

  Future<void> _searchPeople() async {
    final people = await showInviteMembersSheet(
      context,
      excludeIds: {GroupMember.me.id, for (final p in _invited) p.id},
    );
    if (!mounted || people == null || people.isEmpty) return;
    setState(() => _invited = [..._invited, ...people]);
  }

  void _create() {
    setState(() {
      _created = GroupDetails.create(
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        invited: _invited,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final done = _created != null;

    return PopScope(
      canPop: _step == 0 && !done,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _back();
      },
      child: Scaffold(
        backgroundColor: AppColors.white,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(57),
          child: Column(
            children: [
              AppTopBar(
                title: 'Create Group',
                showBackButton: !done,
                onBackPressed: _back,
              ),
              const ColoredBox(
                color: AppColors.secondaryDark,
                child: SizedBox(height: 1, width: double.infinity),
              ),
            ],
          ),
        ),
        body: done
            ? _buildSuccess()
            : ListView(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
                children: [
                  _StepPills(current: _step, count: _stepCount),
                  const SizedBox(height: 24),
                  ...switch (_step) {
                    0 => _buildDetailsStep(),
                    1 => _buildInviteStep(),
                    _ => _buildReviewStep(),
                  },
                ],
              ),
        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: _buildActions(),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildActions() {
    if (_created != null) {
      return [
        AppButton(
          text: 'View Group',
          borderRadius: 16,
          customHeight: 50,
          onPressed: () => Navigator.of(context).pop(_created),
        ),
      ];
    }
    return switch (_step) {
      0 => [
        AppButton(
          text: 'Continue',
          borderRadius: 16,
          customHeight: 50,
          onPressed: _continueFromDetails,
        ),
      ],
      1 => [
        AppButton(
          text: 'Continue',
          borderRadius: 16,
          customHeight: 50,
          onPressed: () => _goTo(2),
        ),
        const SizedBox(height: 14),
        AppButton(
          text: 'Skip for now',
          variant: AppButtonVariant.secondary,
          borderRadius: 16,
          customHeight: 50,
          onPressed: () {
            setState(() => _invited = []);
            _goTo(2);
          },
        ),
      ],
      _ => [
        AppButton(
          text: 'Create Group',
          borderRadius: 16,
          customHeight: 50,
          onPressed: _create,
        ),
      ],
    };
  }

  // ---------------------------------------------------------------------------
  // Step 1: group details
  // ---------------------------------------------------------------------------

  List<Widget> _buildDetailsStep() {
    return [
      const _StepHeading(
        title: 'Every adventure starts here!',
        subtitle: 'Add a few details to get your group started.',
      ),
      const SizedBox(height: 24),
      Row(
        children: [
          AppAvatar.group(size: 92),
          const SizedBox(width: 18),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Group photo',
                style: AppTypography.titleMedium.copyWith(
                  color: AppColors.secondaryDark,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              AppButton(
                text: 'Add photo',
                size: AppButtonSize.small,
                isFullWidth: false,
                borderRadius: 12,
                customHeight: 38,
                iconLeading: const Icon(
                  Iconsax.camera,
                  size: 16,
                  color: AppColors.white,
                ),
                onPressed: () =>
                    _showMessage('Adding a group photo is coming soon'),
              ),
            ],
          ),
        ],
      ),
      const SizedBox(height: 24),
      const _FieldLabel('Group Name', isRequired: true),
      const SizedBox(height: 8),
      AppInputField(
        hint: 'e.g. Weekend Wanderers',
        controller: _nameController,
        borderRadius: 15,
        errorText: _nameError,
        onChanged: (_) {
          if (_nameError != null) setState(() => _nameError = null);
        },
      ),
      const SizedBox(height: 18),
      const _FieldLabel('Description'),
      const SizedBox(height: 8),
      AppInputField(
        hint: 'Add a short description...',
        controller: _descriptionController,
        borderRadius: 15,
        minLines: 3,
        maxLines: 4,
        keyboardType: TextInputType.multiline,
      ),
    ];
  }

  // ---------------------------------------------------------------------------
  // Step 2: invite members
  // ---------------------------------------------------------------------------

  List<Widget> _buildInviteStep() {
    return [
      const _StepHeading(
        title: "Who's in your travel crew?",
        subtitle:
            'Search by username or email and select the people you want to '
            'invite.',
      ),
      const SizedBox(height: 24),
      Semantics(
        button: true,
        container: true,
        label: 'Search people to invite',
        excludeSemantics: true,
        onTap: _searchPeople,
        child: AppInputField(
          hint: 'Search username or email...',
          borderRadius: 15,
          isReadOnly: true,
          onTap: _searchPeople,
          prefixIcon: const Icon(
            Iconsax.search_normal,
            size: 20,
            color: AppColors.secondaryDark,
          ),
        ),
      ),
      const SizedBox(height: 16),
      Align(
        alignment: Alignment.centerLeft,
        child: _CountPill(
          text:
              '${_invited.length} ${_invited.length == 1 ? 'person' : 'people'} '
              'selected',
        ),
      ),
      const SizedBox(height: 16),
      for (final person in _invited)
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: GroupMemberCard(
            member: _asMember(person),
            onRemove: () => setState(
              () => _invited = [
                for (final p in _invited)
                  if (p.id != person.id) p,
              ],
            ),
          ),
        ),
    ];
  }

  GroupMember _asMember(UserProfile person) => GroupMember(
    id: person.id,
    name: person.name,
    handle: person.handle,
    addedAt: DateTime.now(),
  );

  // ---------------------------------------------------------------------------
  // Step 3: review
  // ---------------------------------------------------------------------------

  List<Widget> _buildReviewStep() {
    final description = _descriptionController.text.trim();

    return [
      const _StepHeading(
        title: 'Ready to make it official!',
        subtitle: 'Check your group details before creating it.',
      ),
      const SizedBox(height: 24),
      Center(
        child: SizedBox(
          width: 101,
          height: 101,
          child: Stack(
            children: [
              AppAvatar.group(size: 92),
              Positioned(
                left: 64,
                top: 64,
                child: Semantics(
                  button: true,
                  container: true,
                  label: 'Change group photo',
                  excludeSemantics: true,
                  onTap: () =>
                      _showMessage('Adding a group photo is coming soon'),
                  child: GestureDetector(
                    onTap: () =>
                        _showMessage('Adding a group photo is coming soon'),
                    child: Container(
                      width: 27,
                      height: 27,
                      decoration: BoxDecoration(
                        color: AppColors.primaryNavy,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.secondaryDark,
                          width: 2,
                        ),
                      ),
                      child: const Icon(
                        Icons.edit,
                        size: 13,
                        color: AppColors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      const SizedBox(height: 24),
      _ReviewSection(
        label: 'Group Name',
        editLabel: 'Edit group name',
        onEdit: () => _goTo(0),
        child: _ReviewValue(_nameController.text.trim()),
      ),
      _ReviewSection(
        label: 'Description',
        editLabel: 'Edit description',
        onEdit: () => _goTo(0),
        child: _ReviewValue(
          description.isEmpty ? 'No description' : description,
          isPlaceholder: description.isEmpty,
        ),
      ),
      _ReviewSection(
        label: 'Group Members',
        editLabel: 'Edit group members',
        onEdit: () => _goTo(1),
        child: _invited.isEmpty
            ? const _ReviewValue('Just you for now', isPlaceholder: true)
            : Column(
                children: [
                  for (final person in _invited)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: GroupMemberCard(member: _asMember(person)),
                    ),
                ],
              ),
      ),
    ];
  }

  // ---------------------------------------------------------------------------
  // Success
  // ---------------------------------------------------------------------------

  Widget _buildSuccess() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.verified,
              size: 96,
              color: AppColors.primaryOrange,
            ),
            const SizedBox(height: 20),
            Text(
              'Your group is ready!',
              textAlign: TextAlign.center,
              style: AppTypography.h2.copyWith(
                color: AppColors.secondaryDark,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              '${_created!.name} is all set. Invite your crew and start '
              'planning your first trip together.',
              textAlign: TextAlign.center,
              style: AppTypography.bodyMedium.copyWith(color: AppColors.slate),
            ),
          ],
        ),
      ),
    );
  }
}

/// Three small pills with only the current step filled, and "n/3" below.
class _StepPills extends StatelessWidget {
  final int current;
  final int count;

  const _StepPills({required this.current, required this.count});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Step ${current + 1} of $count',
      excludeSemantics: true,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (var i = 0; i < count; i++)
                Container(
                  width: 36,
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  decoration: BoxDecoration(
                    color: i == current
                        ? AppColors.primaryNavy
                        : AppColors.secondaryLight,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.secondaryDark),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            '${current + 1}/$count',
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.carla,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _StepHeading extends StatelessWidget {
  final String title;
  final String subtitle;

  const _StepHeading({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTypography.h3.copyWith(
            color: AppColors.secondaryDark,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          subtitle,
          style: AppTypography.bodySmall.copyWith(color: AppColors.slate),
        ),
      ],
    );
  }
}

/// Field label with an optional red asterisk for required fields.
class _FieldLabel extends StatelessWidget {
  final String text;
  final bool isRequired;

  const _FieldLabel(this.text, {this.isRequired = false});

  @override
  Widget build(BuildContext context) {
    final style = AppTypography.titleMedium.copyWith(
      color: AppColors.secondaryDark,
      fontWeight: FontWeight.w700,
    );
    return Text.rich(
      TextSpan(
        text: text,
        style: style,
        children: [
          if (isRequired)
            TextSpan(
              text: '*',
              style: style.copyWith(color: AppColors.semanticRed),
            ),
        ],
      ),
    );
  }
}

class _CountPill extends StatelessWidget {
  final String text;

  const _CountPill({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.primaryNavyLight,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primaryNavy),
      ),
      child: Text(
        text,
        style: AppTypography.bodySmall.copyWith(
          color: AppColors.primaryNavy,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

/// Read-only review block with an orange "Edit" link back to its step.
class _ReviewSection extends StatelessWidget {
  final String label;
  final String editLabel;
  final VoidCallback onEdit;
  final Widget child;

  const _ReviewSection({
    required this.label,
    required this.editLabel,
    required this.onEdit,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(child: _FieldLabel(label)),
              Semantics(
                button: true,
                container: true,
                label: editLabel,
                excludeSemantics: true,
                onTap: onEdit,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: onEdit,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 8,
                    ),
                    child: Text(
                      'Edit',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.primaryOrange,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          child,
        ],
      ),
    );
  }
}

class _ReviewValue extends StatelessWidget {
  final String text;
  final bool isPlaceholder;

  const _ReviewValue(this.text, {this.isPlaceholder = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: AppColors.secondaryDark, width: 2),
      ),
      child: Text(
        text,
        style: AppTypography.bodyMedium.copyWith(
          color: isPlaceholder ? AppColors.shayne : AppColors.secondaryDark,
        ),
      ),
    );
  }
}
