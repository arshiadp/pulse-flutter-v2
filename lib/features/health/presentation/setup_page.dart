import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/app_theme.dart';
import '../application/health_controller.dart';
import '../domain/health.dart';
import 'widgets/pulse_widgets.dart';

class SetupPage extends ConsumerStatefulWidget {
  const SetupPage({super.key, required this.initial, this.editing = false});
  final HealthState initial;
  final bool editing;
  @override
  ConsumerState<SetupPage> createState() => _SetupPageState();
}

class _SetupPageState extends ConsumerState<SetupPage> {
  late double height = widget.initial.heightCm,
      weight = widget.initial.weightKg;
  late Units units = widget.initial.units;
  late int days = widget.initial.days,
      minutes = widget.initial.minutes,
      firstDay = widget.initial.firstDay;
  int step = 0;
  bool adult = false, saving = false;
  String? error;
  Future<void> save() async {
    setState(() {
      saving = true;
      error = null;
    });
    try {
      await ref
          .read(healthProvider.notifier)
          .checkIn(
            height: height,
            weight: weight,
            units: units,
            days: days,
            minutes: minutes,
            firstDay: firstDay,
          );
      if (mounted && widget.editing) Navigator.pop(context);
    } catch (_) {
      if (mounted) {
        setState(
          () => error =
              'Could not save. Your entries are unchanged. Please try again.',
        );
      }
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }

  Future<void> enterNumber(bool isHeight) async {
    final metric = units == Units.metric;
    final value = isHeight
        ? (metric ? height : Bmi.inches(height))
        : (metric ? weight : Bmi.pounds(weight));
    final controller = TextEditingController(text: value.toStringAsFixed(1));
    final form = GlobalKey<FormState>();
    final result = await showDialog<double>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          isHeight
              ? 'Height in ${metric ? 'cm' : 'total inches'}'
              : 'Weight in ${metric ? 'kg' : 'lb'}',
        ),
        content: Form(
          key: form,
          child: TextFormField(
            controller: controller,
            autofocus: true,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            validator: (text) {
              final n = double.tryParse((text ?? '').replaceAll(',', '.'));
              if (n == null || !n.isFinite) return 'Enter a valid number';
              final canonical = metric
                  ? n
                  : (isHeight ? Bmi.centimeters(n) : Bmi.kilograms(n));
              if (canonical < (isHeight ? 100 : 30) ||
                  canonical > (isHeight ? 230 : 250)) {
                return isHeight
                    ? 'Range: 100–230 cm / 39.4–90.5 in'
                    : 'Range: 30–250 kg / 66.2–551.1 lb';
              }
              return null;
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              if (form.currentState!.validate()) {
                Navigator.pop(
                  context,
                  double.parse(controller.text.replaceAll(',', '.')),
                );
              }
            },
            child: const Text('Apply'),
          ),
        ],
      ),
    );
    await Future<void>.delayed(const Duration(milliseconds: 300));
    controller.dispose();
    if (result != null && mounted) {
      setState(() {
        if (isHeight) {
          height = metric ? result : Bmi.centimeters(result);
        } else {
          weight = metric ? result : Bmi.kilograms(result);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final metric = units == Units.metric;
    final totalInches = Bmi.inches(height).round();
    final heightText = metric
        ? '${height.toStringAsFixed(0)} cm'
        : '${totalInches ~/ 12} ft ${totalInches % 12} in';
    final weightText =
        '${(metric ? weight : Bmi.pounds(weight)).toStringAsFixed(1)} ${metric ? 'kg' : 'lb'}';
    return PopScope(
      canPop: !saving,
      child: Scaffold(
        body: PulseBackground(
          child: SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 540),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 24, 8),
                      child: Row(
                        children: [
                          IconButton.filledTonal(
                            tooltip: 'Back',
                            onPressed: saving || (step == 0 && !widget.editing)
                                ? null
                                : () {
                                    if (step > 0) {
                                      setState(() => step--);
                                    } else if (widget.editing) {
                                      Navigator.pop(context);
                                    }
                                  },
                            icon: const Icon(Icons.arrow_back_rounded),
                          ),
                          const Expanded(
                            child: Center(
                              child: FittedBox(
                                child: Text(
                                  'pulse',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: -1,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Text(
                            '${step + 1} / 3',
                            style: const TextStyle(color: muted, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 28,
                        vertical: 16,
                      ),
                      child: Row(
                        children: List.generate(
                          3,
                          (i) => Expanded(
                            child: Container(
                              height: 3,
                              margin: const EdgeInsets.symmetric(horizontal: 3),
                              decoration: BoxDecoration(
                                color: i <= step ? mint : surface,
                                borderRadius: BorderRadius.circular(5),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(28, 8, 28, 24),
                        child: Column(
                          children: [
                            Eyebrow(
                              [
                                'A LITTLE ABOUT YOU',
                                'FIND YOUR STARTING POINT',
                                'MAKE ROOM FOR MOVEMENT',
                              ][step],
                            ),
                            const SizedBox(height: 18),
                            Text(
                              [
                                'What is your height?',
                                'What is your weight?',
                                'Set your weekly rhythm',
                              ][step],
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w700,
                                letterSpacing: -.8,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              [
                                'A small detail. A more personal picture.',
                                'One measurement is a starting point, not the whole story.',
                                'Choose a routine that fits your life. You can change it anytime.',
                              ][step],
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: muted, height: 1.7),
                            ),
                            const SizedBox(height: 20),
                            if (step < 2) ...[
                              SegmentedButton<Units>(
                                segments: [
                                  ButtonSegment(
                                    value: Units.metric,
                                    label: Text(step == 0 ? 'cm' : 'kg'),
                                  ),
                                  ButtonSegment(
                                    value: Units.imperial,
                                    label: Text(step == 0 ? 'ft / in' : 'lb'),
                                  ),
                                ],
                                selected: {units},
                                showSelectedIcon: false,
                                onSelectionChanged: (v) =>
                                    setState(() => units = v.first),
                              ),
                              const SizedBox(height: 20),
                              TextButton(
                                onPressed: () => enterNumber(step == 0),
                                child: Text(
                                  step == 0 ? heightText : weightText,
                                  style: const TextStyle(
                                    fontSize: 48,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                    letterSpacing: -2,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              Ruler(
                                value: step == 0 ? height : weight,
                                min: step == 0 ? 100 : 30,
                                max: step == 0 ? 230 : 250,
                                divisions: step == 0 ? 130 : 2200,
                                label: step == 0 ? heightText : weightText,
                                onChanged: (v) => setState(() {
                                  if (step == 0) {
                                    height = v;
                                  } else {
                                    weight = v;
                                  }
                                }),
                              ),
                              const SizedBox(height: 20),
                              if (step == 0 && !widget.editing)
                                CheckboxListTile(
                                  value: adult,
                                  contentPadding: EdgeInsets.zero,
                                  controlAffinity:
                                      ListTileControlAffinity.leading,
                                  onChanged: (v) => setState(() => adult = v!),
                                  title: const Text(
                                    'I am 20 or older',
                                    style: TextStyle(fontSize: 14),
                                  ),
                                  subtitle: const Text(
                                    'This calculator uses adult BMI categories.',
                                    style: TextStyle(
                                      color: muted,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              if (step == 1)
                                BmiSummary(
                                  height: height,
                                  weight: weight,
                                  compact: true,
                                ),
                            ] else ...[
                              const Eyebrow('ACTIVE DAYS PER WEEK'),
                              const SizedBox(height: 18),
                              Wrap(
                                spacing: 10,
                                runSpacing: 10,
                                alignment: WrapAlignment.center,
                                children: List.generate(
                                  7,
                                  (i) => SizedBox(
                                    width: 62,
                                    height: 52,
                                    child: ChoiceChip(
                                      showCheckmark: false,
                                      selected: days == i + 1,
                                      label: Text('${i + 1}'),
                                      selectedColor: mint,
                                      labelStyle: TextStyle(
                                        color: days == i + 1
                                            ? Colors.black
                                            : Colors.white,
                                        fontWeight: FontWeight.w700,
                                      ),
                                      onSelected: (_) =>
                                          setState(() => days = i + 1),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 30),
                              Text(
                                '$minutes minutes per active day',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Slider(
                                value: minutes.toDouble(),
                                min: 10,
                                max: 90,
                                divisions: 16,
                                label: '$minutes min',
                                onChanged: (v) =>
                                    setState(() => minutes = v.round()),
                              ),
                              const SizedBox(height: 16),
                              DropdownButtonFormField<int>(
                                isExpanded: true,
                                initialValue: firstDay,
                                decoration: const InputDecoration(
                                  labelText: 'First day of your week',
                                ),
                                items: List.generate(
                                  7,
                                  (i) => DropdownMenuItem(
                                    value: i + 1,
                                    child: Text(
                                      const [
                                        'Monday',
                                        'Tuesday',
                                        'Wednesday',
                                        'Thursday',
                                        'Friday',
                                        'Saturday',
                                        'Sunday',
                                      ][i],
                                    ),
                                  ),
                                ),
                                onChanged: (v) => setState(() => firstDay = v!),
                              ),
                              const SizedBox(height: 24),
                              Panel(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${days * minutes} min / week',
                                      style: const TextStyle(
                                        fontSize: 26,
                                        fontWeight: FontWeight.bold,
                                        color: mint,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    const Text(
                                      'WHO recommends 150–300 minutes of moderate aerobic activity per week for adults. Start small and build gradually.',
                                      style: TextStyle(
                                        color: muted,
                                        height: 1.6,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                            if (error != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 16),
                                child: Text(
                                  error!,
                                  style: const TextStyle(
                                    color: Colors.orangeAccent,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(28, 8, 28, 20),
                      child: SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed:
                              saving || (step == 0 && !adult && !widget.editing)
                              ? null
                              : () {
                                  if (step < 2) {
                                    setState(() => step++);
                                  } else {
                                    save();
                                  }
                                },
                          child: Text(
                            saving
                                ? 'Saving…'
                                : step == 2
                                ? 'Save & see my overview'
                                : 'Continue',
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
