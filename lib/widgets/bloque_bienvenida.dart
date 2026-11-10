import 'package:flutter/material.dart';

import '../tema/app_theme.dart';

class BloqueBienvenida extends StatelessWidget {
  const BloqueBienvenida({super.key, this.total});

  final int? total;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'CATÁLOGO',
          style: TextStyle(
            fontSize: 10.5,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.6,
            color: Paleta.textoSuave,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Qué ver hoy',
          style: TextStyle(
            fontSize: 30,
            height: 1.1,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.6,
            color: Paleta.texto,
          ),
        ),
      ],
    );
  }
}
