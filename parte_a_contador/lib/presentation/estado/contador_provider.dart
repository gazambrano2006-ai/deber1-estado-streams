import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/usecases/decrementar.dart';
import '../../domain/usecases/incrementar.dart';
import '../../domain/usecases/obtener_contador.dart';

// Los casos de uso se inyectan desde el ProviderScope de main.dart.
final obtenerContadorProvider = Provider<ObtenerContador>((ref) {
  throw StateError('Falta inyectar ObtenerContador.');
});

final incrementarProvider = Provider<Incrementar>((ref) {
  throw StateError('Falta inyectar Incrementar.');
});

final decrementarProvider = Provider<Decrementar>((ref) {
  throw StateError('Falta inyectar Decrementar.');
});

class ContadorEstado {
  const ContadorEstado({this.valor = 0, this.ocupado = false, this.error});

  final int valor;
  final bool ocupado;
  final String? error;
}

// Sin autoDispose: el estado permanece durante la navegación.
final contadorProvider = NotifierProvider<ContadorNotifier, ContadorEstado>(
  ContadorNotifier.new,
);

class ContadorNotifier extends Notifier<ContadorEstado> {
  @override
  ContadorEstado build() {
    // La carga comienza después de crear el estado inicial síncrono.
    Future<void>.microtask(cargar);
    return const ContadorEstado();
  }

  Future<void> cargar() => _ejecutar(
    () => ref.read(obtenerContadorProvider)(),
    'No se pudo cargar el contador.',
  );

  Future<void> incrementar() => _ejecutar(
    () => ref.read(incrementarProvider)(),
    'No se pudo guardar el contador.',
  );

  Future<void> decrementar() => _ejecutar(
    () => ref.read(decrementarProvider)(),
    'No se pudo guardar el contador.',
  );

  Future<void> _ejecutar(
    Future<int> Function() operacion,
    String mensajeError,
  ) async {
    if (!ref.mounted || state.ocupado) return;

    final valorAnterior = state.valor;
    state = ContadorEstado(valor: valorAnterior, ocupado: true);

    try {
      final valor = await operacion();
      if (!ref.mounted) return;

      state = ContadorEstado(valor: valor);
    } catch (_) {
      if (!ref.mounted) return;

      state = ContadorEstado(valor: valorAnterior, error: mensajeError);
    }
  }
}
