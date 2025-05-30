import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raintor_test/features/signal_r/provider/signal_r.dart';

class SignalRView extends ConsumerWidget {
  const SignalRView({super.key});

  static const String name = 'signal-r';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref
        .watch(signalRProvider)
        .when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(
            child: Text('Error: $error', style: const TextStyle(color: Colors.red)),
          ),
          data: (data) {
            final notifier = ref.watch(signalRProvider.notifier);
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                spacing: 20,
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(notifier.myLocation, textAlign: TextAlign.center),
                  const SizedBox(height: 20),
                  Text(
                    notifier.otherUserLocation.isEmpty
                        ? 'Waiting for incoming location...'
                        : notifier.otherUserLocation.join('\n'),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          },
        );
  }
}
