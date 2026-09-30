import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:frontend/data/models/feed_model.dart';
import 'package:frontend/data/models/story_model.dart';
import 'package:frontend/data/models/reel_model.dart';
import 'package:frontend/ui/core/cyber_theme.dart';
import 'package:frontend/ui/screens/home_feed_screen.dart';
import 'package:frontend/ui/screens/story_viewer_screen.dart';
import 'package:frontend/ui/screens/reels_screen.dart';
import 'package:frontend/ui/screens/explore_screen.dart';
import 'package:frontend/ui/screens/main_shell_screen.dart';
import 'package:frontend/ui/widgets/post_card_widget.dart';
import 'package:frontend/ui/widgets/story_tray_widget.dart';
import 'test_http_overrides.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;
  HttpOverrides.global = TestHttpOverrides();

  final samplePost = PostItem(
    id: 'test_post_1',
    author: const PostAuthor(
      id: 'u1',
      username: 'cyber_ren',
      displayName: 'Ren Tanaka',
      avatarUrl: 'https://example.com/ren.jpg',
      isVerified: true,
    ),
    mediaUrl: 'https://example.com/neon.jpg',
    caption: 'Neon pulse in Neo-Tokyo #cyber',
    timestamp: '15m ago',
    likesCount: 120,
    commentsCount: 14,
    musicTrack: 'Nightcall 2088',
    location: 'Shinjuku Sector 4',
  );

  final sampleStory = StoryItem(
    id: 'test_story_1',
    userId: 'u1',
    username: 'cyber_ren',
    avatarUrl: 'https://example.com/ren.jpg',
    mediaUrl: 'https://example.com/story.jpg',
    timestamp: '25m ago',
    hasUnseen: true,
    poll: const StoryPoll(
      question: 'Which cyber optics?',
      options: [
        PollOption(text: 'Cyan HUD', votes: 10),
        PollOption(text: 'Hot Pink UV', votes: 20),
      ],
      userVoted: null,
    ),
  );

  final sampleReel = ReelItem(
    id: 'test_reel_1',
    author: const PostAuthor(
      id: 'u3',
      username: 'kira_synth',
      displayName: 'Kira',
      avatarUrl: 'https://example.com/kira.jpg',
      isVerified: true,
    ),
    videoUrl: 'https://example.com/reel.mp4',
    caption: 'Anti-grav speed test in Shibuya sky-lanes',
    musicTrack: 'Turbo Killer',
    likesCount: 4500,
    commentsCount: 300,
    sharesCount: 150,
  );

  group('Phase 3: Social Navigation & Main Feeds', () {
    testWidgets('PostCardWidget renders metadata and triggers actions', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      bool liked = false;
      bool saved = false;
      bool commented = false;

      await tester.pumpWidget(
        MaterialApp(
          theme: CyberTheme.darkTheme,
          home: Scaffold(
            body: SingleChildScrollView(
              child: PostCardWidget(
                post: samplePost,
                onLike: () => liked = true,
                onSave: () => saved = true,
                onComment: () => commented = true,
                onShare: () {},
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('cyber_ren'), findsWidgets);
      expect(find.text('120 likes'), findsOneWidget);
      expect(find.text('Nightcall 2088'), findsOneWidget);

      // Tap like button
      final likeBtn = find.byIcon(Icons.favorite_border);
      await tester.ensureVisible(likeBtn);
      await tester.tap(likeBtn);
      expect(liked, isTrue);

      // Tap bookmark save button
      final saveBtn = find.byIcon(Icons.bookmark_border);
      await tester.ensureVisible(saveBtn);
      await tester.tap(saveBtn);
      expect(saved, isTrue);

      // Tap comment button
      final commentBtn = find.byIcon(Icons.chat_bubble_outline);
      await tester.ensureVisible(commentBtn);
      await tester.tap(commentBtn);
      expect(commented, isTrue);
    });

    testWidgets('StoryTrayWidget renders stories and add-story button', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      bool storyClicked = false;
      bool addStoryClicked = false;

      await tester.pumpWidget(
        MaterialApp(
          theme: CyberTheme.darkTheme,
          home: Scaffold(
            body: StoryTrayWidget(
              stories: [sampleStory],
              onStorySelected: (s) => storyClicked = true,
              onAddStory: () => addStoryClicked = true,
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Your Story'), findsOneWidget);
      expect(find.text('cyber_ren'), findsOneWidget);

      await tester.tap(find.text('cyber_ren'));
      expect(storyClicked, isTrue);

      await tester.tap(find.text('Your Story'));
      expect(addStoryClicked, isTrue);
    });

    testWidgets('HomeFeedScreen renders logo, appbar shortcuts and feed', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        MaterialApp(
          theme: CyberTheme.darkTheme,
          home: HomeFeedScreen(
            posts: [samplePost],
            stories: [sampleStory],
            isLoading: false,
            onRefresh: () async {},
            onLikePost: (_) {},
            onSavePost: (_) {},
            onCommentPost: (_) {},
            onSharePost: (_) {},
            onStorySelected: (_) {},
            onAddStory: () {},
            onOpenDMs: () {},
            onOpenNotifications: () {},
            onOpenLiveStream: () {},
            onOpenCreateCamera: () {},
          ),
        ),
      );
      await tester.pump();

      expect(find.text('TOKYO'), findsOneWidget);
      expect(find.text('.GRAM'), findsOneWidget);
      expect(find.byIcon(Icons.sensors), findsOneWidget);
      expect(find.byTooltip('Activity'), findsOneWidget);
      expect(find.byTooltip('Direct Messages'), findsOneWidget);
    });

    testWidgets('StoryViewerScreen renders poll and handles voting', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      int votedIndex = -1;

      await tester.pumpWidget(
        MaterialApp(
          theme: CyberTheme.darkTheme,
          home: StoryViewerScreen(
            stories: [sampleStory],
            onVotePoll: (id, idx) => votedIndex = idx,
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Which cyber optics?'), findsOneWidget);
      expect(find.text('Cyan HUD'), findsOneWidget);
      expect(find.text('Hot Pink UV'), findsOneWidget);

      // Vote on option 0
      await tester.tap(find.text('Cyan HUD'));
      expect(votedIndex, 0);
    });

    testWidgets('ReelsScreen renders action buttons and follow toggle', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      bool likeReelCalled = false;
      bool followCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          theme: CyberTheme.darkTheme,
          home: ReelsScreen(
            reels: [sampleReel],
            onLike: (_) => likeReelCalled = true,
            onSave: (_) {},
            onFollow: (_) => followCalled = true,
            onComment: (_) {},
            onShare: (_) {},
          ),
        ),
      );
      await tester.pump();

      expect(find.text('REELS'), findsOneWidget);
      expect(find.text('4500'), findsOneWidget);
      expect(find.text('FOLLOW'), findsOneWidget);

      await tester.tap(find.text('FOLLOW'));
      expect(followCalled, isTrue);

      await tester.tap(find.byIcon(Icons.favorite_border));
      expect(likeReelCalled, isTrue);
    });

    testWidgets('ExploreScreen renders chips and grid items', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      String? selectedTag;

      await tester.pumpWidget(
        MaterialApp(
          theme: CyberTheme.darkTheme,
          home: ExploreScreen(
            exploreData: {
              'trendingTags': ['#NeoTokyo', '#CyberdeckMod'],
              'gridItems': [
                {'id': 'e1', 'type': 'image', 'imageUrl': 'https://example.com/1.jpg', 'likesCount': 500}
              ]
            },
            onTagSelected: (tag) => selectedTag = tag,
          ),
        ),
      );
      await tester.pump();

      expect(find.text('#NeoTokyo'), findsOneWidget);
      expect(find.text('#CyberdeckMod'), findsOneWidget);

      await tester.tap(find.text('#CyberdeckMod'));
      expect(selectedTag, '#CyberdeckMod');
    });

    testWidgets('MainShellScreen bottom nav bar tab switching', (WidgetTester tester) async {
      int selectedTab = 0;

      await tester.pumpWidget(
        MaterialApp(
          theme: CyberTheme.darkTheme,
          home: StatefulBuilder(
            builder: (context, setState) {
              return MainShellScreen(
                currentIndex: selectedTab,
                onTabSelected: (idx) {
                  setState(() => selectedTab = idx);
                },
                currentScreen: Text('Active Tab: $selectedTab'),
              );
            },
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Active Tab: 0'), findsOneWidget);

      // Tap Explore icon (tab 1)
      await tester.tap(find.byIcon(Icons.explore_outlined));
      await tester.pump();
      expect(selectedTab, 1);
      expect(find.text('Active Tab: 1'), findsOneWidget);

      // Tap Reels icon (tab 3)
      await tester.tap(find.byIcon(Icons.movie_filter_outlined));
      await tester.pump();
      expect(selectedTab, 3);
      expect(find.text('Active Tab: 3'), findsOneWidget);
    });
  });
}
