import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:anotara/components/atoms/app_icon.dart';
import 'package:anotara/components/molecules/app_chat_message.dart';
import 'package:anotara/components/molecules/app_message_composer.dart';
import 'package:anotara/components/molecules/floating_messages_button.dart';
import 'package:anotara/components/molecules/message_thread_tile.dart';
import 'package:anotara/core/constants/app_colors.dart';
import 'package:anotara/features/group_chat/presentation/screens/group_chat_screen.dart';
import 'package:anotara/features/group_chat/presentation/screens/messages_list_screen.dart';

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  testWidgets('MessagesListScreen shows loading, threads, search & empty state',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: MessagesListScreen(
          initialLoadingDuration: Duration(milliseconds: 200),
        ),
      ),
    );

    // Loading state shown initially
    expect(find.byType(MessageThreadTileSkeleton), findsWidgets);

    // Finish loading
    await tester.pump(const Duration(milliseconds: 250));
    await tester.pumpAndSettle();

    expect(find.text('Messages'), findsOneWidget);
    expect(find.text('Hannah Dul Set'), findsOneWidget);
    expect(find.text('Wala ko kabalo asa ta oy'), findsOneWidget);

    // Search group filters results
    await tester.enterText(find.byType(TextField), 'Hannah');
    await tester.pump();
    expect(find.text('Hannah Dul Set'), findsOneWidget);
    expect(find.text('Eco Warriors'), findsNothing);

    // Non-matching search shows empty state
    await tester.enterText(find.byType(TextField), 'Nonexistent Group XYZ');
    await tester.pump();
    expect(find.text('No groups found'), findsOneWidget);
    expect(find.text('Clear search'), findsOneWidget);
  });

  testWidgets(
      'GroupChatScreen shows loading, distinct sent/received bubbles, and sends messages',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: GroupChatScreen(
          threadId: 'group_2',
          initialLoadingDuration: Duration(milliseconds: 200),
        ),
      ),
    );

    // Loading state
    expect(find.text('Hannah Dul Set'), findsOneWidget);

    // Wait for messages to load
    await tester.pump(const Duration(milliseconds: 250));
    await tester.pumpAndSettle();

    expect(find.byType(AppChatMessage), findsWidgets);

    // Verify sent and received bubbles use distinct alignments and colors
    final receivedFinder = find.byWidgetPredicate(
      (w) => w is AppChatMessage && !w.isMe,
    );
    final sentFinder = find.byWidgetPredicate(
      (w) => w is AppChatMessage && w.isMe,
    );
    expect(receivedFinder, findsWidgets);
    expect(sentFinder, findsWidgets);

    final receivedContainer = tester.widgetList<Container>(
      find.descendant(
        of: receivedFinder.first,
        matching: find.byType(Container),
      ),
    );
    final sentContainer = tester.widgetList<Container>(
      find.descendant(
        of: sentFinder.first,
        matching: find.byType(Container),
      ),
    );

    final hasLightReceivedBubble = receivedContainer.any((c) {
      final dec = c.decoration;
      return dec is BoxDecoration && dec.color == AppColors.secondaryLight;
    });
    final hasNavySentBubble = sentContainer.any((c) {
      final dec = c.decoration;
      return dec is BoxDecoration && dec.color == AppColors.primaryNavy;
    });

    expect(hasLightReceivedBubble, isTrue);
    expect(hasNavySentBubble, isTrue);

    // Send a new message
    await tester.enterText(find.byType(TextField), 'Tara Colon!');
    await tester.tap(find.byTooltip('Send message'));
    await tester.pumpAndSettle();

    expect(find.text('Tara Colon!'), findsOneWidget);
  });

  testWidgets(
      'AppChatMessage hides current user avatar and aligns received avatar with last bubble',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppChatMessage(
                  text: 'First from Hannah',
                  isMe: false,
                  senderName: 'Hannah',
                  showSenderName: true,
                  showAvatar: false,
                  isFirstInGroup: true,
                  isLastInGroup: false,
                ),
                AppChatMessage(
                  text: 'Second from Hannah\nwith a second line',
                  isMe: false,
                  senderName: 'Hannah',
                  showSenderName: false,
                  showAvatar: true,
                  isFirstInGroup: false,
                  isLastInGroup: true,
                ),
                AppChatMessage(
                  text: 'Reply from me',
                  isMe: true,
                  showAvatar: true,
                  isFirstInGroup: true,
                  isLastInGroup: true,
                ),
              ],
            ),
          ),
        ),
      ),
    );

    final firstMsg = find.byWidgetPredicate(
      (w) => w is AppChatMessage && w.text == 'First from Hannah',
    );
    final lastMsg = find.byWidgetPredicate(
      (w) => w is AppChatMessage && w.text.startsWith('Second from Hannah'),
    );
    final sentMsg = find.byWidgetPredicate(
      (w) => w is AppChatMessage && w.isMe,
    );

    // Sender name only on the first message of the run
    expect(find.descendant(of: firstMsg, matching: find.text('Hannah')),
        findsOneWidget);
    expect(find.descendant(of: lastMsg, matching: find.text('Hannah')),
        findsNothing);

    // Avatar only on the last received message, and never on sent messages
    expect(find.descendant(of: firstMsg, matching: find.byType(AppIcon)),
        findsNothing);
    expect(find.descendant(of: lastMsg, matching: find.byType(AppIcon)),
        findsOneWidget);
    expect(find.descendant(of: sentMsg, matching: find.byType(AppIcon)),
        findsNothing);

    // First and last received bubbles align on the same left x-coordinate
    final firstBubbleContainer = find.descendant(
      of: firstMsg,
      matching: find.byWidgetPredicate(
        (w) =>
            w is Container &&
            w.decoration is BoxDecoration &&
            (w.decoration as BoxDecoration).color == AppColors.secondaryLight,
      ),
    );
    final lastBubbleContainer = find.descendant(
      of: lastMsg,
      matching: find.byWidgetPredicate(
        (w) =>
            w is Container &&
            w.decoration is BoxDecoration &&
            (w.decoration as BoxDecoration).color == AppColors.secondaryLight,
      ),
    );
    final avatarContainer = find.descendant(
      of: lastMsg,
      matching: find.byWidgetPredicate(
        (w) =>
            w is Container &&
            w.decoration is BoxDecoration &&
            (w.decoration as BoxDecoration).shape == BoxShape.circle,
      ),
    );

    final firstBubbleRect = tester.getRect(firstBubbleContainer);
    final lastBubbleRect = tester.getRect(lastBubbleContainer);
    final avatarRect = tester.getRect(avatarContainer);

    expect(firstBubbleRect.left, closeTo(lastBubbleRect.left, 0.5));
    // Profile icon bottom-aligns with the last message bubble
    expect(avatarRect.bottom, closeTo(lastBubbleRect.bottom, 0.5));
  });

  testWidgets(
      'GroupChatScreen auto-scrolls to latest sent message above the input field',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: GroupChatScreen(
          threadId: 'group_2',
          initialLoadingDuration: Duration.zero,
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Scroll up away from the latest message
    final listFinder = find.byType(ListView);
    await tester.drag(listFinder, const Offset(0, 300));
    await tester.pumpAndSettle();

    // Send a new message
    const sentText = 'Latest message stays visible!';
    await tester.enterText(find.byType(TextField), sentText);
    await tester.tap(find.byTooltip('Send message'));
    await tester.pumpAndSettle();

    final latestMsgFinder = find.text(sentText);
    expect(latestMsgFinder, findsOneWidget);

    // Ensure the latest message is fully visible above the message composer
    final latestMsgRect = tester.getRect(latestMsgFinder);
    final composerRect = tester.getRect(find.byType(AppMessageComposer));
    expect(latestMsgRect.bottom, lessThan(composerRect.top));
  });

  testWidgets('GroupChatScreen shows empty state for a group with no messages',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: GroupChatScreen(
          threadId: 'group_1',
          initialLoadingDuration: Duration.zero,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('No messages yet'), findsOneWidget);
    expect(find.text('Say hello'), findsOneWidget);
  });

  testWidgets('FloatingMessagesButton opens the Messages shortcut overlay',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          floatingActionButton: FloatingMessagesButton(),
        ),
      ),
    );

    await tester.tap(find.byType(FloatingMessagesButton));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('Messages'), findsOneWidget);
    expect(find.byTooltip('Open full Messages screen'), findsOneWidget);
    expect(find.byTooltip('Close'), findsOneWidget);
  });
}
