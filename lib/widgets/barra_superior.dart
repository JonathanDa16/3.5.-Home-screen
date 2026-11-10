import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../tema/app_theme.dart';

class BarraSuperior extends StatelessWidget {
  const BarraSuperior({super.key, this.acciones, this.volver = false});

  /// Menú de la derecha. Cuando no se pasa, queda el botón de avisos de las
  /// entregas anteriores.
  final Widget? acciones;

  /// true en las pantallas que se abren encima del inicio: cambia el isotipo
  /// por una flecha para regresar.
  final bool volver;

  @override
  Widget build(BuildContext context) {
    final Widget? extra = acciones;

    return Row(
      children: <Widget>[
        if (volver)
          IconButton(
            onPressed: () => Navigator.of(context).maybePop(),
            tooltip: 'Regresar',
            icon: const Icon(
              Icons.arrow_back_rounded,
              color: Paleta.texto,
              size: 21,
            ),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints.tightFor(width: 34, height: 34),
          )
        else
          const Icon(
            CupertinoIcons.film,
            color: Paleta.acento,
            size: 22,
          ),
        const SizedBox(width: 8),
        const Expanded(
          child: Text(
            'CineCatálogo',
            style: TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.3,
              color: Paleta.texto,
            ),
          ),
        ),
        if (extra != null)
          extra
        else
          IconButton(
            onPressed: () {
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(
                  const SnackBar(content: Text('No tienes avisos nuevos.')),
                );
            },
            tooltip: 'Avisos',
            icon: const Icon(
              CupertinoIcons.bell,
              size: 21,
              color: Paleta.textoSuave,
            ),
            splashRadius: 22,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints.tightFor(width: 34, height: 34),
          ),
      ],
    );
  }
}
