import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Unselected pill color in the step indicator.
const _pillIdle = Color(0xFFE9E6E6);

/// Border/placeholder color of the "Please specify..." boxes.
const _notesBorder = Color(0xFF868097);

/// Seven pills with the current step filled, plus "n/7" underneath.
class StepProgress extends StatelessWidget {
  const StepProgress({super.key, required this.current, required this.total});

  /// 1-based.
  final int current;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            for (var i = 1; i <= total; i++) ...[
              if (i > 1) const SizedBox(width: 8),
              Expanded(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  height: 10,
                  decoration: BoxDecoration(
                    color: i == current ? AppColors.ink : _pillIdle,
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(color: AppColors.ink),
                  ),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 8),
        Text(
          '$current/$total',
          style: const TextStyle(fontSize: 12, color: AppColors.ink),
        ),
      ],
    );
  }
}

class QuestionHeader extends StatelessWidget {
  const QuestionHeader({super.key, required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.ink,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 12, color: AppColors.ink, height: 1.4),
        ),
      ],
    );
  }
}

class ChoiceOption {
  const ChoiceOption(this.label, this.icon);

  final String label;
  final IconData icon;
}

/// 3-column grid of square icon tiles. Multi-select.
class ChoiceGrid extends StatelessWidget {
  const ChoiceGrid({
    super.key,
    required this.options,
    required this.selected,
    required this.onToggle,
    required this.selectedColor,
  });

  final List<ChoiceOption> options;
  final Set<String> selected;
  final ValueChanged<String> onToggle;
  final Color selectedColor;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 3,
      mainAxisSpacing: 9,
      crossAxisSpacing: 11,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        for (final option in options)
          _ChoiceTile(
            option: option,
            isSelected: selected.contains(option.label),
            selectedColor: selectedColor,
            onTap: () => onToggle(option.label),
          ),
      ],
    );
  }
}

class _ChoiceTile extends StatelessWidget {
  const _ChoiceTile({
    required this.option,
    required this.isSelected,
    required this.selectedColor,
    required this.onTap,
  });

  final ChoiceOption option;
  final bool isSelected;
  final Color selectedColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final foreground = isSelected ? Colors.white : AppColors.ink;
    final radius = BorderRadius.circular(16);

    return Semantics(
      selected: isSelected,
      button: true,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: radius,
          boxShadow: const [BoxShadow(color: AppColors.ink, offset: Offset(0, 2))],
        ),
        child: Material(
          color: isSelected ? selectedColor : Colors.white,
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
            borderRadius: radius,
            side: const BorderSide(color: AppColors.ink, width: 2),
          ),
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(6),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(option.icon, size: 40, color: foreground),
                  const SizedBox(height: 10),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      option.label,
                      maxLines: 1,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
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

/// Gray multi-line box used for "Please specify..." and the notes step.
class NotesField extends StatelessWidget {
  const NotesField({
    super.key,
    required this.controller,
    required this.hint,
    this.minLines = 6,
  });

  final TextEditingController controller;
  final String hint;
  final int minLines;

  @override
  Widget build(BuildContext context) {
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(15),
      borderSide: const BorderSide(color: _notesBorder, width: 2),
    );
    return TextField(
      controller: controller,
      minLines: minLines,
      maxLines: null,
      maxLength: 500,
      keyboardType: TextInputType.multiline,
      style: const TextStyle(fontSize: 14, color: AppColors.ink),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(fontSize: 14, color: _notesBorder),
        filled: true,
        fillColor: AppColors.field,
        contentPadding: const EdgeInsets.all(18),
        border: border,
        enabledBorder: border,
        focusedBorder: border.copyWith(
          borderSide: const BorderSide(color: AppColors.navy, width: 2),
        ),
      ),
    );
  }
}
