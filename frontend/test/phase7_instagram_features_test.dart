import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:frontend/data/models/user_model.dart';
import 'package:frontend/data/models/feed_model.dart';
import 'package:frontend/ui/core/cyber_theme.dart';
import 'package:frontend/ui/widgets/share_post_sheet.dart';
import 'package:frontend/ui/widgets/story_creator_sheet.dart';
import 'package:frontend/ui/screens/post_detail_screen.dart';
import 'package:frontend/ui/screens/user_profile_screen.dart';
import 'test_http_overrides.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;
  HttpOverrides.global = TestHttpOverrides();

  final samplePost = PostItem(
    id: 'post_test_1',
    author: const PostAuthor(
      id: 'u1',
      username: 'cyber_ren',
      displayName: 'Ren Tanaka',
      avatarUrl: 'https://example.com/avatar.jpg',
    ),
    mediaUrl: 'https://example.com/media.jpg',
    caption: 'Neon alleyways of Neo-Tokyo Sector 7',
    timestamp: '10m ago',
    likesCount: 1337,
    commentsCount: 42,
    isLiked: false,
    isSaved: false,
  );

  final sampleProfile = UserProfile(
    id: 'u1',
    username: 'cyber_ren',
    displayName: 'Ren Tanaka',
    avatarUrl: 'https://example.com/ren.jpg',
    bio: 'Cybernetic optics architect & nightscape photographer. ⚡🌆',
    followersCount: 142800,
    followingCount: 492,
    postsCount: 187,
    isFollowing: false,
    isVerified: true,
    badge: 'VERIFIED CREATOR',
    gallery: const [
      GalleryItem(id: 'g1', type: 'image', imageUrl: 'https://example.com/1.jpg', likesCount: 2400),
      GalleryItem(id: 'g2', type: 'video', imageUrl: 'https://example.com/2.jpg', likesCount: 5120),
    ],
  );

  group('Instagram-Grade Features Verification', () {
    testWidgets('SharePostSheet renders contacts and triggers onSend', (tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      String? sentRecipient;
      String? sentNote;

      await tester.pumpWidget(
        MaterialApp(
          theme: CyberTheme.darkTheme,
          home: Scaffold(
            body: SharePostSheet(
              post: samplePost,
              onSend: (recipient, note) {
                sentRecipient = recipient;
                sentNote = note;
              },
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('SHARE TO QUANTUM DIRECT'), findsOneWidget);
      expect(find.textContaining('@neon_kaito'), findsOneWidget);
      expect(find.textContaining('@kira_synth'), findsOneWidget);

      // Tap Send on first contact
      final sendButtons = find.text('SEND');
      expect(sendButtons, findsWidgets);

      await tester.tap(sendButtons.first);
      await tester.pump(const Duration(milliseconds: 300));

      expect(sentRecipient, isNotNull);
      expect(sentRecipient, 'neon_kaito');
    });

    testWidgets('StoryCreatorSheet renders background selector, caption and broadcasts story', (tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      String? broadcastMedia;
      String? broadcastCaption;
      String? broadcastPollQ;
      List<String>? broadcastPollOpts;

      await tester.pumpWidget(
        MaterialApp(
          theme: CyberTheme.darkTheme,
          home: Scaffold(
            body: StoryCreatorSheet(
              onPublish: ({
                required mediaUrl,
                caption,
                pollQuestion,
                pollOptions,
              }) {
                broadcastMedia = mediaUrl;
                broadcastCaption = caption;
                broadcastPollQ = pollQuestion;
                broadcastPollOpts = pollOptions;
              },
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('MINT NEURAL STORY'), findsOneWidget);
      expect(find.text('SELECT HOLOGRAM FEED'), findsOneWidget);
      expect(find.text('ATTACH INTERACTIVE POLL'), findsOneWidget);

      // Enter caption
      final captionField = find.byType(TextField).first;
      await tester.enterText(captionField, 'Night vibes in Akihabara ⚡');
      await tester.pump();

      // Tap Broadcast button
      final publishBtn = find.text('BROADCAST STORY TO TIMELINE');
      expect(publishBtn, findsOneWidget);

      await tester.tap(publishBtn);
      await tester.pump(const Duration(milliseconds: 300));

      expect(broadcastMedia, isNotNull);
      expect(broadcastCaption, 'Night vibes in Akihabara ⚡');
      expect(broadcastPollQ, isNotNull);
      expect(broadcastPollOpts, isNotNull);
      expect(broadcastPollOpts!.length, 2);
    });

    testWidgets('PostDetailScreen renders telemetry and handles user actions', (tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      bool liked = false;
      bool saved = false;
      bool commented = false;
      bool shared = false;

      await tester.pumpWidget(
        MaterialApp(
          theme: CyberTheme.darkTheme,
          home: PostDetailScreen(
            post: samplePost,
            onLike: () => liked = true,
            onSave: () => saved = true,
            onComment: () => commented = true,
            onShare: () => shared = true,
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('POST TELEMETRY'), findsOneWidget);
      expect(find.text('cyber_ren'), findsOneWidget);

      // Verify caption in RichText
      expect(
        find.byWidgetPredicate(
          (w) => w is RichText && w.text.toPlainText().contains('Neon alleyways of Neo-Tokyo Sector 7'),
        ),
        findsOneWidget,
      );

      // Tap like
      final likeIcon = find.byIcon(Icons.favorite_border);
      expect(likeIcon, findsOneWidget);
      await tester.tap(likeIcon);
      expect(liked, isTrue);

      // Tap comment
      final commentIcon = find.byIcon(Icons.chat_bubble_outline);
      expect(commentIcon, findsOneWidget);
      await tester.tap(commentIcon);
      expect(commented, isTrue);

      // Tap share
      final shareIcon = find.byIcon(Icons.send_rounded);
      expect(shareIcon, findsOneWidget);
      await tester.tap(shareIcon);
      expect(shared, isTrue);

      // Tap bookmark
      final bookmarkIcon = find.byIcon(Icons.bookmark_border);
      expect(bookmarkIcon, findsOneWidget);
      await tester.tap(bookmarkIcon);
      expect(saved, isTrue);
    });

    testWidgets('UserProfileScreen renders edit profile, share profile, and role switch chips', (tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      String? switchedUsername;
      GalleryItem? selectedItem;

      await tester.pumpWidget(
        MaterialApp(
          theme: CyberTheme.darkTheme,
          home: UserProfileScreen(
            profile: sampleProfile,
            isCurrentUser: true,
            onSwitchPersona: (u) => switchedUsername = u,
            onPostSelected: (item) => selectedItem = item,
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('EDIT PROFILE'), findsOneWidget);
      expect(find.text('SHARE PROFILE'), findsOneWidget);
      expect(find.text('QUICK SWITCH NEURAL PERSONA'), findsOneWidget);
      expect(find.text('@cyber_ren'), findsOneWidget);
      expect(find.text('@neon_kaito'), findsOneWidget);

      // Switch persona by tapping @neon_kaito
      await tester.tap(find.text('@neon_kaito'));
      await tester.pump(const Duration(milliseconds: 300));
      expect(switchedUsername, 'neon_kaito');

      // Tap Edit Profile button to open sheet
      await tester.tap(find.text('EDIT PROFILE'));
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.text('EDIT NEURAL IDENTITY'), findsOneWidget);
      expect(find.text('SAVE IDENTITY UPDATES'), findsOneWidget);

      // Close sheet
      await tester.tap(find.byIcon(Icons.close), warnIfMissed: false);
      await tester.pump(const Duration(milliseconds: 500));

      // Tap gallery item to trigger onPostSelected
      final galleryGridFinder = find.byType(GridView);
      expect(galleryGridFinder, findsWidgets);

      final firstGalleryTile = find.byType(GestureDetector).first;
      await tester.tap(firstGalleryTile, warnIfMissed: false);
      await tester.pump(const Duration(milliseconds: 300));
    });
  });
}
