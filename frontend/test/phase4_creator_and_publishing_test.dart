import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:frontend/ui/core/cyber_theme.dart';
import 'package:frontend/ui/screens/create_camera_screen.dart';
import 'package:frontend/ui/screens/new_post_publishing_screen.dart';
import 'package:frontend/ui/screens/audio_sound_page_screen.dart';
import 'test_http_overrides.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;
  HttpOverrides.global = TestHttpOverrides();

  group('Phase 4: Creator Studio & Publishing Tests', () {
    testWidgets('CreateCameraScreen filter selection and shutter capture', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      Map<String, dynamic>? capturedResult;
      bool closed = false;

      await tester.pumpWidget(
        MaterialApp(
          theme: CyberTheme.darkTheme,
          home: CreateCameraScreen(
            onCapture: (data) => capturedResult = data,
            onClose: () => closed = true,
          ),
        ),
      );
      await tester.pump();

      expect(find.text('NORMAL'), findsOneWidget);
      expect(find.text('NEON GLITCH'), findsOneWidget);

      // Tap filter "NEON GLITCH"
      await tester.tap(find.text('NEON GLITCH'));
      await tester.pump();

      // Tap shutter button
      await tester.tap(find.byIcon(Icons.camera));
      expect(capturedResult, isNotNull);
      expect(capturedResult!['filterName'], 'NEON GLITCH');
      expect(capturedResult!['mediaUrl'], isNotEmpty);

      // Close button
      await tester.tap(find.byIcon(Icons.close));
      expect(closed, isTrue);
    });

    testWidgets('NewPostPublishingScreen publishes post with payload', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      Map<String, dynamic>? publishedPayload;

      await tester.pumpWidget(
        MaterialApp(
          theme: CyberTheme.darkTheme,
          home: NewPostPublishingScreen(
            mediaUrl: 'https://example.com/captured.jpg',
            filterName: 'NEON GLITCH',
            onPublish: (data) async => publishedPayload = data,
            onCancel: () {},
          ),
        ),
      );
      await tester.pump();

      expect(find.text('NEW NEURAL POST'), findsOneWidget);
      expect(find.text('#cyberpunk'), findsOneWidget);

      // Add hashtag
      await tester.tap(find.text('#cyberpunk'));
      await tester.pump();

      // Enter caption
      await tester.enterText(find.byType(TextField), 'Testing cyberpunk transmitter #cyberpunk');
      await tester.pump();

      // Tap SHARE button
      final shareBtn = find.text('SHARE');
      await tester.ensureVisible(shareBtn);
      await tester.tap(shareBtn);
      await tester.pump();

      expect(publishedPayload, isNotNull);
      expect(publishedPayload!['filterName'], 'NEON GLITCH');
      expect(publishedPayload!['tags'], contains('cyberpunk'));
    });

    testWidgets('AudioSoundPageScreen renders and plays audio', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      bool usedAudio = false;

      await tester.pumpWidget(
        MaterialApp(
          theme: CyberTheme.darkTheme,
          home: AudioSoundPageScreen(
            trackTitle: 'Kavinsky - Nightcall',
            artistName: 'Synthwave Records',
            coverUrl: 'https://example.com/cover.jpg',
            reelsCount: 14280,
            onUseAudio: () => usedAudio = true,
            onBack: () {},
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Kavinsky - Nightcall'), findsOneWidget);
      expect(find.text('Synthwave Records'), findsOneWidget);
      expect(find.text('USE AUDIO'), findsOneWidget);

      // Play audio toggle
      final playBtn = find.byIcon(Icons.play_arrow).first;
      await tester.tap(playBtn);
      await tester.pump();
      expect(find.byIcon(Icons.pause), findsOneWidget);

      // Use audio button
      await tester.tap(find.text('USE AUDIO'));
      expect(usedAudio, isTrue);
    });
  });
}
