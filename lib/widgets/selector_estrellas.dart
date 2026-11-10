import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../modelos/calificacion.dart';
import '../tema/app_theme.dart';

class SelectorEstrellas extends StatelessWidget {
  const SelectorEstrellas({
    super.key,
    required this.valor,
    this.alElegir,
    this.tamano = 28,
    this.mostrarEtiqueta = false,
  });

  final int valor;

  final ValueChanged<int>? alElegir;

  final double tamano;

  final bool mostrarEtiqueta;

  @override
  Widget build(BuildContext context) {
    final bool editable = alElegir != null;

    final Widget estrellas = Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        for (int i = 1; i <= Calificacion.maximo; i++)
          Semantics(
            label: '$i ${i == 1 ? 'estrella' : 'estrellas'}',
            button: editable,
            child: GestureDetector(
              onTap: editable
                  ? () {
                      HapticFeedback.selectionClick();
                      alElegir!(i);
                    }
                  : null,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 2),
                child: Icon(
                  i <= valor ? Icons.star_rounded : Icons.star_outline_rounded,
                  size: tamano,
                  color: i <= valor ? Paleta.ambar : Paleta.textoSuave,
                ),
              ),
            ),
          ),
      ],
    );

    if (!mostrarEtiqueta) return estrellas;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        estrellas,
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            valor == 0 ? 'Sin calificar' : '$valor de ${Calificacion.maximo}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              color: Paleta.textoSuave,
            ),
          ),
        ),
      ],
    );
  }
}
