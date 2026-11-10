import 'package:flutter/material.dart';

import '../estado/controlador_mi_lista.dart';
import '../modelos/calificacion.dart';
import '../modelos/favorito.dart';
import '../servicios/error_base_datos.dart';
import '../tema/app_theme.dart';
import '../widgets/hoja_detalle.dart';
import '../widgets/poster_pelicula.dart';
import '../widgets/selector_estrellas.dart';

class MiListaScreen extends StatelessWidget {
  const MiListaScreen({
    super.key,
    required this.controlador,
    this.enLinea = true,
    this.detalleConexion = '',
    this.alExplorar,
  });

  final ControladorMiLista controlador;

  final bool enLinea;

  final String detalleConexion;

  final VoidCallback? alExplorar;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Paleta.fondo,
      body: SafeArea(
        bottom: false,
        child: AnimatedBuilder(
          animation: controlador,
          builder: (BuildContext context, Widget? _) {
            return RefreshIndicator(
              onRefresh: () async {
                controlador.limpiarError();
              },
              color: Paleta.acento,
              backgroundColor: Paleta.superficieAlta,
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                slivers: <Widget>[
                  SliverToBoxAdapter(child: _encabezado(context)),
                  if (controlador.cargando)
                    const SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: CircularProgressIndicator(color: Paleta.acento),
                      ),
                    )
                  else if (controlador.favoritos.isEmpty)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: _vacia(context),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
                      sliver: SliverList.separated(
                        itemCount: controlador.favoritos.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 12),
                        itemBuilder: (BuildContext context, int i) => _FilaFavorito(
                          favorito: controlador.favoritos[i],
                          calificacion: controlador
                              .calificacionDe(controlador.favoritos[i].peliculaId),
                          alTocar: () => mostrarDetallePelicula(
                            context,
                            controlador.favoritos[i].comoPelicula(),
                            controlador: controlador,
                          ),
                          alQuitar: () => _quitar(context, controlador.favoritos[i]),
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _encabezado(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              const Expanded(
                child: Text(
                  'Mi lista',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.6,
                    color: Paleta.texto,
                  ),
                ),
              ),
              _Contador(total: controlador.total),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            controlador.total == 1
                ? '1 película guardada en tu cuenta'
                : '${controlador.total} películas guardadas en tu cuenta',
            style: const TextStyle(fontSize: 13, color: Paleta.textoSuave),
          ),
          const SizedBox(height: 12),
          _ChipConexion(enLinea: enLinea, detalle: detalleConexion),
          if (controlador.ultimoError != null) ...<Widget>[
            const SizedBox(height: 10),
            Text(
              controlador.ultimoError!,
              style: const TextStyle(fontSize: 12.5, color: Paleta.acento),
            ),
          ],
        ],
      ),
    );
  }

  Widget _vacia(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            width: 74,
            height: 74,
            decoration: BoxDecoration(
              color: Paleta.superficie,
              shape: BoxShape.circle,
              border: Border.all(color: Paleta.borde),
            ),
            child: const Icon(
              Icons.bookmark_border_rounded,
              color: Paleta.acento,
              size: 32,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Tu lista está vacía',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Paleta.texto,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Abre una película del catálogo y toca «Mi lista» para guardarla. '
            'Se guarda en la base de datos y aparece aquí al instante.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13.5,
              height: 1.5,
              color: Paleta.textoSuave,
            ),
          ),
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: alExplorar,
            icon: const Icon(Icons.explore_rounded, size: 19),
            label: const Text('Explorar catálogo'),
            style: FilledButton.styleFrom(
              backgroundColor: Paleta.acento,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _quitar(BuildContext context, Favorito favorito) async {
    final ScaffoldMessengerState mensajes = ScaffoldMessenger.of(context);
    try {
      await controlador.repositorio.quitarFavorito(favorito.peliculaId);
      mensajes
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(content: Text('«${favorito.titulo}» salió de tu lista.')),
        );
    } catch (error) {
      final String texto = error is ErrorBaseDatos
          ? error.mensaje
          : 'No se pudo quitar la película.';
      mensajes
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(texto)));
    }
  }
}

class _Contador extends StatelessWidget {
  const _Contador({required this.total});

  final int total;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Paleta.acento.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(Radios.chip),
        border: Border.all(color: Paleta.acento.withValues(alpha: 0.35)),
      ),
      child: Text(
        '$total',
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w800,
          color: Paleta.acento,
        ),
      ),
    );
  }
}

class _ChipConexion extends StatelessWidget {
  const _ChipConexion({required this.enLinea, required this.detalle});

  final bool enLinea;
  final String detalle;

  @override
  Widget build(BuildContext context) {
    final Color color = enLinea ? const Color(0xFF3DD68C) : Paleta.ambar;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            enLinea ? (detalle.isEmpty ? 'Conectado' : detalle) : 'Sin conexión',
            style: const TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: Paleta.textoSuave,
            ),
          ),
        ),
      ],
    );
  }
}

class _FilaFavorito extends StatelessWidget {
  const _FilaFavorito({
    required this.favorito,
    required this.calificacion,
    required this.alTocar,
    required this.alQuitar,
  });

  final Favorito favorito;
  final Calificacion? calificacion;
  final VoidCallback alTocar;
  final VoidCallback alQuitar;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Paleta.superficie,
      borderRadius: BorderRadius.circular(Radios.tarjeta),
      child: InkWell(
        onTap: alTocar,
        borderRadius: BorderRadius.circular(Radios.tarjeta),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(Radios.tarjeta),
            border: Border.all(color: Paleta.borde),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              SizedBox(
                width: 62,
                height: 92,
                child: PosterPelicula(
                  pelicula: favorito.comoPelicula(),
                  radio: 10,
                  semantica: 'Póster de ${favorito.titulo}',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      favorito.titulo,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w700,
                        height: 1.2,
                        color: Paleta.texto,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${favorito.genero} · ${favorito.anio ?? 's/f'}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11.5,
                        color: Paleta.textoSuave,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (calificacion != null)
                      SelectorEstrellas(
                        valor: calificacion!.estrellas,
                        tamano: 16,
                        mostrarEtiqueta: true,
                      )
                    else
                      Text(
                        'Guardada el ${_fecha(favorito.agregadoEn)}',
                        style: const TextStyle(
                          fontSize: 11,
                          color: Paleta.textoSuave,
                        ),
                      ),
                  ],
                ),
              ),
              IconButton(
                onPressed: alQuitar,
                tooltip: 'Quitar de la lista',
                icon: const Icon(
                  Icons.delete_outline_rounded,
                  size: 20,
                  color: Paleta.textoSuave,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static String _fecha(DateTime fecha) {
    const List<String> meses = <String>[
      'ene', 'feb', 'mar', 'abr', 'may', 'jun',
      'jul', 'ago', 'sep', 'oct', 'nov', 'dic',
    ];
    return '${fecha.day} ${meses[fecha.month - 1]} ${fecha.year}';
  }
}
