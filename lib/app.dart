import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/app_theme.dart';
import 'features/health/application/health_controller.dart';
import 'features/health/presentation/dashboard.dart';
import 'features/health/presentation/setup_page.dart';

class PulseApp extends ConsumerWidget {
  const PulseApp({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) => MaterialApp(
    title: 'Pulse · Know your rhythm',
    debugShowCheckedModeBanner: false,
    theme: buildTheme(),
    home: ref
        .watch(healthProvider)
        .when(
          loading: () =>
              const Scaffold(body: Center(child: CircularProgressIndicator())),
          error: (error, stack) => Builder(
            builder: (context) => Scaffold(
              body: Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.cloud_off_rounded, size: 40),
                      const SizedBox(height: 16),
                      const Text('Your saved data could not be opened.'),
                      const SizedBox(height: 16),
                      FilledButton(
                        onPressed: () => ref.invalidate(healthProvider),
                        child: const Text('Try again'),
                      ),
                      TextButton(
                        onPressed: () async {
                          final reset = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Reset local data?'),
                              content: const Text(
                                'This permanently removes saved measurements and settings.',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(context, false),
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  child: const Text('Reset'),
                                ),
                              ],
                            ),
                          );
                          if (reset == true) {
                            try {
                              await ref.read(healthProvider.notifier).reset();
                            } catch (_) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Reset failed. Please try again.',
                                    ),
                                  ),
                                );
                              }
                            }
                          }
                        },
                        child: const Text('Reset saved data'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          data: (data) =>
              data.onboarded ? const Dashboard() : SetupPage(initial: data),
        ),
  );
}
