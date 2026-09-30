import 'package:flutter/material.dart';

import '../../domain/entities/estado_conexion.dart';
import '../../domain/usecases/consultar_conexion.dart';

class PantallaFoto extends StatefulWidget {
  const PantallaFoto({super.key, required this.consultarConexion});

  final ConsultarConexion consultarConexion;

  @override
  State<PantallaFoto> createState() => _PantallaFotoState();
}

class _PantallaFotoState extends State<PantallaFoto> {
  EstadoConexion? _estado;
  DateTime? _ultimaConsulta;
  bool _cargando = false;
  String? _error;

  Future<void> _consultarAhora() async {
    if (_cargando) return;

    setState(() {
      _cargando = true;
      _error = null;
    });

    try {
      final estado = await widget.consultarConexion();
      if (!mounted) return;

      setState(() {
        _estado = estado;
        _ultimaConsulta = DateTime.now();
        _cargando = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _estado = null;
        _ultimaConsulta = DateTime.now();
        _error = 'No se pudo consultar la conexión. Intenta nuevamente.';
        _cargando = false;
      });
    }
  }

  String get _textoEstado => switch (_estado) {
    EstadoConexion.wifi => 'Wi-Fi',
    EstadoConexion.datosMoviles => 'Datos móviles',
    EstadoConexion.otro => 'Otra conexión',
    EstadoConexion.sinConexion => 'Sin conexión',
    null => 'Sin consultar',
  };

  IconData get _iconoEstado => switch (_estado) {
    EstadoConexion.wifi => Icons.wifi,
    EstadoConexion.datosMoviles => Icons.signal_cellular_alt,
    EstadoConexion.otro => Icons.device_hub,
    EstadoConexion.sinConexion => Icons.wifi_off,
    null => Icons.help_outline,
  };

  Color get _colorEstado => switch (_estado) {
    EstadoConexion.sinConexion => Colors.red,
    null => Colors.grey,
    _ => Colors.green,
  };

  String _formatearHora(DateTime hora) {
    final horas = hora.hour.toString().padLeft(2, '0');
    final minutos = hora.minute.toString().padLeft(2, '0');
    final segundos = hora.second.toString().padLeft(2, '0');
    return '$horas:$minutos:$segundos';
  }

  @override
  Widget build(BuildContext context) {
    final ultimaConsulta = _ultimaConsulta;

    return Scaffold(
      appBar: AppBar(title: const Text('Consulta de conexión')),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_cargando) ...[
                  const CircularProgressIndicator(
                    semanticsLabel: 'Consultando conexión',
                  ),
                  const SizedBox(height: 16),
                  const Text('Consultando...'),
                ] else if (_error != null) ...[
                  const Icon(Icons.error_outline, size: 72, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    _error!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red, fontSize: 18),
                  ),
                ] else ...[
                  Icon(_iconoEstado, size: 72, color: _colorEstado),
                  const SizedBox(height: 16),
                  Text(
                    _textoEstado,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 40, color: _colorEstado),
                  ),
                ],
                const SizedBox(height: 24),
                Text(
                  ultimaConsulta == null
                      ? 'Última consulta: —'
                      : 'Última consulta: ${_formatearHora(ultimaConsulta)}',
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _cargando ? null : _consultarAhora,
                  child: const Text('Consultar ahora'),
                ),
                const SizedBox(height: 24),
                const Text(
                  'El tipo de conexión no garantiza acceso a Internet.',
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
