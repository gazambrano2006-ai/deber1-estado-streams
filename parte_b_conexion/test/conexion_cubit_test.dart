import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:parte_b_conexion/domain/entities/estado_conexion.dart';
import 'package:parte_b_conexion/domain/usecases/consultar_conexion.dart';
import 'package:parte_b_conexion/domain/usecases/observar_conexion.dart';
import 'package:parte_b_conexion/presentation/estado/conexion_cubit.dart';

import 'helpers/conexion_repository_prueba.dart';

ConexionCubit crearCubit(ConexionRepositoryPrueba repository) => ConexionCubit(
  consultarConexion: ConsultarConexion(repository),
  observarConexion: ObservarConexion(repository),
);

void main() {
  test(
    'Empieza sin una lectura real y no cuenta la consulta inicial',
    () async {
      final repository = ConexionRepositoryPrueba();
      final cubit = crearCubit(repository);
      addTearDown(repository.cerrar);
      addTearDown(cubit.close);

      expect(cubit.state, EstadoConexion.otro);
      expect(cubit.tieneEstado, isFalse);
      expect(cubit.cambios, 0);

      await cubit.iniciar();

      expect(cubit.state, EstadoConexion.wifi);
      expect(cubit.tieneEstado, isTrue);
      expect(cubit.cambios, 0);
      expect(repository.consultas, 1);
      expect(repository.tieneSuscriptores, isTrue);
    },
  );

  test(
    'Cuenta solo cambios distintos posteriores a la primera lectura',
    () async {
      final repository = ConexionRepositoryPrueba();
      final cubit = crearCubit(repository);
      addTearDown(repository.cerrar);
      addTearDown(cubit.close);
      await cubit.iniciar();

      repository.emitir(EstadoConexion.wifi);
      expect(cubit.cambios, 0);

      repository.emitir(EstadoConexion.datosMoviles);
      expect(cubit.state, EstadoConexion.datosMoviles);
      expect(cubit.cambios, 1);

      repository.emitir(EstadoConexion.sinConexion);
      repository.emitir(EstadoConexion.sinConexion);
      expect(cubit.state, EstadoConexion.sinConexion);
      expect(cubit.cambios, 2);

      repository.emitir(EstadoConexion.wifi);
      expect(cubit.cambios, 3);
    },
  );

  test(
    'Una lectura real de otro también se publica como estado recibido',
    () async {
      final repository = ConexionRepositoryPrueba(actual: EstadoConexion.otro);
      final cubit = crearCubit(repository);
      addTearDown(repository.cerrar);
      addTearDown(cubit.close);
      final primerEstado = cubit.stream.first;

      await cubit.iniciar();

      expect(await primerEstado, EstadoConexion.otro);
      expect(cubit.tieneEstado, isTrue);
      expect(cubit.cambios, 0);
    },
  );

  test(
    'Una consulta tardía no sobrescribe los eventos más recientes',
    () async {
      final respuesta = Completer<EstadoConexion>();
      final repository = ConexionRepositoryPrueba(
        consultar: () => respuesta.future,
      );
      final cubit = crearCubit(repository);
      addTearDown(repository.cerrar);
      addTearDown(cubit.close);
      final inicio = cubit.iniciar();

      expect(repository.tieneSuscriptores, isTrue);
      repository.emitir(EstadoConexion.wifi);
      expect(cubit.cambios, 0);
      repository.emitir(EstadoConexion.datosMoviles);

      respuesta.complete(EstadoConexion.sinConexion);
      await inicio;

      expect(cubit.state, EstadoConexion.datosMoviles);
      expect(cubit.cambios, 1);
    },
  );

  test(
    'Iniciar varias veces mantiene una sola consulta y suscripción',
    () async {
      final respuesta = Completer<EstadoConexion>();
      final repository = ConexionRepositoryPrueba(
        consultar: () => respuesta.future,
      );
      final cubit = crearCubit(repository);
      addTearDown(repository.cerrar);
      addTearDown(cubit.close);

      final primero = cubit.iniciar();
      final segundo = cubit.iniciar();
      expect(repository.consultas, 1);
      expect(repository.observaciones, 1);
      respuesta.complete(EstadoConexion.wifi);
      await Future.wait([primero, segundo]);
      await cubit.iniciar();

      expect(repository.consultas, 1);
      expect(repository.observaciones, 1);
    },
  );

  test('Close cancela la suscripción e ignora eventos posteriores', () async {
    final repository = ConexionRepositoryPrueba();
    final cubit = crearCubit(repository);
    addTearDown(repository.cerrar);
    await cubit.iniciar();

    await cubit.close();
    repository.emitir(EstadoConexion.sinConexion);

    expect(repository.tieneSuscriptores, isFalse);
    expect(repository.cancelaciones, 1);
    expect(cubit.state, EstadoConexion.wifi);
    expect(cubit.cambios, 0);
  });

  test('Cerrar durante la consulta impide emisiones tardías', () async {
    final respuesta = Completer<EstadoConexion>();
    final repository = ConexionRepositoryPrueba(
      consultar: () => respuesta.future,
    );
    final cubit = crearCubit(repository);
    addTearDown(repository.cerrar);
    final inicio = cubit.iniciar();

    await cubit.close();
    respuesta.complete(EstadoConexion.wifi);
    await inicio;

    expect(repository.tieneSuscriptores, isFalse);
    expect(repository.cancelaciones, 1);
    expect(cubit.state, EstadoConexion.otro);
    expect(cubit.tieneEstado, isFalse);
  });
}
