import 'package:parte_a_contador/domain/repositories/contador_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ContadorPrefsRepository implements ContadorRepository {
  static const String _claveContador = 'contador';

  @override
  Future<int> leer() async {
    final preferencias = await SharedPreferences.getInstance();
    return preferencias.getInt(_claveContador) ?? 0;
  }

  @override
  Future<void> guardar(int valor) async {
    final preferencias = await SharedPreferences.getInstance();
    await preferencias.setInt(_claveContador, valor);
  }
}
