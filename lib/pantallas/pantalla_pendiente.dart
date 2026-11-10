import 'package:flutter/material.dart';

import '../tema/app_theme.dart';

class PantallaPendiente extends StatelessWidget {
  const PantallaPendiente({
    super.key,
    required this.titulo,
    required this.descripcion,
    required this.icono,
    required this.actividad,
  });

  final String titulo;
  final String descripcion;
  final IconData icono;
  final String actividad;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Paleta.fondo,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 36),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Container(
                  width: 78,
                  height: 78,
                  decoration: BoxDecoration(
                    color: Paleta.superficie,
                    shape: BoxShape.circle,
                    border: Border.all(color: Paleta.borde),
                  ),
                  child: Icon(icono, color: Paleta.acento, size: 34),
                ),
                const SizedBox(height: 22),
                Text(
                  titulo,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Paleta.texto,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  descripcion,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 13.5,
                    height: 1.5,
                    color: Paleta.textoSuave,
                  ),
                ),
                const SizedBox(height: 22),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: Paleta.superficieAlta,
                    borderRadius: BorderRadius.circular(Radios.chip),
                    border: Border.all(color: Paleta.borde),
                  ),
                  child: Text(
                    actividad,
                    style: const TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: Paleta.textoSuave,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
