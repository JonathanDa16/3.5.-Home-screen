import 'package:flutter/material.dart';

import '../modelos/pelicula.dart';
import '../tema/app_theme.dart';

class PosterPelicula extends StatelessWidget {
  const PosterPelicula({
    super.key,
    required this.pelicula,
    this.radio = Radios.poster,
    this.semantica,
  });

  final Pelicula pelicula;
  final double radio;
  final String? semantica;

  @override
  Widget build(BuildContext context) {
    final String etiqueta = semantica ?? 'Póster de ${pelicula.titulo}';

    return ClipRRect(
      borderRadius: BorderRadius.circular(radio),
      child: _contenido(etiqueta),
    );
  }

  Widget _contenido(String etiqueta) {
    if (pelicula.poster.isEmpty) {
      return _Respaldo(etiqueta: etiqueta, conTexto: true);
    }

    if (!pelicula.posterRemoto) {
      return Image.asset(
        pelicula.poster,
        fit: BoxFit.cover,
        semanticLabel: etiqueta,
        errorBuilder: (_, _, _) => _Respaldo(etiqueta: etiqueta),
      );
    }

    return Image.network(
      pelicula.poster,
      fit: BoxFit.cover,
      semanticLabel: etiqueta,
      cacheWidth: 420,
      frameBuilder: (
        BuildContext context,
        Widget child,
        int? frame,
        bool fueSincrono,
      ) {
        if (fueSincrono) return child;
        return AnimatedOpacity(
          opacity: frame == null ? 0 : 1,
          duration: const Duration(milliseconds: 260),
          curve: Curves.easeOut,
          child: child,
        );
      },
      loadingBuilder: (
        BuildContext context,
        Widget child,
        ImageChunkEvent? progreso,
      ) {
        if (progreso == null) return child;
        final double? avance = progreso.expectedTotalBytes == null
            ? null
            : progreso.cumulativeBytesLoaded / progreso.expectedTotalBytes!;
        return _CargandoPoster(avance: avance);
      },
      errorBuilder: (_, _, _) => _Respaldo(etiqueta: etiqueta),
    );
  }
}

class _CargandoPoster extends StatelessWidget {
  const _CargandoPoster({this.avance});

  final double? avance;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Paleta.superficieAlta,
      child: Center(
        child: SizedBox(
          width: 22,
          height: 22,
          child: CircularProgressIndicator(
            value: avance,
            strokeWidth: 2,
            color: Paleta.acento.withValues(alpha: 0.8),
          ),
        ),
      ),
    );
  }
}

class _Respaldo extends StatelessWidget {
  const _Respaldo({required this.etiqueta, this.conTexto = false});

  final String etiqueta;
  final bool conTexto;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '$etiqueta (imagen no disponible)',
      image: true,
      child: ColoredBox(
        color: Paleta.superficieAlta,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const Icon(
                Icons.movie_filter_rounded,
                color: Paleta.textoSuave,
                size: 26,
              ),
              if (conTexto) ...<Widget>[
                const SizedBox(height: 6),
                const Text(
                  'Sin póster',
                  style: TextStyle(fontSize: 10.5, color: Paleta.textoSuave),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
