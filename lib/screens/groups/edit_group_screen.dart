import 'package:flutter/material.dart';

import '../../components/atoms/app_avatar.dart';
import '../../components/atoms/app_button.dart';
import '../../components/atoms/app_input_field.dart';
import '../../components/organisms/app_top_bar.dart';
import '../../components/organisms/group_member_card.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import '../../models/group_models.dart';
import 'group_sheets.dart';

/// 05.07 Edit Group Details (organizer only).
/// Edits a draft copy of the group; pops with the updated [GroupDetails] on
/// Save Changes, or null on Cancel / back.
class EditGroupScreen extends StatefulWidget {
  final GroupDetails group;

  const EditGroupScreen({super.key, required this.group});

  @override
  State<EditGroupScreen> createState() => _EditGroupScreenState();
}

class _EditGroupScreenState extends State<EditGroupScreen> {
  late GroupDetails _draft = widget.group;
  late final _nameController = TextEditingController(text: widget.group.name);
  late final _descriptionController = TextEditingController(
    text: widget.group.description,
  );
  String? _nameError;

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

  Future<void> _inviteMembers() async {
    final people = await showInviteMembersSheet(
      context,
      excludeIds: {for (final m in _draft.members) m.id},
    );
    if (!mounted || people == null || people.isEmpty) return;
    setState(() => _draft = _draft.withInvited(people));
  }

  Future<void> _removeMember(GroupMember member) async {
    final confirmed = await showRemoveMemberSheet(
      context,
      memberName: member.name,
    );
    if (!mounted || !confirmed) return;
    setState(() {
      _draft = _draft.copyWith(
        members: [
          for (final m in _draft.members)
            if (m.id != member.id) m,
        ],
      );
    });
  }

  void _save() {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      setState(() => _nameError = 'Group name is required');
      return;
    }
    Navigator.of(context).pop(
      _draft.copyWith(
        name: name,
        description: _descriptionController.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(57),
        child: Column(
          children: [
            AppTopBar(title: 'Edit Group Details'),
            ColoredBox(
              color: AppColors.secondaryDark,
              child: SizedBox(height: 1, width: double.infinity),
            ),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 25, 16, 24),
        children: [
          Row(
            children: [
              _GroupPhotoEditor(
                onEditTap: () =>
                    _showMessage('Changing the group photo is coming soon'),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: AppInputField(
                  label: 'Group Name',
                  hint: 'Enter a group name',
                  controller: _nameController,
                  borderRadius: 15,
                  errorText: _nameError,
                  onChanged: (_) {
                    if (_nameError != null) setState(() => _nameError = null);
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          AppInputField(
            label: 'Description',
            hint: 'What is this group about?',
            controller: _descriptionController,
            borderRadius: 15,
            minLines: 3,
            maxLines: 4,
            keyboardType: TextInputType.multiline,
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Group Members',
                  style: AppTypography.h4.copyWith(
                    color: AppColors.secondaryDark,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              _InviteButton(onTap: _inviteMembers),
            ],
          ),
          const SizedBox(height: 18),
          for (final member in _draft.members)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: GroupMemberCard(
                member: member,
                // Organizers cannot remove themselves.
                onRemove: member.isCurrentUser
                    ? null
                    : () => _removeMember(member),
              ),
            ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(13, 12, 19, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppButton(
                text: 'Save Changes',
                borderRadius: 16,
                customHeight: 50,
                onPressed: _save,
              ),
              const SizedBox(height: 18),
              AppButton(
                text: 'Cancel',
                variant: AppButtonVariant.secondary,
                borderRadius: 16,
                customHeight: 50,
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 92px group avatar with the small navy pencil badge on its lower right.
class _GroupPhotoEditor extends StatelessWidget {
  final VoidCallback onEditTap;

  const _GroupPhotoEditor({required this.onEditTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 101,
      height: 101,
      child: Stack(
        children: [
          AppAvatar.group(size: 92),
          Positioned(
            left: 57,
            top: 57,
            child: Semantics(
              button: true,
              label: 'Change group photo',
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: onEditTap,
                child: SizedBox(
                  width: 44,
                  height: 44,
                  child: Center(
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
            ),
          ),
        ],
      ),
    );
  }
}

/// Yellow "+ Invite" pill next to the Group Members heading.
class _InviteButton extends StatelessWidget {
  final VoidCallback onTap;

  const _InviteButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Invite members',
      container: true,
      excludeSemantics: true,
      onTap: onTap,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 7),
          child: Container(
            width: 104,
            height: 30,
            decoration: BoxDecoration(
              color: AppColors.semanticYellow,
              borderRadius: BorderRadius.circular(11),
              border: Border.all(color: AppColors.secondaryDark, width: 2),
              boxShadow: const [
                BoxShadow(
                  color: AppColors.secondaryDark,
                  offset: Offset(0, 2),
                  blurRadius: 0,
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.add_rounded,
                  size: 16,
                  color: AppColors.secondaryDark,
                ),
                const SizedBox(width: 6),
                Text(
                  'Invite',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.secondaryDark,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
