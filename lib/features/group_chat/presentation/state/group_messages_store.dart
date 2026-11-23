import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../models/group_chat_models.dart';
import '../../data/group_chat_repository.dart';

/// Shared reactive state for the Messages list and active group chat.
/// All persisted data is loaded through [GroupChatRepository].
class GroupMessagesStore extends ChangeNotifier {
  GroupMessagesStore._() {
    _activeUserId = _repository.currentUserId;
  }

  static final GroupMessagesStore instance = GroupMessagesStore._();

  final GroupChatRepository _repository = GroupChatRepository();
  final List<GroupMessageThread> _threads = [];
  final Map<String, RealtimeChannel> _channels = {};

  String? _activeUserId;
  String? _threadsError;
  Future<void>? _pendingThreadLoad;
  RealtimeChannel? _threadListChannel;
  Timer? _threadRefreshTimer;
  int _threadMessageRevision = 0;
  bool _refreshingThreadEvents = false;
  bool _isLoadingThreads = false;
  int _accountGeneration = 0;

  List<GroupMessageThread> get threads => List.unmodifiable(_threads);
  bool get hasAnyUnread => _threads.any((thread) => thread.hasUnread);
  bool get isLoadingThreads => _isLoadingThreads;
  String? get threadsError => _threadsError;

  GroupMessageThread? getById(String id) {
    for (final thread in _threads) {
      if (thread.id == id) return thread;
    }
    return null;
  }

  Future<void> loadThreads({bool silent = false}) {
    _resetForAccountChange();
    final pending = _pendingThreadLoad;
    if (pending != null) return pending;

    final generation = _accountGeneration;
    final request = _loadThreads(silent: silent, generation: generation);
    _pendingThreadLoad = request;
    return request.whenComplete(() {
      if (generation == _accountGeneration &&
          identical(_pendingThreadLoad, request)) {
        _pendingThreadLoad = null;
      }
    });
  }

  /// Keeps group previews and unread badges current while the chat list is
  /// closed. The server's RLS policy limits inserts to the user's groups.
  void watchThreads() {
    _resetForAccountChange();
    if (_repository.currentUserId == null || _threadListChannel != null) return;

    _threadListChannel = _repository.subscribeToThreadMessages(
      onInsert: (message) {
        final groupId = message['group_id']?.toString();
        if (groupId == null) return;

        // The active chat's group-specific subscription refreshes its messages
        // and marks them read, so avoid doing that work twice.
        if (_channels.containsKey(groupId)) return;

        _threadMessageRevision++;
        final thread = getById(groupId);
        if (thread != null) {
          final latestText = message['message_text']?.toString();
          if (latestText != null) thread.lastMessage = latestText;
          if (message['sender_id']?.toString() != _repository.currentUserId) {
            thread.hasUnread = true;
          }
          notifyListeners();
        }
        _scheduleThreadRefresh();
      },
    );
  }

  Future<List<GroupChatMessage>> loadMessages(String groupId) async {
    _resetForAccountChange();
    var thread = getById(groupId);
    if (thread == null) {
      await loadThreads(silent: true);
      thread = getById(groupId);
    }
    if (thread == null) {
      throw StateError('This group is unavailable or you are no longer a member.');
    }

    final messages = await _repository.fetchMessages(groupId: groupId);
    thread.messages
      ..clear()
      ..addAll(messages);
    if (messages.isNotEmpty) thread.lastMessage = messages.last.text;
    notifyListeners();
    return messages;
  }

  Future<String> sendMessage(String groupId, String rawText) async {
    final text = rawText.trim();
    final messageId = await _repository.sendMessage(
      groupId: groupId,
      text: text,
    );

    final thread = getById(groupId);
    if (thread != null) {
      thread.lastMessage = text;
      thread.hasUnread = false;
      notifyListeners();
    }
    unawaited(_refreshAfterSend(groupId));
    return messageId;
  }

  void markAsRead(String groupId) {
    final thread = getById(groupId);
    if (thread?.hasUnread == true) {
      thread!.hasUnread = false;
      notifyListeners();
    }
    unawaited(_markAsReadOnServer(groupId));
  }

  void watchThread(String groupId) {
    if (_channels.containsKey(groupId)) return;

    _channels[groupId] = _repository.subscribeToMessages(
      groupId: groupId,
      onInsert: (message) {
        final thread = getById(groupId);
        final latestText = message['message_text']?.toString();
        if (thread != null && latestText != null) {
          thread.lastMessage = latestText;
          notifyListeners();
        }
        unawaited(_refreshAfterRealtimeMessage(groupId));
      },
    );
  }

  void unwatchThread(String groupId) {
    final channel = _channels.remove(groupId);
    if (channel != null) unawaited(_repository.removeSubscription(channel));
  }

  Future<void> _loadThreads({
    required bool silent,
    required int generation,
  }) async {
    _isLoadingThreads = true;
    _threadsError = null;
    if (!silent) notifyListeners();

    try {
      final loadedThreads = await _repository.fetchThreads();
      if (generation != _accountGeneration) return;

      final cachedMessages = {
        for (final thread in _threads)
          thread.id: List<GroupChatMessage>.of(thread.messages),
      };
      for (final thread in loadedThreads) {
        thread.messages.addAll(cachedMessages[thread.id] ?? const []);
      }
      _threads
        ..clear()
        ..addAll(loadedThreads);
    } catch (error) {
      if (generation == _accountGeneration) {
        _threadsError = error.toString();
      }
      rethrow;
    } finally {
      if (generation == _accountGeneration) {
        _isLoadingThreads = false;
        notifyListeners();
      }
    }
  }

  Future<void> _markAsReadOnServer(String groupId) async {
    try {
      await _repository.markThreadRead(groupId);
    } catch (error) {
      _threadsError = error.toString();
      notifyListeners();
    }
  }

  Future<void> _refreshAfterSend(String groupId) async {
    try {
      await loadMessages(groupId);
      await loadThreads(silent: true);
    } catch (error) {
      _threadsError = error.toString();
      notifyListeners();
    }
  }

  Future<void> _refreshAfterRealtimeMessage(String groupId) async {
    try {
      await loadMessages(groupId);
      await loadThreads(silent: true);
      markAsRead(groupId);
    } catch (error) {
      _threadsError = error.toString();
      notifyListeners();
    }
  }

  void _scheduleThreadRefresh() {
    _threadRefreshTimer?.cancel();
    _threadRefreshTimer = Timer(const Duration(milliseconds: 180), () {
      unawaited(_refreshThreadsAfterListMessage());
    });
  }

  Future<void> _refreshThreadsAfterListMessage() async {
    if (_refreshingThreadEvents) return;
    _refreshingThreadEvents = true;

    try {
      while (true) {
        final revision = _threadMessageRevision;
        final pending = _pendingThreadLoad;
        if (pending != null) {
          try {
            await pending;
          } catch (_) {
            // Continue with a fresh request after an earlier load fails.
          }
        }

        await loadThreads(silent: true);
        if (revision == _threadMessageRevision) break;
      }
    } catch (_) {
      // Preserve the live preview while a transient refresh error is retried
      // the next time the message list opens.
    } finally {
      _refreshingThreadEvents = false;
    }
  }

  void _resetForAccountChange() {
    final currentUserId = _repository.currentUserId;
    if (_activeUserId == currentUserId) return;

    _activeUserId = currentUserId;
    _accountGeneration++;
    _pendingThreadLoad = null;
    _isLoadingThreads = false;
    _threadsError = null;
    _threads.clear();
    _threadMessageRevision = 0;
    _threadRefreshTimer?.cancel();
    _threadRefreshTimer = null;
    final threadListChannel = _threadListChannel;
    _threadListChannel = null;
    if (threadListChannel != null) {
      unawaited(_repository.removeSubscription(threadListChannel));
    }
    for (final channel in _channels.values) {
      unawaited(_repository.removeSubscription(channel));
    }
    _channels.clear();
    notifyListeners();
  }
}
