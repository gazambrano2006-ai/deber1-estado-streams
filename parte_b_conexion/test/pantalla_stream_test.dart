import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:parte_b_conexion/domain/entities/estado_conexion.dart';
import 'package:parte_b_conexion/domain/usecases/consultar_conexion.dart';
import 'package:parte_b_conexion/domain/usecases/observar_conexion.dart';
import 'package:parte_b_conexion/main.dart';
import 'package:parte_b_conexion/presentation/pantallas/pantalla_stream.dart';

import 'helpers/conexion_repository_prueba.dart';

void main() {
  testWidgets('Espera datos reales y actualiza el estado automáticamente', (
    tester,
  ) async {
    final respuesta = Completer<EstadoConexion>();
    final repository = ConexionRepositoryPrueba(
      consultar: () => respuesta.future,
    );
    addTearDown(repository.cerrar);
    await tester.pumpWidget(
      MaterialApp(
        home: PantallaStream(
          consultarConexion: ConsultarConexion(repository),
          observarConexion: ObservarConexion(repository),
        ),
      ),
    );

    expect(find.text('Esperando datos de conexión'), findsOneWidget);
    expect(find.text('Otra conexión'), findsNothing);
    expect(repository.consultas, 1);

    respuesta.complete(EstadoConexion.otro);
    await tester.pumpAndSettle();
    expect(find.text('Otra conexión'), findsOneWidget);
    expect(find.text('Cambios detectados: 0'), findsOneWidget);

    const resultados = [
      (EstadoConexion.wifi, 'Wi-Fi', Icons.wifi, Colors.green),
      (
        EstadoConexion.datosMoviles,
        'Datos móviles',
        Icons.signal_cellular_alt,
        Colors.green,
      ),
      (EstadoConexion.sinConexion, 'Sin conexión', Icons.wifi_off, Colors.red),
    ];
    var cambios = 0;
    for (final (estado, texto, icono, color) in resultados) {
      repository.emitir(estado);
      await tester.pumpAndSettle();
      cambios++;

      expect(find.text(texto), findsOneWidget);
      expect(tester.widget<Text>(find.text(texto)).style?.color, color);
      expect(tester.widget<Icon>(find.byIcon(icono)).color, color);
      expect(find.text('Cambios detectados: $cambios'), findsOneWidget);
      expect(find.text('Consultar ahora'), findsNothing);
    }

    repository.emitir(EstadoConexion.sinConexion);
    await tester.pumpAndSettle();
    expect(find.text('Cambios detectados: 3'), findsOneWidget);
    expect(repository.consultas, 1);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
    expect(repository.tieneSuscriptores, isFalse);
  });

  testWidgets('Las pestañas conservan la foto y el seguimiento del Stream', (
    tester,
  ) async {
    final repository = ConexionRepositoryPrueba();
    addTearDown(repository.cerrar);
    await tester.pumpWidget(
      MyApp(
        consultarConexion: ConsultarConexion(repository),
        observarConexion: ObservarConexion(repository),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Sin consultar'), findsOneWidget);
    expect(repository.consultas, 1);
    await tester.tap(find.text('Consultar ahora'));
    await tester.pumpAndSettle();
    expect(find.text('Wi-Fi'), findsOneWidget);
    expect(repository.consultas, 2);

    await tester.tap(find.text('Con Stream'));
    await tester.pumpAndSettle();
    expect(find.text('Wi-Fi'), findsOneWidget);
    expect(find.text('Cambios detectados: 0'), findsOneWidget);

    repository.emitir(EstadoConexion.sinConexion);
    await tester.pumpAndSettle();
    expect(find.text('Sin conexión'), findsOneWidget);
    expect(find.text('Cambios detectados: 1'), findsOneWidget);

    await tester.tap(find.text('Con Future'));
    await tester.pumpAndSettle();
    expect(find.text('Wi-Fi'), findsOneWidget);
    expect(find.text('Sin conexión'), findsNothing);

    // El Cubit sigue observando incluso cuando su pestaña está oculta.
    repository.emitir(EstadoConexion.datosMoviles);
    await tester.pumpAndSettle();
    expect(find.text('Wi-Fi'), findsOneWidget);

    await tester.tap(find.text('Con Stream'));
    await tester.pumpAndSettle();
    expect(find.text('Datos móviles'), findsOneWidget);
    expect(find.text('Cambios detectados: 2'), findsOneWidget);
    expect(repository.consultas, 2);
    expect(repository.observaciones, 1);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
    expect(repository.tieneSuscriptores, isFalse);
    expect(repository.cancelaciones, 1);
  });
}
