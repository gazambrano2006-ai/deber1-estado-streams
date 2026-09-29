import '../entities/estado_conexion.dart';

abstract class ConexionRepository {
  Future<EstadoConexion> consultarAhora();

  Stream<EstadoConexion> observarCambios();
}
