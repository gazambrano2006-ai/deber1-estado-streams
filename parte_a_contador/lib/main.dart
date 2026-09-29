import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'data/repositories/contador_prefs_repository.dart';
import 'domain/usecases/decrementar.dart';
import 'domain/usecases/incrementar.dart';
import 'domain/usecases/obtener_contador.dart';
import 'presentation/estado/contador_cubit.dart';
import 'presentation/pantallas/pantalla_visor.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Bloc.observer = ContadorObserver();

  final repository = ContadorPrefsRepository();
  final obtenerContador = ObtenerContador(repository);
  final incrementar = Incrementar(repository);
  final decrementar = Decrementar(repository);

  runApp(
    BlocProvider<ContadorCubit>(
      lazy: false,
      create: (context) => ContadorCubit(
        obtenerContador: obtenerContador,
        incrementar: incrementar,
        decrementar: decrementar,
      )..cargar(),
      child: const MyApp(),
    ),
  );
}

class ContadorObserver extends BlocObserver {
  @override
  void onChange(BlocBase<dynamic> bloc, Change<dynamic> change) {
    super.onChange(bloc, change);
    if (bloc is ContadorCubit) {
      debugPrint(
        'ContadorCubit: ${change.currentState} -> ${change.nextState}',
      );
    }
  }

  @override
  void onError(BlocBase<dynamic> bloc, Object error, StackTrace stackTrace) {
    super.onError(bloc, error, stackTrace);
    debugPrint('${bloc.runtimeType}: error: $error');
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Contador con BLoC',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const PantallaVisor(),
    );
  }
}
