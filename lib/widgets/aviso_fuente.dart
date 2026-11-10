import 'package:flutter/material.dart';

import '../servicios/peliculas_api.dart';
import '../tema/app_theme.dart';

class AvisoFuente extends StatelessWidget {
  const AvisoFuente({super.key, required this.peticion});

  final PeticionRegistrada? peticion;

  @override
  Widget build(BuildContext context) {
    final PeticionRegistrada? p = peticion;
    final bool ok = p != null && p.status == 200;
    final bool fallo = p != null && p.status != 200;

    if (p == null) return const SizedBox.shrink();

    final String texto;
    if (fallo) {
      texto =
          'Sin respuesta de TMDB · código ${p.status} · ${p.milisegundos} ms';
    } else {
      texto = '${p.resultados} resultados';
    }

    return Row(
      children: <Widget>[
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: fallo ? const Color(0xFFB4544B) : Paleta.borde,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            texto,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 11.5,
              letterSpacing: 0.1,
              color: fallo ? const Color(0xFFB4544B) : Paleta.textoSuave,
            ),
          ),
        ),
        if (ok)
          Text(
            'TMDB',
            style: TextStyle(
              fontSize: 10,
              letterSpacing: 1.2,
              fontWeight: FontWeight.w600,
              color: Paleta.textoSuave.withValues(alpha: 0.7),
            ),
          ),
      ],
    );
  }
}
