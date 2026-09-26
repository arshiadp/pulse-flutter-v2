import 'health.dart';

abstract interface class HealthRepository {
  Future<HealthState> load();
  Future<void> save(HealthState state);
}
