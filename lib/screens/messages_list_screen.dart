import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../app_routes.dart';
import '../components/molecules/message_thread_tile.dart';
import '../components/organisms/app_bottom_navigation.dart';
import '../components/organisms/app_main_top_bar.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_typography.dart';
import '../models/group_chat_models.dart';
import 'group_chat_screen.dart';

/// Messages List Screen matching Figma "05.02 · Groups — message threads.png".
/// Features group search, unread yellow dot indicators, loading skeletons,
/// and empty states.
class MessagesListScreen extends StatefulWidget {
  final Duration initialLoadingDuration;

  const MessagesListScreen({
    super.key,
    this.initialLoadingDuration = const Duration(milliseconds: 500),
  });

  @override
  State<MessagesListScreen> createState() => _MessagesListScreenState();
}

class _MessagesListScreenState extends State<MessagesListScreen> {
  final GroupMessagesStore _store = GroupMessagesStore.instance;
  final TextEditingController _searchController = TextEditingController();

  String _query = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _store.addListener(_onStoreChanged);
    _loadThreads();
  }

  Future<void> _loadThreads() async {
    if (widget.initialLoadingDuration == Duration.zero) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }
    setState(() => _isLoading = true);
    await Future<void>.delayed(widget.initialLoadingDuration);
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

  void _openThread(GroupMessageThread thread) {
    _store.markAsRead(thread.id);
    Navigator.of(context).push(
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

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(61),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppMainTopBar(
              onNotificationTap: () =>
                  Navigator.of(context).pushNamed(AppRoutes.notifications),
            ),
            const Divider(
              height: 1,
              thickness: 1.2,
              color: AppColors.secondaryDark,
            ),
          ],
        ),
      ),
      body: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Heading
              Text(
                'Messages',
                style: AppTypography.h1.copyWith(
                  color: AppColors.secondaryDark,
                  fontWeight: FontWeight.w800,
                  fontSize: 26,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 12),

              // Search group bar
              GroupMessagesSearchBar(
                controller: _searchController,
                hintText: 'Search group',
                onChanged: (value) => setState(() => _query = value),
              ),
              const SizedBox(height: 16),

              // Content area (Loading / Empty / Threads List)
              Expanded(
                child: _isLoading
                    ? ListView.separated(
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: 5,
                        separatorBuilder: (_, _) => const SizedBox(height: 12),
                        itemBuilder: (_, _) =>
                            const MessageThreadTileSkeleton(),
                      )
                    : threads.isEmpty
                        ? _MessagesEmptyState(
                            isSearching: _query.trim().isNotEmpty,
                            query: _query.trim(),
                            onClearSearch: () {
                              _searchController.clear();
                              setState(() => _query = '');
                            },
                          )
                        : RefreshIndicator(
                            color: AppColors.primaryNavy,
                            onRefresh: _loadThreads,
                            child: ListView.separated(
                              physics: const AlwaysScrollableScrollPhysics(),
                              padding: const EdgeInsets.only(bottom: 20),
                              itemCount: threads.length,
                              separatorBuilder: (_, _) =>
                                  const SizedBox(height: 12),
                              itemBuilder: (context, index) {
                                final thread = threads[index];
                                return MessageThreadTile(
                                  thread: thread,
                                  onTap: () => _openThread(thread),
                                );
                              },
                            ),
                          ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: AppBottomNavigation(
        currentIndex: 3, // Groups tab active matching Figma 05.02
        onTabSelected: (index) {
          if (index == 3) return;
          if (index == 0) {
            Navigator.of(context).maybePop();
            return;
          }
          const destinations = [
            'Home',
            'Trips',
            'Create trip',
            'Groups',
            'Profile',
          ];
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${destinations[index]} tapped')),
          );
        },
      ),
    );
  }
}

class _MessagesEmptyState extends StatelessWidget {
  final bool isSearching;
  final String query;
  final VoidCallback onClearSearch;

  const _MessagesEmptyState({
    required this.isSearching,
    required this.query,
    required this.onClearSearch,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 68,
              height: 68,
              decoration: BoxDecoration(
                color: AppColors.primaryNavyLight,
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
              child: Icon(
                isSearching ? Iconsax.search_normal : Iconsax.sms,
                color: AppColors.secondaryDark,
                size: 30,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              isSearching ? 'No groups found' : 'No messages yet',
              style: AppTypography.h4.copyWith(
                color: AppColors.secondaryDark,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              isSearching
                  ? 'We couldn\'t find any group matching "$query".'
                  : 'Join or create a group to start chatting with your travel buddies.',
              textAlign: TextAlign.center,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.carla,
                fontSize: 13.5,
              ),
            ),
            if (isSearching) ...[
              const SizedBox(height: 14),
              TextButton(
                onPressed: onClearSearch,
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primaryNavy,
                  textStyle: AppTypography.buttonMedium.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                child: const Text('Clear search'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
