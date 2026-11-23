import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../models/trip_participant.dart';
import '../../theme/app_theme.dart' show AppFonts;
import '../atoms/app_avatar.dart';

/// Opens the "Nudge Members" bottom sheet listing pending trip participants.
/// Tapping "Nudge" immediately switches that member's button to "Nudged"
/// and notifies the caller via [onNudgeParticipant].
///
/// Matches Figma "07.09 · Trip participants — nudge sheet.png".
Future<void> showNudgeMembersSheet({
  required BuildContext context,
  required List<TripParticipant> pendingParticipants,
  required ValueChanged<String> onNudgeParticipant,
}) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    barrierColor: AppColors.secondaryDark.withValues(alpha: 0.35),
    builder: (sheetContext) {
      return _NudgeMembersSheet(
        pendingParticipants: pendingParticipants,
        onNudgeParticipant: onNudgeParticipant,
      );
    },
  );
}

class _NudgeMembersSheet extends StatefulWidget {
  final List<TripParticipant> pendingParticipants;
  final ValueChanged<String> onNudgeParticipant;

  const _NudgeMembersSheet({
    required this.pendingParticipants,
    required this.onNudgeParticipant,
  });

  @override
  State<_NudgeMembersSheet> createState() => _NudgeMembersSheetState();
}

class _NudgeMembersSheetState extends State<_NudgeMembersSheet> {
  final ScrollController _scrollController = ScrollController();
  late Set<String> _nudgedIds;

  @override
  void initState() {
    super.initState();
    _nudgedIds = widget.pendingParticipants
        .where((p) => p.isNudged)
        .map((p) => p.id)
        .toSet();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _handleNudge(TripParticipant participant) {
    if (_nudgedIds.contains(participant.id)) return;
    setState(() {
      _nudgedIds.add(participant.id);
    });
    widget.onNudgeParticipant(participant.id);
  }

  @override
  Widget build(BuildContext context) {
    final maxHeight = MediaQuery.of(context).size.height * 0.72;

    return Container(
      constraints: BoxConstraints(maxHeight: maxHeight),
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(
          top: BorderSide(color: AppColors.secondaryDark, width: 2.0),
          left: BorderSide(color: AppColors.secondaryDark, width: 2.0),
          right: BorderSide(color: AppColors.secondaryDark, width: 2.0),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 14),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Drag handle
                  Container(
                    width: 46,
                    height: 4.5,
                    decoration: BoxDecoration(
                      color: AppColors.secondaryDark,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Header row: "Nudge Members" + X button
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Nudge Members',
                          style: TextStyle(
                            fontFamily: AppFonts.urbanist,
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: AppColors.secondaryDark,
                          ),
                        ),
                      ),
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => Navigator.of(context).pop(),
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(
                            minWidth: 40,
                            minHeight: 40,
                          ),
                          child: Center(
                            child: Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: AppColors.white,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: AppColors.secondaryDark,
                                  width: 2.0,
                                ),
                                boxShadow: const [
                                  BoxShadow(
                                    color: AppColors.secondaryDark,
                                    offset: Offset(0, 2.5),
                                    blurRadius: 0,
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.close_rounded,
                                size: 20,
                                color: AppColors.secondaryDark,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Divider(
              height: 1,
              thickness: 1,
              color: AppColors.borderLight,
            ),

            // Pending members list
            if (widget.pendingParticipants.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 36),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Everyone has responded!',
                      style: TextStyle(
                        fontFamily: AppFonts.urbanist,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.secondaryDark,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'There are no pending members to nudge right now.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: AppFonts.openSans,
                        fontSize: 13,
                        color: AppColors.carla,
                      ),
                    ),
                  ],
                ),
              )
            else
              Flexible(
                child: RawScrollbar(
                  controller: _scrollController,
                  thumbVisibility: true,
                  radius: const Radius.circular(999),
                  thickness: 4,
                  thumbColor: AppColors.ann,
                  padding: const EdgeInsets.only(right: 4, top: 8, bottom: 8),
                  child: ListView.separated(
                    controller: _scrollController,
                    shrinkWrap: true,
                    padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
                    itemCount: widget.pendingParticipants.length,
                    separatorBuilder: (_, _) => const Divider(
                      height: 1,
                      thickness: 1,
                      color: AppColors.borderLight,
                    ),
                    itemBuilder: (context, index) {
                      final member = widget.pendingParticipants[index];
                      final isNudged = _nudgedIds.contains(member.id);

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Row(
                          children: [
                            AppAvatar.singleUser(size: 46),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    member.name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontFamily: AppFonts.urbanist,
                                      fontSize: 15.5,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.secondaryDark,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    member.handle,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontFamily: AppFonts.openSans,
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w400,
                                      color: AppColors.shayne,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            _NudgeActionButton(
                              isNudged: isNudged,
                              onTap: () => _handleNudge(member),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _NudgeActionButton extends StatelessWidget {
  final bool isNudged;
  final VoidCallback onTap;

  const _NudgeActionButton({
    required this.isNudged,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final borderColor =
        isNudged ? AppColors.primaryOrange : AppColors.secondaryDark;
    final textColor =
        isNudged ? AppColors.primaryOrange : AppColors.secondaryDark;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: isNudged ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        width: 92,
        height: 38,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: borderColor,
            width: 1.8,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          isNudged ? 'Nudged' : 'Nudge',
          style: TextStyle(
            fontFamily: AppFonts.urbanist,
            fontSize: 13.5,
            fontWeight: FontWeight.w700,
            color: textColor,
          ),
        ),
      ),
    );
  }
}
