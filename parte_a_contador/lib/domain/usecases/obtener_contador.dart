import '../repositories/contador_repository.dart';

class ObtenerContador {
  const ObtenerContador(this.repository);

  final ContadorRepository repository;

  Future<int> call() => repository.leer();
}
