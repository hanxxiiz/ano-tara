import 'package:flutter/material.dart';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:anotara/main.dart';

import '../../models/member_preferences.dart';
import '../../services/preferences_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/auth_widgets.dart';
import '../../widgets/onboarding_widgets.dart';
import 'onboarding_steps.dart';

/// The 7-step onboarding questionnaire.
///
/// After sign up it ends at Home. With [editing] set, it loads the saved
/// answers first and pops back with `true` once they are saved.
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
  TravelPace? _pace;

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
      activityOptions.map((o) => o.label),
      _activities,
      _activitiesOther,
    );
    _restoreChoices(
      p.dietaryPreferences,
      dietaryOptions.map((o) => o.label),
      _dietary,
      _dietaryOther,
    );
    _restoreChoices(
      p.allergies,
      allergyOptions.map((o) => o.label),
      _allergies,
      _allergiesOther,
    );
    _budget = budgetStops.contains(p.budget) ? p.budget : 2000;
    _pace = TravelPace.values.where((v) => v.name == p.travelPace).firstOrNull;
    _days
      ..clear()
      ..addAll(p.availableDays.where(weekDays.contains));
    _notes.text = p.notes;
  }

  /// Saved values that aren't one of the preset labels came from "Others".
  void _restoreChoices(
    List<String> saved,
    Iterable<String> labels,
    Set<String> target,
    TextEditingController other,
  ) {
    final known = labels.toSet()..remove(othersLabel);
    final custom = saved.where((v) => !known.contains(v)).toList();
    target
      ..clear()
      ..addAll(saved.where(known.contains));
    if (custom.isNotEmpty) {
      target.add(othersLabel);
      other.text = custom.join(', ');
    }
  }

  List<String> _collect(Set<String> selected, TextEditingController other) {
    final values = selected.where((v) => v != othersLabel).toList();
    final custom = other.text.trim();
    if (selected.contains(othersLabel) && custom.isNotEmpty) values.add(custom);
    return values;
  }

  MemberPreferences _answers() => MemberPreferences(
    activities: _collect(_activities, _activitiesOther),
    dietaryPreferences: _collect(_dietary, _dietaryOther),
    allergies: _collect(_allergies, _allergiesOther),
    budget: _budget,
    travelPace: _pace?.name,
    availableDays: weekDays.where(_days.contains).toList(),
    notes: _notes.text.trim(),
  );

  void _toggle(Set<String> set, String value) {
    setState(() => set.contains(value) ? set.remove(value) : set.add(value));
  }

  /// Returns an error message if the current step can't be left yet.
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
    debugPrint('SENDING: ${_answers().toMap()}');
    try {
      await _service.save(_answers());
    } on NotSignedInException {
      _showMessage('Log in again to save your preferences.');
      if (mounted) setState(() => _saving = false);
      return;
    } catch (e) {
      debugPrint('SAVE FAILED: $e');
      _showMessage("Couldn't save your answers. Please try again.");
      if (mounted) setState(() => _saving = false);
      return;
    }
    // catch (_) {
    //   _showMessage("Couldn't save your answers. Please try again.");
    //   if (mounted) setState(() => _saving = false);
    //   return;
    // }

    if (!mounted) return;
    if (widget.editing) {
      _showMessage('Preferences updated.');
      Navigator.of(context).pop(true);
    } else {
      // Rebuilds AuthGate, which now finds saved preferences and shows Home.
      Navigator.of(context).pushNamedAndRemoveUntil('/', (_) => false);
    }
  }

  void _showMessage(String text) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      // Floats above the Next button so it never blocks it.
      ..showSnackBar(
        SnackBar(
          content: Text(text),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.fromLTRB(24, 0, 24, 96),
        ),
      );
  }

  Widget _currentStep() {
    return switch (_step) {
      0 => ChoiceStep.activities(
        selected: _activities,
        onToggle: (v) => _toggle(_activities, v),
        otherController: _activitiesOther,
      ),
      1 => ChoiceStep.dietary(
        selected: _dietary,
        onToggle: (v) => _toggle(_dietary, v),
        otherController: _dietaryOther,
      ),
      2 => ChoiceStep.allergies(
        selected: _allergies,
        onToggle: (v) => _toggle(_allergies, v),
        otherController: _allergiesOther,
      ),
      3 => BudgetStep(
        budget: _budget,
        onChanged: (v) => setState(() => _budget = v),
      ),
      4 => PaceStep(pace: _pace, onChanged: (v) => setState(() => _pace = v)),
      5 => DaysStep(selected: _days, onToggle: (v) => _toggle(_days, v)),
      _ => NotesStep(controller: _notes),
    };
  }

  @override
  Widget build(BuildContext context) {
    final canGoBack = _step > 0 || Navigator.of(context).canPop();
    final isLast = _step == _stepCount - 1;

    return PopScope(
      // System back moves to the previous question instead of leaving.
      canPop: _step == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _back();
      },
      child: Scaffold(
        body: SafeArea(
          child: _loading
              ? const Center(
                  child: CircularProgressIndicator(color: AppColors.ink),
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
                                  Icons.arrow_back,
                                  color: AppColors.ink,
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
                        label: isLast ? 'Finish' : 'Next',
                        loading: _saving,
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
