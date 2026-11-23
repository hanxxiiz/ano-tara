import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

/// A single chat message inside a group conversation.
class GroupChatMessage {
  final String id;
  final String senderId;
  final String senderName;
  final String? senderAvatarUrl;
  final Color avatarColor;
  final String text;
  final DateTime createdAt;
  final String timeLabel;
  final bool isMe;

  const GroupChatMessage({
    required this.id,
    required this.senderId,
    required this.senderName,
    this.senderAvatarUrl,
    required this.avatarColor,
    required this.text,
    required this.createdAt,
    required this.timeLabel,
    required this.isMe,
  });
}

/// A group conversation thread shown in the Messages list and shortcut sheet.
class GroupMessageThread {
  final String id;
  final String groupName;
  final String? avatarUrl;
  final Color avatarColor;
  String? lastMessage;
  bool hasUnread;
  final List<GroupChatMessage> messages;

  GroupMessageThread({
    required this.id,
    required this.groupName,
    this.avatarUrl,
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

