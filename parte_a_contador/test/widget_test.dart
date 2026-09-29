import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:parte_a_contador/domain/repositories/contador_repository.dart';
import 'package:parte_a_contador/domain/usecases/decrementar.dart';
import 'package:parte_a_contador/domain/usecases/incrementar.dart';
import 'package:parte_a_contador/domain/usecases/obtener_contador.dart';
import 'package:parte_a_contador/main.dart';
import 'package:parte_a_contador/presentation/estado/contador_provider.dart';

void main() {
  testWidgets('Visor carga el valor guardado una sola vez', (tester) async {
    final repository = _ContadorEnMemoria(7);

    await _mostrarApp(tester, repository);

    expect(find.text('Visor'), findsOneWidget);
    expect(find.text('Contador: 7'), findsOneWidget);
    expect(repository.lecturas, 1);
    expect(repository.valoresGuardados, isEmpty);
  });

  testWidgets('Control persiste las operaciones y Volver actualiza Visor', (
    tester,
  ) async {
    final repository = _ContadorEnMemoria(3);
    await _mostrarApp(tester, repository);

    await tester.tap(find.text('Ir a Control'));
    await tester.pumpAndSettle();
    expect(find.text('Contador: 3'), findsOneWidget);

    await tester.tap(find.text('+1'));
    await tester.pumpAndSettle();
    expect(find.text('Contador: 4'), findsOneWidget);
    expect(repository.valor, 4);

    await tester.tap(find.text('-1'));
    await tester.pumpAndSettle();
    expect(find.text('Contador: 3'), findsOneWidget);
    expect(repository.valor, 3);

    await tester.tap(find.text('+1'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Volver'));
    await tester.pumpAndSettle();

    expect(find.text('Visor'), findsOneWidget);
    expect(find.text('Contador: 4'), findsOneWidget);
    expect(repository.valoresGuardados, [4, 3, 4]);
    expect(repository.lecturas, 4);
  });

  testWidgets('Atrás del sistema conserva el estado y reabrir no lo recarga', (
    tester,
  ) async {
    final repository = _ContadorEnMemoria(8);
    await _mostrarApp(tester, repository);

    await tester.tap(find.text('Ir a Control'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('-1'));
    await tester.pumpAndSettle();

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();

    expect(find.text('Visor'), findsOneWidget);
    expect(find.text('Contador: 7'), findsOneWidget);
    expect(repository.lecturas, 2);

    await tester.tap(find.text('Ir a Control'));
    await tester.pumpAndSettle();

    expect(find.text('Control'), findsOneWidget);
    expect(find.text('Contador: 7'), findsOneWidget);
    expect(repository.lecturas, 2);
    expect(repository.valoresGuardados, [7]);
  });

  testWidgets('Una carga fallida informa el error y permite seguir operando', (
    tester,
  ) async {
    final repository = _ContadorEnMemoria(7)..fallarProximaLectura = true;
    await _mostrarApp(tester, repository);

    expect(find.byType(SnackBar), findsOneWidget);
    expect(find.text('No se pudo cargar el contador.'), findsOneWidget);
    expect(find.text('Contador: 0'), findsOneWidget);
    expect(
      tester
          .widget<ElevatedButton>(
            find.widgetWithText(ElevatedButton, 'Ir a Control'),
          )
          .onPressed,
      isNotNull,
    );

    await tester.tap(find.text('Ir a Control'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('+1'));
    await tester.pumpAndSettle();

    expect(find.text('Contador: 8'), findsOneWidget);
    expect(repository.valor, 8);
    expect(repository.valoresGuardados, [8]);
    expect(tester.takeException(), isNull);
  });
}

Future<void> _mostrarApp(
  WidgetTester tester,
  _ContadorEnMemoria repository,
) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        obtenerContadorProvider.overrideWithValue(ObtenerContador(repository)),
        incrementarProvider.overrideWithValue(Incrementar(repository)),
        decrementarProvider.overrideWithValue(Decrementar(repository)),
      ],
      child: const MyApp(),
    ),
  );
  await tester.pumpAndSettle();
}

class _ContadorEnMemoria implements ContadorRepository {
  _ContadorEnMemoria(this.valor);

  int valor;
  int lecturas = 0;
  bool fallarProximaLectura = false;
  final List<int> valoresGuardados = [];

  @override
  Future<int> leer() async {
    lecturas += 1;
    if (fallarProximaLectura) {
      fallarProximaLectura = false;
      throw StateError('Lectura fallida para la prueba');
    }
    return valor;
  }

  @override
  Future<void> guardar(int nuevoValor) async {
    valor = nuevoValor;
    valoresGuardados.add(nuevoValor);
  }
}
