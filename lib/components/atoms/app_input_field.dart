import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';

/// Input field atom matching Ano Tara Atomic Design ("01 Atoms - Text inputs"):
/// Uses OutlineInputBorder with 20px rounded corners, solid 2px Dark Ink (#0F0331) or Error Orange (#E24B27) border,
/// and smooth neutral fill (#E6E3DF). Supports default, disabled, loading, and error states.
class AppInputField extends StatelessWidget {
  final String? label;
  final String? hint;
  final String? errorText;
  final bool showErrorCaption;
  final String? helperText;
  final TextEditingController? controller;
  final TextInputType keyboardType;
  final bool isPassword;
  final bool isEnabled;
  final bool isLoading;
  final bool isReadOnly;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final int minLines;
  final int maxLines;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onTap;
  final FormFieldValidator<String>? validator;

  const AppInputField({
    super.key,
    this.label,
    this.hint,
    this.errorText,
    this.showErrorCaption = true,
    this.helperText,
    this.controller,
    this.keyboardType = TextInputType.text,
    this.isPassword = false,
    this.isEnabled = true,
    this.isLoading = false,
    this.isReadOnly = false,
    this.prefixIcon,
    this.suffixIcon,
    this.minLines = 1,
    this.maxLines = 1,
    this.onChanged,
    this.onTap,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    final bool hasError = errorText != null && errorText!.isNotEmpty;
    final bool effectivelyEnabled = isEnabled && !isLoading;

    final outlineBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(20.0),
      borderSide: BorderSide(
        color: hasError
            ? AppColors.primaryOrange
            : (effectivelyEnabled ? AppColors.secondaryDark : AppColors.shayne),
        width: 2.0,
      ),
    );

    final Widget? effectiveSuffix = isLoading
        ? const Padding(
            padding: EdgeInsets.all(12.0),
            child: SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2.0,
                color: AppColors.primaryNavy,
              ),
            ),
          )
        : suffixIcon;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: GoogleFonts.urbanist(
              fontSize: 14.0,
              fontWeight: FontWeight.w700,
              color: effectivelyEnabled ? AppColors.secondaryDark : AppColors.shayne,
            ),
          ),
          const SizedBox(height: 6),
        ],
        ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 48.0),
          child: TextFormField(
            controller: controller,
            enabled: effectivelyEnabled,
            readOnly: isReadOnly,
            obscureText: isPassword,
            keyboardType: keyboardType,
            minLines: isPassword ? 1 : minLines,
            maxLines: isPassword ? 1 : maxLines,
            textAlignVertical: TextAlignVertical.center,
            onChanged: onChanged,
            onTap: onTap,
            validator: validator,
            style: GoogleFonts.urbanist(
              fontSize: 15.0,
              fontWeight: FontWeight.w600,
              color: hasError ? AppColors.primaryOrange : AppColors.secondaryDark,
            ),
            cursorColor: AppColors.secondaryDark,
            cursorHeight: 20.0,
            decoration: InputDecoration(
              isDense: true,
              filled: true,
              fillColor: effectivelyEnabled ? AppColors.secondaryLight : AppColors.surfaceLight,
              hintText: hint,
              hintStyle: GoogleFonts.urbanist(
                fontSize: 14.0,
                fontWeight: FontWeight.w500,
                color: hasError ? AppColors.primaryOrange : AppColors.shayne,
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              border: outlineBorder,
              enabledBorder: outlineBorder,
              focusedBorder: outlineBorder,
              errorBorder: outlineBorder,
              focusedErrorBorder: outlineBorder,
              disabledBorder: outlineBorder,
              prefixIcon: prefixIcon,
              prefixIconConstraints: const BoxConstraints(minWidth: 44, minHeight: 44),
              suffixIcon: effectiveSuffix,
              suffixIconConstraints: const BoxConstraints(minWidth: 44, minHeight: 44),
            ),
          ),
        ),
        if (hasError && showErrorCaption) ...[
          const SizedBox(height: 4),
          Text(
            errorText!,
            style: GoogleFonts.urbanist(
              fontSize: 12.0,
              fontWeight: FontWeight.w600,
              color: AppColors.primaryOrange,
            ),
          ),
        ] else if (helperText != null) ...[
          const SizedBox(height: 4),
          Text(
            helperText!,
            style: GoogleFonts.urbanist(
              fontSize: 12.0,
              fontWeight: FontWeight.w500,
              color: AppColors.shayne,
            ),
          ),
        ],
      ],
    );
  }
}
