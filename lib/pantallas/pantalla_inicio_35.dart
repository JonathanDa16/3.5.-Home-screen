import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../config/api_config.dart';
import '../servicios/iniciar_base_de_datos.dart';
import '../tema/app_theme.dart';
import 'navegacion_principal.dart';

class PantallaInicio35 extends StatelessWidget {
  const PantallaInicio35({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Image.asset(
            ApiConfig.fondoLocal,
            fit: BoxFit.cover,
            semanticLabel: 'Imagen de fondo: sala de cine a oscuras',
          ),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: <Color>[
                  Color(0xB30F1011),
                  Color(0x990F1011),
                  Color(0xF70F1011),
                ],
                stops: <double>[0.0, 0.45, 1.0],
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(26, 22, 26, 26),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      const Icon(CupertinoIcons.film, color: Paleta.acento, size: 26),
                      const SizedBox(width: 9),
                      const Text(
                        'CineCatálogo',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.3,
                          color: Paleta.texto,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Container(width: 46, height: 3, color: Paleta.acento),
                  const SizedBox(height: 18),
                  const Text(
                    'Bienvenido',
                    style: TextStyle(
                      fontSize: 38,
                      height: 1.05,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -1.0,
                      color: Paleta.texto,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Este es tu catálogo de películas. Busca por título, género o año, abre la ficha de cada una y guarda las que quieras ver después.',
                    style: TextStyle(
                      fontSize: 14.5,
                      height: 1.5,
                      color: Paleta.textoSuave,
                    ),
                  ),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => NavegacionPrincipal(
                            conexion: ConexionBase.sinConexion(
                              'Datos de ejemplo en memoria',
                            ),
                          ),
                        ),
                      ),
                      style: FilledButton.styleFrom(
                        backgroundColor: Paleta.acento,
                        foregroundColor: const Color(0xFF15130C),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(Radios.campo),
                        ),
                      ),
                      child: const Text(
                        'Entrar al catálogo',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
