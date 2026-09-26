import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bmi_calculator/features/health/application/health_controller.dart';
import 'package:bmi_calculator/features/health/domain/health.dart';

import 'fake_repository.dart';

void main() {
  late ProviderContainer container;
  late FakeRepository repository;
  setUp(() {
    repository = FakeRepository();
    container = ProviderContainer(
      overrides: [healthRepositoryProvider.overrideWithValue(repository)],
    );
  });
  tearDown(() => container.dispose());
  Future<void> save(double weight, DateTime date) => container
      .read(healthProvider.notifier)
      .checkIn(
        height: 170,
        weight: weight,
        units: Units.metric,
        days: 3,
        minutes: 30,
        firstDay: 1,
        now: date,
      );
  test(
    'Same-day saves update, different days append, history stays sorted',
    () async {
      await container.read(healthProvider.future);
      await save(65, DateTime(2026, 9, 2, 10));
      await save(66, DateTime(2026, 9, 2, 20));
      await save(64, DateTime(2026, 9, 1));
      expect(repository.value.entries.length, 2);
      expect(repository.value.entries.last.weightKg, 66);
      expect(repository.value.entries.first.weightKg, 64);
    },
  );
  test(
    'Concurrent writes are serialized and failure does not change state',
    () async {
      await container.read(healthProvider.future);
      await Future.wait([
        save(65, DateTime(2026, 9, 1)),
        save(66, DateTime(2026, 9, 2)),
      ]);
      expect(repository.value.entries.length, 2);
      repository.fail = true;
      await expectLater(save(80, DateTime(2026, 9, 3)), throwsException);
      expect(container.read(healthProvider).requireValue.weightKg, 66);
      repository.fail = false;
      await save(67, DateTime(2026, 9, 3));
      expect(repository.value.entries.length, 3);
    },
  );
  test('Delete and reset persist across a fresh container', () async {
    await container.read(healthProvider.future);
    await save(65, DateTime(2026, 9, 1));
    await container
        .read(healthProvider.notifier)
        .deleteEntry(DateTime(2026, 9, 1));
    expect(repository.value.entries, isEmpty);
    final second = ProviderContainer(
      overrides: [healthRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(second.dispose);
    expect((await second.read(healthProvider.future)).onboarded, isTrue);
    await second.read(healthProvider.notifier).reset();
    expect(repository.value.onboarded, isFalse);
  });
}
