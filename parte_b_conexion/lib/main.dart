import 'package:flutter/material.dart';

import 'data/repositories/conexion_plus_repository.dart';
import 'domain/usecases/consultar_conexion.dart';
import 'domain/usecases/observar_conexion.dart';
import 'presentation/pantallas/pantalla_foto.dart';
import 'presentation/pantallas/pantalla_stream.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  final repository = ConexionPlusRepository();
  final consultarConexion = ConsultarConexion(repository);
  final observarConexion = ObservarConexion(repository);

  runApp(
    MyApp(
      consultarConexion: consultarConexion,
      observarConexion: observarConexion,
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({
    super.key,
    required this.consultarConexion,
    required this.observarConexion,
  });

  final ConsultarConexion consultarConexion;
  final ObservarConexion observarConexion;

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int _indice = 0;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Consulta de conexión',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: Scaffold(
        body: IndexedStack(
          index: _indice,
          children: [
            PantallaFoto(consultarConexion: widget.consultarConexion),
            PantallaStream(
              consultarConexion: widget.consultarConexion,
              observarConexion: widget.observarConexion,
            ),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _indice,
          onTap: (indice) {
            setState(() {
              _indice = indice;
            });
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.camera_alt_outlined),
              label: 'Con Future',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.sensors),
              label: 'Con Stream',
            ),
          ],
        ),
      ),
    );
  }
}
