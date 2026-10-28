import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../components/molecules/app_chat_message.dart';
import '../../../../components/molecules/app_message_composer.dart';

class GroupChatScreen extends StatefulWidget {
  final String groupName;

  const GroupChatScreen({
    super.key,
    this.groupName = 'Hannah Dul Set',
  });

  @override
  State<GroupChatScreen> createState() => _GroupChatScreenState();
}

class _GroupChatScreenState extends State<GroupChatScreen> {
  final _messageController = TextEditingController();
  final List<Map<String, dynamic>> _messages = [
    {
      'sender': 'Hannah',
      'text': 'Hello',
      'isMe': false,
    },
    {
      'sender': 'Hannah',
      'text': 'Asa ta gaiss manglaag?\nColon or Carbon?',
      'isMe': false,
    },
    {
      'sender': 'You',
      'text': 'Hello',
      'isMe': true,
    },
    {
      'sender': 'You',
      'text': 'Asa ta gaiss manglaag?\nColon or Carbon?',
      'isMe': true,
    },
    {
      'sender': 'Louielyn',
      'text': 'Hello',
      'isMe': false,
    },
    {
      'sender': 'Louielyn',
      'text': 'Asa ta gaiss manglaag?\nColon or Carbon?',
      'isMe': false,
    },
  ];

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add({
        'sender': 'You',
        'text': text,
        'isMe': true,
      });
      _messageController.clear();
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_left, color: AppColors.secondaryDark, size: 24),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          widget.groupName,
          style: AppTypography.titleLarge.copyWith(
            color: AppColors.secondaryDark,
            fontWeight: FontWeight.w800,
            fontSize: 18,
          ),
        ),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1.0),
          child: Divider(color: AppColors.secondaryDark, height: 1.0, thickness: 1.5),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final msg = _messages[index];
                  return AppChatMessage(
                    text: msg['text'] as String,
                    isMe: msg['isMe'] as bool,
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: AppMessageComposer(
                controller: _messageController,
                onSend: _sendMessage,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
