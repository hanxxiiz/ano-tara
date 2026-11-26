import 'package:flutter/material.dart';

import '../../../../components/organisms/app_top_bar.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../models/member_preferences.dart';
import '../../../../screens/onboarding/onboarding_steps.dart'
    show budgetStops, formatPeso;
import '../../data/profile_repository.dart';
import '../widgets/preference_category.dart';
import 'preference_screens.dart';

const _ink = AppColors.secondaryDark;
const _hardShadow = [BoxShadow(color: _ink, offset: Offset(0, 4))];
const _notesHint = 'I prefer morning activities, and I love cafes...';

/// Single-value preferences: budget (12.08/12.09), travel pace (12.10/12.11)
/// and additional notes (12.12/12.13).
enum PreferenceDetail {
  budget(
    title: 'Budget Preference',
    heading: "What's your usual budget for a trip or hangout?",
    subtitle: 'Update the amount you usually want to spend.',
  ),
  pace(
    title: 'Travel Pace',
    heading: 'How do you usually like to travel?',
    subtitle: 'Choose the pace that feels right to you.',
  ),
  notes(
    title: 'Additional Notes',
    heading: 'Anything else we should keep in mind\nwhen planning for you?',
    subtitle: 'Revise any details you want your group to know.',
  );

  const PreferenceDetail({
    required this.title,
    required this.heading,
    required this.subtitle,
  });

  final String title;
  final String heading;
  final String subtitle;

  String get editTitle => 'Edit $title';
}

/// Read-only view with the yellow Edit pill.
class PreferenceDetailViewScreen extends StatelessWidget {
  const PreferenceDetailViewScreen({
    super.key,
    required this.detail,
    this.repository,
  });

  final PreferenceDetail detail;
  final ProfileRepository? repository;

  ProfileRepository get _repo => repository ?? ProfileRepository.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppTopBar(
        title: detail.title,
        actions: [
          PreferenceEditPill(
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => PreferenceDetailEditScreen(
                  detail: detail,
                  repository: _repo,
                ),
              ),
            ),
          ),
        ],
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
                  PreferenceQuestion.text(
                    heading: detail.heading,
                    subtitle: detail.subtitle,
                  ),
                  const SizedBox(height: 30),
                  switch (detail) {
                    PreferenceDetail.budget => BudgetPreferencePicker(
                      budget: prefs.budget,
                    ),
                    PreferenceDetail.pace => TravelPacePicker(
                      pace: prefs.travelPace,
                    ),
                    PreferenceDetail.notes => PreferenceSpecifyBox(
                      text: prefs.notes,
                      height: 395,
                      hint: _notesHint,
                    ),
                  },
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Editable version with Save Changes and Cancel.
class PreferenceDetailEditScreen extends StatefulWidget {
  const PreferenceDetailEditScreen({
    super.key,
    required this.detail,
    this.repository,
  });

  final PreferenceDetail detail;
  final ProfileRepository? repository;

  @override
  State<PreferenceDetailEditScreen> createState() =>
      _PreferenceDetailEditScreenState();
}

class _PreferenceDetailEditScreenState
    extends State<PreferenceDetailEditScreen> {
  late final ProfileRepository _repo =
      widget.repository ?? ProfileRepository.instance;
  late int _budget;
  String? _pace;
  late final TextEditingController _notes;
  bool _saving = false;

  PreferenceDetail get _detail => widget.detail;

  @override
  void initState() {
    super.initState();
    final prefs = _repo.preferences.value;
    _budget = prefs.budget;
    _pace = prefs.travelPace;
    _notes = TextEditingController(text: prefs.notes);
  }

  @override
  void dispose() {
    _notes.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    FocusScope.of(context).unfocus();
    setState(() => _saving = true);
    final current = _repo.preferences.value;
    final updated = switch (_detail) {
      PreferenceDetail.budget => current.copyWith(budget: _budget),
      PreferenceDetail.pace => current.copyWith(travelPace: _pace),
      PreferenceDetail.notes => current.copyWith(notes: _notes.text.trim()),
    };
    final synced = await _repo.save(updated);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          synced
              ? '${_detail.title} updated.'
              : '${_detail.title} saved on this device.',
        ),
      ),
    );
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppTopBar(title: _detail.editTitle),
      body: Column(
        children: [
          const PreferenceBarDivider(),
          Expanded(
            child: ListView(
              padding: preferencePagePadding,
              children: [
                PreferenceQuestion.text(
                  heading: _detail.heading,
                  subtitle: _detail.subtitle,
                ),
                const SizedBox(height: 30),
                switch (_detail) {
                  PreferenceDetail.budget => BudgetPreferencePicker(
                    budget: _budget,
                    onChanged: (v) => setState(() => _budget = v),
                  ),
                  PreferenceDetail.pace => TravelPacePicker(
                    pace: _pace,
                    onChanged: (v) => setState(() => _pace = v),
                  ),
                  PreferenceDetail.notes => PreferenceSpecifyBox(
                    controller: _notes,
                    height: 395,
                    hint: _notesHint,
                    maxLength: 500,
                    fieldKey: const ValueKey('pref-notes'),
                  ),
                },
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

/// Amount box + 5-stop slider. Read-only when [onChanged] is null.
class BudgetPreferencePicker extends StatelessWidget {
  const BudgetPreferencePicker({
    super.key,
    required this.budget,
    this.onChanged,
  });

  final int budget;
  final ValueChanged<int>? onChanged;

  static const _inset = 26.0;

  int get _index {
    final exact = budgetStops.indexOf(budget);
    if (exact >= 0) return exact;
    var best = 0;
    for (var i = 1; i < budgetStops.length; i++) {
      if ((budgetStops[i] - budget).abs() <
          (budgetStops[best] - budget).abs()) {
        best = i;
      }
    }
    return best;
  }

  @override
  Widget build(BuildContext context) {
    final index = _index;
    final readOnly = onChanged == null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          height: 99,
          margin: const EdgeInsets.symmetric(horizontal: 24),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: const Color(0xFFD9D9D9),
            borderRadius: BorderRadius.circular(9),
            border: Border.all(color: _ink, width: 2),
            boxShadow: _hardShadow,
          ),
          child: Text(
            formatPeso(budgetStops[index]),
            key: const ValueKey('budget-amount'),
            style: AppTypography.h1.copyWith(
              fontSize: 40,
              fontWeight: FontWeight.w800,
              color: _ink,
            ),
          ),
        ),
        const SizedBox(height: 26),
        IgnorePointer(
          ignoring: readOnly,
          child: SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 27,
              activeTrackColor: _ink,
              inactiveTrackColor: _ink,
              activeTickMarkColor: Colors.transparent,
              inactiveTickMarkColor: Colors.transparent,
              thumbColor: _ink,
              overlayColor: _ink.withValues(alpha: 0.12),
              thumbShape: const _RingThumb(),
              overlayShape: const RoundSliderOverlayShape(
                overlayRadius: _inset,
              ),
              padding: const EdgeInsets.symmetric(horizontal: _inset),
              trackShape: const RoundedRectSliderTrackShape(),
              showValueIndicator: ShowValueIndicator.never,
            ),
            child: Slider(
              key: const ValueKey('budget-slider'),
              value: index.toDouble(),
              max: (budgetStops.length - 1).toDouble(),
              divisions: budgetStops.length - 1,
              semanticFormatterCallback: (v) =>
                  formatPeso(budgetStops[v.round()]),
              // A no-op keeps the enabled colors in read-only mode.
              onChanged: (v) => onChanged?.call(budgetStops[v.round()]),
            ),
          ),
        ),
        const SizedBox(height: 6),
        LayoutBuilder(
          builder: (context, constraints) {
            const labelWidth = 64.0;
            final step =
                (constraints.maxWidth - _inset * 2) / (budgetStops.length - 1);
            return SizedBox(
              height: 46,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  for (var i = 0; i < budgetStops.length; i++)
                    Positioned(
                      left: _inset + step * i - labelWidth / 2,
                      width: labelWidth,
                      child: GestureDetector(
                        key: ValueKey('budget-stop-${budgetStops[i]}'),
                        behavior: HitTestBehavior.opaque,
                        onTap: readOnly
                            ? null
                            : () => onChanged!(budgetStops[i]),
                        child: Column(
                          children: [
                            Container(
                              width: 3,
                              height: 14,
                              decoration: BoxDecoration(
                                color: _ink,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            const SizedBox(height: 14),
                            Text(
                              formatPeso(budgetStops[i]).substring(1),
                              style: AppTypography.bodySmall.copyWith(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: _ink,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}

/// Dark thumb with a thick white ring.
class _RingThumb extends SliderComponentShape {
  const _RingThumb();

  static const _radius = 22.5;

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) =>
      const Size.fromRadius(_radius);

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {
    final canvas = context.canvas;
    canvas.drawCircle(center, _radius, Paint()..color = Colors.white);
    canvas.drawCircle(center, _radius - 5, Paint()..color = _ink);
  }
}

/// Relaxed / Balanced / Packed cards. Read-only when [onChanged] is null.
class TravelPacePicker extends StatelessWidget {
  const TravelPacePicker({super.key, required this.pace, this.onChanged});

  /// A [TravelPace] name, or null.
  final String? pace;
  final ValueChanged<String>? onChanged;

  static const _cards = [
    (
      TravelPace.relaxed,
      'Relaxed',
      'Slow mornings, spontaneous plans, and plenty of time to unwind.',
      Icons.air_rounded,
    ),
    (
      TravelPace.balanced,
      'Balanced',
      'A healthy mix of activities and downtime to recharge.',
      Icons.hourglass_bottom_rounded,
    ),
    (
      TravelPace.packed,
      'Packed',
      'Make the most of every moment with a full itinerary.',
      Icons.timer_rounded,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final (value, title, description, icon) in _cards) ...[
          _PaceCard(
            key: ValueKey('pace-${value.name}'),
            title: title,
            description: description,
            icon: icon,
            isSelected: pace == value.name,
            onTap: onChanged == null ? null : () => onChanged!(value.name),
          ),
          const SizedBox(height: 16),
        ],
      ],
    );
  }
}

class _PaceCard extends StatelessWidget {
  const _PaceCard({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    required this.isSelected,
    this.onTap,
  });

  final String title;
  final String description;
  final IconData icon;
  final bool isSelected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(15);
    final foreground = isSelected ? AppColors.white : _ink;

    return Semantics(
      label: title,
      selected: isSelected,
      button: onTap != null,
      child: Container(
        decoration: BoxDecoration(borderRadius: radius, boxShadow: _hardShadow),
        child: Material(
          color: isSelected ? AppColors.primaryNavy : AppColors.white,
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
            borderRadius: radius,
            side: const BorderSide(color: _ink, width: 2),
          ),
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(11),
              child: Row(
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: AppColors.primaryOrange,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(icon, color: AppColors.white, size: 32),
                  ),
                  const SizedBox(width: 13),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: AppTypography.titleLarge.copyWith(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: foreground,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          description,
                          style: AppTypography.bodySmall.copyWith(
                            fontSize: 12,
                            height: 1.3,
                            color: foreground,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right_rounded, color: foreground),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
