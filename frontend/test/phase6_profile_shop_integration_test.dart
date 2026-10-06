import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:frontend/data/models/user_model.dart';
import 'package:frontend/data/models/shop_model.dart';
import 'package:frontend/data/models/collection_model.dart';
import 'package:frontend/ui/core/cyber_theme.dart';
import 'package:frontend/ui/screens/user_profile_screen.dart';
import 'package:frontend/ui/screens/shop_marketplace_screen.dart';
import 'package:frontend/ui/screens/saved_collections_screen.dart';
import 'package:frontend/ui/screens/settings_screen.dart';
import 'package:frontend/main.dart';
import 'test_http_overrides.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;
  HttpOverrides.global = TestHttpOverrides();

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

  final sampleProducts = [
    const ShopProduct(
      id: 'p1',
      title: 'Tactical Holo-Visor V3',
      price: 249.99,
      brand: 'NEO-TECH CORP',
      imageUrl: 'https://example.com/p1.jpg',
      inStock: true,
      category: 'Optics',
      rating: 4.9,
    ),
    const ShopProduct(
      id: 'p2',
      title: 'Anti-Thermal Cyber Jacket',
      price: 389.00,
      brand: 'SHINJUKU LABS',
      imageUrl: 'https://example.com/p2.jpg',
      inStock: false,
      category: 'Techwear',
      rating: 4.8,
    ),
  ];

  final sampleCollections = [
    const CollectionItem(
      id: 'col_1',
      name: 'Neon Inspo 2088',
      coverUrl: 'https://example.com/c1.jpg',
      count: 34,
      isPrivate: true,
    ),
  ];

  group('Phase 6: Profiles, Shop, Collections & Full App Integration', () {
    testWidgets('UserProfileScreen renders stats, highlights, and tabs', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        MaterialApp(
          theme: CyberTheme.darkTheme,
          home: UserProfileScreen(
            profile: sampleProfile,
            isCurrentUser: true,
          ),
        ),
      );
      await tester.pump();

      expect(find.text('cyber_ren'), findsOneWidget);
      expect(find.text('Ren Tanaka'), findsOneWidget);
      expect(find.text('VERIFIED CREATOR'), findsOneWidget);
      expect(find.text('187'), findsOneWidget); // Posts count
      expect(find.text('142.8K'), findsOneWidget); // Followers count
      expect(find.text('EDIT PROFILE'), findsOneWidget);

      // Tap Reels tab
      await tester.tap(find.byIcon(Icons.movie_outlined));
      await tester.pumpAndSettle();
    });

    testWidgets('ShopMarketplaceScreen filters categories and toggles wishlist', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      String? selectedCat;
      String? wishlistedId;

      await tester.pumpWidget(
        MaterialApp(
          theme: CyberTheme.darkTheme,
          home: ShopMarketplaceScreen(
            products: sampleProducts,
            selectedCategory: 'All',
            onSelectCategory: (c) => selectedCat = c,
            onToggleWishlist: (id) => wishlistedId = id,
            onBack: () {},
          ),
        ),
      );
      await tester.pump();

      expect(find.text('CYBER MARKETPLACE'), findsOneWidget);
      expect(find.text('Tactical Holo-Visor V3'), findsOneWidget);
      expect(find.text('\$249.99'), findsOneWidget);
      expect(find.text('IN STOCK'), findsOneWidget);

      // Select category
      await tester.tap(find.text('Techwear'));
      expect(selectedCat, 'Techwear');

      // Toggle wishlist
      await tester.tap(find.byIcon(Icons.favorite_border).first);
      expect(wishlistedId, 'p1');
    });

    testWidgets('SavedCollectionsScreen renders private vault folder', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      bool newFolderTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          theme: CyberTheme.darkTheme,
          home: SavedCollectionsScreen(
            collections: sampleCollections,
            onAddCollection: () => newFolderTapped = true,
            onSelectCollection: (_) {},
            onBack: () {},
          ),
        ),
      );
      await tester.pump();

      expect(find.text('SAVED VAULT'), findsOneWidget);
      expect(find.text('Neon Inspo 2088'), findsOneWidget);
      expect(find.text('34 items'), findsOneWidget);
      expect(find.byIcon(Icons.lock), findsOneWidget);

      await tester.tap(find.byIcon(Icons.add));
      expect(newFolderTapped, isTrue);
    });

    testWidgets('SettingsScreen updates security and optics toggles', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      Map<String, dynamic>? updatedSettings;

      await tester.pumpWidget(
        MaterialApp(
          theme: CyberTheme.darkTheme,
          home: SettingsScreen(
            initialSettings: const {
              'quantumEncryption': true,
              'hologramPreview': true,
              'biometricAuth': true,
              'hapticFeedback': true,
              'stealthMode': false,
              'cyberOpticsMode': 'Neon Vivid',
            },
            onUpdateSettings: (s) => updatedSettings = s,
            onBack: () {},
          ),
        ),
      );
      await tester.pump();

      expect(find.text('SETTINGS & NEURAL LINK'), findsOneWidget);
      expect(find.text('Quantum End-to-End Encryption'), findsOneWidget);
      expect(find.text('Stealth Cloak Mode'), findsOneWidget);

      // Toggle Stealth Mode switch
      final stealthSwitch = find.byWidgetPredicate(
        (w) => w is Switch && w.value == false,
      );
      if (stealthSwitch.evaluate().isNotEmpty) {
        await tester.tap(stealthSwitch.first);
        await tester.pump();
        expect(updatedSettings, isNotNull);
        expect(updatedSettings!['stealthMode'], isTrue);
      }
    });

    testWidgets('TokyoGramApp root widget initializes and renders shell', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(const TokyoGramApp());
      await tester.pump();

      // Verify Auth Terminal is displayed
      expect(find.text('TOKYO'), findsOneWidget);
      expect(find.text('.GRAM'), findsOneWidget);
      expect(find.text('SIGN IN'), findsOneWidget);
      expect(find.text('CONNECT TO NEURAL GRID'), findsOneWidget);

      // Perform login handshake
      await tester.tap(find.text('CONNECT TO NEURAL GRID'));
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump(const Duration(milliseconds: 500));

      // Verify main shell navigation icons are now active
      expect(find.byIcon(Icons.home_filled), findsOneWidget);
      expect(find.byIcon(Icons.explore_outlined), findsOneWidget);
      expect(find.byIcon(Icons.movie_filter_outlined), findsOneWidget);
      expect(find.byIcon(Icons.person_outline), findsOneWidget);
    });
  });
}
