import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/estado_conexion.dart';
import '../../domain/usecases/consultar_conexion.dart';
import '../../domain/usecases/observar_conexion.dart';

class ConexionCubit extends Cubit<EstadoConexion> {
  ConexionCubit({
    required this._consultarConexion,
    required this._observarConexion,
  }) : super(EstadoConexion.otro);

  final ConsultarConexion _consultarConexion;
  final ObservarConexion _observarConexion;

  StreamSubscription<EstadoConexion>? _suscripcion;
  Future<void>? _inicio;
  bool _cerrando = false;
  bool _huboEvento = false;
  bool _tieneEstado = false;
  int _cambios = 0;

  bool get tieneEstado => _tieneEstado;
  int get cambios => _cambios;

  Future<void> iniciar() {
    if (_cerrando || isClosed) return Future<void>.value();
    return _inicio ??= _iniciar();
  }

  Future<void> _iniciar() async {
    // Se escucha primero para no perder cambios durante la consulta inicial.
    try {
      _suscripcion = _observarConexion().listen(
        (estado) {
          _huboEvento = true;
          _actualizar(estado);
        },
        onError: (Object error, StackTrace stackTrace) {
          _registrarError(error, stackTrace);
        },
      );
    } catch (error, stackTrace) {
      _registrarError(error, stackTrace);
    }

    try {
      final estado = await _consultarConexion();
      // Un evento recibido es más reciente que la captura inicial.
      if (!_huboEvento) _actualizar(estado);
    } catch (error, stackTrace) {
      _registrarError(error, stackTrace);
    }
  }

  void _actualizar(EstadoConexion nuevoEstado) {
    if (_cerrando || isClosed) return;
    if (_tieneEstado && nuevoEstado == state) return;

    if (_tieneEstado) _cambios++;
    _tieneEstado = true;
    emit(nuevoEstado);
  }

  void _registrarError(Object error, StackTrace stackTrace) {
    // Un error no equivale a detectar una desconexión.
    if (!_cerrando && !isClosed) addError(error, stackTrace);
  }

  @override
  Future<void> close() async {
    _cerrando = true;
    try {
      await _suscripcion?.cancel();
    } finally {
      await super.close();
    }
  }
}
