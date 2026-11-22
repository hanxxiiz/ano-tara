import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:anotara/components/molecules/app_chat_message.dart';
import 'package:anotara/components/molecules/floating_messages_button.dart';
import 'package:anotara/components/molecules/message_thread_tile.dart';
import 'package:anotara/core/constants/app_colors.dart';
import 'package:anotara/screens/group_chat_screen.dart';
import 'package:anotara/screens/messages_list_screen.dart';

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
