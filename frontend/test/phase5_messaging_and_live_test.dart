import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:frontend/data/models/feed_model.dart';
import 'package:frontend/data/models/message_model.dart';
import 'package:frontend/data/models/comment_model.dart';
import 'package:frontend/data/models/live_model.dart';
import 'package:frontend/viewmodels/live_viewmodel.dart';
import 'package:frontend/ui/core/cyber_theme.dart';
import 'package:frontend/ui/screens/direct_messages_screen.dart';
import 'package:frontend/ui/screens/direct_chat_thread_screen.dart';
import 'package:frontend/ui/screens/comments_discussion_screen.dart';
import 'package:frontend/ui/screens/live_stream_viewer_screen.dart';
import 'test_http_overrides.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;
  HttpOverrides.global = TestHttpOverrides();

  final sampleThread = ChatThread(
    id: 'thread_kaito',
    user: const PostAuthor(
      id: 'u2',
      username: 'neon_kaito',
      displayName: 'Kaito Vance',
      avatarUrl: 'https://example.com/kaito.jpg',
      isVerified: true,
    ),
    lastMessage: 'The encrypted neural payload is ready.',
    unreadCount: 3,
    isPinned: true,
    messages: [
      const ChatMessage(id: 'm1', sender: 'kaito', text: 'Encrypted ping received', timestamp: '10:00 PM', type: 'text'),
      const ChatMessage(id: 'm2', sender: 'me', text: 'Roger that.', timestamp: '10:01 PM', type: 'text'),
      const ChatMessage(
        id: 'm3',
        sender: 'kaito',
        text: 'Voice stream incoming:',
        duration: '0:24',
        waveform: [20, 50, 80, 40, 95],
        timestamp: '10:02 PM',
        type: 'voice',
      ),
      const ChatMessage(
        id: 'm4',
        sender: 'kaito',
        text: '3D Spatial Geometry',
        timestamp: '10:03 PM',
        type: 'hologram',
      ),
    ],
  );

  final sampleComment = CommentItem(
    id: 'c1',
    postId: 'post_1',
    author: const PostAuthor(
      id: 'u2',
      username: 'neon_kaito',
      displayName: 'Kaito Vance',
      avatarUrl: 'https://example.com/kaito.jpg',
      isVerified: true,
    ),
    text: 'The volumetric bloom on the wet tarmac is unmatched!',
    timestamp: '10m ago',
    likesCount: 15,
    isPinned: true,
    replies: [
      const CommentItem(
        id: 'c1_r1',
        postId: 'post_1',
        author: PostAuthor(
          id: 'u1',
          username: 'cyber_ren',
          displayName: 'Ren',
          avatarUrl: 'https://example.com/ren.jpg',
        ),
        text: 'Custom anamorphic prism with ISO 3200!',
        timestamp: '5m ago',
        likesCount: 4,
      ),
    ],
  );

  final sampleLiveStream = LiveStream(
    id: 'live_test',
    host: const PostAuthor(
      id: 'u3',
      username: 'kira_synth',
      displayName: 'Kira',
      avatarUrl: 'https://example.com/kira.jpg',
      isVerified: true,
    ),
    title: 'Midnight Cyber Synth Jam',
    viewersCount: 14200,
    chatMessages: const [
      LiveComment(id: 'lc1', user: 'neon_kaito', text: 'Insane bass frequencies! 🔥', timestamp: '10:10 PM', isPin: true),
      LiveComment(id: 'lc2', user: 'cyber_ren', text: 'Neo-Tokyo is listening', timestamp: '10:11 PM', giftType: 'quantum_ramen'),
    ],
  );

  group('Phase 5: Messaging & Live Real-Time Tests', () {
    testWidgets('DirectMessagesScreen renders encryption banner and thread', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      String? selectedId;

      await tester.pumpWidget(
        MaterialApp(
          theme: CyberTheme.darkTheme,
          home: DirectMessagesScreen(
            threads: [sampleThread],
            onSelectThread: (id) => selectedId = id,
            onBack: () {},
            onNewMessage: () {},
          ),
        ),
      );
      await tester.pump();

      expect(find.text('QUANTUM ENCRYPTION ACTIVE // PROTOCOL V4.2'), findsOneWidget);
      expect(find.text('Kaito Vance'), findsOneWidget);
      expect(find.text('3'), findsOneWidget); // Unread badge count

      await tester.tap(find.text('Kaito Vance'));
      expect(selectedId, 'thread_kaito');
    });

    testWidgets('DirectChatThreadScreen renders text, voice, and hologram bubbles', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      String? sentText;
      bool voiceSent = false;
      bool holoSent = false;

      await tester.pumpWidget(
        MaterialApp(
          theme: CyberTheme.darkTheme,
          home: DirectChatThreadScreen(
            thread: sampleThread,
            onSendText: (t) => sentText = t,
            onSendVoice: (dur, wf) => voiceSent = true,
            onSendHologram: (h) => holoSent = true,
            onBack: () {},
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Encrypted ping received'), findsOneWidget);
      expect(find.text('0:24'), findsOneWidget); // Voice waveform duration
      expect(find.text('3D SPATIAL HOLOGRAM'), findsOneWidget);

      // Send text message
      await tester.enterText(find.byType(TextField), 'Testing quantum signal');
      await tester.tap(find.byIcon(Icons.send_rounded));
      expect(sentText, 'Testing quantum signal');

      // Send voice message shortcut
      await tester.tap(find.byIcon(Icons.mic));
      expect(voiceSent, isTrue);

      // Send 3D Hologram shortcut
      await tester.tap(find.byTooltip('Send 3D Hologram'));
      expect(holoSent, isTrue);
    });

    testWidgets('CommentsDiscussionScreen renders pinned comments and replies', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      String? submittedComment;

      await tester.pumpWidget(
        MaterialApp(
          theme: CyberTheme.darkTheme,
          home: Scaffold(
            body: CommentsDiscussionScreen(
              postId: 'post_1',
              comments: [sampleComment],
              onAddComment: (t, {replyToId}) async => submittedComment = t,
              onClose: () {},
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('COMMENTS & DISCUSSION'), findsOneWidget);
      expect(find.text('PINNED'), findsOneWidget);
      expect(find.text('The volumetric bloom on the wet tarmac is unmatched!'), findsOneWidget);
      expect(find.text('Custom anamorphic prism with ISO 3200!'), findsOneWidget);

      // Quick Emoji Tap
      await tester.tap(find.text('🔥'));
      await tester.pump();

      // Tap POST button
      await tester.tap(find.text('POST'));
      expect(submittedComment, '🔥');
    });

    testWidgets('LiveStreamViewerScreen renders HUD, chat, and dispatches reactions', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      String? sentReaction;
      String? sentChat;

      final floatingReaction = FloatingReactionItem(
        id: 'r_1',
        emoji: '⚡',
        xOffset: 0.5,
        createdAt: DateTime.now(),
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: CyberTheme.darkTheme,
          home: LiveStreamViewerScreen(
            stream: sampleLiveStream,
            floatingReactions: [floatingReaction],
            onSendReaction: (r) => sentReaction = r,
            onSendChat: (t, {giftType}) => sentChat = t,
            onClose: () {},
          ),
        ),
      );
      await tester.pump();

      expect(find.text('kira_synth'), findsOneWidget);
      expect(find.text('LIVE'), findsOneWidget);
      expect(find.text('14200'), findsOneWidget);
      expect(find.text('⚡'), findsWidgets); // Floating particle

      // Tap Flame reaction button
      await tester.tap(find.text('🔥').last);
      expect(sentReaction, 'flame');

      // Submit chat
      await tester.enterText(find.byType(TextField), 'Tokyo broadcast live!');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      expect(sentChat, 'Tokyo broadcast live!');
    });
  });
}
