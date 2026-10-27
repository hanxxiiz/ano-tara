import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_radii.dart';
import '../../core/constants/app_typography.dart';

/// Input field atom matching Figma specs (with label, placeholder, icons, password eye, error state).
class AppInputField extends StatefulWidget {
  final String? label;
  final String? hint;
  final String? errorText;
  final String? helperText;
  final TextEditingController? controller;
  final TextInputType keyboardType;
  final bool isPassword;
  final bool isEnabled;
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
    this.helperText,
    this.controller,
    this.keyboardType = TextInputType.text,
    this.isPassword = false,
    this.isEnabled = true,
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
  State<AppInputField> createState() => _AppInputFieldState();
}

class _AppInputFieldState extends State<AppInputField> {
  late bool _obscureText;
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.isPassword;
    _focusNode.addListener(() {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool hasError = widget.errorText != null && widget.errorText!.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.label != null) ...[
          Text(
            widget.label!,
            style: AppTypography.inputLabel.copyWith(
              color: widget.isEnabled ? AppColors.chucky : AppColors.shayne,
            ),
          ),
          const SizedBox(height: 6),
        ],
        Container(
          constraints: const BoxConstraints(minHeight: 48.0),
          decoration: BoxDecoration(
            color: widget.isEnabled ? AppColors.surfaceMuted : AppColors.surfaceLight,
            borderRadius: AppRadii.radiusMd,
            border: Border.all(
              color: hasError
                  ? AppColors.semanticRed
                  : _isFocused
                      ? AppColors.primaryNavy
                      : AppColors.ann,
              width: _isFocused ? 1.5 : 1.0,
            ),
          ),
          child: TextFormField(
            controller: widget.controller,
            focusNode: _focusNode,
            enabled: widget.isEnabled,
            readOnly: widget.isReadOnly,
            obscureText: widget.isPassword ? _obscureText : false,
            keyboardType: widget.keyboardType,
            minLines: widget.isPassword ? 1 : widget.minLines,
            maxLines: widget.isPassword ? 1 : widget.maxLines,
            onChanged: widget.onChanged,
            onTap: widget.onTap,
            validator: widget.validator,
            style: AppTypography.inputText.copyWith(
              color: widget.isEnabled ? AppColors.chucky : AppColors.shayne,
            ),
            cursorColor: AppColors.primaryNavy,
            decoration: InputDecoration(
              isDense: true,
              hintText: widget.hint,
              hintStyle: AppTypography.inputHint,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              errorBorder: InputBorder.none,
              focusedErrorBorder: InputBorder.none,
              disabledBorder: InputBorder.none,
              prefixIcon: widget.prefixIcon != null
                  ? Padding(
                      padding: const EdgeInsets.only(left: 12, right: 8),
                      child: widget.prefixIcon,
                    )
                  : null,
              prefixIconConstraints: const BoxConstraints(minWidth: 40, minHeight: 40),
              suffixIcon: widget.isPassword
                  ? IconButton(
                      icon: Icon(
                        _obscureText ? Iconsax.eye_slash : Iconsax.eye,
                        color: AppColors.shayne,
                        size: 20,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureText = !_obscureText;
                        });
                      },
                      splashRadius: 20,
                    )
                  : (widget.suffixIcon != null
                      ? Padding(
                          padding: const EdgeInsets.only(right: 12),
                          child: widget.suffixIcon,
                        )
                      : null),
              suffixIconConstraints: const BoxConstraints(minWidth: 40, minHeight: 40),
            ),
          ),
        ),
        if (hasError) ...[
          const SizedBox(height: 4),
          Text(
            widget.errorText!,
            style: AppTypography.caption.copyWith(color: AppColors.semanticRed),
          ),
        ] else if (widget.helperText != null) ...[
          const SizedBox(height: 4),
          Text(
            widget.helperText!,
            style: AppTypography.caption,
          ),
        ],
      ],
    );
  }
}
