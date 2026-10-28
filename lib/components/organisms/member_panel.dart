import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import '../molecules/app_member_action_row.dart';
import '../molecules/app_search_filter_bar.dart';

class MemberData {
  final String id;
  final String name;
  final String role;
  final List<String> availableDays;
  final String? avatarUrl;
  final bool isCurrentUser;

  const MemberData({
    required this.id,
    required this.name,
    this.role = 'Member',
    this.availableDays = const [],
    this.avatarUrl,
    this.isCurrentUser = false,
  });
}

/// O05 Member panel organism matching Figma "03 Organisms" board:
/// Recipe: Search molecule + repeated M04 member action rows.
/// Accepts data as parameters (`memberNames` or `member` for single item) and supports loading & empty states.
class MemberPanel extends StatefulWidget {
  final List<String> memberNames;
  final MemberData? member;
  final String searchHint;
  final ValueChanged<String>? onMemberActionTap;
  final VoidCallback? onTap;
  final VoidCallback? onMorePressed;
  final bool showSearch;
  final bool isLoading;
  final String emptyMessage;

  const MemberPanel({
    super.key,
    this.memberNames = const [
      'Hannah S. Labandero',
      'Louielyn Abella',
      'Ellle Bernante',
    ],
    this.member,
    this.searchHint = 'Search members...',
    this.onMemberActionTap,
    this.onTap,
    this.onMorePressed,
    this.showSearch = true,
    this.isLoading = false,
    this.emptyMessage = 'No matching members found.',
  });

  @override
  State<MemberPanel> createState() => _MemberPanelState();
}

class _MemberPanelState extends State<MemberPanel> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Backwards-compatible single member row mode
    if (widget.member != null) {
      return AppMemberActionRow(
        name: widget.member!.name,
        onActionTap: widget.onMorePressed ?? widget.onTap,
      );
    }

    if (widget.isLoading) {
      return const Padding(
        padding: EdgeInsets.all(24.0),
        child: Center(
          child: CircularProgressIndicator(color: AppColors.primaryNavy),
        ),
      );
    }

    final filtered = widget.memberNames
        .where((name) => name.toLowerCase().contains(_query.toLowerCase()))
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.showSearch) ...[
          AppSearchFilterBar(
            hintText: widget.searchHint,
            controller: _searchController,
            showFilterButton: false,
            onChanged: (val) => setState(() => _query = val),
          ),
          const SizedBox(height: 14),
        ],
        if (filtered.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.secondaryDark, width: 1.5),
            ),
            child: Center(
              child: Text(
                widget.emptyMessage,
                style: AppTypography.bodySmall.copyWith(color: AppColors.carla),
              ),
            ),
          )
        else
          for (int i = 0; i < filtered.length; i++) ...[
            AppMemberActionRow(
              name: filtered[i],
              onActionTap: () => widget.onMemberActionTap?.call(filtered[i]),
            ),
            if (i < filtered.length - 1) const SizedBox(height: 12),
          ],
      ],
    );
  }
}
