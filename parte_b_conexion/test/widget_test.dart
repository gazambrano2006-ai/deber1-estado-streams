import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:parte_b_conexion/domain/entities/estado_conexion.dart';
import 'package:parte_b_conexion/domain/repositories/conexion_repository.dart';
import 'package:parte_b_conexion/domain/usecases/consultar_conexion.dart';
import 'package:parte_b_conexion/presentation/pantallas/pantalla_foto.dart';

class _ConexionRepository implements ConexionRepository {
  _ConexionRepository(this.consultar);

  final Future<EstadoConexion> Function() consultar;
  int consultas = 0;

  @override
  Future<EstadoConexion> consultarAhora() {
    consultas++;
    return consultar();
  }

  @override
  Stream<EstadoConexion> observarCambios() =>
      throw UnsupportedError('Esta pantalla solo consulta mediante Future.');
}

final _horaConsulta = RegExp(
  r'^Última consulta: (?:[01]\d|2[0-3]):[0-5]\d:[0-5]\d$',
);

void main() {
  testWidgets('Consulta solo al pulsar y muestra carga hasta completar', (
    tester,
  ) async {
    final respuesta = Completer<EstadoConexion>();
    final repository = _ConexionRepository(() => respuesta.future);
    await tester.pumpWidget(
      MaterialApp(
        home: PantallaFoto(consultarConexion: ConsultarConexion(repository)),
      ),
    );

    expect(repository.consultas, 0);
    expect(find.text('Sin consultar'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);

    await tester.tap(find.text('Consultar ahora'));
    await tester.pump();

    expect(repository.consultas, 1);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    final boton = tester.widget<ButtonStyleButton>(
      find.byWidgetPredicate((widget) => widget is ButtonStyleButton),
    );
    expect(boton.onPressed, isNull);

    respuesta.complete(EstadoConexion.wifi);
    await tester.pumpAndSettle();
    expect(find.text('Wi-Fi'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });

  const resultados = [
    (EstadoConexion.wifi, 'Wi-Fi', Icons.wifi, Colors.green),
    (
      EstadoConexion.datosMoviles,
      'Datos móviles',
      Icons.signal_cellular_alt,
      Colors.green,
    ),
    (EstadoConexion.otro, 'Otra conexión', Icons.device_hub, Colors.green),
    (EstadoConexion.sinConexion, 'Sin conexión', Icons.wifi_off, Colors.red),
  ];

  for (final (estado, texto, icono, color) in resultados) {
    testWidgets('Muestra $texto con icono, color y hora', (tester) async {
      final repository = _ConexionRepository(() async => estado);
      await tester.pumpWidget(
        MaterialApp(
          home: PantallaFoto(consultarConexion: ConsultarConexion(repository)),
        ),
      );

      await tester.tap(find.text('Consultar ahora'));
      await tester.pumpAndSettle();

      final resultado = tester.widget<Text>(find.text(texto));
      expect(resultado.style?.color, color);
      expect(resultado.style?.fontSize, greaterThanOrEqualTo(24));
      expect(tester.widget<Icon>(find.byIcon(icono)).color, color);
      expect(find.textContaining(_horaConsulta), findsOneWidget);
    });
  }

  testWidgets('Maneja errores sin confundirlos con desconexión y reintenta', (
    tester,
  ) async {
    var intento = 0;
    final repository = _ConexionRepository(() async {
      if (intento++ == 0) {
        throw StateError('Consulta fallida');
      }
      return EstadoConexion.datosMoviles;
    });
    await tester.pumpWidget(
      MaterialApp(
        home: PantallaFoto(consultarConexion: ConsultarConexion(repository)),
      ),
    );

    await tester.tap(find.text('Consultar ahora'));
    await tester.pumpAndSettle();
    expect(
      find.text('No se pudo consultar la conexión. Intenta nuevamente.'),
      findsOneWidget,
    );
    expect(find.text('Sin conexión'), findsNothing);
    expect(find.textContaining(_horaConsulta), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(tester.takeException(), isNull);

    await tester.tap(find.text('Consultar ahora'));
    await tester.pumpAndSettle();
    expect(repository.consultas, 2);
    expect(find.text('Datos móviles'), findsOneWidget);
    expect(
      find.text('No se pudo consultar la conexión. Intenta nuevamente.'),
      findsNothing,
    );
  });

  for (final falla in [false, true]) {
    testWidgets('No actualiza una pantalla desmontada (error: $falla)', (
      tester,
    ) async {
      final respuesta = Completer<EstadoConexion>();
      final repository = _ConexionRepository(() => respuesta.future);
      await tester.pumpWidget(
        MaterialApp(
          home: PantallaFoto(consultarConexion: ConsultarConexion(repository)),
        ),
      );
      await tester.tap(find.text('Consultar ahora'));
      await tester.pump();
      await tester.pumpWidget(const SizedBox.shrink());

      if (falla) {
        respuesta.completeError(StateError('Consulta fallida'));
      } else {
        respuesta.complete(EstadoConexion.wifi);
      }
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  }
}
