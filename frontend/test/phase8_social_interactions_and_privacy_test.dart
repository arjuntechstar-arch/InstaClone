import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:frontend/data/models/user_model.dart';
import 'package:frontend/data/models/feed_model.dart';
import 'package:frontend/data/models/comment_model.dart';
import 'package:frontend/ui/core/cyber_theme.dart';
import 'package:frontend/ui/widgets/suggested_users_tray.dart';
import 'package:frontend/ui/widgets/post_card_widget.dart';
import 'package:frontend/ui/screens/user_profile_screen.dart';
import 'package:frontend/ui/screens/comments_discussion_screen.dart';
import 'test_http_overrides.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;
  HttpOverrides.global = TestHttpOverrides();

  final suggestedUsers = [
    const UserProfile(
      id: 'u4',
      username: 'rei_kusanagi',
      displayName: 'Rei Kusanagi',
      avatarUrl: 'https://example.com/rei.jpg',
      badge: 'STEALTH OPERATIVE',
      bio: 'Ghost in the neural network.',
      followersCount: 890,
      followingCount: 120,
      postsCount: 42,
      isPrivate: true,
      isFollowing: false,
      isFollowRequested: false,
      gallery: [],
    ),
    const UserProfile(
      id: 'u2',
      username: 'neon_kaito',
      displayName: 'Kaito Kuroba',
      avatarUrl: 'https://example.com/kaito.jpg',
      badge: 'CYBER ARCHITECT',
      bio: 'Building the quantum grid.',
      followersCount: 1540,
      followingCount: 300,
      postsCount: 65,
      isPrivate: false,
      isFollowing: false,
      isFollowRequested: false,
      gallery: [],
    ),
  ];

  final samplePost = PostItem(
    id: 'post_88',
    author: const PostAuthor(
      id: 'u1',
      username: 'cyber_ren',
      displayName: 'Ren Tanaka',
      avatarUrl: 'https://example.com/ren.jpg',
    ),
    mediaUrl: 'https://example.com/media.jpg',
    caption: 'Quantum mesh deployment successful. 🌌⚡',
    timestamp: '5m ago',
    likesCount: 104,
    commentsCount: 12,
    repostsCount: 37,
    isLiked: false,
    isSaved: false,
    isReposted: false,
  );

  group('Phase 8: Social Interactions, Suggested Users & Account Privacy Tests', () {
    testWidgets('SuggestedUsersTray renders suggested users with Follow & Dismiss actions', (tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      String? followedUserId;
      String? dismissedUserId;

      await tester.pumpWidget(
        MaterialApp(
          theme: CyberTheme.darkTheme,
          home: Scaffold(
            body: SuggestedUsersTray(
              users: suggestedUsers,
              onFollow: (id) => followedUserId = id,
              onDismiss: (id) => dismissedUserId = id,
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('SUGGESTED FOR YOU'), findsOneWidget);
      expect(find.text('@rei_kusanagi'), findsOneWidget);
      expect(find.text('@neon_kaito'), findsOneWidget);
      expect(find.text('Rei Kusanagi'), findsOneWidget);

      // Verify lock icon is rendered for private user
      expect(find.byIcon(Icons.lock), findsWidgets);

      // Rei is private, so button is 'REQUEST'
      final requestButton = find.text('REQUEST');
      expect(requestButton, findsOneWidget);
      await tester.tap(requestButton);
      await tester.pump();
      expect(followedUserId, 'rei_kusanagi');

      // Kaito is public, so button is 'FOLLOW'
      final followButton = find.text('FOLLOW');
      expect(followButton, findsOneWidget);
      await tester.tap(followButton);
      await tester.pump();
      expect(followedUserId, 'neon_kaito');

      // Tap dismiss on Kaito (Icons.close)
      final closeIcons = find.byIcon(Icons.close);
      expect(closeIcons, findsWidgets);
      await tester.tap(closeIcons.last);
      await tester.pump();
      expect(dismissedUserId, 'neon_kaito');
    });

    testWidgets('PostCardWidget renders Repost action and triggers callback', (tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      bool liked = false;
      bool saved = false;
      bool reposted = false;
      bool commented = false;
      bool shared = false;

      await tester.pumpWidget(
        MaterialApp(
          theme: CyberTheme.darkTheme,
          home: Scaffold(
            body: PostCardWidget(
              post: samplePost,
              onLike: () => liked = true,
              onSave: () => saved = true,
              onComment: () => commented = true,
              onShare: () => shared = true,
              onRepost: () => reposted = true,
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 300));

      // Verify repost count is displayed
      expect(find.text('37'), findsOneWidget);

      // Tap repost button (Icons.repeat_rounded)
      final repostBtn = find.byIcon(Icons.repeat_rounded);
      expect(repostBtn, findsOneWidget);
      await tester.tap(repostBtn);
      await tester.pump();
      expect(reposted, isTrue);

      // Tap like button
      final likeBtn = find.byIcon(Icons.favorite_border);
      expect(likeBtn, findsOneWidget);
      await tester.tap(likeBtn);
      await tester.pump();
      expect(liked, isTrue);
    });

    testWidgets('UserProfileScreen displays Private Lock HUD reticle when viewing locked private user', (tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      bool followRequested = false;

      final privateProfile = UserProfile(
        id: 'u4',
        username: 'rei_kusanagi',
        displayName: 'Rei Kusanagi',
        avatarUrl: 'https://example.com/rei.jpg',
        bio: 'Classified sector ghost operative.',
        followersCount: 890,
        followingCount: 120,
        postsCount: 42,
        isFollowing: false,
        isPrivate: true,
        isFollowRequested: false,
        badge: 'STEALTH OPERATIVE',
        gallery: const [
          GalleryItem(id: 'g9', type: 'image', imageUrl: 'https://example.com/classified.jpg', likesCount: 999),
        ],
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: CyberTheme.darkTheme,
          home: UserProfileScreen(
            profile: privateProfile,
            isCurrentUser: false,
            onToggleFollow: () => followRequested = true,
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 300));

      // Header shows lock icon
      expect(find.byIcon(Icons.lock), findsWidgets);

      // Lock Reticle is visible
      expect(find.text('THIS ACCOUNT IS PRIVATE'), findsOneWidget);
      expect(find.text('Follow this node to view their media, holographic reels, and telemetry streams.'), findsOneWidget);
      expect(find.text('REQUEST ACCESS'), findsWidgets);

      // Tapping REQUEST ACCESS triggers onToggleFollow
      await tester.tap(find.text('REQUEST ACCESS').first);
      await tester.pump();
      expect(followRequested, isTrue);
    });

    testWidgets('CommentsDiscussionScreen allows posting and displays comments interactively', (tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      String? submittedText;

      final initialComments = [
        const CommentItem(
          id: 'c1',
          postId: 'post_88',
          author: PostAuthor(
            id: 'u3',
            username: 'glitch_phantom',
            displayName: 'Glitch Phantom',
            avatarUrl: 'https://example.com/glitch.jpg',
          ),
          text: 'Signal calibrated at 99.8% precision.',
          timestamp: '2m ago',
          likesCount: 5,
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          theme: CyberTheme.darkTheme,
          home: Scaffold(
            body: CommentsDiscussionScreen(
              postId: 'post_88',
              comments: initialComments,
              onAddComment: (txt, {replyToId}) async => submittedText = txt,
              onClose: () {},
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('COMMENTS & DISCUSSION'), findsOneWidget);
      expect(find.text('Signal calibrated at 99.8% precision.'), findsOneWidget);

      // Enter comment in textfield and submit
      final inputField = find.byType(TextField);
      expect(inputField, findsOneWidget);
      await tester.enterText(inputField, 'Neural link acknowledged! 🚀');
      await tester.pump();

      final postButton = find.text('POST');
      expect(postButton, findsOneWidget);
      await tester.tap(postButton);
      await tester.pump();

      expect(submittedText, 'Neural link acknowledged! 🚀');
      // Optimistic comment added to list
      expect(find.text('Neural link acknowledged! 🚀'), findsOneWidget);
    });
  });
}
