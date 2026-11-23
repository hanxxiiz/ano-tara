import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import '../../features/group_chat/presentation/state/group_messages_store.dart';
import '../../features/group_chat/models/group_chat_models.dart';
import '../../features/group_chat/presentation/screens/group_chat_screen.dart';
import '../../features/group_chat/presentation/screens/messages_list_screen.dart';
import '../molecules/message_thread_tile.dart';

/// Opens the Group Messages list shortcut overlay matching Figma
/// "05.20 · Group messages — list shortcut.png".
Future<void> showMessagesShortcutSheet(BuildContext context) {
  return showGeneralDialog<void>(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Close Messages',
    barrierColor: AppColors.secondaryDark.withValues(alpha: 0.35),
    transitionDuration: const Duration(milliseconds: 220),
    pageBuilder: (dialogContext, _, _) {
      return const _MessagesShortcutDialog();
    },
    transitionBuilder: (context, animation, _, child) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
      );
      return FadeTransition(
        opacity: curved,
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.94, end: 1.0).animate(curved),
          child: child,
        ),
      );
    },
  );
}

class _MessagesShortcutDialog extends StatefulWidget {
  const _MessagesShortcutDialog();

  @override
  State<_MessagesShortcutDialog> createState() =>
      _MessagesShortcutDialogState();
}

class _MessagesShortcutDialogState extends State<_MessagesShortcutDialog> {
  final GroupMessagesStore _store = GroupMessagesStore.instance;
  final TextEditingController _searchController = TextEditingController();

  String _query = '';
  bool _isLoading = true;
  bool _loadFailed = false;

  @override
  void initState() {
    super.initState();
    _store.addListener(_onStoreChanged);
    _store.watchThreads();
    _loadThreads();
  }

  Future<void> _loadThreads() async {
    setState(() {
      _isLoading = true;
      _loadFailed = false;
    });
    try {
      await Future.wait<void>([
        _store.loadThreads(),
        Future<void>.delayed(const Duration(milliseconds: 350)),
      ]);
    } catch (_) {
      _loadFailed = true;
    }
    if (!mounted) return;
    setState(() => _isLoading = false);
  }

  void _onStoreChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  List<GroupMessageThread> get _filteredThreads {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return _store.threads;
    return _store.threads.where((thread) {
      return thread.groupName.toLowerCase().contains(q) ||
          thread.previewText.toLowerCase().contains(q);
    }).toList();
  }

  void _expandToFullScreen() {
    final navigator = Navigator.of(context);
    navigator.pop();
    navigator.push(
      MaterialPageRoute(builder: (_) => const MessagesListScreen()),
    );
  }

  void _openThread(GroupMessageThread thread) {
    _store.markAsRead(thread.id);
    final navigator = Navigator.of(context);
    navigator.pop();
    navigator.push(
      MaterialPageRoute(
        builder: (_) => GroupChatScreen(threadId: thread.id),
      ),
    );
  }

  @override
  void dispose() {
    _store.removeListener(_onStoreChanged);
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final threads = _filteredThreads;
    final media = MediaQuery.of(context);

    return SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 24),
          child: Material(
            color: Colors.transparent,
            child: Container(
              constraints: BoxConstraints(
                maxWidth: 420,
                maxHeight: media.size.height * 0.72,
              ),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: AppColors.secondaryDark,
                  width: 2.0,
                ),
                boxShadow: const [
                  BoxShadow(
                    color: AppColors.secondaryDark,
                    offset: Offset(0, 4),
                    blurRadius: 0,
                  ),
                ],
              ),
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header: "Messages" + Expand + Close
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Messages',
                          style: AppTypography.h2.copyWith(
                            color: AppColors.secondaryDark,
                            fontWeight: FontWeight.w800,
                            fontSize: 23,
                          ),
                        ),
                      ),
                      ConstrainedBox(
                        constraints: const BoxConstraints(
                          minWidth: 40,
                          minHeight: 40,
                        ),
                        child: IconButton(
                          tooltip: 'Open full Messages screen',
                          onPressed: _expandToFullScreen,
                          icon: const Icon(
                            Icons.open_in_full_rounded,
                            color: AppColors.secondaryDark,
                            size: 20,
                          ),
                          splashRadius: 20,
                        ),
                      ),
                      ConstrainedBox(
                        constraints: const BoxConstraints(
                          minWidth: 40,
                          minHeight: 40,
                        ),
                        child: IconButton(
                          tooltip: 'Close',
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(
                            Icons.close_rounded,
                            color: AppColors.secondaryDark,
                            size: 24,
                          ),
                          splashRadius: 20,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Search bar
                  GroupMessagesSearchBar(
                    controller: _searchController,
                    hintText: 'Search group',
                    onChanged: (value) => setState(() => _query = value),
                  ),
                  const SizedBox(height: 14),

                  // Thread list / Loading / Empty
                  Flexible(
                    child: _isLoading
                        ? ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: 4,
                            separatorBuilder: (_, _) =>
                                const SizedBox(height: 10),
                            itemBuilder: (_, _) =>
                                const MessageThreadTileSkeleton(),
                          )
                        : _loadFailed
                            ? Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 24,
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      'Could not load group messages.',
                                      textAlign: TextAlign.center,
                                      style: AppTypography.bodySmall,
                                    ),
                                    TextButton(
                                      onPressed: _loadThreads,
                                      child: const Text('Try again'),
                                    ),
                                  ],
                                ),
                              )
                        : threads.isEmpty
                            ? Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 32),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Iconsax.search_normal,
                                      size: 32,
                                      color: AppColors.shayne,
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      _query.trim().isNotEmpty
                                          ? 'No groups found'
                                          : 'No messages yet',
                                      style: AppTypography.titleLarge.copyWith(
                                        color: AppColors.secondaryDark,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      _query.trim().isNotEmpty
                                          ? 'Try a different group name.'
                                          : 'Your group chats will appear here.',
                                      style: AppTypography.bodySmall,
                                    ),
                                  ],
                                ),
                              )
                            : ListView.separated(
                                shrinkWrap: true,
                                itemCount: threads.length,
                                separatorBuilder: (_, _) =>
                                    const SizedBox(height: 10),
                                itemBuilder: (context, index) {
                                  final thread = threads[index];
                                  return MessageThreadTile(
                                    thread: thread,
                                    onTap: () => _openThread(thread),
                                  );
                                },
                              ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
