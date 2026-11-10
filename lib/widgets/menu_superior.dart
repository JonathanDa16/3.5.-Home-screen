import 'package:flutter/material.dart';

import '../estado/controlador_mi_lista.dart';
import '../servicios/iniciar_base_de_datos.dart';
import '../servicios/sesion.dart';
import '../tema/app_theme.dart';
import '../pantallas/pantalla_administracion.dart';
import '../pantallas/pantalla_catalogo_base.dart';

/// Menú de la parte superior. Desde aquí se elige qué catálogo ver, se entra
/// a la administración y se cierra la sesión.
class MenuSuperior extends StatelessWidget {
  const MenuSuperior({
    super.key,
    required this.conexion,
    required this.controlador,
    this.sesion,
    this.usuario,
    this.alIrAMiLista,
  });

  final ConexionBase conexion;

  final ControladorMiLista controlador;

  final ServicioSesion? sesion;

  final UsuarioSesion? usuario;

  final VoidCallback? alIrAMiLista;

  Future<void> _elegir(BuildContext context, String opcion) async {
    final NavigatorState navegador = Navigator.of(context);
    switch (opcion) {
      case 'tmdb':
        navegador.popUntil((Route<dynamic> r) => r.isFirst);
      case 'base':
        navegador.push(
          MaterialPageRoute<void>(
            builder: (_) => PantallaCatalogoBase(
              conexion: conexion,
              controlador: controlador,
              sesion: sesion,
              usuario: usuario,
              alIrAMiLista: alIrAMiLista,
            ),
          ),
        );
      case 'miLista':
        navegador.popUntil((Route<dynamic> r) => r.isFirst);
        alIrAMiLista?.call();
      case 'admin':
        navegador.push(
          MaterialPageRoute<void>(
            builder: (_) => PantallaAdministracion(
              conexion: conexion,
              controlador: controlador,
              sesion: sesion,
              usuario: usuario,
            ),
          ),
        );
      case 'salir':
        await _confirmarSalida(context);
    }
  }

  Future<void> _confirmarSalida(BuildContext context) async {
    final ServicioSesion? servicio = sesion;
    final bool? salir = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        backgroundColor: Paleta.superficieAlta,
        title: const Text('Cerrar sesión', style: TextStyle(fontSize: 17)),
        content: const Text(
          'Volverás a la pantalla de bienvenida. Tu lista y tus '
          'calificaciones quedan guardadas en la base de datos.',
          style: TextStyle(fontSize: 13.5, height: 1.5),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: Paleta.acento,
              foregroundColor: const Color(0xFF15130C),
            ),
            child: const Text('Cerrar sesión'),
          ),
        ],
      ),
    );
    if (salir == true) await servicio?.cerrarSesion();
  }

  @override
  Widget build(BuildContext context) {
    final String correo = usuario?.correoTexto ?? 'sesión local';

    return PopupMenuButton<String>(
      tooltip: 'Menú del catálogo',
      color: Paleta.superficieAlta,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: Paleta.borde),
      ),
      onSelected: (String opcion) => _elegir(context, opcion),
      icon: const Icon(
        Icons.menu_rounded,
        size: 23,
        color: Paleta.texto,
      ),
      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
        PopupMenuItem<String>(
          enabled: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                usuario?.nombreTexto ?? 'Invitado',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Paleta.texto,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                correo,
                style: const TextStyle(fontSize: 11.5, color: Paleta.textoSuave),
              ),
            ],
          ),
        ),
        const PopupMenuDivider(),
        _opcion('tmdb', Icons.movie_filter_rounded, 'Catálogo TMDB'),
        _opcion('base', Icons.storage_rounded, 'Catálogo de la base de datos'),
        _opcion('miLista', Icons.bookmark_rounded, 'Mi lista'),
        _opcion(
          'admin',
          Icons.admin_panel_settings_rounded,
          'Administrar películas',
        ),
        const PopupMenuDivider(),
        _opcion('salir', Icons.logout_rounded, 'Cerrar sesión'),
      ],
    );
  }

  PopupMenuItem<String> _opcion(String valor, IconData icono, String texto) {
    return PopupMenuItem<String>(
      value: valor,
      height: 44,
      child: Row(
        children: <Widget>[
          Icon(icono, size: 18, color: Paleta.acento),
          const SizedBox(width: 11),
          Text(texto, style: const TextStyle(fontSize: 13.5)),
        ],
      ),
    );
  }
}
