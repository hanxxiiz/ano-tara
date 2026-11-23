import 'dart:async';

import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../components/molecules/app_chat_message.dart';
import '../../../../components/molecules/app_message_composer.dart';
import '../../../../components/molecules/group_chat_avatar.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../state/group_messages_store.dart';
import '../../models/group_chat_models.dart';

/// Group Chat Screen matching Figma "05.06 · Group chat — conversation.png".
/// Supports loading state, empty state, distinct sent/received message bubbles,
/// and live message sending.
class GroupChatScreen extends StatefulWidget {
  final String threadId;
  final Duration initialLoadingDuration;

  const GroupChatScreen({
    super.key,
    required this.threadId,
    this.initialLoadingDuration = const Duration(milliseconds: 450),
  });

  @override
  State<GroupChatScreen> createState() => _GroupChatScreenState();
}

class _GroupChatScreenState extends State<GroupChatScreen> {
  final GroupMessagesStore _store = GroupMessagesStore.instance;
  final TextEditingController _composerController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _composerFocusNode = FocusNode();

  bool _isLoading = true;
  bool _isSending = false;
  String? _loadError;

  GroupMessageThread? get _thread => _store.getById(widget.threadId);

  @override
  void initState() {
    super.initState();
    _store.addListener(_onStoreChanged);
    _store.watchThread(widget.threadId);
    _loadMessages();
  }

  Future<void> _loadMessages() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _loadError = null;
      });
    }
    final loadingAnimation = widget.initialLoadingDuration == Duration.zero
        ? Future<void>.value()
        : Future<void>.delayed(widget.initialLoadingDuration);
    try {
      await Future.wait<void>([
        _store.loadMessages(widget.threadId),
        loadingAnimation,
      ]);
      _store.markAsRead(widget.threadId);
    } catch (_) {
      _loadError = 'Could not load this group chat. Check your connection and retry.';
    }
    if (!mounted) return;
    setState(() => _isLoading = false);
  }

  void _onStoreChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  void _scrollToBottom({bool animate = true}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scrollController.hasClients) return;
      if (_scrollController.offset == 0.0) return;
      if (animate) {
        _scrollController.animateTo(
          0.0,
          duration: const Duration(milliseconds: 240),
          curve: Curves.easeOutCubic,
        );
      } else {
        _scrollController.jumpTo(0.0);
      }
    });
  }

  void _handleSend() {
    if (_isLoading || _isSending || _loadError != null) return;
    final text = _composerController.text.trim();
    if (text.isEmpty) return;

    unawaited(_sendMessage(text));
  }

  Future<void> _sendMessage(String text) async {
    setState(() => _isSending = true);
    try {
      await _store.sendMessage(widget.threadId, text);
      if (!mounted) return;
      _composerController.clear();
      _scrollToBottom(animate: true);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Message could not be sent. Try again.')),
      );
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  @override
  void dispose() {
    _store.removeListener(_onStoreChanged);
    _store.unwatchThread(widget.threadId);
    _composerController.dispose();
    _scrollController.dispose();
    _composerFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final thread = _thread;
    final title = thread?.groupName ?? 'Group Chat';
    final messages = thread?.messages ?? const <GroupChatMessage>[];

    return Scaffold(
      backgroundColor: AppColors.white,
      resizeToAvoidBottomInset: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(57),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppBar(
              backgroundColor: AppColors.white,
              elevation: 0,
              scrolledUnderElevation: 0,
              leading: ConstrainedBox(
                constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
                child: IconButton(
                  tooltip: 'Back',
                  icon: const Icon(
                    Iconsax.arrow_left,
                    color: AppColors.secondaryDark,
                    size: 24,
                  ),
                  onPressed: () => Navigator.of(context).maybePop(),
                  splashRadius: 22,
                ),
              ),
              titleSpacing: 4,
              title: Row(
                children: [
                  GroupChatAvatar(
                    size: 34,
                    imageUrl: thread?.avatarUrl,
                    fallbackColor: thread?.avatarColor ??
                        AppColors.primaryOrange,
                    borderWidth: 1.2,
                  ),
                  const SizedBox(width: 9),
                  Expanded(
                    child: Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.h4.copyWith(
                        color: AppColors.secondaryDark,
                        fontWeight: FontWeight.w800,
                        fontSize: 19,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(
              height: 1,
              thickness: 1.2,
              color: AppColors.secondaryDark,
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: _isLoading
                ? const _ChatLoadingSkeleton()
                : _loadError != null
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 28),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                _loadError!,
                                textAlign: TextAlign.center,
                                style: AppTypography.bodyMedium.copyWith(
                                  color: AppColors.carla,
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextButton(
                                onPressed: _loadMessages,
                                child: const Text('Try again'),
                              ),
                            ],
                          ),
                        ),
                      )
                : messages.isEmpty
                    ? _ChatEmptyState(
                        groupName: title,
                        onStartTyping: () => _composerFocusNode.requestFocus(),
                      )
                    : _buildMessagesList(messages),
          ),
          ColoredBox(
            color: AppColors.white,
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 14),
                child: AppMessageComposer(
                  controller: _composerController,
                  focusNode: _composerFocusNode,
                  onSend: _handleSend,
                  enabled: !_isLoading && !_isSending && _loadError == null,
                  hintText: 'Type your message',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessagesList(List<GroupChatMessage> messages) {
    return ListView.builder(
      controller: _scrollController,
      reverse: true,
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      itemCount: messages.length,
      itemBuilder: (context, reversedIndex) {
        final index = messages.length - 1 - reversedIndex;
        final message = messages[index];
        final previous = index > 0 ? messages[index - 1] : null;
        final next = index < messages.length - 1 ? messages[index + 1] : null;

        // Show a date separator once when the calendar day changes. Each
        // bubble has its own local time label.
        final showDateSeparator = previous == null ||
            !_isSameDay(previous.createdAt, message.createdAt);

        final nextShowsDateSeparator = next != null &&
            !_isSameDay(message.createdAt, next.createdAt);

        final isFirstInGroup = showDateSeparator ||
            previous == null ||
            previous.senderId != message.senderId;
        final isLastInGroup = next == null ||
            nextShowsDateSeparator ||
            next.senderId != message.senderId;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (showDateSeparator)
              Padding(
                padding: EdgeInsets.only(
                  top: index == 0 ? 0 : 14,
                  bottom: 10,
                ),
                child: Center(
                  child: Text(
                    _dateSeparatorLabel(message.createdAt),
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.shayne,
                      fontWeight: FontWeight.w600,
                      fontSize: 12.5,
                    ),
                  ),
                ),
              ),
            AppChatMessage(
              text: message.text,
              timeLabel: message.timeLabel,
              isMe: message.isMe,
              senderName: message.isMe ? null : message.senderName,
              senderAvatarUrl: message.senderAvatarUrl,
              avatarColor: message.avatarColor,
              showAvatar: !message.isMe && isLastInGroup,
              showSenderName: !message.isMe && isFirstInGroup,
              isFirstInGroup: isFirstInGroup,
              isLastInGroup: isLastInGroup,
            ),
          ],
        );
      },
    );
  }

  bool _isSameDay(DateTime first, DateTime second) {
    return first.year == second.year &&
        first.month == second.month &&
        first.day == second.day;
  }

  String _dateSeparatorLabel(DateTime value) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDate = DateTime(value.year, value.month, value.day);
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    final date = '${months[value.month - 1]} ${value.day}';

    if (messageDate == today) return 'Today, $date';
    if (messageDate == today.subtract(const Duration(days: 1))) {
      return 'Yesterday, $date';
    }
    return date;
  }
}

/// Empty state shown when a group chat has no messages yet.
class _ChatEmptyState extends StatelessWidget {
  final String groupName;
  final VoidCallback onStartTyping;

  const _ChatEmptyState({
    required this.groupName,
    required this.onStartTyping,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.semanticYellowLight,
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.secondaryDark,
                  width: 2.0,
                ),
                boxShadow: const [
                  BoxShadow(
                    color: AppColors.secondaryDark,
                    offset: Offset(0, 3),
                    blurRadius: 0,
                  ),
                ],
              ),
              child: const Icon(
                Iconsax.message_text,
                color: AppColors.secondaryDark,
                size: 32,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'No messages yet',
              style: AppTypography.h4.copyWith(
                color: AppColors.secondaryDark,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Start the conversation with $groupName and plan your next trip together.',
              textAlign: TextAlign.center,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.carla,
                fontSize: 13.5,
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: onStartTyping,
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primaryNavy,
                textStyle: AppTypography.buttonMedium.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              child: const Text('Say hello'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Pulsing skeleton chat bubbles shown while messages are loading.
class _ChatLoadingSkeleton extends StatefulWidget {
  const _ChatLoadingSkeleton();

  @override
  State<_ChatLoadingSkeleton> createState() => _ChatLoadingSkeletonState();
}

class _ChatLoadingSkeletonState extends State<_ChatLoadingSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _opacity = Tween<double>(begin: 0.4, end: 0.9).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
        physics: const NeverScrollableScrollPhysics(),
        children: [
          Center(
            child: Container(
              width: 72,
              height: 12,
              decoration: BoxDecoration(
                color: AppColors.surfaceMuted,
                borderRadius: BorderRadius.circular(6),
              ),
            ),
          ),
          const SizedBox(height: 18),
          _buildBubbleSkeleton(
            isMe: false,
            width: 120,
            height: 42,
            showAvatar: false,
          ),
          const SizedBox(height: 10),
          _buildBubbleSkeleton(
            isMe: false,
            width: 210,
            height: 60,
            showAvatar: true,
          ),
          const SizedBox(height: 16),
          _buildBubbleSkeleton(
            isMe: true,
            width: 140,
            height: 42,
            showAvatar: false,
          ),
          const SizedBox(height: 10),
          _buildBubbleSkeleton(
            isMe: true,
            width: 195,
            height: 56,
            showAvatar: false,
          ),
          const SizedBox(height: 16),
          _buildBubbleSkeleton(
            isMe: false,
            width: 160,
            height: 44,
            showAvatar: true,
          ),
        ],
      ),
    );
  }

  Widget _buildBubbleSkeleton({
    required bool isMe,
    required double width,
    required double height,
    bool showAvatar = true,
  }) {
    final avatar = !isMe && showAvatar
        ? Container(
            width: 42,
            height: 42,
            decoration: const BoxDecoration(
              color: AppColors.secondaryLight,
              shape: BoxShape.circle,
            ),
          )
        : const SizedBox(width: 42);

    final bubble = Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: isMe ? AppColors.primaryNavyLight : AppColors.secondaryLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.ann, width: 1.5),
      ),
    );

    return Row(
      mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: isMe ? [bubble] : [avatar, const SizedBox(width: 10), bubble],
    );
  }
}
