import '../repositories/contador_repository.dart';

class Decrementar {
  const Decrementar(this.repository);

  final ContadorRepository repository;

  Future<int> call() async {
    final valorActual = await repository.leer();
    final nuevoValor = valorActual - 1;

    await repository.guardar(nuevoValor);

    return nuevoValor;
  }
}
