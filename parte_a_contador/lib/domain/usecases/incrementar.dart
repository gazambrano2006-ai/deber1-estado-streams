import '../repositories/contador_repository.dart';

class Incrementar {
  const Incrementar(this.repository);

  final ContadorRepository repository;

  Future<int> call() async {
    final valorActual = await repository.leer();
    final nuevoValor = valorActual + 1;

    await repository.guardar(nuevoValor);

    return nuevoValor;
  }
}
