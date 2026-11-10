import 'dart:async';

import 'package:flutter/material.dart';

import '../servicios/iniciar_base_de_datos.dart';
import '../servicios/peliculas_api.dart';
import '../servicios/sesion.dart';
import 'navegacion_principal.dart';
import 'pantalla_arranque.dart';
import 'pantalla_bienvenida.dart';

/// Decide qué se ve según el estado de la sesión: la bienvenida cuando no hay
/// nadie autenticado y la navegación del catálogo cuando ya hay cuenta.
class PuertaSesion extends StatefulWidget {
  const PuertaSesion({
    super.key,
    required this.disponible,
    this.conexionDirecta,
    this.api,
  });

  /// false cuando Firebase no arrancó: se ofrece el modo local.
  final bool disponible;

  /// Conexión ya armada (pruebas de widget): entra directo al catálogo.
  final ConexionBase? conexionDirecta;

  final PeliculasApi? api;

  @override
  State<PuertaSesion> createState() => _PuertaSesionState();
}

class _PuertaSesionState extends State<PuertaSesion> {
  ServicioSesion? _servicio;
  StreamSubscription<UsuarioSesion?>? _suscripcion;

  UsuarioSesion? _usuario;
  ConexionBase? _conexion;
  bool _preparando = false;

  @override
  void initState() {
    super.initState();
    final ConexionBase? directa = widget.conexionDirecta;
    if (directa != null) {
      _usuario = UsuarioSesion.local();
      _conexion = directa;
      return;
    }
    if (widget.disponible) {
      _servicio = ServicioSesion();
      _suscripcion = _servicio!.cambios.listen(_alCambiarSesion);
    }
  }

  @override
  void dispose() {
    _suscripcion?.cancel();
    super.dispose();
  }

  Future<void> _alCambiarSesion(UsuarioSesion? usuario) async {
    if (usuario == null) {
      setState(() {
        _usuario = null;
        _conexion = null;
        _preparando = false;
      });
      return;
    }

    setState(() {
      _usuario = usuario;
      _preparando = true;
      _conexion = null;
    });

    final ConexionBase conexion = await conectarUsuario(usuario);
    if (!mounted) return;
    setState(() {
      _conexion = conexion;
      _preparando = false;
    });
  }

  void _entrarEnLocal() {
    setState(() {
      _usuario = UsuarioSesion.local();
      _conexion = ConexionBase.sinConexion(
        'Sin Firebase: los datos viven solo en memoria durante esta sesión.',
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final ConexionBase? conexion = _conexion;
    final UsuarioSesion? usuario = _usuario;

    if (usuario != null && conexion != null) {
      return NavegacionPrincipal(
        api: widget.api,
        conexion: conexion,
        usuario: usuario,
        servicio: _servicio,
      );
    }

    if (usuario != null && _preparando) return const PantallaArranque();

    return PantallaBienvenida(
      servicio: _servicio,
      disponible: widget.disponible,
      alEntrarLocal: _entrarEnLocal,
    );
  }
}
