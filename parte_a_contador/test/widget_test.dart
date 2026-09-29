import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:parte_a_contador/domain/repositories/contador_repository.dart';
import 'package:parte_a_contador/domain/usecases/decrementar.dart';
import 'package:parte_a_contador/domain/usecases/incrementar.dart';
import 'package:parte_a_contador/domain/usecases/obtener_contador.dart';
import 'package:parte_a_contador/main.dart';
import 'package:parte_a_contador/presentation/estado/contador_cubit.dart';

void main() {
  testWidgets('El visor carga el contador guardado', (tester) async {
    await _montarAplicacion(tester, _RepositorioEnMemoria(7));

    expect(find.text('Contador: 7'), findsOneWidget);
    expect(find.text('Ir a Control'), findsOneWidget);
  });

  testWidgets('Control guarda las operaciones y Volver actualiza el visor', (
    tester,
  ) async {
    final repositorio = _RepositorioEnMemoria(3);
    await _montarAplicacion(tester, repositorio);

    await tester.tap(find.text('Ir a Control'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('+1'));
    await tester.pumpAndSettle();
    expect(find.text('Contador: 4'), findsOneWidget);
    expect(repositorio.valor, 4);

    await tester.tap(find.text('-1'));
    await tester.pumpAndSettle();
    expect(find.text('Contador: 3'), findsOneWidget);
    expect(repositorio.valor, 3);

    await tester.tap(find.text('+1'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Volver'));
    await tester.pumpAndSettle();

    expect(find.text('Contador: 4'), findsOneWidget);
    expect(find.text('Ir a Control'), findsOneWidget);
  });

  testWidgets('Atras del sistema y reabrir Control conservan el estado', (
    tester,
  ) async {
    await _montarAplicacion(tester, _RepositorioEnMemoria(10));

    await tester.tap(find.text('Ir a Control'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('+1'));
    await tester.pumpAndSettle();

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text('Contador: 11'), findsOneWidget);
    expect(find.text('Ir a Control'), findsOneWidget);

    await tester.tap(find.text('Ir a Control'));
    await tester.pumpAndSettle();
    expect(find.text('Contador: 11'), findsOneWidget);
    expect(find.text('Volver'), findsOneWidget);
  });

  test('Operaciones concurrentes conservan todos los cambios', () async {
    final repositorio = _RepositorioEnMemoria(5);
    final cubit = _crearCubit(repositorio);
    addTearDown(cubit.close);

    expect(cubit.state, 0);
    await Future.wait([
      cubit.cargar(),
      cubit.incrementar(),
      cubit.incrementar(),
      cubit.incrementar(),
      cubit.decrementar(),
    ]);

    expect(cubit.state, 7);
    expect(repositorio.valor, 7);
  });

  test('El observer imprime el cambio con el formato solicitado', () async {
    final observerAnterior = Bloc.observer;
    final imprimirAnterior = debugPrint;
    final mensajes = <String?>[];
    Bloc.observer = ContadorObserver();
    debugPrint = (String? mensaje, {int? wrapWidth}) {
      mensajes.add(mensaje);
    };
    final cubit = _crearCubit(_RepositorioEnMemoria(3));

    try {
      await cubit.cargar();
      mensajes.clear();
      await cubit.incrementar();

      expect(mensajes, ['ContadorCubit: 3 -> 4']);
    } finally {
      await cubit.close();
      Bloc.observer = observerAnterior;
      debugPrint = imprimirAnterior;
    }
  });
}

ContadorCubit _crearCubit(ContadorRepository repositorio) {
  return ContadorCubit(
    obtenerContador: ObtenerContador(repositorio),
    incrementar: Incrementar(repositorio),
    decrementar: Decrementar(repositorio),
  );
}

Future<void> _montarAplicacion(
  WidgetTester tester,
  ContadorRepository repositorio,
) async {
  await tester.pumpWidget(
    BlocProvider<ContadorCubit>(
      create: (_) => _crearCubit(repositorio)..cargar(),
      child: const MyApp(),
    ),
  );
  await tester.pumpAndSettle();
}

class _RepositorioEnMemoria implements ContadorRepository {
  _RepositorioEnMemoria(this.valor);

  int valor;

  @override
  Future<int> leer() async => valor;

  @override
  Future<void> guardar(int nuevoValor) async {
    valor = nuevoValor;
  }
}
