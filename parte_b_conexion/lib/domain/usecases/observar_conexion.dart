import '../entities/estado_conexion.dart';
import '../repositories/conexion_repository.dart';

class ObservarConexion {
  const ObservarConexion(this.repository);

  final ConexionRepository repository;

  Stream<EstadoConexion> call() => repository.observarCambios();
}
