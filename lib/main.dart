import 'package:flutter/material.dart';

import 'pantallas/pantalla_arranque.dart';
import 'pantallas/puerta_sesion.dart';
import 'servicios/iniciar_base_de_datos.dart';
import 'servicios/peliculas_api.dart';
import 'tema/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const CineCatalogoApp());
}

class CineCatalogoApp extends StatefulWidget {
  const CineCatalogoApp({super.key, this.api, this.conexion});

  final PeliculasApi? api;

  /// Cuando se pasa una conexión ya armada (pruebas de widget) la app entra
  /// directo al catálogo, sin pasar por el inicio de sesión.
  final ConexionBase? conexion;

  @override
  State<CineCatalogoApp> createState() => _CineCatalogoAppState();
}

class _CineCatalogoAppState extends State<CineCatalogoApp> {
  bool _listo = false;
  bool _firebaseDisponible = false;

  @override
  void initState() {
    super.initState();
    if (widget.conexion != null) {
      _listo = true;
      _firebaseDisponible = true;
    } else {
      _arrancar();
    }
  }

  Future<void> _arrancar() async {
    final bool disponible = await iniciarFirebase();
    if (!mounted) return;
    setState(() {
      _firebaseDisponible = disponible;
      _listo = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CineCatálogo',
      debugShowCheckedModeBanner: false,
      theme: construirTema(),
      home: !_listo
          ? const PantallaArranque()
          : PuertaSesion(
              disponible: _firebaseDisponible,
              conexionDirecta: widget.conexion,
              api: widget.api,
            ),
    );
  }
}
