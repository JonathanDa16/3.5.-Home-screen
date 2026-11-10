import 'package:flutter/material.dart';

import '../tema/app_theme.dart';

class EstadoVacio extends StatelessWidget {
  const EstadoVacio({
    super.key,
    required this.consulta,
    required this.alLimpiar,
  });

  final String consulta;
  final VoidCallback alLimpiar;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 44, horizontal: 16),
      child: Column(
        children: <Widget>[
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: Paleta.superficie,
              shape: BoxShape.circle,
              border: Border.all(color: Paleta.borde),
            ),
            child: const Icon(
              Icons.search_off_rounded,
              color: Paleta.textoSuave,
              size: 30,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Sin resultados',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Paleta.texto,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Ninguna película del catálogo coincide con «$consulta».',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13,
              height: 1.45,
              color: Paleta.textoSuave,
            ),
          ),
          const SizedBox(height: 18),
          TextButton.icon(
            onPressed: alLimpiar,
            icon: const Icon(Icons.refresh_rounded, size: 18),
            label: const Text('Ver todo el catálogo'),
            style: TextButton.styleFrom(foregroundColor: Paleta.acento),
          ),
        ],
      ),
    );
  }
}
