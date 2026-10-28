import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../../core/constants/app_colors.dart';
import 'app_icon.dart';

enum AppAvatarType {
  singleUser,
  group,
  initials,
}

/// Avatar atom matching Figma "Avatars" board:
/// Supports single user avatar (yellow circle), group avatar (orange with group icon), and avatar cluster.
class AppAvatar extends StatelessWidget {
  final String? name;
  final String? imageUrl;
  final double size;
  final AppAvatarType type;
  final Color? backgroundColor;
  final Color? textColor;
  final bool hasBorder;

  const AppAvatar({
    super.key,
    this.name,
    this.imageUrl,
    this.size = 44.0,
    this.type = AppAvatarType.singleUser,
    this.backgroundColor,
    this.textColor,
    this.hasBorder = false,
  });

  factory AppAvatar.group({double size = 56.0}) {
    return AppAvatar(
      size: size,
      type: AppAvatarType.group,
      hasBorder: true,
      backgroundColor: AppColors.primaryOrange,
    );
  }

  factory AppAvatar.singleUser({double size = 44.0}) {
    return AppAvatar(
      size: size,
      type: AppAvatarType.singleUser,
      backgroundColor: AppColors.semanticYellow,
    );
  }

  @override
  Widget build(BuildContext context) {
    Color bg = backgroundColor ?? (type == AppAvatarType.group ? AppColors.primaryOrange : AppColors.semanticYellow);

    Widget childWidget;
    if (type == AppAvatarType.group) {
      childWidget = Icon(
        Iconsax.profile_2user5,
        color: AppColors.white,
        size: size * 0.5,
      );
    } else if (type == AppAvatarType.singleUser) {
      childWidget = AppIcon(
        Iconsax.user5,
        color: AppColors.white,
        size: size * 0.55,
      );
    } else {
      final initial = (name != null && name!.isNotEmpty) ? name![0].toUpperCase() : 'U';
      childWidget = Text(
        initial,
        style: TextStyle(
          color: textColor ?? AppColors.white,
          fontSize: size * 0.42,
          fontWeight: FontWeight.w800,
        ),
      );
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: bg,
        shape: BoxShape.circle,
        border: hasBorder ? Border.all(color: AppColors.secondaryDark, width: 2.0) : null,
        boxShadow: hasBorder
            ? const [
                BoxShadow(
                  color: AppColors.secondaryDark,
                  offset: Offset(0, 3),
                  blurRadius: 0,
                ),
              ]
            : null,
      ),
      child: Center(child: childWidget),
    );
  }
}

/// Reusable member avatar tokens row matching Figma "A06 Member tokens":
/// 4 overlapping gradient orange-to-peach circles + separate "+3" circle.
class AppMemberTokenCluster extends StatelessWidget {
  final int extraCount;
  final double size;

  const AppMemberTokenCluster({
    super.key,
    this.extraCount = 3,
    this.size = 18.0,
  });

  @override
  Widget build(BuildContext context) {
    const colors = [
      Color(0xFFE24B27),
      Color(0xFFEA7B61),
      Color(0xFFF2A794),
      Color(0xFFF9D2C8),
    ];

    final double overlapStep = size * 0.62;
    final double stackWidth = size + (colors.length - 1) * overlapStep;

    return SizedBox(
      height: size,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: stackWidth,
            height: size,
            child: Stack(
              children: [
                for (int i = 0; i < colors.length; i++)
                  Positioned(
                    left: i * overlapStep,
                    child: Container(
                      width: size,
                      height: size,
                      decoration: BoxDecoration(
                        color: colors[i],
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          if (extraCount > 0) ...[
            const SizedBox(width: 4),
            Container(
              width: size,
              height: size,
              decoration: const BoxDecoration(
                color: AppColors.primaryOrange,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '+$extraCount',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: size * 0.45,
                    fontWeight: FontWeight.w800,
                    height: 1.0,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Avatar group showing overlapping member avatars with optional "+N" overflow badge.
class AppAvatarGroup extends StatelessWidget {
  final List<String> names;
  final int maxVisible;
  final double avatarSize;

  const AppAvatarGroup({
    super.key,
    required this.names,
    this.maxVisible = 3,
    this.avatarSize = 32.0,
  });

  @override
  Widget build(BuildContext context) {
    final visibleNames = names.take(maxVisible).toList();
    final overflow = names.length - maxVisible;

    return SizedBox(
      height: avatarSize,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (int i = 0; i < visibleNames.length; i++)
            Transform.translate(
              offset: Offset(i * -8.0, 0),
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.white, width: 2),
                ),
                child: AppAvatar(
                  name: visibleNames[i],
                  type: AppAvatarType.initials,
                  size: avatarSize,
                  backgroundColor: AppColors.primaryOrange,
                ),
              ),
            ),
          if (overflow > 0)
            Transform.translate(
              offset: Offset(visibleNames.length * -8.0, 0),
              child: Container(
                width: avatarSize,
                height: avatarSize,
                decoration: BoxDecoration(
                  color: AppColors.chucky,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.white, width: 2),
                ),
                child: Center(
                  child: Text(
                    '+$overflow',
                    style: TextStyle(
                      color: AppColors.white,
                      fontSize: avatarSize * 0.35,
                      fontWeight: FontWeight.bold,
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
