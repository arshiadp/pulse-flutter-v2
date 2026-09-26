import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/app_theme.dart';
import '../../domain/health.dart';

class PulseBackground extends StatelessWidget {
  const PulseBackground({super.key, required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: const BoxDecoration(
      gradient: RadialGradient(
        center: Alignment(.5, -1.1),
        radius: 1.2,
        colors: [Color(0xFF234647), Color(0xFF0B131B)],
        stops: [0, .75],
      ),
    ),
    child: child,
  );
}

class Panel extends StatelessWidget {
  const Panel({super.key, required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(
      color: surface,
      borderRadius: BorderRadius.circular(28),
      border: Border.all(color: Colors.white.withValues(alpha: .05)),
    ),
    child: child,
  );
}

class Eyebrow extends StatelessWidget {
  const Eyebrow(this.text, {super.key});
  final String text;
  @override
  Widget build(BuildContext context) => Text(
    text,
    style: const TextStyle(
      fontSize: 11,
      color: muted,
      letterSpacing: 2,
      fontWeight: FontWeight.w700,
    ),
  );
}

class BmiSummary extends StatelessWidget {
  const BmiSummary({
    super.key,
    required this.height,
    required this.weight,
    this.compact = false,
  });
  final double height, weight;
  final bool compact;
  @override
  Widget build(BuildContext context) {
    final bmi = Bmi.calculate(height, weight);
    return Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Eyebrow('YOUR BODY MASS INDEX'),
          const SizedBox(height: 12),
          Wrap(
            spacing: 16,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                bmi.toStringAsFixed(1),
                style: const TextStyle(
                  fontSize: 52,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -2,
                ),
              ),
              Chip(
                label: Text(Bmi.category(bmi)),
                backgroundColor: mint.withValues(alpha: .1),
                labelStyle: const TextStyle(color: mint),
                side: BorderSide.none,
              ),
            ],
          ),
          if (!compact) ...[
            const SizedBox(height: 18),
            Align(
              alignment: Alignment(((bmi - 10) / 30).clamp(0, 1) * 2 - 1, 0),
              child: const Icon(Icons.arrow_drop_down, size: 24),
            ),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: const Row(
                children: [
                  Expanded(
                    flex: 85,
                    child: ColoredBox(
                      color: Color(0xFF82B9DC),
                      child: SizedBox(height: 7),
                    ),
                  ),
                  Expanded(
                    flex: 65,
                    child: ColoredBox(
                      color: Color(0xFFA7F3CE),
                      child: SizedBox(height: 7),
                    ),
                  ),
                  Expanded(
                    flex: 50,
                    child: ColoredBox(
                      color: Color(0xFFFFD29D),
                      child: SizedBox(height: 7),
                    ),
                  ),
                  Expanded(
                    flex: 100,
                    child: ColoredBox(
                      color: Color(0xFFD88B7E),
                      child: SizedBox(height: 7),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 12),
          const Text(
            'A screening measure, not a diagnosis.',
            style: TextStyle(color: muted, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class Ruler extends StatelessWidget {
  const Ruler({
    super.key,
    required this.value,
    required this.min,
    required this.max,
    required this.divisions,
    required this.label,
    required this.onChanged,
  });
  final double value, min, max;
  final int divisions;
  final String label;
  final ValueChanged<double> onChanged;
  @override
  Widget build(BuildContext context) => Column(
    children: [
      SizedBox(
        height: 48,
        width: double.infinity,
        child: CustomPaint(painter: _RulerPainter()),
      ),
      Slider(
        value: value.clamp(min, max),
        min: min,
        max: max,
        divisions: divisions,
        label: label,
        semanticFormatterCallback: (_) => label,
        onChanged: onChanged,
      ),
      const Text(
        'Slide to adjust · tap the number to type',
        style: TextStyle(color: muted, fontSize: 12),
      ),
    ],
  );
}

class _RulerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF718891)
      ..strokeWidth = 1;
    for (int i = 0; i <= 40; i++) {
      final x = i * size.width / 40;
      canvas.drawLine(
        Offset(x, size.height),
        Offset(x, i % 5 == 0 ? 20 : 38),
        paint,
      );
    }
    canvas.drawLine(
      Offset(size.width / 2, 0),
      Offset(size.width / 2, size.height),
      Paint()
        ..color = mint
        ..strokeWidth = 2,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

String dateLabel(DateTime d) =>
    '${d.day} ${const ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'][d.month - 1]} ${d.year}';

class TrendChart extends StatelessWidget {
  const TrendChart({super.key, required this.entries, required this.units});
  final List<CheckIn> entries;
  final Units units;
  @override
  Widget build(BuildContext context) {
    if (entries.length < 2) {
      return const SizedBox(
        height: 140,
        child: Center(
          child: Text(
            'Your story starts here.\nAdd a check-in on another day to see your trend.',
            textAlign: TextAlign.center,
            style: TextStyle(color: muted, height: 1.6),
          ),
        ),
      );
    }
    final values = entries
        .map((e) => units == Units.metric ? e.weightKg : Bmi.pounds(e.weightKg))
        .toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${values.reduce(math.min).toStringAsFixed(1)}–${values.reduce(math.max).toStringAsFixed(1)} ${units == Units.metric ? 'kg' : 'lb'}',
          style: const TextStyle(color: muted),
        ),
        const SizedBox(height: 16),
        Semantics(
          label: 'Weight trend. Exact measurements are listed below.',
          child: SizedBox(
            height: 140,
            width: double.infinity,
            child: CustomPaint(painter: _TrendPainter(entries, values)),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              dateLabel(entries.first.date),
              style: const TextStyle(color: muted, fontSize: 12),
            ),
            Text(
              dateLabel(entries.last.date),
              style: const TextStyle(color: muted, fontSize: 12),
            ),
          ],
        ),
      ],
    );
  }
}

class _TrendPainter extends CustomPainter {
  _TrendPainter(this.entries, this.values);
  final List<CheckIn> entries;
  final List<double> values;
  @override
  void paint(Canvas canvas, Size size) {
    final low = values.reduce(math.min) - 1, high = values.reduce(math.max) + 1;
    final duration = entries.last.date.difference(entries.first.date).inSeconds;
    final points = List.generate(
      values.length,
      (i) => Offset(
        4 +
            entries[i].date.difference(entries.first.date).inSeconds /
                math.max(1, duration) *
                (size.width - 8),
        4 + (high - values[i]) / (high - low) * (size.height - 8),
      ),
    );
    for (int i = 0; i < 4; i++) {
      final y = i * size.height / 3;
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        Paint()
          ..color = const Color(0xFF2E3D46)
          ..strokeWidth = 1,
      );
    }
    final path = Path()..moveTo(points.first.dx, points.first.dy);
    for (final p in points.skip(1)) {
      path.lineTo(p.dx, p.dy);
    }
    canvas.drawPath(
      path,
      Paint()
        ..color = mint
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5,
    );
    for (final p in points) {
      canvas.drawCircle(p, 4, Paint()..color = mint);
    }
  }

  @override
  bool shouldRepaint(covariant _TrendPainter oldDelegate) =>
      oldDelegate.entries != entries || oldDelegate.values != values;
}
