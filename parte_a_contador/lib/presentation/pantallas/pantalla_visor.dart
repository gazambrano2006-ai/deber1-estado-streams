import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../estado/contador_provider.dart';
import 'pantalla_control.dart';

class PantallaVisor extends ConsumerWidget {
  const PantallaVisor({super.key});

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
      appBar: AppBar(title: const Text('Visor')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Contador: ${contador.valor}',
              style: const TextStyle(fontSize: 40),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: contador.ocupado
                  ? null
                  : () {
                      Navigator.push<void>(
                        context,
                        MaterialPageRoute<void>(
                          builder: (context) => const PantallaControl(),
                        ),
                      );
                    },
              child: const Text('Ir a Control'),
            ),
          ],
        ),
      ),
    );
  }
}
