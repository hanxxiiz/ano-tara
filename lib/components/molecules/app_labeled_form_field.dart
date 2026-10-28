import 'package:flutter/material.dart';
import '../atoms/app_input_field.dart';

/// M01 Labeled form field molecule:
/// Recipe: A01 Label + A04 Input + A01 Helper text.
class AppLabeledFormField extends StatelessWidget {
  final String label;
  final String? hint;
  final String? helperText;
  final String? errorText;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;

  const AppLabeledFormField({
    super.key,
    required this.label,
    this.hint,
    this.helperText,
    this.errorText,
    this.controller,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        AppInputField(
          label: label,
          hint: hint,
          helperText: helperText,
          errorText: errorText,
          controller: controller,
          onChanged: onChanged,
        ),
      ],
    );
  }
}
