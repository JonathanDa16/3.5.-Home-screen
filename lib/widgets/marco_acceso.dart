import 'package:flutter/material.dart';

import '../tema/app_theme.dart';

/// Marco común de las pantallas de acceso y registro: fondo oscuro, botón de
/// regreso, título, subtítulo y el bloque de campos.
class MarcoAcceso extends StatelessWidget {
  const MarcoAcceso({
    super.key,
    required this.titulo,
    required this.subtitulo,
    required this.hijos,
  });

  final String titulo;
  final String subtitulo;
  final List<Widget> hijos;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Paleta.fondo,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  onPressed: () => Navigator.of(context).maybePop(),
                  icon: const Icon(
                    Icons.arrow_back_rounded,
                    color: Paleta.texto,
                    size: 22,
                  ),
                  tooltip: 'Regresar',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints.tightFor(
                    width: 38,
                    height: 38,
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                titulo,
                style: const TextStyle(
                  fontSize: 27,
                  height: 1.16,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.6,
                  color: Paleta.texto,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                subtitulo,
                style: const TextStyle(
                  fontSize: 13.5,
                  height: 1.55,
                  color: Paleta.textoSuave,
                ),
              ),
              const SizedBox(height: 26),
              ...hijos,
            ],
          ),
        ),
      ),
    );
  }
}

/// Caja roja para mostrar el error que devuelve el servicio de autenticación.
class AvisoError extends StatelessWidget {
  const AvisoError({super.key, required this.mensaje});

  final String mensaje;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: const Color(0xFF2A1A19),
        borderRadius: BorderRadius.circular(11),
        border: Border.all(color: const Color(0xFF5A2B27)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Icon(
            Icons.error_outline_rounded,
            size: 17,
            color: Color(0xFFE0736B),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              mensaje,
              style: const TextStyle(
                fontSize: 12.5,
                height: 1.45,
                color: Color(0xFFE8B4B0),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
