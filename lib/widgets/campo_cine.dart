import 'package:flutter/material.dart';

import '../tema/app_theme.dart';

/// Campo de texto con el estilo oscuro de la app, para las pantallas de
/// registro y acceso.
class CampoCine extends StatelessWidget {
  const CampoCine({
    super.key,
    required this.etiqueta,
    required this.controlador,
    this.pista,
    this.icono,
    this.tipoTeclado,
    this.oculto = false,
    this.validador,
    this.alEnviar,
    this.accionTeclado,
  });

  final String etiqueta;
  final TextEditingController controlador;
  final String? pista;
  final IconData? icono;
  final TextInputType? tipoTeclado;
  final bool oculto;
  final String? Function(String?)? validador;
  final VoidCallback? alEnviar;
  final TextInputAction? accionTeclado;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controlador,
      keyboardType: tipoTeclado,
      obscureText: oculto,
      validator: validador,
      onFieldSubmitted: (_) => alEnviar?.call(),
      textInputAction: accionTeclado,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      style: const TextStyle(fontSize: 14.5, color: Paleta.texto),
      cursorColor: Paleta.acento,
      decoration: InputDecoration(
        labelText: etiqueta,
        hintText: pista,
        prefixIcon: icono == null
            ? null
            : Icon(icono, size: 19, color: Paleta.textoSuave),
        filled: true,
        fillColor: Paleta.superficie,
        labelStyle: const TextStyle(fontSize: 13.5, color: Paleta.textoSuave),
        hintStyle: const TextStyle(fontSize: 13, color: Color(0xFF6D7278)),
        errorStyle: const TextStyle(fontSize: 11.5, color: Color(0xFFE0736B)),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Paleta.borde),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Paleta.acento, width: 1.4),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF8C3B36)),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE0736B)),
        ),
      ),
    );
  }
}
