import 'package:flutter/material.dart';

import '../estado/controlador_mi_lista.dart';
import '../servicios/iniciar_base_de_datos.dart';
import '../servicios/sesion.dart';
import '../tema/app_theme.dart';
import '../widgets/barra_superior.dart';
import '../widgets/menu_superior.dart';
import 'pantalla_administracion.dart';
import 'pantalla_catalogo_base.dart';

/// Datos de la cuenta con la que se abrió la sesión y las salidas rápidas a
/// los catálogos administrables.
class PantallaPerfil extends StatelessWidget {
  const PantallaPerfil({
    super.key,
    required this.usuario,
    required this.conexion,
    required this.controlador,
    this.sesion,
  });

  final UsuarioSesion usuario;

  final ConexionBase conexion;

  final ControladorMiLista controlador;

  final ServicioSesion? sesion;

  @override
  Widget build(BuildContext context) {
    final String nombre = usuario.nombreTexto;
    final String inicial = nombre.trim().isEmpty
        ? '?'
        : nombre.trim().substring(0, 1).toUpperCase();

    return Scaffold(
      backgroundColor: Paleta.fondo,
      body: SafeArea(
        bottom: false,
        child: ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 28),
          children: <Widget>[
            BarraSuperior(
              acciones: MenuSuperior(
                conexion: conexion,
                controlador: controlador,
                sesion: sesion,
                usuario: usuario,
              ),
            ),
            const SizedBox(height: 26),
            Row(
              children: <Widget>[
                Container(
                  width: 58,
                  height: 58,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: <Color>[Paleta.acento, Paleta.acentoOscuro],
                    ),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Text(
                    inicial,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        nombre,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.4,
                          color: Paleta.texto,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        usuario.correoTexto,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Paleta.textoSuave,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 22),
            _Seccion(titulo: 'Cuenta', hijos: <Widget>[
              _Dato(etiqueta: 'Identificador', valor: usuario.uid),
              _Dato(
                etiqueta: 'Tipo de sesión',
                valor: usuario.anonimo
                    ? 'local (sin Firebase)'
                    : 'correo y contraseña',
              ),
            ]),
            const SizedBox(height: 14),
            _Seccion(titulo: 'Base de datos', hijos: <Widget>[
              _Dato(
                etiqueta: 'Estado',
                valor: conexion.enLinea ? 'conectada' : 'sin conexión',
              ),
              _Dato(etiqueta: 'Servicio', valor: conexion.mensaje),
              _Dato(
                etiqueta: 'Guardado',
                valor: '${controlador.total} en Mi lista · '
                    '${controlador.calificaciones.length} calificadas',
              ),
            ]),
            const SizedBox(height: 20),
            _Salida(
              icono: Icons.storage_rounded,
              titulo: 'Catálogo de la base de datos',
              detalle: 'Las películas que se dieron de alta en la app.',
              alTocar: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => PantallaCatalogoBase(
                    conexion: conexion,
                    controlador: controlador,
                    sesion: sesion,
                    usuario: usuario,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            _Salida(
              icono: Icons.admin_panel_settings_rounded,
              titulo: 'Administrar películas',
              detalle: 'Alta y baja del catálogo en Cloud Firestore.',
              alTocar: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => PantallaAdministracion(
                    conexion: conexion,
                    controlador: controlador,
                    sesion: sesion,
                    usuario: usuario,
                  ),
                ),
              ),
            ),
            if (sesion != null) ...<Widget>[
              const SizedBox(height: 22),
              OutlinedButton.icon(
                onPressed: () => sesion!.cerrarSesion(),
                icon: const Icon(Icons.logout_rounded, size: 18),
                label: const Text('Cerrar sesión'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Paleta.textoSuave,
                  side: const BorderSide(color: Paleta.borde),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _Seccion extends StatelessWidget {
  const _Seccion({required this.titulo, required this.hijos});

  final String titulo;
  final List<Widget> hijos;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
      decoration: BoxDecoration(
        color: Paleta.superficie,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Paleta.borde),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            titulo.toUpperCase(),
            style: const TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
              color: Paleta.textoSuave,
            ),
          ),
          const SizedBox(height: 8),
          ...hijos,
        ],
      ),
    );
  }
}

class _Dato extends StatelessWidget {
  const _Dato({required this.etiqueta, required this.valor});

  final String etiqueta;
  final String valor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            etiqueta,
            style: const TextStyle(fontSize: 11.5, color: Paleta.textoSuave),
          ),
          const SizedBox(height: 2),
          Text(
            valor,
            style: const TextStyle(
              fontSize: 13,
              height: 1.4,
              fontWeight: FontWeight.w600,
              color: Paleta.texto,
            ),
          ),
        ],
      ),
    );
  }
}

class _Salida extends StatelessWidget {
  const _Salida({
    required this.icono,
    required this.titulo,
    required this.detalle,
    required this.alTocar,
  });

  final IconData icono;
  final String titulo;
  final String detalle;
  final VoidCallback alTocar;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Paleta.superficie,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: alTocar,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Paleta.borde),
          ),
          child: Row(
            children: <Widget>[
              Icon(icono, size: 20, color: Paleta.acento),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      titulo,
                      style: const TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: Paleta.texto,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      detalle,
                      style: const TextStyle(
                        fontSize: 11.5,
                        color: Paleta.textoSuave,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                size: 20,
                color: Paleta.textoSuave,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
