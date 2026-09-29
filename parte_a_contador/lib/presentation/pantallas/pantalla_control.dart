import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../estado/contador_cubit.dart';

class PantallaControl extends StatelessWidget {
  const PantallaControl({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Control')),
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
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () => context.read<ContadorCubit>().incrementar(),
                  child: const Text('+1'),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: () => context.read<ContadorCubit>().decrementar(),
                  child: const Text('-1'),
                ),
              ],
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Volver'),
            ),
          ],
        ),
      ),
    );
  }
}
