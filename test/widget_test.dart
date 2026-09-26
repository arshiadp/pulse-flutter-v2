import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bmi_calculator/app.dart';
import 'package:bmi_calculator/features/health/application/health_controller.dart';
import 'package:bmi_calculator/features/health/domain/health.dart';

import 'fake_repository.dart';

void main() {
  testWidgets(
    'Corrupt data can be reset through a working confirmation dialog',
    (tester) async {
      final repo = FakeRepository()..failLoad = true;
      await tester.pumpWidget(
        ProviderScope(
          overrides: [healthRepositoryProvider.overrideWithValue(repo)],
          child: const PulseApp(),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Reset saved data'));
      await tester.pumpAndSettle();
      expect(find.text('Reset local data?'), findsOneWidget);
      await tester.tap(find.text('Reset'));
      await tester.pumpAndSettle();
      expect(find.text('What is your height?'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets(
    'Small phone onboarding remains scrollable at larger text sizes',
    (tester) async {
      tester.view.physicalSize = const Size(320, 640);
      tester.view.devicePixelRatio = 1;
      tester.platformDispatcher.textScaleFactorTestValue = 1.5;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            healthRepositoryProvider.overrideWithValue(FakeRepository()),
          ],
          child: const PulseApp(),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await tester.ensureVisible(find.byType(CheckboxListTile));
      await tester.tap(find.byType(CheckboxListTile));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('Adult gate and complete onboarding save a check-in', (
    tester,
  ) async {
    final repo = FakeRepository();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [healthRepositoryProvider.overrideWithValue(repo)],
        child: const PulseApp(),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('What is your height?'), findsOneWidget);
    final button = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, 'Continue'),
    );
    expect(button.onPressed, isNull);
    await tester.ensureVisible(find.byType(CheckboxListTile));
    await tester.tap(find.byType(CheckboxListTile));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    expect(find.text('What is your weight?'), findsOneWidget);
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save & see my overview'));
    await tester.pumpAndSettle();
    expect(find.text('Know your rhythm.'), findsOneWidget);
    expect(repo.value.entries.length, 1);
    expect(tester.takeException(), isNull);
  });
  for (final size in [
    const Size(320, 640),
    const Size(390, 844),
    const Size(1200, 900),
  ]) {
    testWidgets('Dashboard navigation fits $size', (tester) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            healthRepositoryProvider.overrideWithValue(
              FakeRepository(HealthState(onboarded: true)),
            ),
          ],
          child: const PulseApp(),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      for (final label in ['Progress', 'Plan', 'Insights', 'Overview']) {
        await tester.tap(find.text(label));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      }
    });
  }
}
