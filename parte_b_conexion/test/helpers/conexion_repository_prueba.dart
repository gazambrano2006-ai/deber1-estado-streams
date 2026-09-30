import 'dart:async';

import 'package:parte_b_conexion/domain/entities/estado_conexion.dart';
import 'package:parte_b_conexion/domain/repositories/conexion_repository.dart';

// Fuente controlada exclusivamente para pruebas; la aplicación usa el plugin real.
class ConexionRepositoryPrueba implements ConexionRepository {
  ConexionRepositoryPrueba({
    this.actual = EstadoConexion.wifi,
    this.consultar,
  }) {
    _eventos = StreamController<EstadoConexion>.broadcast(
      sync: true,
      onCancel: () => cancelaciones++,
    );
  }

  EstadoConexion actual;
  final Future<EstadoConexion> Function()? consultar;
  late final StreamController<EstadoConexion> _eventos;
  int consultas = 0;
  int observaciones = 0;
  int cancelaciones = 0;

  bool get tieneSuscriptores => _eventos.hasListener;

  @override
  Future<EstadoConexion> consultarAhora() {
    consultas++;
    return consultar?.call() ?? Future.value(actual);
  }

  @override
  Stream<EstadoConexion> observarCambios() {
    observaciones++;
    return _eventos.stream;
  }

  void emitir(EstadoConexion estado) {
    actual = estado;
    _eventos.add(estado);
  }

  Future<void> cerrar() => _eventos.close();
}
