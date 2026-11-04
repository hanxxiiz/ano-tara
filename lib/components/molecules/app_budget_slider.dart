import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';

/// Custom thumb shape with white border ring and #0F0331 fill matching Figma.
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

    // Outer #0F0331 ring so the white ring has a crisp #0F0331 outline
    final Paint outerInkPaint = Paint()
      ..color = AppColors.secondaryDark
      ..style = PaintingStyle.fill;

    // White inner border ring
    final Paint borderPaint = Paint()
      ..color = AppColors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5;

    canvas.drawCircle(center, thumbRadius, outerInkPaint);
    canvas.drawCircle(center, thumbRadius - 3.0, borderPaint);
  }
}

/// Custom track shape whose visual pill bar aligns 100% flush with the display field edges
/// (0..parentBox.width), while keeping the thumb centers inset by [thumbRadius] so the thumb
/// never overhangs outside the field boundaries.
class _FlushSliderTrackShape extends SliderTrackShape {
  final double thumbRadius;

  const _FlushSliderTrackShape({this.thumbRadius = 18.0});

  @override
  Rect getPreferredRect({
    required RenderBox parentBox,
    Offset offset = Offset.zero,
    required SliderThemeData sliderTheme,
    bool isEnabled = false,
    bool isDiscrete = false,
  }) {
    final double trackHeight = sliderTheme.trackHeight ?? 22.0;
    final double trackLeft = offset.dx + thumbRadius;
    final double trackTop =
        offset.dy + (parentBox.size.height - trackHeight) / 2;
    final double trackWidth = parentBox.size.width - (thumbRadius * 2);
    return Rect.fromLTWH(trackLeft, trackTop, trackWidth, trackHeight);
  }

  @override
  void paint(
    PaintingContext context,
    Offset offset, {
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required Animation<double> enableAnimation,
    required Offset thumbCenter,
    Offset? secondaryOffset,
    bool isEnabled = false,
    bool isDiscrete = false,
    required TextDirection textDirection,
  }) {
    final double trackHeight = sliderTheme.trackHeight ?? 22.0;
    final double trackTop =
        offset.dy + (parentBox.size.height - trackHeight) / 2;
    final Rect fullTrackRect = Rect.fromLTWH(
      offset.dx,
      trackTop,
      parentBox.size.width,
      trackHeight,
    );
    final RRect trackRRect = RRect.fromRectAndRadius(
      fullTrackRect,
      Radius.circular(trackHeight / 2),
    );

    final Paint trackPaint = Paint()
      ..color = AppColors.secondaryDark
      ..style = PaintingStyle.fill;

    context.canvas.drawRRect(trackRRect, trackPaint);
  }
}

/// Budget selector molecule featuring a prominent value card and step slider.
/// Uses #0F0331 (AppColors.secondaryDark) throughout and aligns the slider track,
/// thumb stops, and tick marks/labels flush with the display field above.
class AppBudgetSlider extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onIndexChanged;
  static const List<int> budgetSteps = [500, 1000, 2000, 5000, 10000];
  static const List<String> budgetLabels = [
    '500',
    '1,000',
    '2,000',
    '5,000',
    '10,000+',
  ];
  static const double _thumbRadius = 18.0;

  const AppBudgetSlider({
    super.key,
    required this.selectedIndex,
    required this.onIndexChanged,
  });

  String get formattedValue {
    if (selectedIndex >= budgetSteps.length - 1) {
      return 'P10,000+';
    }
    final num = budgetSteps[selectedIndex];
    return 'P${num.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Highlighted Display Card with 2px #0F0331 outline & hard drop shadow
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
          child: FittedBox(
            fit: BoxFit.scaleDown,
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
        ),

        const SizedBox(height: 28),

        // Custom Slider aligned flush with the display field above
        SizedBox(
          height: 36,
          child: SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 22.0,
              activeTrackColor: AppColors.secondaryDark,
              inactiveTrackColor: AppColors.secondaryDark,
              trackShape:
                  const _FlushSliderTrackShape(thumbRadius: _thumbRadius),
              thumbColor: AppColors.secondaryDark,
              overlayColor: Colors.transparent,
              overlayShape: SliderComponentShape.noOverlay,
              thumbShape:
                  const _AnoTaraSliderThumbShape(thumbRadius: _thumbRadius),
              tickMarkShape: SliderTickMarkShape.noTickMark,
            ),
            child: Slider(
              padding: EdgeInsets.zero,
              value: selectedIndex.clamp(0, budgetSteps.length - 1).toDouble(),
              min: 0,
              max: (budgetSteps.length - 1).toDouble(),
              divisions: budgetSteps.length - 1,
              onChanged: (val) => onIndexChanged(val.round()),
            ),
          ),
        ),

        const SizedBox(height: 8),

        // Vertical Tick Marks and Labels positioned at exact stop coordinates
        LayoutBuilder(
          builder: (context, constraints) {
            final double totalWidth = constraints.maxWidth;
            final double usableWidth = totalWidth - (_thumbRadius * 2);
            final int count = budgetLabels.length;

            return SizedBox(
              height: 40,
              width: totalWidth,
              child: Stack(
                clipBehavior: Clip.none,
                children: List.generate(count, (index) {
                  final double stopX =
                      _thumbRadius + usableWidth * (index / (count - 1));
                  const double itemWidth = 64.0;
                  final double rawLeft = stopX - (itemWidth / 2);
                  final double clampedLeft =
                      rawLeft.clamp(0.0, totalWidth - itemWidth);

                  return Positioned(
                    left: clampedLeft,
                    top: 0,
                    width: itemWidth,
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => onIndexChanged(index),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Align(
                            alignment: Alignment(
                              ((stopX - clampedLeft) / itemWidth) * 2 - 1,
                              0,
                            ),
                            child: Container(
                              width: 4,
                              height: 14,
                              decoration: BoxDecoration(
                                color: AppColors.secondaryDark,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Align(
                            alignment: Alignment(
                              ((stopX - clampedLeft) / itemWidth) * 2 - 1,
                              0,
                            ),
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                budgetLabels[index],
                                style: GoogleFonts.urbanist(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 13,
                                  color: AppColors.secondaryDark,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            );
          },
        ),
      ],
    );
  }
}
