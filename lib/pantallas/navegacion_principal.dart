import 'package:flutter/material.dart';

import '../estado/controlador_mi_lista.dart';
import '../servicios/iniciar_base_de_datos.dart';
import '../servicios/peliculas_api.dart';
import '../servicios/sesion.dart';
import '../tema/app_theme.dart';
import '../widgets/menu_superior.dart';
import 'home_screen.dart';
import 'mi_lista_screen.dart';
import 'pantalla_perfil.dart';

class NavegacionPrincipal extends StatefulWidget {
  const NavegacionPrincipal({
    super.key,
    this.api,
    required this.conexion,
    this.usuario,
    this.servicio,
  });

  final PeliculasApi? api;

  final ConexionBase conexion;

  final UsuarioSesion? usuario;

  final ServicioSesion? servicio;

  @override
  State<NavegacionPrincipal> createState() => _NavegacionPrincipalState();
}

class _NavegacionPrincipalState extends State<NavegacionPrincipal> {
  int _indice = 0;
  late final ControladorMiLista _controlador =
      ControladorMiLista(repositorio: widget.conexion.repositorio);

  @override
  void dispose() {
    _controlador.dispose();
    super.dispose();
  }

  void _irA(int indice) => setState(() => _indice = indice);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Paleta.fondo,
      body: IndexedStack(
        index: _indice,
        children: <Widget>[
          HomeScreen(
            api: widget.api,
            controlador: _controlador,
            acciones: MenuSuperior(
              conexion: widget.conexion,
              controlador: _controlador,
              sesion: widget.servicio,
              usuario: widget.usuario,
              alIrAMiLista: () => _irA(1),
            ),
          ),
          MiListaScreen(
            controlador: _controlador,
            enLinea: widget.conexion.enLinea,
            detalleConexion: widget.conexion.mensaje,
            alExplorar: () => _irA(0),
          ),
          PantallaPerfil(
            usuario: widget.usuario ?? UsuarioSesion.local(),
            conexion: widget.conexion,
            controlador: _controlador,
            sesion: widget.servicio,
          ),
        ],
      ),
      bottomNavigationBar: DecoratedBox(
        decoration: const BoxDecoration(
          color: Paleta.superficie,
          border: Border(top: BorderSide(color: Paleta.borde)),
        ),
        child: AnimatedBuilder(
          animation: _controlador,
          builder: (BuildContext context, Widget? _) => _barra(),
        ),
      ),
    );
  }

  Widget _barra() {
    return NavigationBarTheme(
      data: NavigationBarThemeData(
        height: 68,
        backgroundColor: Colors.transparent,
        elevation: 0,
        indicatorColor: Paleta.acento.withValues(alpha: 0.16),
        labelTextStyle: WidgetStateProperty.resolveWith<TextStyle>(
          (Set<WidgetState> estados) => TextStyle(
            fontSize: 11.5,
            fontWeight: estados.contains(WidgetState.selected)
                ? FontWeight.w700
                : FontWeight.w500,
            color: estados.contains(WidgetState.selected)
                ? Paleta.texto
                : Paleta.textoSuave,
          ),
        ),
        iconTheme: WidgetStateProperty.resolveWith<IconThemeData>(
          (Set<WidgetState> estados) => IconThemeData(
            size: 23,
            color: estados.contains(WidgetState.selected)
                ? Paleta.acento
                : Paleta.textoSuave,
          ),
        ),
      ),
      child: NavigationBar(
        selectedIndex: _indice,
        onDestinationSelected: _irA,
        destinations: <Widget>[
          const NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Inicio',
          ),
          NavigationDestination(
            icon: Badge(
              isLabelVisible: _controlador.total > 0,
              backgroundColor: Paleta.acento,
              label: Text('${_controlador.total}'),
              child: const Icon(Icons.bookmark_border_rounded),
            ),
            selectedIcon: Badge(
              isLabelVisible: _controlador.total > 0,
              backgroundColor: Paleta.acento,
              label: Text('${_controlador.total}'),
              child: const Icon(Icons.bookmark_rounded),
            ),
            label: 'Mi lista',
          ),
          const NavigationDestination(
            icon: Icon(Icons.person_outline_rounded),
            selectedIcon: Icon(Icons.person_rounded),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}
