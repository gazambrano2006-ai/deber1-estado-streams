import 'package:flutter_test/flutter_test.dart';
import 'package:parte_a_contador/data/repositories/contador_prefs_repository.dart';
import 'package:parte_a_contador/domain/usecases/decrementar.dart';
import 'package:parte_a_contador/domain/usecases/incrementar.dart';
import 'package:parte_a_contador/domain/usecases/obtener_contador.dart';
import 'package:parte_a_contador/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  Future<ContadorPrefsRepository> iniciarApp(
    WidgetTester tester, {
    required int valorGuardado,
  }) async {
    SharedPreferences.setMockInitialValues({'contador': valorGuardado});
    final repository = ContadorPrefsRepository();

    await tester.pumpWidget(
      MyApp(
        obtenerContador: ObtenerContador(repository),
        incrementar: Incrementar(repository),
        decrementar: Decrementar(repository),
      ),
    );
    await tester.pumpAndSettle();

    return repository;
  }

  testWidgets('Visor carga el contador guardado al iniciar', (tester) async {
    await iniciarApp(tester, valorGuardado: 7);

    expect(find.text('Contador: 7'), findsOneWidget);
    expect(find.text('Ir a Control'), findsOneWidget);
  });

  testWidgets('Control guarda los cambios y Volver actualiza Visor', (
    tester,
  ) async {
    final repository = await iniciarApp(tester, valorGuardado: 3);

    await tester.tap(find.text('Ir a Control'));
    await tester.pumpAndSettle();
    expect(find.text('Contador: 3'), findsOneWidget);

    await tester.tap(find.text('+1'));
    await tester.pumpAndSettle();
    expect(find.text('Contador: 4'), findsOneWidget);
    expect(await repository.leer(), 4);

    await tester.tap(find.text('-1'));
    await tester.pumpAndSettle();
    expect(find.text('Contador: 3'), findsOneWidget);
    expect(await repository.leer(), 3);

    await tester.tap(find.text('-1'));
    await tester.pumpAndSettle();
    expect(find.text('Contador: 2'), findsOneWidget);
    expect(await repository.leer(), 2);

    await tester.tap(find.text('Volver'));
    await tester.pumpAndSettle();
    expect(find.text('Ir a Control'), findsOneWidget);
    expect(find.text('Contador: 2'), findsOneWidget);
  });

  testWidgets('Atras del sistema deja Visor con su valor anterior', (
    tester,
  ) async {
    final repository = await iniciarApp(tester, valorGuardado: 8);

    await tester.tap(find.text('Ir a Control'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('+1'));
    await tester.pumpAndSettle();
    expect(find.text('Contador: 9'), findsOneWidget);

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text('Ir a Control'), findsOneWidget);
    expect(find.text('Contador: 8'), findsOneWidget);
    expect(await repository.leer(), 9);
  });
}
