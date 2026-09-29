import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../estado/contador_cubit.dart';
import 'pantalla_control.dart';

class PantallaVisor extends StatelessWidget {
  const PantallaVisor({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Visor')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            BlocBuilder<ContadorCubit, int>(
              builder: (context, contador) => Text(
                'Contador: $contador',
                style: const TextStyle(fontSize: 40),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
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
