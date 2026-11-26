import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../components/atoms/app_button.dart';
import '../../../../components/atoms/app_icon.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../data/profile_repository.dart';

const _ink = AppColors.secondaryDark;
const _hardShadow = [BoxShadow(color: _ink, offset: Offset(0, 4))];

/// Navy banner with the round avatar overlapping its bottom edge.
class ProfileHeader extends StatelessWidget {
  const ProfileHeader({super.key, required this.summary, this.onEditAvatar});

  final ProfileSummary summary;
  final VoidCallback? onEditAvatar;

  static const _bannerHeight = 135.0;
  static const _avatarSize = 121.0;
  static const _avatarTop = 39.0;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: _avatarTop + _avatarSize + 4,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.topCenter,
            children: [
              Container(
                height: _bannerHeight,
                decoration: const BoxDecoration(
                  color: AppColors.primaryNavy,
                  border: Border(bottom: BorderSide(color: _ink, width: 2)),
                ),
              ),
              Positioned(
                top: _avatarTop,
                child: SizedBox(
                  width: _avatarSize + 10,
                  height: _avatarSize,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      _Avatar(summary: summary, size: _avatarSize),
                      Positioned(
                        left: 95,
                        top: 77,
                        child: _EditAvatarButton(onTap: onEditAvatar),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          summary.fullName,
          textAlign: TextAlign.center,
          style: AppTypography.h4.copyWith(
            fontWeight: FontWeight.w700,
            color: const Color(0xFF18191F),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          '@${summary.username}',
          style: AppTypography.bodySmall.copyWith(fontSize: 11, color: _ink),
        ),
      ],
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.summary, required this.size});

  final ProfileSummary summary;
  final double size;

  @override
  Widget build(BuildContext context) {
    final url = summary.avatarUrl;
    final initials = summary.fullName
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty)
        .take(2)
        .map((p) => p[0].toUpperCase())
        .join();
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFFFFBD12),
        border: Border.all(color: _ink, width: 2),
        boxShadow: _hardShadow,
        image: url != null && url.isNotEmpty
            ? DecorationImage(image: NetworkImage(url), fit: BoxFit.cover)
            : null,
      ),
      alignment: Alignment.center,
      child: url != null && url.isNotEmpty
          ? null
          : Text(
              initials.isEmpty ? '?' : initials,
              style: AppTypography.h1.copyWith(fontSize: 40, color: _ink),
            ),
    );
  }
}

class _EditAvatarButton extends StatelessWidget {
  const _EditAvatarButton({this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Edit profile photo',
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFFD9D9D9),
            border: Border.all(color: _ink, width: 2),
            boxShadow: _hardShadow,
          ),
          alignment: Alignment.center,
          child: const AppIcon(Iconsax.edit_25, size: 17, color: _ink),
        ),
      ),
    );
  }
}

/// Trips | Groups | Active Trips card.
class ProfileStatsCard extends StatelessWidget {
  const ProfileStatsCard({super.key, required this.summary});

  final ProfileSummary summary;

  @override
  Widget build(BuildContext context) {
    Widget stat(String value, String label) => Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(value, style: AppTypography.h2.copyWith(height: 1.1)),
            const SizedBox(height: 4),
            Text(
              label,
              style: AppTypography.bodySmall.copyWith(
                fontSize: 12,
                color: _ink,
              ),
            ),
          ],
        ),
      ),
    );
    const divider = VerticalDivider(width: 2, thickness: 2, color: _ink);

    return Container(
      constraints: const BoxConstraints(minHeight: 66),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: _ink, width: 2),
        boxShadow: _hardShadow,
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            stat('${summary.trips}', 'Trips'),
            divider,
            stat('${summary.groups}', 'Groups'),
            divider,
            stat('${summary.activeTrips}', 'Active Trips'),
          ],
        ),
      ),
    );
  }
}

class ProfileSectionTitle extends StatelessWidget {
  const ProfileSectionTitle(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) =>
      Text(text, style: AppTypography.h4.copyWith(fontWeight: FontWeight.w700));
}

/// Yellow "Current Plan" card with the Manage Subscription button.
class CurrentPlanCard extends StatelessWidget {
  const CurrentPlanCard({
    super.key,
    required this.summary,
    this.onManageSubscription,
  });

  final ProfileSummary summary;
  final VoidCallback? onManageSubscription;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 22, 18, 22),
      decoration: BoxDecoration(
        color: AppColors.semanticYellow,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: _ink, width: 2),
        boxShadow: _hardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 57,
                height: 57,
                decoration: const BoxDecoration(
                  color: AppColors.primaryOrange,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: const AppIcon(
                  Iconsax.crown_15,
                  size: 30,
                  color: AppColors.semanticYellow,
                ),
              ),
              const SizedBox(width: 25),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      summary.planName,
                      style: AppTypography.titleLarge.copyWith(
                        color: AppColors.black,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Expires: ${summary.planExpires}',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.black,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (onManageSubscription != null) ...[
            const SizedBox(height: 22),
            AppButton(
              key: const ValueKey('manage-subscription'),
              text: 'Manage Subscription',
              customHeight: 39,
              borderRadius: 12,
              iconTrailing: const Icon(
                Iconsax.arrow_right_1,
                size: 18,
                color: AppColors.white,
              ),
              onPressed: onManageSubscription,
            ),
          ],
        ],
      ),
    );
  }
}

/// One row of the Preferences card.
class ProfilePreferenceItem {
  const ProfilePreferenceItem({
    required this.title,
    required this.value,
    this.icon,
    this.svgAsset,
    this.onTap,
  });

  final String title;
  final String value;
  final IconData? icon;
  final String? svgAsset;
  final VoidCallback? onTap;
}

class ProfilePreferencesCard extends StatelessWidget {
  const ProfilePreferencesCard({super.key, required this.items});

  final List<ProfilePreferenceItem> items;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _ink, width: 2),
        boxShadow: _hardShadow,
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: Colors.transparent,
        child: Column(
          children: [
            for (var i = 0; i < items.length; i++) ...[
              if (i > 0)
                const Divider(
                  height: 1,
                  thickness: 1,
                  color: Color(0xFFD9D9D9),
                ),
              _PreferenceRow(item: items[i]),
            ],
          ],
        ),
      ),
    );
  }
}

class _PreferenceRow extends StatelessWidget {
  const _PreferenceRow({required this.item});

  final ProfilePreferenceItem item;

  @override
  Widget build(BuildContext context) {
    final iconWidget = item.svgAsset != null
        ? SvgPicture.asset(
            item.svgAsset!,
            width: 26,
            height: 26,
            colorFilter: const ColorFilter.mode(
              AppColors.white,
              BlendMode.srcIn,
            ),
          )
        : AppIcon(
            item.icon ?? Iconsax.setting_25,
            size: 26,
            color: AppColors.white,
          );

    return InkWell(
      key: ValueKey('profile-pref-${item.title}'),
      onTap: item.onTap,
      child: SizedBox(
        height: 79,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 20, 0),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 46,
                decoration: BoxDecoration(
                  color: AppColors.primaryOrange,
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: iconWidget,
              ),
              const SizedBox(width: 21),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: AppTypography.titleLarge.copyWith(
                        color: AppColors.black,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.value,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.bodyMedium.copyWith(
                        fontSize: 13,
                        color: AppColors.black,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.chevron_right_rounded,
                size: 22,
                color: Color(0xFF1E1E1E),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
