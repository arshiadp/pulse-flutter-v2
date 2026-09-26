// Run: flutter test tool/render_previews.dart
// These screenshots use an isolated in-memory repository; no sample data ships in the app.
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bmi_calculator/app.dart';
import 'package:bmi_calculator/features/health/application/health_controller.dart';
import 'package:bmi_calculator/features/health/domain/health.dart';
import '../test/fake_repository.dart';

void main() {
  testWidgets('Render real Flutter screens', (tester) async {
    await tester.runAsync(() async {
      final loader = FontLoader('PulseSans');
      for (final name in ['Regular', 'Medium', 'Bold', 'Black']) {
        loader.addFont(
          File(
            'assets/fonts/Roboto-$name.ttf',
          ).readAsBytes().then(ByteData.sublistView),
        );
      }
      await loader.load();
      final icons = FontLoader('MaterialIcons')
        ..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'));
      await icons.load();
    });
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final boundary = GlobalKey();
    Future<void> capture(String name) async {
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      final render =
          boundary.currentContext!.findRenderObject()! as RenderRepaintBoundary;
      await tester.runAsync(() async {
        final image = await render.toImage(pixelRatio: 2);
        final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
        await File(
          'docs/previews/$name.png',
        ).writeAsBytes(bytes!.buffer.asUint8List());
        image.dispose();
      });
    }

    final repo = FakeRepository();
    await tester.pumpWidget(
      RepaintBoundary(
        key: boundary,
        child: ProviderScope(
          overrides: [healthRepositoryProvider.overrideWithValue(repo)],
          child: const PulseApp(),
        ),
      ),
    );
    await capture('01-height');
    await tester.tap(find.byType(CheckboxListTile));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Continue'));
    await capture('02-weight');
    await tester.tap(find.text('Continue'));
    await capture('03-plan');
    await tester.tap(find.text('Save & see my overview'));
    await capture('04-overview');
    await tester.pumpWidget(const SizedBox());
    await tester.pumpAndSettle();
    final demo = HealthState(
      onboarded: true,
      weightKg: 65,
      entries: [
        for (int i = 0; i < 8; i++)
          CheckIn(
            date: DateTime(2026, 9, 5 + i * 3),
            heightCm: 170,
            weightKg: [66.2, 66.0, 66.3, 65.8, 65.9, 65.4, 65.2, 65.0][i],
          ),
      ],
    );
    tester.view.physicalSize = const Size(1440, 1000);
    await tester.pumpWidget(
      RepaintBoundary(
        key: boundary,
        child: ProviderScope(
          overrides: [
            healthRepositoryProvider.overrideWithValue(FakeRepository(demo)),
          ],
          child: const PulseApp(),
        ),
      ),
    );
    await capture('05-desktop-demo');
  });
}
