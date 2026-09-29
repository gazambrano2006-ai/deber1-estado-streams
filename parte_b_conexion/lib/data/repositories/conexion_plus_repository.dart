import 'package:connectivity_plus/connectivity_plus.dart';

import '../../domain/entities/estado_conexion.dart';
import '../../domain/repositories/conexion_repository.dart';

class ConexionPlusRepository implements ConexionRepository {
  @override
  Future<EstadoConexion> consultarAhora() async {
    final resultados = await Connectivity().checkConnectivity();
    return _convertir(resultados);
  }

  @override
  Stream<EstadoConexion> observarCambios() {
    return Connectivity().onConnectivityChanged.map(_convertir);
  }

  EstadoConexion _convertir(List<ConnectivityResult> resultados) {
    if (resultados.contains(ConnectivityResult.wifi)) {
      return EstadoConexion.wifi;
    }

    if (resultados.contains(ConnectivityResult.mobile)) {
      return EstadoConexion.datosMoviles;
    }

    if (resultados.any((resultado) => resultado != ConnectivityResult.none)) {
      return EstadoConexion.otro;
    }

    return EstadoConexion.sinConexion;
  }
}
