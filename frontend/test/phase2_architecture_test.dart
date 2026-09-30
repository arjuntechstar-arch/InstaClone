import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/ui/core/cyber_colors.dart';
import 'package:frontend/ui/core/cyber_theme.dart';
import 'package:frontend/ui/core/cyber_widgets.dart';
import 'package:frontend/data/models/feed_model.dart';
import 'package:frontend/data/models/story_model.dart';
import 'package:frontend/data/models/reel_model.dart';
import 'package:frontend/data/models/message_model.dart';
import 'package:frontend/viewmodels/feed_viewmodel.dart';
import 'package:frontend/viewmodels/reel_viewmodel.dart';
import 'package:frontend/viewmodels/chat_viewmodel.dart';
import 'package:frontend/viewmodels/live_viewmodel.dart';
import 'package:frontend/viewmodels/shop_viewmodel.dart';

import 'package:google_fonts/google_fonts.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;

  group('Phase 2: Cyberpunk Design Tokens & Theme', () {
    test('CyberColors match Neon Tokyo specifications', () {
      expect(CyberColors.primaryHotPink, const Color(0xFFFF2D78));
      expect(CyberColors.secondaryCyan, const Color(0xFF00FFCC));
      expect(CyberColors.tertiaryYellow, const Color(0xFFFFE04A));
      expect(CyberColors.bgVoid, const Color(0xFF0A0A12));
    });

    test('CyberTheme initializes valid dark ThemeData', () {
      final theme = CyberTheme.darkTheme;
      expect(theme.brightness, Brightness.dark);
      expect(theme.scaffoldBackgroundColor, CyberColors.bgVoid);
      expect(theme.primaryColor, CyberColors.primaryHotPink);
    });

    testWidgets('CyberButton renders and fires onTap', (WidgetTester tester) async {
      bool tapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CyberButton(
              label: 'JACK IN',
              onPressed: () => tapped = true,
            ),
          ),
        ),
      );

      expect(find.text('JACK IN'), findsOneWidget);
      await tester.tap(find.text('JACK IN'));
      expect(tapped, isTrue);
    });

    testWidgets('CyberBadge and CyberAvatar render correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                CyberBadge(text: 'ONLINE', color: CyberColors.secondaryCyan),
                CyberAvatar(radius: 20, isLive: true),
              ],
            ),
          ),
        ),
      );

      expect(find.text('ONLINE'), findsOneWidget);
      expect(find.text('LIVE'), findsOneWidget);
    });
  });

  group('Phase 2: Domain Data Models & Serialization', () {
    test('PostItem serializes and deserializes correctly', () {
      final json = {
        'id': 'p_101',
        'author': {
          'id': 'u_ren',
          'username': 'cyber_ren',
          'displayName': 'Ren Tanaka',
          'avatarUrl': 'https://example.com/avatar.jpg',
          'isVerified': true,
        },
        'mediaUrl': 'https://example.com/feed.jpg',
        'caption': 'Cyberpunk night in Neo-Tokyo #neon',
        'timestamp': '5m ago',
        'likesCount': 500,
        'commentsCount': 25,
        'isLiked': true,
        'isSaved': false,
        'musicTrack': 'Synthwave 2088',
        'location': 'Shibuya Sky',
        'filterName': 'Neon Glitch',
        'tags': ['neon', 'tokyo'],
      };

      final post = PostItem.fromJson(json);
      expect(post.id, 'p_101');
      expect(post.author.username, 'cyber_ren');
      expect(post.likesCount, 500);
      expect(post.isLiked, isTrue);

      final encoded = post.toJson();
      expect(encoded['id'], 'p_101');
      expect(encoded['musicTrack'], 'Synthwave 2088');
    });

    test('StoryItem & StoryPoll voting data structure', () {
      final json = {
        'id': 's_1',
        'userId': 'u1',
        'username': 'cyber_ren',
        'avatarUrl': 'https://example.com/ren.jpg',
        'mediaUrl': 'https://example.com/story.jpg',
        'timestamp': '10m ago',
        'hasUnseen': true,
        'poll': {
          'question': 'Cyan or Pink?',
          'options': [
            {'text': 'Cyan HUD', 'votes': 40},
            {'text': 'Hot Pink UV', 'votes': 60},
          ],
          'userVoted': 1,
        }
      };

      final story = StoryItem.fromJson(json);
      expect(story.poll, isNotNull);
      expect(story.poll!.options.length, 2);
      expect(story.poll!.options[1].votes, 60);
      expect(story.poll!.userVoted, 1);
    });

    test('ReelItem serializes properly', () {
      final json = {
        'id': 'r_1',
        'author': {
          'id': 'u3',
          'username': 'kira_synth',
          'displayName': 'Kira',
          'avatarUrl': 'https://example.com/kira.jpg',
          'isVerified': true,
        },
        'videoUrl': 'https://example.com/reel.mp4',
        'caption': 'Anti-grav speed test',
        'musicTrack': 'Turbo Killer',
        'likesCount': 42000,
        'commentsCount': 1200,
        'sharesCount': 5000,
        'isLiked': true,
        'isSaved': true,
        'isFollowing': true,
      };

      final reel = ReelItem.fromJson(json);
      expect(reel.likesCount, 42000);
      expect(reel.isFollowing, isTrue);
    });

    test('ChatMessage voice waveform and 3D hologram serialization', () {
      final voiceJson = {
        'id': 'm_v1',
        'sender': 'kaito',
        'text': 'Audio Voice Waveform',
        'duration': '0:22',
        'waveform': [20, 60, 80, 40, 95],
        'isEncrypted': true,
        'timestamp': '9:40 PM',
        'type': 'voice',
      };

      final msg = ChatMessage.fromJson(voiceJson);
      expect(msg.type, 'voice');
      expect(msg.waveform, [20, 60, 80, 40, 95]);
      expect(msg.duration, '0:22');
      expect(msg.isEncrypted, isTrue);
    });
  });

  group('Phase 2: State ViewModels Verification', () {
    test('FeedViewModel initializes, toggles like & save optimistically', () async {
      final vm = FeedViewModel();
      await vm.init();

      expect(vm.posts.isNotEmpty, isTrue);
      final initialPost = vm.posts.first;
      final initialLikes = initialPost.likesCount;
      final initialLiked = initialPost.isLiked;

      await vm.toggleLike(initialPost.id);
      expect(vm.posts.first.isLiked, !initialLiked);
      expect(vm.posts.first.likesCount, initialLiked ? initialLikes - 1 : initialLikes + 1);

      final initialSaved = initialPost.isSaved;
      await vm.toggleSave(initialPost.id);
      expect(vm.posts.first.isSaved, !initialSaved);
    });

    test('FeedViewModel votes on story poll', () async {
      final vm = FeedViewModel();
      await vm.init();

      expect(vm.stories.isNotEmpty, isTrue);
      final storyWithPoll = vm.stories.firstWhere((s) => s.poll != null);
      final initialVotes = storyWithPoll.poll!.options[0].votes;

      await vm.voteStoryPoll(storyWithPoll.id, 0);
      final updatedStory = vm.stories.firstWhere((s) => s.id == storyWithPoll.id);
      expect(updatedStory.poll!.options[0].votes, initialVotes + 1);
      expect(updatedStory.poll!.userVoted, 0);
    });

    test('ReelViewModel navigation and interactions', () async {
      final vm = ReelViewModel();
      await vm.init();

      expect(vm.reels.isNotEmpty, isTrue);
      vm.onPageChanged(1);
      expect(vm.currentIndex, 1);

      final initialLiked = vm.reels.first.isLiked;
      await vm.toggleLike(vm.reels.first.id);
      expect(vm.reels.first.isLiked, !initialLiked);
    });

    test('ChatViewModel message composition & state append', () async {
      final vm = ChatViewModel();
      await vm.init();

      expect(vm.threads.isNotEmpty, isTrue);
      final initialCount = vm.activeThread!.messages.length;

      await vm.sendTextMessage('Neural connection established');
      expect(vm.activeThread!.messages.length, initialCount + 1);
      expect(vm.activeThread!.messages.last.text, 'Neural connection established');

      await vm.sendVoiceMessage('0:15', [30, 70, 90]);
      expect(vm.activeThread!.messages.last.type, 'voice');
      expect(vm.activeThread!.messages.last.duration, '0:15');

      await vm.sendHologramMessage('3D Mesh Model');
      expect(vm.activeThread!.messages.last.type, 'hologram');
    });

    test('LiveViewModel particle spawn & live chat dispatch', () async {
      final vm = LiveViewModel();
      await vm.init();

      expect(vm.stream, isNotNull);
      expect(vm.floatingReactions.isEmpty, isTrue);

      vm.spawnReaction('🔥');
      expect(vm.floatingReactions.length, 1);
      expect(vm.floatingReactions.first.emoji, '🔥');

      final initialChatCount = vm.stream!.chatMessages.length;
      await vm.sendChatMessage('Tokyo cyber drop incoming!');
      expect(vm.stream!.chatMessages.length, initialChatCount + 1);
      expect(vm.stream!.chatMessages.last.text, 'Tokyo cyber drop incoming!');
    });

    test('ShopViewModel filtering and wishlist', () async {
      final vm = ShopViewModel();
      await vm.init();

      expect(vm.products.isNotEmpty, isTrue);
      final initialWishlist = vm.products.first.isWishlisted;

      vm.toggleWishlist(vm.products.first.id);
      expect(vm.products.first.isWishlisted, !initialWishlist);

      vm.filterCategory('Optics');
      expect(vm.selectedCategory, 'Optics');
      for (final p in vm.filteredProducts) {
        expect(p.category.toLowerCase(), 'optics');
      }
    });
  });
}
