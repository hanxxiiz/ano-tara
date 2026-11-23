import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/constants/app_colors.dart';
import '../models/group_chat_models.dart';

/// Supabase API for group chat.
///
/// Reads are scoped by the database's group membership RLS policies. Sending
/// and marking messages read use database RPCs so the client cannot spoof a
/// sender or update another user's notifications.
class GroupChatRepository {
  GroupChatRepository({SupabaseClient? client})
    : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  String? get currentUserId => _client.auth.currentUser?.id;

  /// Returns every active, non-archived group the signed-in user can chat in,
  /// ordered by most recent activity.
  Future<List<GroupMessageThread>> fetchThreads() async {
    if (_client.auth.currentUser == null) return const [];

    final response = await _client.rpc('anotara_get_group_chat_threads');
    final rows = (response as List<dynamic>)
        .map((row) => Map<String, dynamic>.from(row as Map))
        .toList(growable: false);
    if (rows.isEmpty) return const [];

    final groupIds = rows.map((row) => row['group_id'].toString()).toList();
    final groups = await _client
        .from('groups')
        .select('id,avatar_url')
        .inFilter('id', groupIds);
    final avatarUrls = {
      for (final group in groups)
        group['id'].toString(): _resolveGroupAvatarUrl(group['avatar_url']),
    };

    return rows
        .map((row) {
          final thread = _threadFromRow(row);
          return GroupMessageThread(
            id: thread.id,
            groupName: thread.groupName,
            avatarUrl: avatarUrls[thread.id],
            avatarColor: thread.avatarColor,
            lastMessage: thread.lastMessage,
            hasUnread: thread.hasUnread,
            messages: thread.messages,
          );
        })
        .toList(growable: false);
  }

  /// Loads one page of messages in chronological display order.
  Future<List<GroupChatMessage>> fetchMessages({
    required String groupId,
    int limit = 50,
    int offset = 0,
  }) async {
    if (limit < 1 || limit > 100) {
      throw RangeError.range(limit, 1, 100, 'limit');
    }
    if (offset < 0) throw RangeError.value(offset, 'offset');

    final currentUserId = _client.auth.currentUser?.id;
    if (currentUserId == null) return const [];

    final selectedColumns =
        'id,group_id,sender_id,message_text,created_at';
    final rows = await _client
        .from('group_messages')
        .select(selectedColumns)
        .eq('group_id', groupId)
        .order('created_at', ascending: false)
        .order('id', ascending: false)
        .range(offset, offset + limit - 1);

    if (rows.isEmpty) return const [];

    final senderIds = rows
        .map((row) => row['sender_id']?.toString())
        .whereType<String>()
        .toSet()
        .toList(growable: false);
    final profiles = await _loadProfiles(senderIds);

    // The query is newest-first for efficient paging. The UI displays oldest
    // to newest and reverses the list for its reverse ListView.
    return rows.reversed
        .map(
          (row) => _messageFromRow(
            row,
            profiles[row['sender_id']?.toString()],
            currentUserId,
          ),
        )
        .toList(growable: false);
  }

  /// Sends a message as the authenticated user using the database's
  /// membership checks and rate limit. Returns the persisted message UUID.
  Future<String> sendMessage({
    required String groupId,
    required String text,
  }) async {
    final message = text.trim();
    if (message.isEmpty || message.length > 5000) {
      throw ArgumentError.value(
        text,
        'text',
        'Message must contain 1 to 5000 characters.',
      );
    }
    if (_client.auth.currentUser == null) {
      throw StateError('Sign in to send a group message.');
    }

    final response = await _client.rpc(
      'anotara_send_group_message',
      params: {'p_group_id': groupId, 'p_message_text': message},
    );
    return response.toString();
  }

  /// Marks only this group's unread chat notifications as read.
  Future<int> markThreadRead(String groupId) async {
    if (_client.auth.currentUser == null) return 0;
    final response = await _client.rpc(
      'anotara_mark_group_chat_read',
      params: {'p_group_id': groupId},
    );
    return (response as num).toInt();
  }

  /// Subscribes to inserts for one group. The callback receives the new
  /// database row; remove the returned channel when the chat screen closes.
  RealtimeChannel subscribeToMessages({
    required String groupId,
    required void Function(Map<String, dynamic> message) onInsert,
  }) {
    return _client
        .channel('group-chat:$groupId')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'group_messages',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'group_id',
            value: groupId,
          ),
          callback: (payload) => onInsert(payload.newRecord),
        )
        .subscribe();
  }

  /// Subscribes to message inserts visible to the signed-in user. Supabase
  /// applies the group_messages SELECT policy, so other groups remain hidden.
  RealtimeChannel subscribeToThreadMessages({
    required void Function(Map<String, dynamic> message) onInsert,
  }) {
    final userId = currentUserId;
    if (userId == null) throw StateError('Sign in to watch group messages.');

    return _client
        .channel('group-chat-threads:$userId')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'group_messages',
          callback: (payload) => onInsert(payload.newRecord),
        )
        .subscribe();
  }

  Future<void> removeSubscription(RealtimeChannel channel) async {
    await _client.removeChannel(channel);
  }

  Future<Map<String, Map<String, dynamic>>> _loadProfiles(
    List<String> userIds,
  ) async {
    if (userIds.isEmpty) return const {};

    final rows = await _client
        .from('profiles')
        .select('id,first_name,last_name,username,avatar_url')
        .inFilter('id', userIds);
    return {
      for (final row in rows)
        row['id'].toString(): Map<String, dynamic>.from(row),
    };
  }

  GroupMessageThread _threadFromRow(Map<String, dynamic> row) {
    final unreadCount = (row['unread_count'] as num?)?.toInt() ?? 0;
    return GroupMessageThread(
      id: row['group_id'].toString(),
      groupName: row['group_name']?.toString() ?? 'Group',
      avatarColor: AppColors.primaryOrange,
      lastMessage: row['last_message']?.toString(),
      hasUnread: unreadCount > 0,
      messages: [],
    );
  }

  GroupChatMessage _messageFromRow(
    Map<String, dynamic> row,
    Map<String, dynamic>? profile,
    String currentUserId,
  ) {
    final senderId = row['sender_id'].toString();
    final firstName = profile?['first_name']?.toString().trim() ?? '';
    final lastName = profile?['last_name']?.toString().trim() ?? '';
    final fullName = '$firstName $lastName'.trim();
    final username = profile?['username']?.toString().trim() ?? '';
    final isMe = senderId == currentUserId;
    final createdAt = DateTime.parse(row['created_at'].toString()).toLocal();

    return GroupChatMessage(
      id: row['id'].toString(),
      senderId: senderId,
      senderName: isMe
          ? 'You'
          : fullName.isNotEmpty
          ? fullName
          : username.isNotEmpty
          ? username
          : 'Group member',
      senderAvatarUrl: _resolveAvatarUrl(profile?['avatar_url']),
      avatarColor: isMe ? AppColors.primaryNavy : AppColors.semanticYellow,
      text: row['message_text']?.toString() ?? '',
      createdAt: createdAt,
      timeLabel: _formatTime(createdAt),
      isMe: isMe,
    );
  }

  String _formatTime(DateTime value) {
    final hour = value.hour % 12 == 0 ? 12 : value.hour % 12;
    final minute = value.minute.toString().padLeft(2, '0');
    final period = value.hour < 12 ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  String? _resolveAvatarUrl(dynamic value) {
    final avatar = value?.toString().trim();
    if (avatar == null || avatar.isEmpty) return null;

    final uri = Uri.tryParse(avatar);
    if (uri != null && uri.hasScheme) return avatar;

    final objectPath = avatar.replaceFirst(RegExp(r'^/+'), '');
    return _client.storage.from('profile-avatars').getPublicUrl(objectPath);
  }

  String? _resolveGroupAvatarUrl(dynamic value) {
    final avatar = value?.toString().trim();
    if (avatar == null || avatar.isEmpty) return null;

    final uri = Uri.tryParse(avatar);
    if (uri != null && uri.hasScheme) return avatar;

    var objectPath = avatar.replaceFirst(RegExp(r'^/+'), '');
    if (objectPath.startsWith('group-avatars/')) {
      objectPath = objectPath.substring('group-avatars/'.length);
    }
    return _client.storage.from('group-avatars').getPublicUrl(objectPath);
  }
}
