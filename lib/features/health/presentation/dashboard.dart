import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/app_theme.dart';
import '../application/health_controller.dart';
import '../domain/health.dart';
import 'setup_page.dart';
import 'widgets/pulse_widgets.dart';

class Dashboard extends ConsumerStatefulWidget {
  const Dashboard({super.key});
  @override
  ConsumerState<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends ConsumerState<Dashboard> {
  int tab = 0;
  bool busy = false;
  Future<void> action(Future<void> Function() run, String success) async {
    setState(() => busy = true);
    try {
      await run();
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(success)));
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not complete this action. Please try again.'),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  void edit(HealthState data) => Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => SetupPage(initial: data, editing: true),
    ),
  );
  Future<bool> confirm(String title, String body) async =>
      await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(title),
          content: Text(body),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Delete'),
            ),
          ],
        ),
      ) ??
      false;
  @override
  Widget build(BuildContext context) {
    final data = ref.watch(healthProvider).requireValue;
    return Scaffold(
      body: PulseBackground(
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, box) {
              final wide = box.maxWidth >= 900;
              final page = SingleChildScrollView(
                padding: EdgeInsets.all(wide ? 40 : 24),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1120),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.blur_on_rounded,
                              color: mint,
                              size: 30,
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'pulse',
                              style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -1,
                              ),
                            ),
                            const Spacer(),
                            const Icon(
                              Icons.lock_outline_rounded,
                              color: muted,
                              size: 14,
                            ),
                            const SizedBox(width: 6),
                            if (box.maxWidth >= 360)
                              const Text(
                                'On-device',
                                style: TextStyle(color: muted, fontSize: 12),
                              ),
                          ],
                        ),
                        const SizedBox(height: 40),
                        Eyebrow(
                          [
                            'YOUR EVERYDAY OVERVIEW',
                            'SMALL STEPS, BIGGER PICTURE',
                            'A ROUTINE THAT FITS',
                            'KNOW THE CONTEXT',
                          ][tab],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          [
                            'Know your rhythm.',
                            'Your progress.',
                            'Make time for you.',
                            'More than a number.',
                          ][tab],
                          style: const TextStyle(
                            fontSize: 34,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -1.2,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          [
                            'Check in with your body. Move at your own pace.',
                            'A longer view is more useful than a single day.',
                            'Consistency starts with a realistic plan.',
                            'Understand what BMI can — and cannot — tell you.',
                          ][tab],
                          style: const TextStyle(color: muted, height: 1.6),
                        ),
                        const SizedBox(height: 28),
                        if (tab == 0) overview(data, wide),
                        if (tab == 1) history(data),
                        if (tab == 2) plan(data),
                        if (tab == 3) insights(data),
                        const SizedBox(height: 32),
                        const Text(
                          'Made for your pace.  •  PULSE 2.0',
                          style: TextStyle(
                            color: muted,
                            fontSize: 11,
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
              return Row(
                children: [
                  if (wide)
                    NavigationRail(
                      backgroundColor: Colors.transparent,
                      selectedIndex: tab,
                      onDestinationSelected: (v) => setState(() => tab = v),
                      labelType: NavigationRailLabelType.all,
                      destinations: const [
                        NavigationRailDestination(
                          icon: Icon(Icons.grid_view_rounded),
                          label: Text('Overview'),
                        ),
                        NavigationRailDestination(
                          icon: Icon(Icons.show_chart_rounded),
                          label: Text('Progress'),
                        ),
                        NavigationRailDestination(
                          icon: Icon(Icons.calendar_today_rounded),
                          label: Text('Plan'),
                        ),
                        NavigationRailDestination(
                          icon: Icon(Icons.lightbulb_outline_rounded),
                          label: Text('Insights'),
                        ),
                      ],
                    ),
                  Expanded(child: page),
                ],
              );
            },
          ),
        ),
      ),
      bottomNavigationBar: MediaQuery.sizeOf(context).width >= 900
          ? null
          : NavigationBar(
              selectedIndex: tab,
              onDestinationSelected: (v) => setState(() => tab = v),
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.grid_view_rounded),
                  label: 'Overview',
                ),
                NavigationDestination(
                  icon: Icon(Icons.show_chart_rounded),
                  label: 'Progress',
                ),
                NavigationDestination(
                  icon: Icon(Icons.calendar_today_rounded),
                  label: 'Plan',
                ),
                NavigationDestination(
                  icon: Icon(Icons.lightbulb_outline_rounded),
                  label: 'Insights',
                ),
              ],
            ),
    );
  }

  Widget overview(HealthState data, bool wide) {
    final primary = Column(
      children: [
        BmiSummary(height: data.heightCm, weight: data.weightKg),
        const SizedBox(height: 18),
        Panel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Eyebrow('WEIGHT OVER TIME'),
              const SizedBox(height: 20),
              TrendChart(entries: data.entries, units: data.units),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => setState(() => tab = 1),
                child: const Text('View all check-ins'),
              ),
            ],
          ),
        ),
      ],
    );
    final secondary = Column(
      children: [
        Panel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Eyebrow('CURRENT MEASUREMENTS'),
              const SizedBox(height: 20),
              Text(
                weightLabel(data.weightKg, data.units),
                style: const TextStyle(
                  fontSize: 38,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${data.heightCm.toStringAsFixed(1)} cm tall',
                style: const TextStyle(color: muted),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () => edit(data),
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('New check-in'),
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Saving again today updates today’s entry.',
                style: TextStyle(color: muted, fontSize: 11),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        Panel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.bolt_rounded, color: lavender, size: 32),
              const SizedBox(height: 16),
              const Eyebrow('YOUR WEEKLY PLAN'),
              const SizedBox(height: 12),
              Text(
                '${data.days} days · ${data.days * data.minutes} min',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'A plan, not a performance score. Every bit of movement counts.',
                style: TextStyle(color: muted, height: 1.6),
              ),
              TextButton(
                onPressed: () => setState(() => tab = 2),
                child: const Text('Explore your plan'),
              ),
            ],
          ),
        ),
      ],
    );
    if (!wide) {
      return Column(children: [primary, const SizedBox(height: 18), secondary]);
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: 3, child: primary),
        const SizedBox(width: 20),
        Expanded(flex: 2, child: secondary),
      ],
    );
  }

  String weightLabel(double kg, Units units) =>
      '${(units == Units.metric ? kg : Bmi.pounds(kg)).toStringAsFixed(1)} ${units == Units.metric ? 'kg' : 'lb'}';
  Widget history(HealthState data) => Column(
    children: [
      Panel(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Eyebrow('YOUR MEASUREMENTS'),
            const SizedBox(height: 20),
            TrendChart(entries: data.entries, units: data.units),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 8,
              children: [
                FilledButton.icon(
                  onPressed: () => edit(data),
                  icon: const Icon(Icons.add),
                  label: const Text('Check in'),
                ),
                OutlinedButton.icon(
                  onPressed: busy || data.entries.isEmpty
                      ? null
                      : () => action(() async {
                          final csv = [
                            'date,height_cm,weight_kg,bmi',
                            ...data.entries.map(
                              (e) =>
                                  '${e.date.toIso8601String().split('T').first},${e.heightCm.toStringAsFixed(2)},${e.weightKg.toStringAsFixed(2)},${e.bmi.toStringAsFixed(2)}',
                            ),
                          ].join('\n');
                          await Clipboard.setData(ClipboardData(text: csv));
                        }, 'CSV copied to clipboard'),
                  icon: const Icon(Icons.copy_rounded),
                  label: const Text('Copy CSV'),
                ),
              ],
            ),
          ],
        ),
      ),
      const SizedBox(height: 18),
      if (data.entries.isEmpty)
        const Panel(
          child: Text('No check-ins yet. Add your first measurement to begin.'),
        ),
      ...data.entries.reversed.map(
        (e) => Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Panel(
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        dateLabel(e.date),
                        style: const TextStyle(color: muted, fontSize: 12),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        weightLabel(e.weightKg, data.units),
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        'BMI ${e.bmi.toStringAsFixed(1)} · ${Bmi.category(e.bmi)}',
                        style: const TextStyle(color: muted, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Delete check-in',
                  onPressed: busy
                      ? null
                      : () async {
                          if (await confirm(
                                'Delete this check-in?',
                                'The measurement from ${dateLabel(e.date)} will be removed.',
                              ) &&
                              mounted) {
                            await action(
                              () => ref
                                  .read(healthProvider.notifier)
                                  .deleteEntry(e.date),
                              'Check-in deleted',
                            );
                          }
                        },
                  icon: const Icon(Icons.delete_outline_rounded, color: muted),
                ),
              ],
            ),
          ),
        ),
      ),
    ],
  );
  Widget plan(HealthState data) => Panel(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Eyebrow('YOUR INTENTION FOR THE WEEK'),
        const SizedBox(height: 18),
        Text(
          '${data.days * data.minutes}',
          style: const TextStyle(
            color: mint,
            fontSize: 64,
            fontWeight: FontWeight.bold,
            letterSpacing: -3,
          ),
        ),
        const Text(
          'planned minutes of movement',
          style: TextStyle(color: muted),
        ),
        const SizedBox(height: 28),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: List.generate(7, (i) {
            final weekday = (data.firstDay - 1 + i) % 7;
            final active = List.generate(
              data.days,
              (n) => (n * 7 / data.days).floor(),
            ).contains(i);
            return Container(
              width: 82,
              padding: const EdgeInsets.symmetric(vertical: 18),
              decoration: BoxDecoration(
                color: active ? mint : const Color(0xFF24323E),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                children: [
                  Text(
                    const [
                      'Mon',
                      'Tue',
                      'Wed',
                      'Thu',
                      'Fri',
                      'Sat',
                      'Sun',
                    ][weekday],
                    style: TextStyle(color: active ? Colors.black : muted),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    active ? '${data.minutes}m' : 'Rest',
                    style: TextStyle(
                      color: active ? Colors.black : Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            );
          }),
        ),
        const SizedBox(height: 24),
        const Text(
          'An evenly spaced suggested schedule. These are planned sessions, not recorded activity.',
          style: TextStyle(color: muted, height: 1.6),
        ),
        const SizedBox(height: 24),
        FilledButton(
          onPressed: () => edit(data),
          child: const Text('Edit measurements & plan'),
        ),
        const SizedBox(height: 24),
        const Divider(),
        const SizedBox(height: 16),
        const Text(
          'Build gradually',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        const Text(
          'WHO recommends 150–300 minutes of moderate aerobic activity weekly, or 75–150 minutes of vigorous activity, plus muscle-strengthening activity on at least 2 days. Adapt activity to your abilities and health circumstances.',
          style: TextStyle(color: muted, height: 1.7),
        ),
      ],
    ),
  );
  Widget insights(HealthState data) => Column(
    children: [
      const Panel(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Eyebrow('BMI, EXPLAINED'),
            SizedBox(height: 16),
            Text(
              'A useful starting point.\nNever the whole picture.',
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 16),
            Text(
              'BMI = weight (kg) ÷ height (m)². It does not directly measure body fat or distinguish muscle from fat. Health history, body composition and other measurements matter too. Adult categories are not appropriate for children or teens; pregnancy also needs different assessment.',
              style: TextStyle(color: muted, height: 1.7),
            ),
            SizedBox(height: 20),
            Text(
              'Adult categories (20+)',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            Text(
              'Below 18.5   ·   Underweight\n18.5 to <25   ·   Healthy weight\n25 to <30      ·   Overweight\n30 or above ·   Obesity',
              style: TextStyle(color: muted, height: 2),
            ),
            SizedBox(height: 16),
            Text(
              'The label uses the full calculated value; the displayed BMI is rounded. Discuss results with a qualified healthcare professional for individual guidance.',
              style: TextStyle(color: muted, height: 1.7),
            ),
          ],
        ),
      ),
      const SizedBox(height: 18),
      Panel(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Eyebrow('SOURCES & PRIVACY'),
            const SizedBox(height: 16),
            const SelectableText(
              'CDC · Adult BMI categories\nhttps://www.cdc.gov/bmi/adult-calculator/bmi-categories.html\n\nCDC · About BMI\nhttps://www.cdc.gov/bmi/about/index.html\n\nWHO · Physical activity\nhttps://www.who.int/news-room/fact-sheets/detail/physical-activity',
              style: TextStyle(color: muted, height: 1.7),
            ),
            const SizedBox(height: 20),
            const Text(
              'Your entries stay in this app’s local storage. No account, analytics or cloud sync. Storage is not encrypted; device/browser backups may include it. Copy CSV before clearing app data if you need a record.',
              style: TextStyle(color: muted, height: 1.7),
            ),
            const SizedBox(height: 20),
            OutlinedButton(
              onPressed: busy
                  ? null
                  : () async {
                      if (await confirm(
                            'Delete all local data?',
                            'This removes all check-ins, measurements and your plan. This cannot be undone.',
                          ) &&
                          mounted) {
                        await action(
                          () => ref.read(healthProvider.notifier).reset(),
                          'All local data deleted',
                        );
                      }
                    },
              child: const Text('Delete all my data'),
            ),
          ],
        ),
      ),
    ],
  );
}
