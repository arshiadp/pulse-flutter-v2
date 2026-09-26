import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:bmi_calculator/features/health/domain/health.dart';

void main() {
  test('BMI calculation and all category boundaries', () {
    expect(Bmi.calculate(170, 65), closeTo(22.491349, .00001));
    for (final entry in <double, String>{
      18.49: 'Underweight',
      18.5: 'Healthy weight',
      24.999: 'Healthy weight',
      25: 'Overweight',
      29.999: 'Overweight',
      30: 'Obesity · class 1',
      35: 'Obesity · class 2',
      40: 'Obesity · class 3',
    }.entries) {
      expect(Bmi.category(entry.key), entry.value);
    }
  });
  test('Reject zero, negative and non-finite inputs', () {
    for (final n in [0.0, -1.0, double.nan, double.infinity]) {
      expect(() => Bmi.calculate(n, 65), throwsArgumentError);
      expect(() => Bmi.calculate(170, n), throwsArgumentError);
    }
  });
  test('Unit conversions preserve precision', () {
    expect(Bmi.centimeters(67), closeTo(170.18, .0001));
    expect(Bmi.kilograms(Bmi.pounds(65.3)), closeTo(65.3, .000001));
    expect(Bmi.centimeters(Bmi.inches(171.6)), closeTo(171.6, .000001));
  });
  test('Versioned data round-trips and entries are immutable', () {
    final state = HealthState(
      units: Units.imperial,
      onboarded: true,
      entries: [
        CheckIn(date: DateTime(2026, 9, 1), heightCm: 170, weightKg: 65),
      ],
    );
    final restored = HealthState.fromJson(
      jsonDecode(jsonEncode(state.toJson())) as Map<String, dynamic>,
    );
    expect(restored.entries.single.bmi, closeTo(state.bmi, .00001));
    expect(restored.units, Units.imperial);
    expect(() => restored.entries.clear(), throwsUnsupportedError);
    expect(
      () => HealthState.fromJson({...state.toJson(), 'height': 0}),
      throwsFormatException,
    );
    expect(
      () => HealthState.fromJson({...state.toJson(), 'version': 99}),
      throwsFormatException,
    );
  });
}
