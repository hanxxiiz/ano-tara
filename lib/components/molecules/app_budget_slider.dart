import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';

/// Custom thumb shape with white border ring matching Figma
class _AnoTaraSliderThumbShape extends SliderComponentShape {
  final double thumbRadius;

  const _AnoTaraSliderThumbShape({this.thumbRadius = 18.0});

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) {
    return Size.fromRadius(thumbRadius);
  }

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
    final Canvas canvas = context.canvas;

    // Outer white border ring
    final Paint borderPaint = Paint()
      ..color = AppColors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0;

    // Inner dark ink circle
    final Paint fillPaint = Paint()
      ..color = AppColors.secondaryDark
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, thumbRadius, fillPaint);
    canvas.drawCircle(center, thumbRadius - 2.0, borderPaint);
  }
}

/// Budget selector molecule featuring a prominent value card and step slider.
class AppBudgetSlider extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onIndexChanged;
  static const List<int> budgetSteps = [500, 1000, 2000, 5000, 10000];
  static const List<String> budgetLabels = ['500', '1,000', '2,000', '5,000', '10,000+'];

  const AppBudgetSlider({
    super.key,
    required this.selectedIndex,
    required this.onIndexChanged,
  });

  String get formattedValue {
    if (selectedIndex >= budgetSteps.length - 1) {
      return 'P 10.000+';
    }
    final num = budgetSteps[selectedIndex];
    return 'P ${num.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Highlighted Display Card with 2px Ink outline & hard drop shadow
        Container(
          width: double.infinity,
          height: 120,
          decoration: BoxDecoration(
            color: AppColors.secondaryLight,
            borderRadius: BorderRadius.circular(20.0),
            border: Border.all(
              color: AppColors.secondaryDark,
              width: 2.0,
            ),
            boxShadow: const [
              BoxShadow(
                color: AppColors.secondaryDark,
                offset: Offset(0, 4),
                blurRadius: 0,
              ),
            ],
          ),
          alignment: Alignment.center,
          child: Text(
            formattedValue,
            style: GoogleFonts.urbanist(
              color: AppColors.secondaryDark,
              fontSize: 38,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.5,
            ),
          ),
        ),

        const SizedBox(height: 36),

        // Custom Slider with thick ink bar
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            trackHeight: 22.0,
            activeTrackColor: AppColors.secondaryDark,
            inactiveTrackColor: AppColors.secondaryDark,
            trackShape: const RoundedRectSliderTrackShape(),
            thumbColor: AppColors.secondaryDark,
            overlayColor: Colors.transparent,
            thumbShape: const _AnoTaraSliderThumbShape(thumbRadius: 18.0),
            tickMarkShape: SliderTickMarkShape.noTickMark,
          ),
          child: Slider(
            value: selectedIndex.toDouble(),
            min: 0,
            max: (budgetSteps.length - 1).toDouble(),
            divisions: budgetSteps.length - 1,
            onChanged: (val) => onIndexChanged(val.round()),
          ),
        ),

        const SizedBox(height: 12),

        // Vertical Tick Marks and Labels Below
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: List.generate(budgetLabels.length, (index) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 4,
                    height: 14,
                    decoration: BoxDecoration(
                      color: AppColors.secondaryDark,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    budgetLabels[index],
                    style: GoogleFonts.urbanist(
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                      color: AppColors.secondaryDark,
                    ),
                  ),
                ],
              );
            }),
          ),
        ),
      ],
    );
  }
}
