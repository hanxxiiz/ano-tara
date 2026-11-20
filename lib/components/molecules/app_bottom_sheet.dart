import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';

/// Opens [builder] as a modal sheet; the builder should return an [AppBottomSheet].
Future<T?> showAppBottomSheet<T>(
  BuildContext context, {
  required WidgetBuilder builder,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    barrierColor: AppColors.secondaryDark.withValues(alpha: 0.45),
    builder: builder,
  );
}

/// Bottom sheet frame matching Figma group sheets (05.10, 05.14, 05.17, 05.19):
/// Recipe: Drag handle + optional marker title + close button + content.
class AppBottomSheet extends StatelessWidget {
  final String? title;
  final bool showTitleMarker;
  final Widget child;

  const AppBottomSheet({
    super.key,
    this.title,
    this.showTitleMarker = true,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
        border: Border(
          top: BorderSide(color: AppColors.secondaryDark, width: 2),
          left: BorderSide(color: AppColors.secondaryDark, width: 2),
          right: BorderSide(color: AppColors.secondaryDark, width: 2),
        ),
      ),
      padding: EdgeInsets.fromLTRB(20, 16, 20, 20 + bottomInset),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 45,
                height: 5,
                decoration: BoxDecoration(
                  color: AppColors.secondaryDark,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                if (title != null) ...[
                  if (showTitleMarker) ...[
                    const _TitleMarker(height: 26),
                    const SizedBox(width: 12),
                  ],
                  Expanded(
                    child: Text(
                      title!,
                      style: AppTypography.h3.copyWith(
                        fontWeight: FontWeight.w800,
                        color: AppColors.secondaryDark,
                      ),
                    ),
                  ),
                ] else
                  const Spacer(),
                const AppSheetCloseButton(),
              ],
            ),
            Flexible(child: child),
          ],
        ),
      ),
    );
  }
}

/// Section heading inside a sheet: yellow marker + bold label.
class AppSheetSectionTitle extends StatelessWidget {
  final String title;

  const AppSheetSectionTitle(this.title, {super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const _TitleMarker(height: 14),
        const SizedBox(width: 10),
        Text(
          title,
          style: AppTypography.titleLarge.copyWith(
            color: AppColors.secondaryDark,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

/// 34px square close action used in every group sheet header.
class AppSheetCloseButton extends StatelessWidget {
  const AppSheetCloseButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Close',
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => Navigator.of(context).maybePop(),
        child: SizedBox(
          width: 44,
          height: 44,
          child: Center(
            child: Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.secondaryDark, width: 1.7),
                boxShadow: const [
                  BoxShadow(
                    color: AppColors.secondaryDark,
                    offset: Offset(0, 2),
                    blurRadius: 0,
                  ),
                ],
              ),
              child: const Icon(
                Icons.close_rounded,
                size: 18,
                color: AppColors.secondaryDark,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TitleMarker extends StatelessWidget {
  final double height;

  const _TitleMarker({required this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 3.5,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.semanticYellow,
        borderRadius: BorderRadius.circular(2),
        border: Border.all(color: AppColors.secondaryDark, width: 0.8),
      ),
    );
  }
}
