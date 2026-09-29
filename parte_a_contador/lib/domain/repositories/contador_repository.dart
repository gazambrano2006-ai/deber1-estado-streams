abstract class ContadorRepository {
  Future<int> leer();

  Future<void> guardar(int valor);
}
