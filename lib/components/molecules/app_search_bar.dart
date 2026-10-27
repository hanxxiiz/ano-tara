import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_radii.dart';
import '../../core/constants/app_typography.dart';

/// Search bar molecule matching Figma "search box.pdf".
class AppSearchBar extends StatefulWidget {
  final String hintText;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onClear;
  final TextEditingController? controller;
  final bool isEnabled;

  const AppSearchBar({
    super.key,
    this.hintText = 'Search trips, members, places...',
    this.onChanged,
    this.onSubmitted,
    this.onClear,
    this.controller,
    this.isEnabled = true,
  });

  @override
  State<AppSearchBar> createState() => _AppSearchBarState();
}

class _AppSearchBarState extends State<AppSearchBar> {
  late TextEditingController _controller;
  bool _showClear = false;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _controller.addListener(() {
      final shouldShow = _controller.text.isNotEmpty;
      if (shouldShow != _showClear) {
        setState(() {
          _showClear = shouldShow;
        });
      }
    });
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48.0,
      decoration: BoxDecoration(
        color: widget.isEnabled ? AppColors.surfaceMuted : AppColors.surfaceLight,
        borderRadius: AppRadii.radiusPill,
        border: Border.all(color: AppColors.ann, width: 1.0),
      ),
      child: Center(
        child: TextField(
          controller: _controller,
          enabled: widget.isEnabled,
          onChanged: widget.onChanged,
          onSubmitted: widget.onSubmitted,
          style: AppTypography.inputText,
          cursorColor: AppColors.primaryNavy,
          decoration: InputDecoration(
            isDense: true,
            hintText: widget.hintText,
            hintStyle: AppTypography.inputHint,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            prefixIcon: const Padding(
              padding: EdgeInsets.only(left: 14, right: 8),
              child: Icon(
                Iconsax.search_normal,
                color: AppColors.shayne,
                size: 20,
              ),
            ),
            prefixIconConstraints: const BoxConstraints(minWidth: 44, minHeight: 44),
            suffixIcon: _showClear
                ? IconButton(
                    icon: const Icon(Icons.close, color: AppColors.shayne, size: 18),
                    onPressed: () {
                      _controller.clear();
                      widget.onClear?.call();
                      widget.onChanged?.call('');
                    },
                    splashRadius: 20,
                  )
                : null,
            suffixIconConstraints: const BoxConstraints(minWidth: 44, minHeight: 44),
          ),
        ),
      ),
    );
  }
}
