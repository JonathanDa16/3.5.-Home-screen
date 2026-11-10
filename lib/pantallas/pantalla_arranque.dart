import 'package:flutter/material.dart';

import '../config/firebase_config.dart';
import '../tema/app_theme.dart';

class PantallaArranque extends StatelessWidget {
  const PantallaArranque({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Paleta.fondo,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                width: 78,
                height: 78,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: <Color>[Paleta.acento, Paleta.acentoOscuro],
                  ),
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: Paleta.acento.withValues(alpha: 0.35),
                      blurRadius: 22,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.movie_filter_rounded,
                  color: Colors.white,
                  size: 36,
                ),
              ),
              const SizedBox(height: 22),
              const Text(
                'CineCatálogo',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                  color: Paleta.texto,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                FirebaseConfig.usarEmulador
                    ? 'Conectando con Cloud Firestore (emulador)…'
                    : 'Conectando con Cloud Firestore…',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13,
                  height: 1.5,
                  color: Paleta.textoSuave,
                ),
              ),
              const SizedBox(height: 26),
              const SizedBox(
                width: 26,
                height: 26,
                child: CircularProgressIndicator(
                  strokeWidth: 2.4,
                  color: Paleta.acento,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
