enum Units { metric, imperial }

class Bmi {
  static double calculate(double heightCm, double weightKg) {
    if (!heightCm.isFinite ||
        !weightKg.isFinite ||
        heightCm <= 0 ||
        weightKg <= 0) {
      throw ArgumentError('Height and weight must be positive, finite values.');
    }
    return weightKg / ((heightCm / 100) * (heightCm / 100));
  }

  static String category(double value) {
    if (value < 18.5) return 'Underweight';
    if (value < 25) return 'Healthy weight';
    if (value < 30) return 'Overweight';
    if (value < 35) return 'Obesity · class 1';
    if (value < 40) return 'Obesity · class 2';
    return 'Obesity · class 3';
  }

  static double pounds(double kg) => kg * 2.2046226218;
  static double kilograms(double lb) => lb / 2.2046226218;
  static double inches(double cm) => cm / 2.54;
  static double centimeters(double inches) => inches * 2.54;
}

class CheckIn {
  const CheckIn({
    required this.date,
    required this.heightCm,
    required this.weightKg,
  });
  final DateTime date;
  final double heightCm;
  final double weightKg;
  double get bmi => Bmi.calculate(heightCm, weightKg);
  Map<String, Object> toJson() => {
    'date': date.toIso8601String(),
    'height': heightCm,
    'weight': weightKg,
  };
  factory CheckIn.fromJson(Map<String, dynamic> json) {
    final height = (json['height'] as num).toDouble();
    final weight = (json['weight'] as num).toDouble();
    if (!height.isFinite ||
        !weight.isFinite ||
        height < 100 ||
        height > 230 ||
        weight < 30 ||
        weight > 250) {
      throw const FormatException('Invalid measurement');
    }
    return CheckIn(
      date: DateTime.parse(json['date'] as String),
      heightCm: height,
      weightKg: weight,
    );
  }
}

class HealthState {
  HealthState({
    this.heightCm = 170,
    this.weightKg = 65,
    this.units = Units.metric,
    this.days = 3,
    this.minutes = 30,
    this.firstDay = 1,
    this.onboarded = false,
    List<CheckIn> entries = const [],
  }) : entries = List.unmodifiable(entries);
  final double heightCm, weightKg;
  final Units units;
  final int days, minutes, firstDay;
  final bool onboarded;
  final List<CheckIn> entries;
  double get bmi => Bmi.calculate(heightCm, weightKg);
  HealthState copyWith({
    double? heightCm,
    double? weightKg,
    Units? units,
    int? days,
    int? minutes,
    int? firstDay,
    bool? onboarded,
    List<CheckIn>? entries,
  }) => HealthState(
    heightCm: heightCm ?? this.heightCm,
    weightKg: weightKg ?? this.weightKg,
    units: units ?? this.units,
    days: days ?? this.days,
    minutes: minutes ?? this.minutes,
    firstDay: firstDay ?? this.firstDay,
    onboarded: onboarded ?? this.onboarded,
    entries: entries ?? this.entries,
  );
  Map<String, Object> toJson() => {
    'version': 1,
    'height': heightCm,
    'weight': weightKg,
    'units': units.name,
    'days': days,
    'minutes': minutes,
    'firstDay': firstDay,
    'onboarded': onboarded,
    'entries': entries.map((e) => e.toJson()).toList(),
  };
  factory HealthState.fromJson(Map<String, dynamic> json) {
    if (json['version'] != 1) {
      throw const FormatException('Unsupported saved data');
    }
    final height = (json['height'] as num).toDouble();
    final weight = (json['weight'] as num).toDouble();
    final days = json['days'] as int;
    final minutes = json['minutes'] as int;
    final firstDay = json['firstDay'] as int;
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
      throw const FormatException('Invalid saved data');
    }
    return HealthState(
      heightCm: height,
      weightKg: weight,
      units: Units.values.byName(json['units'] as String),
      days: days,
      minutes: minutes,
      firstDay: firstDay,
      onboarded: json['onboarded'] as bool,
      entries: (json['entries'] as List)
          .map((e) => CheckIn.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
    );
  }
}
