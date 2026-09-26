import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../domain/health.dart';
import '../domain/health_repository.dart';

class LocalHealthRepository implements HealthRepository {
  LocalHealthRepository(this.preferences);
  final SharedPreferencesAsync preferences;
  static const key = 'pulse.health.v1';
  @override
  Future<HealthState> load() async {
    final raw = await preferences.getString(key);
    if (raw == null) return HealthState();
    return HealthState.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  @override
  Future<void> save(HealthState state) =>
      preferences.setString(key, jsonEncode(state.toJson()));
}
