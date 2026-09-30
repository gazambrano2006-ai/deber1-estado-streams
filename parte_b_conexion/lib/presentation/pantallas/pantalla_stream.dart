import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/estado_conexion.dart';
import '../../domain/usecases/consultar_conexion.dart';
import '../../domain/usecases/observar_conexion.dart';
import '../estado/conexion_cubit.dart';

class PantallaStream extends StatelessWidget {
  const PantallaStream({
    super.key,
    required this.consultarConexion,
    required this.observarConexion,
  });

  final ConsultarConexion consultarConexion;
  final ObservarConexion observarConexion;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ConexionCubit>(
      create: (context) => ConexionCubit(
        consultarConexion: consultarConexion,
        observarConexion: observarConexion,
      )..iniciar(),
      child: Scaffold(
        appBar: AppBar(title: const Text('Conexión en vivo')),
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: BlocBuilder<ConexionCubit, EstadoConexion>(
                builder: (context, estado) {
                  final cubit = context.read<ConexionCubit>();
                  final texto = switch (estado) {
                    EstadoConexion.wifi => 'Wi-Fi',
                    EstadoConexion.datosMoviles => 'Datos móviles',
                    EstadoConexion.otro => 'Otra conexión',
                    EstadoConexion.sinConexion => 'Sin conexión',
                  };
                  final icono = switch (estado) {
                    EstadoConexion.wifi => Icons.wifi,
                    EstadoConexion.datosMoviles => Icons.signal_cellular_alt,
                    EstadoConexion.otro => Icons.device_hub,
                    EstadoConexion.sinConexion => Icons.wifi_off,
                  };
                  final color = estado == EstadoConexion.sinConexion
                      ? Colors.red
                      : Colors.green;

                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        cubit.tieneEstado ? icono : Icons.hourglass_empty,
                        size: 72,
                        color: cubit.tieneEstado ? color : Colors.grey,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        cubit.tieneEstado
                            ? texto
                            : 'Esperando datos de conexión',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 40,
                          color: cubit.tieneEstado ? color : Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text('Cambios detectados: ${cubit.cambios}'),
                      const SizedBox(height: 24),
                      const Text(
                        kIsWeb
                            ? 'En Chrome, “Wi-Fi” significa que el navegador '
                                  'informa conexión; no confirma el tipo de red '
                                  'ni acceso a Internet.'
                            : 'El tipo de conexión no garantiza acceso a Internet.',
                        textAlign: TextAlign.center,
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
