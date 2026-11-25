import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';

/// A single chat message inside a group conversation.
class GroupChatMessage {
  final String id;
  final String senderId;
  final String senderName;
  final Color avatarColor;
  final String text;
  final String timestampLabel;
  final bool isMe;

  const GroupChatMessage({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.avatarColor,
    required this.text,
    required this.timestampLabel,
    required this.isMe,
  });
}

/// A group conversation thread shown in the Messages list and shortcut sheet.
class GroupMessageThread {
  final String id;
  final String groupName;
  final Color avatarColor;
  String? lastMessage;
  bool hasUnread;
  final List<GroupChatMessage> messages;

  GroupMessageThread({
    required this.id,
    required this.groupName,
    this.avatarColor = AppColors.primaryOrange,
    this.lastMessage,
    this.hasUnread = false,
    List<GroupChatMessage>? messages,
  }) : messages = messages ?? [];

  /// Preview subtitle matching Figma: falls back to "Tap to chat" when empty.
  String get previewText =>
      (lastMessage == null || lastMessage!.trim().isEmpty)
          ? 'Tap to chat'
          : lastMessage!;
}

/// In-memory store for group message threads and chat messages.
/// Keeps the Messages list, floating shortcut sheet, and Group Chat screen in sync.
class GroupMessagesStore extends ChangeNotifier {
  GroupMessagesStore._();

  static final GroupMessagesStore instance = GroupMessagesStore._();

  final List<GroupMessageThread> _threads = [
    GroupMessageThread(
      id: 'group_1',
      groupName: 'Bantayan Squad',
      avatarColor: AppColors.primaryOrange,
      lastMessage: null,
      hasUnread: false,
      messages: [],
    ),
    GroupMessageThread(
      id: 'group_2',
      groupName: 'Hannah Dul Set',
      avatarColor: AppColors.primaryOrange,
      lastMessage: 'Wala ko kabalo asa ta oy',
      hasUnread: true,
      messages: [
        const GroupChatMessage(
          id: 'm1',
          senderId: 'user_hannah',
          senderName: 'Hannah',
          avatarColor: AppColors.semanticYellow,
          text: 'Hello',
          timestampLabel: 'Tue 10:30',
          isMe: false,
        ),
        const GroupChatMessage(
          id: 'm2',
          senderId: 'user_hannah',
          senderName: 'Hannah',
          avatarColor: AppColors.semanticYellow,
          text: 'Asa ta gaiss manglaag?\nColon or Carbon?',
          timestampLabel: 'Tue 10:30',
          isMe: false,
        ),
        const GroupChatMessage(
          id: 'm3',
          senderId: 'me',
          senderName: 'You',
          avatarColor: AppColors.primaryNavy,
          text: 'Hello',
          timestampLabel: 'Tue 10:31',
          isMe: true,
        ),
        const GroupChatMessage(
          id: 'm4',
          senderId: 'me',
          senderName: 'You',
          avatarColor: AppColors.primaryNavy,
          text: 'Asa ta gaiss manglaag?\nColon or Carbon?',
          timestampLabel: 'Tue 10:31',
          isMe: true,
        ),
        const GroupChatMessage(
          id: 'm5',
          senderId: 'user_mika',
          senderName: 'Mika',
          avatarColor: AppColors.primaryOrange,
          text: 'Hello',
          timestampLabel: 'Tue 10:32',
          isMe: false,
        ),
        const GroupChatMessage(
          id: 'm6',
          senderId: 'me',
          senderName: 'You',
          avatarColor: AppColors.primaryNavy,
          text: 'Hello',
          timestampLabel: 'Tue 10:33',
          isMe: true,
        ),
        const GroupChatMessage(
          id: 'm7',
          senderId: 'me',
          senderName: 'You',
          avatarColor: AppColors.primaryNavy,
          text: 'Wala ko kabalo asa ta oy',
          timestampLabel: 'Tue 10:33',
          isMe: true,
        ),
        const GroupChatMessage(
          id: 'm8',
          senderId: 'user_mika',
          senderName: 'Mika',
          avatarColor: AppColors.primaryOrange,
          text: 'Hello',
          timestampLabel: 'Tue 10:34',
          isMe: false,
        ),
      ],
    ),
    GroupMessageThread(
      id: 'group_3',
      groupName: 'Eco Warriors',
      avatarColor: AppColors.primaryOrange,
      lastMessage: 'See you at the port 6 AM!',
      hasUnread: true,
      messages: [
        const GroupChatMessage(
          id: 'e1',
          senderId: 'user_maya',
          senderName: 'Maya Cruz',
          avatarColor: AppColors.semanticYellow,
          text: 'Hey team, are we still on for the coastal cleanup?',
          timestampLabel: 'Wed 08:15',
          isMe: false,
        ),
        const GroupChatMessage(
          id: 'e2',
          senderId: 'me',
          senderName: 'You',
          avatarColor: AppColors.primaryNavy,
          text: 'Yes! Bringing extra reusable bags and water.',
          timestampLabel: 'Wed 08:18',
          isMe: true,
        ),
        const GroupChatMessage(
          id: 'e3',
          senderId: 'user_maya',
          senderName: 'Maya Cruz',
          avatarColor: AppColors.semanticYellow,
          text: 'See you at the port 6 AM!',
          timestampLabel: 'Wed 08:20',
          isMe: false,
        ),
      ],
    ),
    GroupMessageThread(
      id: 'group_4',
      groupName: 'Tech Innovator',
      avatarColor: AppColors.primaryOrange,
      lastMessage: null,
      hasUnread: false,
      messages: [],
    ),
    GroupMessageThread(
      id: 'group_5',
      groupName: 'Weekend Wanderers',
      avatarColor: AppColors.primaryOrange,
      lastMessage: null,
      hasUnread: false,
      messages: [],
    ),
    GroupMessageThread(
      id: 'group_6',
      groupName: 'Siargao Crew',
      avatarColor: AppColors.primaryOrange,
      lastMessage: null,
      hasUnread: false,
      messages: [],
    ),
  ];

  List<GroupMessageThread> get threads => List.unmodifiable(_threads);

  bool get hasAnyUnread => _threads.any((t) => t.hasUnread);

  GroupMessageThread? getById(String id) {
    for (final thread in _threads) {
      if (thread.id == id) return thread;
    }
    return null;
  }

  void markAsRead(String threadId) {
    final thread = getById(threadId);
    if (thread != null && thread.hasUnread) {
      thread.hasUnread = false;
      notifyListeners();
    }
  }

  void sendMessage(String threadId, String rawText) {
    final text = rawText.trim();
    if (text.isEmpty) return;

    final thread = getById(threadId);
    if (thread == null) return;

    final now = DateTime.now();
    final hour = now.hour.toString().padLeft(2, '0');
    final minute = now.minute.toString().padLeft(2, '0');

    thread.messages.add(
      GroupChatMessage(
        id: 'msg_${now.microsecondsSinceEpoch}',
        senderId: 'me',
        senderName: 'You',
        avatarColor: AppColors.primaryNavy,
        text: text,
        timestampLabel: 'Today $hour:$minute',
        isMe: true,
      ),
    );
    thread.lastMessage = text;
    thread.hasUnread = false;
    notifyListeners();
  }
}
