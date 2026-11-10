import 'package:flutter/material.dart';

import '../estado/controlador_mi_lista.dart';
import '../modelos/pelicula.dart';
import '../servicios/iniciar_base_de_datos.dart';
import '../servicios/sesion.dart';
import '../tema/app_theme.dart';
import '../widgets/barra_superior.dart';
import '../widgets/hoja_detalle.dart';
import '../widgets/menu_superior.dart';
import '../widgets/tarjeta_pelicula.dart';
import 'pantalla_administracion.dart';

/// Catálogo que vive en la colección `catalogo` de Firestore: las películas
/// que se dieron de alta desde la pantalla de administración. Se abre desde
/// el menú de la parte superior.
class PantallaCatalogoBase extends StatelessWidget {
  const PantallaCatalogoBase({
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Paleta.fondo,
      body: SafeArea(
        bottom: false,
        child: StreamBuilder<List<Pelicula>>(
          stream: conexion.repositorio.catalogo(),
          builder: (
            BuildContext context,
            AsyncSnapshot<List<Pelicula>> instantanea,
          ) {
            final List<Pelicula> peliculas =
                instantanea.data ?? const <Pelicula>[];

            return CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: <Widget>[
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
                  sliver: SliverToBoxAdapter(
                    child: BarraSuperior(
                      volver: true,
                      acciones: MenuSuperior(
                        conexion: conexion,
                        controlador: controlador,
                        sesion: sesion,
                        usuario: usuario,
                        alIrAMiLista: alIrAMiLista,
                      ),
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                  sliver: SliverToBoxAdapter(child: _encabezado(peliculas)),
                ),
                if (instantanea.hasError)
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 26, 20, 0),
                    sliver: SliverToBoxAdapter(
                      child: Text(
                        'No se pudo leer la colección catalogo: '
                        '${instantanea.error}',
                        style: const TextStyle(
                          fontSize: 12.5,
                          height: 1.5,
                          color: Color(0xFFE0736B),
                        ),
                      ),
                    ),
                  ),
                if (peliculas.isEmpty && !instantanea.hasError)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: _vacio(context),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 18, 20, 30),
                    sliver: SliverGrid(
                      gridDelegate:
                          const SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: 210,
                        mainAxisSpacing: 20,
                        crossAxisSpacing: 16,
                        mainAxisExtent: 310,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (BuildContext context, int i) {
                          final Pelicula p = peliculas[i];
                          return TarjetaPelicula(
                            pelicula: p,
                            alTocar: () => mostrarDetallePelicula(
                              context,
                              p,
                              controlador: controlador,
                            ),
                          );
                        },
                        childCount: peliculas.length,
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _encabezado(List<Pelicula> peliculas) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Text(
          'Catálogo de la base de datos',
          style: TextStyle(
            fontSize: 23,
            height: 1.15,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
            color: Paleta.texto,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Películas dadas de alta desde la pantalla de administración. '
          'Se guardan en la colección catalogo de Cloud Firestore y las ve '
          'cualquier cuenta registrada.',
          style: TextStyle(
            fontSize: 13,
            height: 1.55,
            color: Paleta.textoSuave,
          ),
        ),
        const SizedBox(height: 14),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: <Widget>[
            _Pildora(
              icono: Icons.storage_rounded,
              texto: '${peliculas.length} '
                  '${peliculas.length == 1 ? 'película' : 'películas'}',
            ),
            _Pildora(
              icono: conexion.enLinea
                  ? Icons.cloud_done_rounded
                  : Icons.cloud_off_rounded,
              texto: conexion.mensaje,
            ),
          ],
        ),
      ],
    );
  }

  Widget _vacio(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 30, 28, 30),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          const Icon(
            Icons.storage_rounded,
            size: 46,
            color: Paleta.textoSuave,
          ),
          const SizedBox(height: 16),
          const Text(
            'Todavía no hay películas en la base de datos',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15.5,
              fontWeight: FontWeight.w700,
              color: Paleta.texto,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Las que agregues desde la administración aparecen aquí y se '
            'quedan guardadas aunque cierres la sesión.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              height: 1.55,
              color: Paleta.textoSuave,
            ),
          ),
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => PantallaAdministracion(
                  conexion: conexion,
                  controlador: controlador,
                  sesion: sesion,
                  usuario: usuario,
                ),
              ),
            ),
            icon: const Icon(Icons.add_rounded, size: 19),
            label: const Text('Ir a administración'),
            style: FilledButton.styleFrom(
              backgroundColor: Paleta.acento,
              foregroundColor: const Color(0xFF15130C),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(13),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Pildora extends StatelessWidget {
  const _Pildora({required this.icono, required this.texto});

  final IconData icono;
  final String texto;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Paleta.superficieAlta,
        borderRadius: BorderRadius.circular(Radios.chip),
        border: Border.all(color: Paleta.borde),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icono, size: 13, color: Paleta.acento),
          const SizedBox(width: 6),
          Text(
            texto,
            style: const TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: Paleta.textoSuave,
            ),
          ),
        ],
      ),
    );
  }
}
