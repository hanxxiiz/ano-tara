import 'package:flutter/material.dart';

import '../../models/member_preferences.dart';
import '../../theme/app_theme.dart';
import '../../widgets/onboarding_widgets.dart';

const othersLabel = 'Others';

const activityOptions = [
  ChoiceOption('Beaches', Icons.beach_access_rounded),
  ChoiceOption('Food Trips', Icons.restaurant_rounded),
  ChoiceOption('Sightseeing', Icons.visibility_rounded),
  ChoiceOption('Hiking', Icons.terrain_rounded),
  ChoiceOption('Museums', Icons.museum_rounded),
  ChoiceOption('Shopping', Icons.shopping_bag_rounded),
  ChoiceOption('Nightlife', Icons.nightlife_rounded),
  ChoiceOption('Nature Trips', Icons.park_rounded),
  ChoiceOption(othersLabel, Icons.add_circle_rounded),
];

const dietaryOptions = [
  ChoiceOption('Gluten-free', Icons.grass_rounded),
  ChoiceOption('Vegetarian', Icons.eco_rounded),
  ChoiceOption('Pescatarian', Icons.set_meal_rounded),
  ChoiceOption('Keto', Icons.egg_alt_rounded),
  ChoiceOption('Vegan', Icons.spa_rounded),
  ChoiceOption(othersLabel, Icons.add_circle_rounded),
];

const allergyOptions = [
  ChoiceOption('Seafood', Icons.set_meal_rounded),
  ChoiceOption('Peanuts', Icons.grain_rounded),
  ChoiceOption('Dairy', Icons.local_drink_rounded),
  ChoiceOption('Gluten', Icons.bakery_dining_rounded),
  ChoiceOption('Eggs', Icons.egg_rounded),
  ChoiceOption('Shellfish', Icons.water_rounded),
  ChoiceOption('Soy', Icons.eco_rounded),
  ChoiceOption('Sesame', Icons.scatter_plot_rounded),
  ChoiceOption(othersLabel, Icons.add_circle_rounded),
];

/// Budget stops shown under the slider. The last one means "10,000+".
const budgetStops = [500, 1000, 2000, 5000, 10000];

const weekDays = [
  'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday',
];

/// Selected tile color per step, as in the Figma screens.
const _activitySelected = AppColors.ink;
const _dietarySelected = AppColors.navy;
const _allergySelected = AppColors.accent;

/// Horizontal inset of the budget slider track; the tick labels use it too.
const _sliderOverlayRadius = 26.0;

/// Lighter orange used for unselected day chips.
const _dayIdle = Color(0xFFF0A492);

String formatPeso(int amount) {
  final digits = amount.toString().replaceAllMapped(
        RegExp(r'\B(?=(\d{3})+(?!\d))'),
        (_) => ',',
      );
  return amount >= budgetStops.last ? '₱$digits+' : '₱$digits';
}

/// Multi-select tile grid, with a "Please specify..." box when Others is on.
class ChoiceStep extends StatelessWidget {
  const ChoiceStep({
    super.key,
    required this.title,
    required this.options,
    required this.selected,
    required this.onToggle,
    required this.otherController,
    required this.selectedColor,
  });

  final String title;
  final List<ChoiceOption> options;
  final Set<String> selected;
  final ValueChanged<String> onToggle;
  final TextEditingController otherController;
  final Color selectedColor;

  factory ChoiceStep.activities({
    required Set<String> selected,
    required ValueChanged<String> onToggle,
    required TextEditingController otherController,
  }) =>
      ChoiceStep(
        title: 'What kind of activities do you enjoy\nmost when traveling?',
        options: activityOptions,
        selected: selected,
        onToggle: onToggle,
        otherController: otherController,
        selectedColor: _activitySelected,
      );

  factory ChoiceStep.dietary({
    required Set<String> selected,
    required ValueChanged<String> onToggle,
    required TextEditingController otherController,
  }) =>
      ChoiceStep(
        title: 'Do you have any dietary preferences?',
        options: dietaryOptions,
        selected: selected,
        onToggle: onToggle,
        otherController: otherController,
        selectedColor: _dietarySelected,
      );

  factory ChoiceStep.allergies({
    required Set<String> selected,
    required ValueChanged<String> onToggle,
    required TextEditingController otherController,
  }) =>
      ChoiceStep(
        title: 'Do you have any food allergies\nor restrictions?',
        options: allergyOptions,
        selected: selected,
        onToggle: onToggle,
        otherController: otherController,
        selectedColor: _allergySelected,
      );

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        QuestionHeader(title: title, subtitle: 'Select all that apply.'),
        const SizedBox(height: 30),
        ChoiceGrid(
          options: options,
          selected: selected,
          onToggle: onToggle,
          selectedColor: selectedColor,
        ),
        if (selected.contains(othersLabel)) ...[
          const SizedBox(height: 18),
          NotesField(controller: otherController, hint: 'Please specify...'),
        ],
      ],
    );
  }
}

class BudgetStep extends StatelessWidget {
  const BudgetStep({super.key, required this.budget, required this.onChanged});

  final int budget;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final index = budgetStops.indexOf(budget).clamp(0, budgetStops.length - 1);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const QuestionHeader(
          title: "What's your usual budget for a trip?",
          subtitle: 'Set your preferred budget range per person.',
        ),
        const SizedBox(height: 50),
        Container(
          height: 99,
          margin: const EdgeInsets.symmetric(horizontal: 33),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: const Color(0xFFD9D9D9),
            borderRadius: BorderRadius.circular(9),
            border: Border.all(color: AppColors.ink, width: 2),
            boxShadow: const [BoxShadow(color: AppColors.ink, offset: Offset(0, 4))],
          ),
          child: Text(
            formatPeso(budgetStops[index]),
            style: const TextStyle(
              fontSize: 40,
              fontWeight: FontWeight.w800,
              color: AppColors.ink,
            ),
          ),
        ),
        const SizedBox(height: 26),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            trackHeight: 27,
            activeTrackColor: AppColors.ink,
            inactiveTrackColor: AppColors.ink,
            activeTickMarkColor: Colors.transparent,
            inactiveTickMarkColor: Colors.transparent,
            thumbColor: AppColors.ink,
            overlayColor: AppColors.ink.withValues(alpha: 0.12),
            thumbShape: const _RingThumb(),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: _sliderOverlayRadius),
            padding: const EdgeInsets.symmetric(horizontal: _sliderOverlayRadius),
            trackShape: const RoundedRectSliderTrackShape(),
            showValueIndicator: ShowValueIndicator.never,
          ),
          child: Slider(
            value: index.toDouble(),
            min: 0,
            max: (budgetStops.length - 1).toDouble(),
            divisions: budgetStops.length - 1,
            semanticFormatterCallback: (v) => formatPeso(budgetStops[v.round()]),
            onChanged: (v) => onChanged(budgetStops[v.round()]),
          ),
        ),
        const SizedBox(height: 6),
        // Each tick sits under its slider stop. The slider insets its track by
        // the overlay radius on both sides.
        LayoutBuilder(
          builder: (context, constraints) {
            const inset = _sliderOverlayRadius;
            const labelWidth = 64.0;
            final step = (constraints.maxWidth - inset * 2) / (budgetStops.length - 1);
            return SizedBox(
              height: 46,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  for (var i = 0; i < budgetStops.length; i++)
                    Positioned(
                      left: inset + step * i - labelWidth / 2,
                      width: labelWidth,
                      child: GestureDetector(
                        onTap: () => onChanged(budgetStops[i]),
                        child: Column(
                          children: [
                            Container(
                              width: 3,
                              height: 14,
                              decoration: BoxDecoration(
                                color: AppColors.ink,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            const SizedBox(height: 14),
                            Text(
                              formatPeso(budgetStops[i]).substring(1),
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: AppColors.ink,
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

/// Dark thumb with a thick white ring, as in the budget slider design.
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
    canvas.drawCircle(center, _radius - 5, Paint()..color = AppColors.ink);
  }
}

class PaceStep extends StatelessWidget {
  const PaceStep({super.key, required this.pace, required this.onChanged});

  final TravelPace? pace;
  final ValueChanged<TravelPace> onChanged;

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
        const QuestionHeader(
          title: 'How do you usually like to travel?',
          subtitle: 'Choose the pace that suits you best.',
        ),
        const SizedBox(height: 30),
        for (final (value, title, description, icon) in _cards) ...[
          _PaceCard(
            title: title,
            description: description,
            icon: icon,
            isSelected: pace == value,
            onTap: () => onChanged(value),
          ),
          const SizedBox(height: 16),
        ],
      ],
    );
  }
}

class _PaceCard extends StatelessWidget {
  const _PaceCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  final String title;
  final String description;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(15);
    final foreground = isSelected ? Colors.white : AppColors.ink;

    return Semantics(
      selected: isSelected,
      button: true,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: radius,
          boxShadow: const [BoxShadow(color: AppColors.ink, offset: Offset(0, 4))],
        ),
        child: Material(
          color: isSelected ? AppColors.navy : Colors.white,
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
            borderRadius: radius,
            side: const BorderSide(color: AppColors.ink, width: 2),
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
                      color: AppColors.accent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(icon, color: Colors.white, size: 32),
                  ),
                  const SizedBox(width: 13),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: foreground,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          description,
                          style: TextStyle(fontSize: 12, color: foreground, height: 1.3),
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

class DaysStep extends StatelessWidget {
  const DaysStep({super.key, required this.selected, required this.onToggle});

  final Set<String> selected;
  final ValueChanged<String> onToggle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const QuestionHeader(
          title: 'When are you usually available\nfor travel?',
          subtitle: 'Select the days that generally work for you.',
        ),
        const SizedBox(height: 30),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 22,
          runSpacing: 20,
          children: [
            for (final day in weekDays)
              _DayChip(
                label: day,
                isSelected: selected.contains(day),
                onTap: () => onToggle(day),
              ),
          ],
        ),
      ],
    );
  }
}

class _DayChip extends StatelessWidget {
  const _DayChip({required this.label, required this.isSelected, required this.onTap});

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(16);
    return Semantics(
      selected: isSelected,
      button: true,
      child: Container(
        width: 137,
        height: 50,
        decoration: BoxDecoration(
          borderRadius: radius,
          boxShadow: const [BoxShadow(color: AppColors.ink, offset: Offset(0, 4))],
        ),
        child: Material(
          color: isSelected ? AppColors.accent : _dayIdle,
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
            borderRadius: radius,
            side: const BorderSide(color: AppColors.ink, width: 2),
          ),
          child: InkWell(
            onTap: onTap,
            child: Center(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class NotesStep extends StatelessWidget {
  const NotesStep({super.key, required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const QuestionHeader(
          title: 'Anything else we should keep in mind?',
          subtitle: 'Optional notes to further customize your suggestions.',
        ),
        const SizedBox(height: 40),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: NotesField(
            controller: controller,
            minLines: 16,
            hint: 'I prefer morning activities, avoid long travel times...',
          ),
        ),
      ],
    );
  }
}
