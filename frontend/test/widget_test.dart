import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:frontend/main.dart';
import 'test_http_overrides.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;
  HttpOverrides.global = TestHttpOverrides();

  testWidgets('TokyoGramApp smoke test', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(const TokyoGramApp());
    await tester.pump();

    expect(find.text('TOKYO'), findsOneWidget);
    expect(find.text('.GRAM'), findsOneWidget);
  });
}
