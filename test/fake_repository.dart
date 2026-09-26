import 'package:bmi_calculator/features/health/domain/health.dart';
import 'package:bmi_calculator/features/health/domain/health_repository.dart';

class FakeRepository implements HealthRepository {
  FakeRepository([HealthState? value]) : value = value ?? HealthState();
  HealthState value;
  bool fail = false;
  bool failLoad = false;
  @override
  Future<HealthState> load() async {
    if (failLoad) throw const FormatException('Corrupt data');
    return value;
  }

  @override
  Future<void> save(HealthState state) async {
    if (fail) throw Exception('Disk unavailable');
    value = state;
  }
}
