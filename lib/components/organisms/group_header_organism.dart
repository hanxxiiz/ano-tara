import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import '../atoms/app_avatar.dart';
import '../atoms/app_button.dart';

/// O02 Group header organism matching Figma "05.03 Group details":
/// Recipe: Yellow band + group avatar + name + role badge + member tokens
/// + Plan a Trip CTA + organizer-only actions menu.
class GroupHeaderOrganism extends StatelessWidget {
  final String groupName;
  final bool isOrganizer;
  final List<String> memberNames;
  final VoidCallback? onPlanTripTap;

  /// Opens Group Actions. Only rendered for organizers.
  final VoidCallback? onMenuTap;

  const GroupHeaderOrganism({
    super.key,
    required this.groupName,
    this.isOrganizer = false,
    this.memberNames = const [],
    this.onPlanTripTap,
    this.onMenuTap,
  });

  static const double _bandHeight = 46;
  static const double _avatarSize = 86;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: AppColors.secondaryDark, width: 2),
        boxShadow: const [
          BoxShadow(
            color: AppColors.secondaryDark,
            offset: Offset(0, 4),
            blurRadius: 0,
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                height: _bandHeight,
                decoration: const BoxDecoration(
                  color: AppColors.semanticYellow,
                  border: Border(
                    bottom: BorderSide(
                      color: AppColors.secondaryDark,
                      width: 2,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(117, 12, 14, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      groupName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.h3.copyWith(
                        fontWeight: FontWeight.w800,
                        color: AppColors.secondaryDark,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        _RoleBadge(isOrganizer: isOrganizer),
                        const SizedBox(width: 10),
                        Flexible(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: AppInitialsTokenRow(
                              names: memberNames,
                              maxVisible: 4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(21, 18, 21, 23),
                child: Row(
                  children: [
                    Expanded(
                      child: AppButton(
                        text: 'Plan a Trip',
                        variant: AppButtonVariant.secondary,
                        size: AppButtonSize.small,
                        customHeight: 36,
                        borderRadius: 12,
                        iconLeading: const Icon(
                          Icons.add_rounded,
                          size: 20,
                          color: AppColors.secondaryDark,
                        ),
                        onPressed: onPlanTripTap ?? () {},
                      ),
                    ),
                    if (isOrganizer) ...[
                      const SizedBox(width: 10),
                      _MenuButton(onTap: onMenuTap),
                    ],
                  ],
                ),
              ),
            ],
          ),
          Positioned(
            left: 21,
            top: _bandHeight - 19,
            child: AppAvatar.group(size: _avatarSize),
          ),
        ],
      ),
    );
  }
}

class _RoleBadge extends StatelessWidget {
  final bool isOrganizer;

  const _RoleBadge({required this.isOrganizer});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 20,
      padding: const EdgeInsets.symmetric(horizontal: 13),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: isOrganizer
            ? AppColors.primaryOrange.withValues(alpha: 0.75)
            : AppColors.primaryNavy,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        isOrganizer ? 'Organizer' : 'Member',
        style: AppTypography.badge.copyWith(
          color: AppColors.white,
          fontSize: 11,
          letterSpacing: 0,
        ),
      ),
    );
  }
}

class _MenuButton extends StatelessWidget {
  final VoidCallback? onTap;

  const _MenuButton({this.onTap});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Group actions',
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Container(
          width: 44,
          height: 44,
          alignment: Alignment.center,
          child: Container(
            width: 40,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.secondaryDark, width: 2),
              boxShadow: const [
                BoxShadow(
                  color: AppColors.secondaryDark,
                  offset: Offset(0, 2),
                  blurRadius: 0,
                ),
              ],
            ),
            child: const Icon(
              Iconsax.more,
              size: 22,
              color: AppColors.secondaryDark,
            ),
          ),
        ),
      ),
    );
  }
}
