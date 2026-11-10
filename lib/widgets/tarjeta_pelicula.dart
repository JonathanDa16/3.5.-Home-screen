import 'package:flutter/material.dart';

import '../modelos/pelicula.dart';
import '../tema/app_theme.dart';
import 'poster_pelicula.dart';

class TarjetaPelicula extends StatelessWidget {
  const TarjetaPelicula({
    super.key,
    required this.pelicula,
    required this.alTocar,
    this.anchoFijo,
  });

  final Pelicula pelicula;
  final VoidCallback alTocar;
  final double? anchoFijo;

  @override
  Widget build(BuildContext context) {
    final Widget contenido = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(Radios.poster),
            child: Stack(
              fit: StackFit.expand,
              children: <Widget>[
                PosterPelicula(pelicula: pelicula),

                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: <Color>[
                          Colors.transparent,
                          Colors.transparent,
                          Paleta.fondo.withValues(alpha: 0.55),
                        ],
                        stops: const <double>[0, 0.6, 1],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: _ChipCalificacion(calificacion: pelicula.calificacion),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          pelicula.titulo,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 13.5,
            fontWeight: FontWeight.w600,
            color: Paleta.texto,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          '${pelicula.genero} · ${pelicula.anioTexto}',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 11.5, color: Paleta.textoSuave),
        ),
      ],
    );

    return Semantics(
      button: true,
      label: '${pelicula.titulo}, ${pelicula.anio}, '
          'calificación ${pelicula.calificacion}',
      child: GestureDetector(
        onTap: alTocar,
        behavior: HitTestBehavior.opaque,
        child: anchoFijo == null
            ? contenido
            : SizedBox(width: anchoFijo, child: contenido),
      ),
    );
  }
}

class _ChipCalificacion extends StatelessWidget {
  const _ChipCalificacion({required this.calificacion});

  final double calificacion;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        const Icon(Icons.star_rounded, color: Paleta.ambar, size: 13),
        const SizedBox(width: 3),
        Text(
          calificacion.toStringAsFixed(1),
          style: const TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.w600,
            color: Color(0xFFF2F2F2),
            shadows: <Shadow>[
              Shadow(blurRadius: 4, color: Color(0xCC000000)),
            ],
          ),
        ),
      ],
    );
  }
}
