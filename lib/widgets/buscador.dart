import 'package:flutter/material.dart';

import '../tema/app_theme.dart';

class Buscador extends StatelessWidget {
  const Buscador({
    super.key,
    required this.controlador,
    required this.alCambiar,
    required this.alLimpiar,
  });

  final TextEditingController controlador;
  final ValueChanged<String> alCambiar;
  final VoidCallback alLimpiar;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: controlador,
      builder: (BuildContext context, TextEditingValue valor, _) {
        return TextField(
          controller: controlador,
          onChanged: alCambiar,
          onSubmitted: alCambiar,
          textInputAction: TextInputAction.search,
          style: const TextStyle(fontSize: 14.5, color: Paleta.texto),
          cursorColor: Paleta.acento,
          decoration: InputDecoration(
            hintText: 'Busca por título, género o año',
            hintStyle: const TextStyle(
              fontSize: 14,
              color: Paleta.textoSuave,
            ),
            prefixIcon: const Icon(
              Icons.search_rounded,
              color: Paleta.textoSuave,
              size: 21,
            ),
            suffixIcon: valor.text.isEmpty
                ? null
                : IconButton(
                    tooltip: 'Limpiar búsqueda',
                    onPressed: alLimpiar,
                    icon: const Icon(
                      Icons.close_rounded,
                      color: Paleta.textoSuave,
                      size: 19,
                    ),
                  ),
            filled: true,
            fillColor: Paleta.superficie.withValues(alpha: 0.82),
            contentPadding: const EdgeInsets.symmetric(
              vertical: 16,
              horizontal: 4,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(Radios.campo),
              borderSide: const BorderSide(color: Paleta.borde),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(Radios.campo),
              borderSide: const BorderSide(color: Paleta.acento, width: 1.4),
            ),
          ),
        );
      },
    );
  }
}
