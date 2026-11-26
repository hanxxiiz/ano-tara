import 'package:flutter/material.dart';

import '../../../../components/atoms/app_button.dart';
import '../../../../components/organisms/app_top_bar.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../models/member_preferences.dart';
import '../../data/profile_repository.dart';
import '../widgets/preference_category.dart';

const preferencePagePadding = EdgeInsets.fromLTRB(26, 24, 26, 32);

/// Divider under the top bar, as in the Figma screens.
class PreferenceBarDivider extends StatelessWidget {
  const PreferenceBarDivider({super.key});

  @override
  Widget build(BuildContext context) =>
      const Divider(height: 1, thickness: 1, color: AppColors.secondaryDark);
}

/// Save Changes + Cancel pair at the bottom of every edit screen.
class PreferenceEditActions extends StatelessWidget {
  const PreferenceEditActions({
    super.key,
    required this.saving,
    required this.onSave,
  });

  final bool saving;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppButton(
          key: const ValueKey('pref-save'),
          text: 'Save Changes',
          borderRadius: 16,
          customHeight: 53,
          isLoading: saving,
          onPressed: onSave,
        ),
        const SizedBox(height: 15),
        AppButton(
          key: const ValueKey('pref-cancel'),
          text: 'Cancel',
          variant: AppButtonVariant.secondary,
          borderRadius: 16,
          customHeight: 50,
          isDisabled: saving,
          onPressed: () => Navigator.of(context).pop(false),
        ),
      ],
    );
  }
}

/// 12.02 / 12.04 / 12.06 — read-only view with an Edit pill.
class PreferenceViewScreen extends StatelessWidget {
  const PreferenceViewScreen({
    super.key,
    required this.category,
    this.repository,
  });

  final PreferenceCategory category;
  final ProfileRepository? repository;

  ProfileRepository get _repo => repository ?? ProfileRepository.instance;

  void _edit(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) =>
            PreferenceEditScreen(category: category, repository: _repo),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppTopBar(
        title: category.title,
        actions: [PreferenceEditPill(onTap: () => _edit(context))],
      ),
      body: Column(
        children: [
          const PreferenceBarDivider(),
          Expanded(
            child: ValueListenableBuilder<MemberPreferences>(
              valueListenable: _repo.preferences,
              builder: (context, prefs, _) => ListView(
                padding: preferencePagePadding,
                children: [
                  PreferenceQuestion(category: category),
                  const SizedBox(height: 28),
                  PreferenceTileGrid(
                    category: category,
                    selected: category.selectedLabels(prefs),
                  ),
                  const SizedBox(height: 17),
                  PreferenceSpecifyBox(text: category.otherText(prefs)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 12.03 / 12.05 / 12.07 — tile picker with Save Changes and Cancel.
class PreferenceEditScreen extends StatefulWidget {
  const PreferenceEditScreen({
    super.key,
    required this.category,
    this.repository,
  });

  final PreferenceCategory category;
  final ProfileRepository? repository;

  @override
  State<PreferenceEditScreen> createState() => _PreferenceEditScreenState();
}

class _PreferenceEditScreenState extends State<PreferenceEditScreen> {
  late final ProfileRepository _repo =
      widget.repository ?? ProfileRepository.instance;
  late final Set<String> _selected;
  late final TextEditingController _other;
  bool _saving = false;

  PreferenceCategory get _category => widget.category;

  @override
  void initState() {
    super.initState();
    final prefs = _repo.preferences.value;
    _selected = _category.selectedLabels(prefs);
    _other = TextEditingController(text: _category.otherText(prefs));
  }

  @override
  void dispose() {
    _other.dispose();
    super.dispose();
  }

  void _toggle(String label) {
    setState(() {
      if (!_selected.remove(label)) _selected.add(label);
    });
  }

  Future<void> _save() async {
    FocusScope.of(context).unfocus();
    setState(() => _saving = true);
    final values = _category.collect(_selected, _other.text);
    final synced = await _repo.save(
      _category.write(_repo.preferences.value, values),
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          synced
              ? '${_category.title} updated.'
              : '${_category.title} saved on this device.',
        ),
      ),
    );
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final othersOn = _selected.contains(preferenceOthersLabel);
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppTopBar(title: _category.editTitle),
      body: Column(
        children: [
          const PreferenceBarDivider(),
          Expanded(
            child: ListView(
              padding: preferencePagePadding,
              children: [
                PreferenceQuestion(category: _category),
                const SizedBox(height: 28),
                PreferenceTileGrid(
                  category: _category,
                  selected: _selected,
                  onToggle: _toggle,
                ),
                const SizedBox(height: 17),
                PreferenceSpecifyBox(controller: _other, enabled: othersOn),
                const SizedBox(height: 30),
                PreferenceEditActions(saving: _saving, onSave: _save),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
