import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../components/atoms/app_icon.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_preference_icons.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../models/member_preferences.dart';

/// Label of the tile that opens the "Please specify..." box.
const preferenceOthersLabel = 'Others';

/// One multi-select preference (activities, dietary, allergies) with the copy,
/// options and selected color used by its view and edit screens.
class PreferenceCategory {
  const PreferenceCategory._({
    required this.key,
    required this.title,
    required this.editTitle,
    required this.heading,
    required this.subtitle,
    required this.options,
    required this.selectedColor,
    required this.read,
    required this.write,
  });

  final String key;
  final String title;
  final String editTitle;
  final String heading;
  final String subtitle;
  final List<String> options;
  final Color selectedColor;
  final List<String> Function(MemberPreferences) read;
  final MemberPreferences Function(MemberPreferences, List<String>) write;

  static final activities = PreferenceCategory._(
    key: 'activities',
    title: 'Preferred Activities',
    editTitle: 'Edit Preferred Activities',
    heading: 'What kind of activities do you\nusually enjoy?',
    subtitle: 'Your favorite activities are highlighted below.',
    options: const [
      'Beaches',
      'Food Trips',
      'Sightseeing',
      'Hiking',
      'Museums',
      'Shopping',
      'Nightlife',
      'Nature Trips',
      preferenceOthersLabel,
    ],
    selectedColor: AppColors.secondaryDark,
    read: (p) => p.activities,
    write: (p, v) => p.copyWith(activities: v),
  );

  static final dietary = PreferenceCategory._(
    key: 'dietary',
    title: 'Dietary Preferences',
    editTitle: 'Edit Dietary Preference',
    heading: 'Do you have any dietary preferences?',
    subtitle: 'Choose the options that match how you eat.',
    options: const [
      'Gluten-free',
      'Vegan',
      'Pescatarian',
      'Keto',
      'Vegetarian',
      preferenceOthersLabel,
    ],
    selectedColor: AppColors.primaryNavy,
    read: (p) => p.dietaryPreferences,
    write: (p, v) => p.copyWith(dietaryPreferences: v),
  );

  static final allergies = PreferenceCategory._(
    key: 'allergies',
    title: 'Allergies',
    editTitle: 'Edit Allergies',
    heading:
        'Do you have any food allergies or restrictions\nwe should consider?',
    subtitle: 'Keep your group meals safe and worry-free.',
    options: const [
      'Seafood',
      'Peanuts',
      'Dairy',
      'Gluten',
      'Eggs',
      'Shellfish',
      'Soy',
      'Sesame',
      preferenceOthersLabel,
    ],
    selectedColor: AppColors.primaryOrange,
    read: (p) => p.allergies,
    write: (p, v) => p.copyWith(allergies: v),
  );

  Set<String> get _presets => options.toSet()..remove(preferenceOthersLabel);

  /// Saved values as tile labels; anything custom lights up "Others".
  Set<String> selectedLabels(MemberPreferences p) {
    final saved = read(p);
    return {
      ...saved.where(_presets.contains),
      if (saved.any((v) => !_presets.contains(v))) preferenceOthersLabel,
    };
  }

  /// Custom text saved through "Others", comma-joined.
  String otherText(MemberPreferences p) =>
      read(p).where((v) => !_presets.contains(v)).join(', ');

  /// Tile selection + "Others" text back into saved values, in tile order.
  List<String> collect(Set<String> selected, String other) => [
    ...options.where((o) => o != preferenceOthersLabel && selected.contains(o)),
    if (selected.contains(preferenceOthersLabel) && other.trim().isNotEmpty)
      other.trim(),
  ];
}

/// Icon for a preference tile: bundled SVG artwork when there is one.
class PreferenceTileIcon extends StatelessWidget {
  const PreferenceTileIcon({
    super.key,
    required this.label,
    required this.color,
    this.size = 44,
  });

  final String label;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    if (label == preferenceOthersLabel) {
      return AppIcon(Iconsax.add_circle5, size: size, color: color);
    }
    final asset = AppPreferenceIcons.assets[label];
    if (asset != null) {
      return SvgPicture.asset(
        asset,
        width: size,
        height: size,
        colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
      );
    }
    return Icon(Icons.park_rounded, size: size, color: color);
  }
}

/// 3-column grid of 98px rounded tiles. Read-only when [onToggle] is null.
class PreferenceTileGrid extends StatelessWidget {
  const PreferenceTileGrid({
    super.key,
    required this.category,
    required this.selected,
    this.onToggle,
  });

  final PreferenceCategory category;
  final Set<String> selected;
  final ValueChanged<String>? onToggle;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 3,
      mainAxisSpacing: 11,
      crossAxisSpacing: 13,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        for (final label in category.options)
          _PreferenceTile(
            key: ValueKey('pref-tile-$label'),
            label: label,
            isSelected: selected.contains(label),
            selectedColor: category.selectedColor,
            onTap: onToggle == null ? null : () => onToggle!(label),
          ),
      ],
    );
  }
}

class _PreferenceTile extends StatelessWidget {
  const _PreferenceTile({
    super.key,
    required this.label,
    required this.isSelected,
    required this.selectedColor,
    this.onTap,
  });

  final String label;
  final bool isSelected;
  final Color selectedColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final foreground = isSelected ? AppColors.white : AppColors.secondaryDark;
    final radius = BorderRadius.circular(15);
    return Semantics(
      button: onTap != null,
      selected: isSelected,
      label: label,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: radius,
          boxShadow: const [
            BoxShadow(color: AppColors.secondaryDark, offset: Offset(0, 2)),
          ],
        ),
        child: Material(
          color: isSelected ? selectedColor : AppColors.white,
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
            borderRadius: radius,
            side: const BorderSide(color: AppColors.secondaryDark, width: 2),
          ),
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    child: PreferenceTileIcon(label: label, color: foreground),
                  ),
                  const SizedBox(height: 10),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      label,
                      maxLines: 1,
                      style: AppTypography.titleLarge.copyWith(
                        fontSize: 14,
                        color: foreground,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Gray "Please specify..." box. Editable when [controller] is given.
class PreferenceSpecifyBox extends StatelessWidget {
  const PreferenceSpecifyBox({
    super.key,
    this.controller,
    this.text = '',
    this.enabled = true,
    this.height = 214,
    this.hint = 'Please specify...',
    this.maxLength = 300,
    this.fieldKey = const ValueKey('pref-specify'),
  });

  final TextEditingController? controller;
  final String text;
  final bool enabled;
  final double height;
  final String hint;
  final int maxLength;
  final Key fieldKey;

  static const _border = Color(0xFF868097);

  @override
  Widget build(BuildContext context) {
    final style = AppTypography.bodyMedium.copyWith(
      fontSize: 13,
      color: AppColors.secondaryDark,
    );
    final hintStyle = style.copyWith(color: _border);
    return Container(
      height: height,
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 14),
      decoration: BoxDecoration(
        color: AppColors.secondaryLight,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: _border, width: 2),
      ),
      child: controller == null
          ? Align(
              alignment: Alignment.topLeft,
              child: Text(
                text.isEmpty ? hint : text,
                style: text.isEmpty ? hintStyle : style,
              ),
            )
          : TextField(
              key: fieldKey,
              controller: controller,
              enabled: enabled,
              maxLines: null,
              expands: true,
              maxLength: maxLength,
              textAlignVertical: TextAlignVertical.top,
              style: style,
              decoration: InputDecoration(
                isCollapsed: true,
                border: InputBorder.none,
                counterText: '',
                hintText: enabled ? hint : 'Select "Others" to add your own',
                hintStyle: hintStyle,
              ),
            ),
    );
  }
}

/// Yellow "Edit" pill used in the top bar of the view screens.
class PreferenceEditPill extends StatelessWidget {
  const PreferenceEditPill({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(12);
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: radius,
          boxShadow: const [
            BoxShadow(color: AppColors.secondaryDark, offset: Offset(0, 2)),
          ],
        ),
        child: Material(
          color: AppColors.semanticYellow,
          shape: RoundedRectangleBorder(
            borderRadius: radius,
            side: const BorderSide(color: AppColors.secondaryDark, width: 2),
          ),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            key: const ValueKey('pref-edit'),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const AppIcon(
                    Iconsax.edit_25,
                    size: 16,
                    color: AppColors.secondaryDark,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Edit',
                    style: AppTypography.titleLarge.copyWith(fontSize: 13),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Centered bold question + small subtitle above the tile grid.
class PreferenceQuestion extends StatelessWidget {
  PreferenceQuestion({super.key, required PreferenceCategory category})
    : heading = category.heading,
      subtitle = category.subtitle;

  const PreferenceQuestion.text({
    super.key,
    required this.heading,
    required this.subtitle,
  });

  final String heading;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          heading,
          textAlign: TextAlign.center,
          style: AppTypography.h4.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 10),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: AppTypography.bodyMedium.copyWith(
            fontSize: 13,
            color: AppColors.secondaryDark,
          ),
        ),
      ],
    );
  }
}
