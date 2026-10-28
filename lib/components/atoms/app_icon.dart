import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import 'iconsax_solid_paths.dart';

/// A02 Icons atom matching Figma "Icons" specification:
/// Single action or meaning • reused Iconsax components.
/// Directly renders all solid `Iconsax` (`*5`) glyphs from their exact
/// `iconsax.ttf` TrueType vector outlines via `CustomPaint`, bypassing
/// Android HarfBuzz text shaping bugs on Unicode Combining Marks
/// (`0x0300..0x036F`), Hebrew (`0x0590..0x05FF`), and Arabic (`0x0600..0x06FF`)
/// codepoints so every icon is 100% visible and dead-center on Android.
class AppIcon extends StatelessWidget {
  final IconData icon;
  final double size;
  final Color color;
  final String? label;

  const AppIcon(
    this.icon, {
    super.key,
    this.size = 22.0,
    this.color = AppColors.secondaryDark,
    this.label,
  });

  Widget _buildGlyph() {
    final family = icon.fontFamily?.toLowerCase();
    if (family == 'iconsax' && hasIconsaxSolidPath(icon.codePoint)) {
      return SizedBox(
        width: size,
        height: size,
        child: CustomPaint(
          painter: _IconsaxSolidGlyphPainter(
            codePoint: icon.codePoint,
            color: color,
          ),
        ),
      );
    }
    return Icon(icon, size: size, color: color);
  }

  @override
  Widget build(BuildContext context) {
    if (label == null) {
      return _buildGlyph();
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildGlyph(),
        const SizedBox(height: 6),
        Text(
          label!,
          style: AppTypography.caption.copyWith(
            color: AppColors.secondaryDark,
            fontSize: 10.5,
          ),
        ),
      ],
    );
  }
}

class _IconsaxSolidGlyphPainter extends CustomPainter {
  final int codePoint;
  final Color color;

  const _IconsaxSolidGlyphPainter({
    required this.codePoint,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final path = buildIconsaxSolidPath(codePoint, size);
    if (path == null) return;

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _IconsaxSolidGlyphPainter oldDelegate) =>
      oldDelegate.codePoint != codePoint || oldDelegate.color != color;
}
