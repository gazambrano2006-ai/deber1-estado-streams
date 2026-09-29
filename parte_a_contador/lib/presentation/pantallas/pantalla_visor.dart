import 'package:flutter/material.dart';

import '../../domain/usecases/decrementar.dart';
import '../../domain/usecases/incrementar.dart';
import '../../domain/usecases/obtener_contador.dart';
import 'pantalla_control.dart';

class PantallaVisor extends StatefulWidget {
  const PantallaVisor({
    super.key,
    required this.obtenerContador,
    required this.incrementar,
    required this.decrementar,
  });

  final ObtenerContador obtenerContador;
  final Incrementar incrementar;
  final Decrementar decrementar;

  @override
  State<PantallaVisor> createState() => _PantallaVisorState();
}

class _PantallaVisorState extends State<PantallaVisor> {
  int _contador = 0;
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargarContador();
  }

  Future<void> _cargarContador() async {
    try {
      final valor = await widget.obtenerContador();
      if (!mounted) return;

      setState(() {
        _contador = valor;
      });
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo cargar el contador.')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _cargando = false;
        });
      }
    }
  }

  Future<void> _irAControl() async {
    final valor = await Navigator.push<int>(
      context,
      MaterialPageRoute<int>(
        builder: (context) => PantallaControl(
          contadorInicial: _contador,
          obtenerContador: widget.obtenerContador,
          incrementar: widget.incrementar,
          decrementar: widget.decrementar,
        ),
      ),
    );

    // El botón atrás del sistema no devuelve un valor al Visor.
    if (!mounted || valor == null) return;

    setState(() {
      _contador = valor;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Visor')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Contador: $_contador', style: const TextStyle(fontSize: 40)),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _cargando ? null : _irAControl,
              child: const Text('Ir a Control'),
            ),
          ],
        ),
      ),
    );
  }
}
