import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import '../../components/atoms/app_button.dart';
import '../../components/atoms/app_input_field.dart';
import '../../components/molecules/app_availability_pill.dart';
import '../../components/molecules/app_budget_slider.dart';
import '../../components/molecules/app_option_card.dart';
import '../../components/molecules/app_pace_card.dart';
import '../../components/molecules/step_progress.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import '../../models/member_preferences.dart';
import '../../services/preferences_service.dart';

const String _othersLabel = 'Others';

class _ChoiceItem {
  final String label;
  final IconData icon;
  const _ChoiceItem(this.label, this.icon);
}

const List<_ChoiceItem> _activityOptions = [
  _ChoiceItem('Beaches & Islands', Iconsax.sun_1),
  _ChoiceItem('Nature', Iconsax.tree),
  _ChoiceItem('Cafes', Iconsax.coffee),
  _ChoiceItem('Local Food & Markets', Iconsax.shop),
  _ChoiceItem('Shopping', Iconsax.shopping_bag),
  _ChoiceItem('Nightlife & Bars', Iconsax.music),
  _ChoiceItem('Cultural & Historical Sites', Iconsax.bank),
  _ChoiceItem('Museums', Iconsax.courthouse),
  _ChoiceItem('Adventure', Iconsax.flash_1),
  _ChoiceItem('Hiking', Iconsax.routing_2),
  _ChoiceItem('Relaxation & Wellness', Iconsax.heart),
  _ChoiceItem('Scenic Spots', Iconsax.camera),
  _ChoiceItem('Theme Parks', Iconsax.ticket_star),
  _ChoiceItem('Water Activities', Iconsax.wind_2),
  _ChoiceItem(_othersLabel, Iconsax.more_circle),
];

const List<_ChoiceItem> _dietaryOptions = [
  _ChoiceItem('Halal', Iconsax.verify),
  _ChoiceItem('Vegetarian', Iconsax.unlimited),
  _ChoiceItem('Vegan', Iconsax.tree),
  _ChoiceItem('Pescatarian', Iconsax.drop),
  _ChoiceItem('No Pork', Iconsax.slash),
  _ChoiceItem('No Beef', Iconsax.slash),
  _ChoiceItem('Gluten-Free', Iconsax.forbidden_2),
  _ChoiceItem('Dairy-Free', Iconsax.milk),
  _ChoiceItem(_othersLabel, Iconsax.more_circle),
];

const List<_ChoiceItem> _allergyOptions = [
  _ChoiceItem('Peanuts', Iconsax.danger),
  _ChoiceItem('Tree Nuts', Iconsax.tree),
  _ChoiceItem('Seafood', Iconsax.drop),
  _ChoiceItem('Shellfish', Iconsax.warning_2),
  _ChoiceItem('Eggs', Iconsax.record_circle),
  _ChoiceItem('Milk', Iconsax.milk),
  _ChoiceItem('Soy', Iconsax.cup),
  _ChoiceItem('Wheat', Iconsax.forbidden_2),
  _ChoiceItem(_othersLabel, Iconsax.more_circle),
];

const List<int> _budgetStops = [500, 1000, 2000, 5000, 10000];

const List<String> _weekDays = [
  'Monday',
  'Tuesday',
  'Wednesday',
  'Thursday',
  'Friday',
  'Saturday',
  'Sunday',
];

enum _TravelPace {
  relaxed('Relaxed', 'Slow days, plenty of downtime, 1-2 main activities', Iconsax.coffee),
  balanced('Balanced', 'A mix of planned activities and free time', Iconsax.weight),
  packed('Packed', 'Full days, see and do as much as possible', Iconsax.flash_1);

  const _TravelPace(this.title, this.subtitle, this.icon);
  final String title;
  final String subtitle;
  final IconData icon;
}

/// The 7-step onboarding questionnaire using Atomic Design components.
class OnboardingFlow extends StatefulWidget {
  const OnboardingFlow({super.key, this.editing = false, this.service});

  final bool editing;
  final PreferencesService? service;

  @override
  State<OnboardingFlow> createState() => _OnboardingFlowState();
}

class _OnboardingFlowState extends State<OnboardingFlow> {
  static const _stepCount = 7;

  late final PreferencesService _service =
      widget.service ?? PreferencesService();

  int _step = 0;
  bool _loading = false;
  bool _saving = false;

  final _activities = <String>{};
  final _dietary = <String>{};
  final _allergies = <String>{};
  final _days = <String>{};
  int _budget = 2000;
  _TravelPace? _pace;

  final _activitiesOther = TextEditingController();
  final _dietaryOther = TextEditingController();
  final _allergiesOther = TextEditingController();
  final _notes = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.editing) _loadSaved();
  }

  @override
  void dispose() {
    _activitiesOther.dispose();
    _dietaryOther.dispose();
    _allergiesOther.dispose();
    _notes.dispose();
    super.dispose();
  }

  Future<void> _loadSaved() async {
    setState(() => _loading = true);
    try {
      final saved = await _service.load();
      if (saved != null && mounted) setState(() => _apply(saved));
    } catch (_) {
      _showMessage("Couldn't load your saved preferences.");
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _apply(MemberPreferences p) {
    _restoreChoices(
      p.activities,
      _activityOptions.map((o) => o.label),
      _activities,
      _activitiesOther,
    );
    _restoreChoices(
      p.dietaryPreferences,
      _dietaryOptions.map((o) => o.label),
      _dietary,
      _dietaryOther,
    );
    _restoreChoices(
      p.allergies,
      _allergyOptions.map((o) => o.label),
      _allergies,
      _allergiesOther,
    );
    _budget = _budgetStops.contains(p.budget) ? p.budget : 2000;
    _pace = _TravelPace.values.where((v) => v.name == p.travelPace).firstOrNull;
    _days
      ..clear()
      ..addAll(p.availableDays.where(_weekDays.contains));
    _notes.text = p.notes;
  }

  void _restoreChoices(
    List<String> saved,
    Iterable<String> labels,
    Set<String> target,
    TextEditingController other,
  ) {
    final known = labels.toSet()..remove(_othersLabel);
    final custom = saved.where((v) => !known.contains(v)).toList();
    target
      ..clear()
      ..addAll(saved.where(known.contains));
    if (custom.isNotEmpty) {
      target.add(_othersLabel);
      other.text = custom.join(', ');
    }
  }

  List<String> _collect(Set<String> selected, TextEditingController other) {
    final values = selected.where((v) => v != _othersLabel).toList();
    final custom = other.text.trim();
    if (selected.contains(_othersLabel) && custom.isNotEmpty) values.add(custom);
    return values;
  }

  MemberPreferences _answers() => MemberPreferences(
    activities: _collect(_activities, _activitiesOther),
    dietaryPreferences: _collect(_dietary, _dietaryOther),
    allergies: _collect(_allergies, _allergiesOther),
    budget: _budget,
    travelPace: _pace?.name,
    availableDays: _weekDays.where(_days.contains).toList(),
    notes: _notes.text.trim(),
  );

  void _toggle(Set<String> set, String value) {
    setState(() => set.contains(value) ? set.remove(value) : set.add(value));
  }

  String? _stepError() {
    switch (_step) {
      case 0:
        if (_activities.isEmpty) return 'Pick at least one activity.';
      case 4:
        if (_pace == null) return 'Choose a travel pace.';
      case 5:
        if (_days.isEmpty) return 'Pick at least one day.';
    }
    return null;
  }

  void _next() {
    final error = _stepError();
    if (error != null) {
      _showMessage(error);
      return;
    }
    FocusScope.of(context).unfocus();
    if (_step < _stepCount - 1) {
      setState(() => _step++);
    } else {
      _finish();
    }
  }

  void _back() {
    FocusScope.of(context).unfocus();
    if (_step > 0) {
      setState(() => _step--);
    } else {
      Navigator.of(context).maybePop();
    }
  }

  Future<void> _finish() async {
    setState(() => _saving = true);
    try {
      await _service.save(_answers());
    } on NotSignedInException {
      _showMessage('Log in again to save your preferences.');
      if (mounted) setState(() => _saving = false);
      return;
    } catch (_) {
      _showMessage("Couldn't save your answers. Please try again.");
      if (mounted) setState(() => _saving = false);
      return;
    }

    if (!mounted) return;
    if (widget.editing) {
      _showMessage('Preferences updated.');
      Navigator.of(context).pop(true);
    } else {
      Navigator.of(context).pushNamedAndRemoveUntil('/home', (_) => false);
    }
  }

  void _showMessage(String text) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(text),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.fromLTRB(24, 0, 24, 96),
        ),
      );
  }

  Widget _buildHeader(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTypography.h2.copyWith(color: AppColors.secondaryDark),
        ),
        const SizedBox(height: 6),
        Text(
          subtitle,
          style: AppTypography.bodyMedium.copyWith(color: AppColors.secondaryDark),
        ),
      ],
    );
  }

  Widget _buildChoiceStep({
    required String title,
    required String subtitle,
    required List<_ChoiceItem> options,
    required Set<String> selected,
    required ValueChanged<String> onToggle,
    required TextEditingController otherController,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildHeader(title, subtitle),
        const SizedBox(height: 22),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: options.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 14,
            crossAxisSpacing: 12,
            mainAxisExtent: 92,
          ),
          itemBuilder: (_, index) {
            final item = options[index];
            return AppOptionCard(
              label: item.label,
              icon: item.icon,
              isSelected: selected.contains(item.label),
              onTap: () => onToggle(item.label),
            );
          },
        ),
        if (selected.contains(_othersLabel)) ...[
          const SizedBox(height: 16),
          AppInputField(
            label: 'Please specify',
            controller: otherController,
          ),
        ],
      ],
    );
  }

  Widget _buildBudgetStep() {
    final stepIndex = _budgetStops.indexOf(_budget).clamp(0, _budgetStops.length - 1);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildHeader(
          "What's your comfortable per-trip budget?",
          'Drag the slider or tap a preset amount.',
        ),
        const SizedBox(height: 24),
        AppBudgetSlider(
          selectedIndex: stepIndex,
          onIndexChanged: (idx) {
            setState(() => _budget = _budgetStops[idx]);
          },
        ),
      ],
    );
  }

  Widget _buildPaceStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildHeader(
          'What travel pace do you prefer?',
          'Choose how you like your days structured.',
        ),
        const SizedBox(height: 22),
        for (final p in _TravelPace.values) ...[
          AppPaceCard(
            title: p.title,
            description: p.subtitle,
            icon: p.icon,
            isSelected: _pace == p,
            onTap: () => setState(() => _pace = p),
          ),
          const SizedBox(height: 14),
        ],
      ],
    );
  }

  Widget _buildDaysStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildHeader(
          'Which days are you usually free to travel?',
          'Select all days that generally work for you.',
        ),
        const SizedBox(height: 22),
        for (final day in _weekDays) ...[
          AppAvailabilityPill(
            day: day,
            isSelected: _days.contains(day),
            onTap: () => _toggle(_days, day),
          ),
          const SizedBox(height: 12),
        ],
      ],
    );
  }

  Widget _buildNotesStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildHeader(
          'Anything else your group should know?',
          'Share preferences, constraints, or travel notes (optional).',
        ),
        const SizedBox(height: 22),
        AppInputField(
          controller: _notes,
          hint: 'Write your notes here...',
          maxLines: 5,
        ),
      ],
    );
  }

  Widget _currentStep() {
    return switch (_step) {
      0 => _buildChoiceStep(
          title: 'What kind of activities do you enjoy on trips?',
          subtitle: 'Pick all that apply so we can tailor recommendations.',
          options: _activityOptions,
          selected: _activities,
          onToggle: (v) => _toggle(_activities, v),
          otherController: _activitiesOther,
        ),
      1 => _buildChoiceStep(
          title: 'Do you have any dietary preferences?',
          subtitle: 'Select any that apply (optional).',
          options: _dietaryOptions,
          selected: _dietary,
          onToggle: (v) => _toggle(_dietary, v),
          otherController: _dietaryOther,
        ),
      2 => _buildChoiceStep(
          title: 'Do you have any food allergies?',
          subtitle: 'Let your group know ahead of time (optional).',
          options: _allergyOptions,
          selected: _allergies,
          onToggle: (v) => _toggle(_allergies, v),
          otherController: _allergiesOther,
        ),
      3 => _buildBudgetStep(),
      4 => _buildPaceStep(),
      5 => _buildDaysStep(),
      _ => _buildNotesStep(),
    };
  }

  @override
  Widget build(BuildContext context) {
    final canGoBack = _step > 0 || Navigator.of(context).canPop();
    final isLast = _step == _stepCount - 1;

    return PopScope(
      canPop: _step == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _back();
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: _loading
              ? const Center(
                  child: CircularProgressIndicator(color: AppColors.secondaryDark),
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(
                      height: 48,
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: canGoBack
                            ? IconButton(
                                tooltip: 'Back',
                                onPressed: _back,
                                icon: const Icon(
                                  Iconsax.arrow_left,
                                  color: AppColors.secondaryDark,
                                ),
                              )
                            : null,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 52),
                      child: StepProgress(
                        current: _step + 1,
                        total: _stepCount,
                      ),
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(26, 24, 26, 24),
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 200),
                          child: KeyedSubtree(
                            key: ValueKey(_step),
                            child: _currentStep(),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                      child: AppButton(
                        text: isLast ? 'Finish' : 'Next',
                        isLoading: _saving,
                        onPressed: _next,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
