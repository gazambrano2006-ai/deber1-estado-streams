import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../estado/contador_provider.dart';

class PantallaControl extends ConsumerWidget {
  const PantallaControl({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contador = ref.watch(contadorProvider);

    ref.listen(contadorProvider, (anterior, actual) {
      if (actual.error != null && anterior?.error != actual.error) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(actual.error!)));
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Control')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Contador: ${contador.valor}',
              style: const TextStyle(fontSize: 40),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: contador.ocupado
                      ? null
                      : () => ref.read(contadorProvider.notifier).incrementar(),
                  child: const Text('+1'),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: contador.ocupado
                      ? null
                      : () => ref.read(contadorProvider.notifier).decrementar(),
                  child: const Text('-1'),
                ),
              ],
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: contador.ocupado ? null : () => Navigator.pop(context),
              child: const Text('Volver'),
            ),
          ],
        ),
      ),
    );
  }
}
