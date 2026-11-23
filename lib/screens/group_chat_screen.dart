import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../components/molecules/app_chat_message.dart';
import '../components/molecules/app_message_composer.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_typography.dart';
import '../models/group_chat_models.dart';

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

  GroupMessageThread? get _thread => _store.getById(widget.threadId);

  @override
  void initState() {
    super.initState();
    _store.addListener(_onStoreChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _store.markAsRead(widget.threadId);
    });
    _loadMessages();
  }

  Future<void> _loadMessages() async {
    if (widget.initialLoadingDuration == Duration.zero) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }
    await Future<void>.delayed(widget.initialLoadingDuration);
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
    final text = _composerController.text.trim();
    if (text.isEmpty) return;

    _store.sendMessage(widget.threadId, text);
    _composerController.clear();
    _scrollToBottom(animate: true);
  }

  @override
  void dispose() {
    _store.removeListener(_onStoreChanged);
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
              title: Text(
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
                  enabled: !_isLoading,
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

        // Show timestamp header at the start of the conversation or when the
        // day/session label changes significantly (e.g., Tue -> Today).
        final showTimestampHeader = previous == null ||
            _sessionPrefix(previous.timestampLabel) !=
                _sessionPrefix(message.timestampLabel);

        final nextShowsTimestampHeader = next != null &&
            _sessionPrefix(message.timestampLabel) !=
                _sessionPrefix(next.timestampLabel);

        final isFirstInGroup =
            showTimestampHeader || previous.senderId != message.senderId;
        final isLastInGroup = next == null ||
            nextShowsTimestampHeader ||
            next.senderId != message.senderId;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (showTimestampHeader)
              Padding(
                padding: EdgeInsets.only(
                  top: index == 0 ? 0 : 14,
                  bottom: 10,
                ),
                child: Center(
                  child: Text(
                    message.timestampLabel,
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
              isMe: message.isMe,
              senderName: message.isMe ? null : message.senderName,
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

  String _sessionPrefix(String timestamp) {
    final parts = timestamp.split(' ');
    return parts.isNotEmpty ? parts.first : timestamp;
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
