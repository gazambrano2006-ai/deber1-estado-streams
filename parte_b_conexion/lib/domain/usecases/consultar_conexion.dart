import '../entities/estado_conexion.dart';
import '../repositories/conexion_repository.dart';

class ConsultarConexion {
  const ConsultarConexion(this.repository);

  final ConexionRepository repository;

  Future<EstadoConexion> call() => repository.consultarAhora();
}
