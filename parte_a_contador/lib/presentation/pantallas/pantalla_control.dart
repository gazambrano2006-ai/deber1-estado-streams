import 'package:flutter/material.dart';

import '../../domain/usecases/decrementar.dart';
import '../../domain/usecases/incrementar.dart';
import '../../domain/usecases/obtener_contador.dart';

class PantallaControl extends StatefulWidget {
  const PantallaControl({
    super.key,
    required this.contadorInicial,
    required this.obtenerContador,
    required this.incrementar,
    required this.decrementar,
  });

  final int contadorInicial;
  final ObtenerContador obtenerContador;
  final Incrementar incrementar;
  final Decrementar decrementar;

  @override
  State<PantallaControl> createState() => _PantallaControlState();
}

class _PantallaControlState extends State<PantallaControl> {
  late int _contador;
  bool _guardando = false;

  @override
  void initState() {
    super.initState();
    _contador = widget.contadorInicial;
  }

  Future<void> _actualizarContador(Future<int> Function() operacion) async {
    if (_guardando) return;

    setState(() {
      _guardando = true;
    });

    try {
      final valor = await operacion();
      if (!mounted) return;

      setState(() {
        _contador = valor;
      });
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo guardar el contador.')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _guardando = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Control')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Contador: $_contador', style: const TextStyle(fontSize: 40)),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: _guardando
                      ? null
                      : () => _actualizarContador(widget.incrementar.call),
                  child: const Text('+1'),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: _guardando
                      ? null
                      : () => _actualizarContador(widget.decrementar.call),
                  child: const Text('-1'),
                ),
              ],
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _guardando
                  ? null
                  : () => Navigator.pop(context, _contador),
              child: const Text('Volver'),
            ),
          ],
        ),
      ),
    );
  }
}
