import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/local_health_repository.dart';
import '../domain/health.dart';
import '../domain/health_repository.dart';

final healthRepositoryProvider = Provider<HealthRepository>(
  (ref) => LocalHealthRepository(SharedPreferencesAsync()),
);
final healthProvider = AsyncNotifierProvider<HealthController, HealthState>(
  HealthController.new,
  retry: (_, _) => null,
);

class HealthController extends AsyncNotifier<HealthState> {
  @override
  Future<HealthState> build() => ref.watch(healthRepositoryProvider).load();
  Future<void> _tail = Future.value();
  Future<void> _commit(HealthState Function(HealthState) transform) {
    final operation = _tail.then((_) async {
      final current = state.requireValue;
      final next = transform(current);
      await ref.read(healthRepositoryProvider).save(next);
      state = AsyncData(next);
    });
    _tail = operation.then<void>((_) {}, onError: (Object _, StackTrace __) {});
    return operation;
  }

  Future<void> checkIn({
    required double height,
    required double weight,
    required Units units,
    required int days,
    required int minutes,
    required int firstDay,
    DateTime? now,
  }) {
    if (!height.isFinite ||
        !weight.isFinite ||
        height < 100 ||
        height > 230 ||
        weight < 30 ||
        weight > 250 ||
        days < 1 ||
        days > 7 ||
        minutes < 10 ||
        minutes > 90 ||
        firstDay < 1 ||
        firstDay > 7) {
      return Future.error(ArgumentError('Invalid measurements or plan'));
    }
    return _commit((current) {
      final time = now ?? DateTime.now();
      final date = DateTime(time.year, time.month, time.day);
      final entries = current.entries.where((e) => e.date != date).toList()
        ..add(CheckIn(date: date, heightCm: height, weightKg: weight))
        ..sort((a, b) => a.date.compareTo(b.date));
      return current.copyWith(
        heightCm: height,
        weightKg: weight,
        units: units,
        days: days,
        minutes: minutes,
        firstDay: firstDay,
        onboarded: true,
        entries: entries,
      );
    });
  }

  Future<void> deleteEntry(DateTime date) => _commit(
    (s) => s.copyWith(entries: s.entries.where((e) => e.date != date).toList()),
  );
  Future<void> reset() {
    final operation = _tail.then((_) async {
      final next = HealthState();
      await ref.read(healthRepositoryProvider).save(next);
      state = AsyncData(next);
    });
    _tail = operation.then<void>((_) {}, onError: (Object _, StackTrace __) {});
    return operation;
  }
}
