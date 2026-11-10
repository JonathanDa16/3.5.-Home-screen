import 'package:flutter/material.dart';

import '../tema/app_theme.dart';

class TituloSeccion extends StatelessWidget {
  const TituloSeccion({
    super.key,
    required this.titulo,
    this.detalle,
    this.accion,
    this.alTocarAccion,
  });

  final String titulo;
  final String? detalle;
  final String? accion;
  final VoidCallback? alTocarAccion;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Text(
          titulo,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.2,
            color: Paleta.texto,
          ),
        ),
        if (detalle != null) ...<Widget>[
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
            decoration: BoxDecoration(
              color: Paleta.superficieAlta,
              borderRadius: BorderRadius.circular(Radios.chip),
            ),
            child: Text(
              detalle!,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Paleta.textoSuave,
              ),
            ),
          ),
        ],
        const Spacer(),
        if (accion != null)
          TextButton(
            onPressed: alTocarAccion,
            style: TextButton.styleFrom(
              foregroundColor: Paleta.acento,
              padding: const EdgeInsets.symmetric(horizontal: 4),
              minimumSize: const Size(0, 32),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              accion!,
              style: const TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
      ],
    );
  }
}
