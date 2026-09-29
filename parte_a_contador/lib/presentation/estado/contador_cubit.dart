import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/decrementar.dart';
import '../../domain/usecases/incrementar.dart';
import '../../domain/usecases/obtener_contador.dart';

class ContadorCubit extends Cubit<int> {
  ContadorCubit({
    required this._obtenerContador,
    required this._incrementar,
    required this._decrementar,
  }) : super(0);

  final ObtenerContador _obtenerContador;
  final Incrementar _incrementar;
  final Decrementar _decrementar;

  Future<void> _pendiente = Future<void>.value();

  Future<void> cargar() => _ejecutar(_obtenerContador.call);

  Future<void> incrementar() => _ejecutar(_incrementar.call);

  Future<void> decrementar() => _ejecutar(_decrementar.call);

  Future<void> _ejecutar(Future<int> Function() operacion) {
    // Serializa lectura y guardado para conservar las pulsaciones rápidas.
    _pendiente = _pendiente.then((_) async {
      if (isClosed) return;

      try {
        final valor = await operacion();
        if (!isClosed) emit(valor);
      } catch (error, stackTrace) {
        // El observer registra el error y la cola puede seguir procesándose.
        if (!isClosed) addError(error, stackTrace);
      }
    });

    return _pendiente;
  }
}
