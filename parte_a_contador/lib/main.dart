import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'data/repositories/contador_prefs_repository.dart';
import 'domain/usecases/decrementar.dart';
import 'domain/usecases/incrementar.dart';
import 'domain/usecases/obtener_contador.dart';
import 'presentation/estado/contador_provider.dart';
import 'presentation/pantallas/pantalla_visor.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  final repository = ContadorPrefsRepository();
  final obtenerContador = ObtenerContador(repository);
  final incrementar = Incrementar(repository);
  final decrementar = Decrementar(repository);

  runApp(
    ProviderScope(
      overrides: [
        obtenerContadorProvider.overrideWithValue(obtenerContador),
        incrementarProvider.overrideWithValue(incrementar),
        decrementarProvider.overrideWithValue(decrementar),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Contador con Riverpod',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const PantallaVisor(),
    );
  }
}
