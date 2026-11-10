import 'package:flutter/material.dart';

import '../config/api_config.dart';
import '../servicios/sesion.dart';
import '../tema/app_theme.dart';
import 'pantalla_acceso.dart';
import 'pantalla_registro.dart';

/// Primera pantalla de la app. Muestra la bienvenida y las dos puertas que
/// pide el producto integrador: registrarse o entrar con una cuenta existente.
class PantallaBienvenida extends StatelessWidget {
  const PantallaBienvenida({
    super.key,
    this.servicio,
    this.disponible = true,
    this.alEntrarLocal,
  });

  final ServicioSesion? servicio;

  /// false cuando Firebase no arrancó: solo queda el modo local.
  final bool disponible;

  final VoidCallback? alEntrarLocal;

  @override
  Widget build(BuildContext context) {
    final ServicioSesion? sesion = servicio;

    return Scaffold(
      backgroundColor: Paleta.fondo,
      body: Stack(
        children: <Widget>[
          Positioned.fill(
            child: Image.asset(
              ApiConfig.fondoLocal,
              fit: BoxFit.cover,
              semanticLabel: 'Imagen de fondo: sala de cine a oscuras',
            ),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: <Color>[
                    Paleta.fondo.withValues(alpha: 0.78),
                    Paleta.fondo.withValues(alpha: 0.88),
                    Paleta.fondo,
                  ],
                  stops: const <double>[0.0, 0.45, 1.0],
                ),
              ),
            ),
          ),
          SafeArea(
            child: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints medidas) {
                return SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: medidas.maxHeight),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(26, 18, 26, 22),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          const _Marca(),
                          const SizedBox(height: 54),
                          const Text(
                            'Bienvenido a CineCatálogo',
                            style: TextStyle(
                              fontSize: 29,
                              height: 1.16,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.7,
                              color: Paleta.texto,
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Regístrate para armar tu lista de películas, '
                            'calificarlas y administrar el catálogo de la '
                            'base de datos.',
                            style: TextStyle(
                              fontSize: 14,
                              height: 1.55,
                              color: Paleta.textoSuave,
                            ),
                          ),
                          const SizedBox(height: 34),
                          if (sesion != null) ...<Widget>[
                            FilledButton(
                              onPressed: () => Navigator.of(context).push(
                                MaterialPageRoute<void>(
                                  builder: (_) => PantallaRegistro(
                                    servicio: sesion,
                                  ),
                                ),
                              ),
                              style: FilledButton.styleFrom(
                                backgroundColor: Paleta.acento,
                                foregroundColor: const Color(0xFF15130C),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 17),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              child: const Text(
                                'Crear una cuenta',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            OutlinedButton(
                              onPressed: () => Navigator.of(context).push(
                                MaterialPageRoute<void>(
                                  builder: (_) => PantallaAcceso(
                                    servicio: sesion,
                                  ),
                                ),
                              ),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Paleta.texto,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 17),
                                side: const BorderSide(color: Paleta.borde),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              child: const Text(
                                'Ya tengo cuenta · Iniciar sesión',
                                style: TextStyle(
                                  fontSize: 14.5,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ] else ...<Widget>[
                            Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: Paleta.superficie,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Paleta.borde),
                              ),
                              child: const Text(
                                'El servicio de autenticación no está '
                                'disponible en este momento. Puedes recorrer '
                                'la app con los datos en memoria.',
                                style: TextStyle(
                                  fontSize: 13,
                                  height: 1.5,
                                  color: Paleta.textoSuave,
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            FilledButton(
                              onPressed: alEntrarLocal,
                              style: FilledButton.styleFrom(
                                backgroundColor: Paleta.acento,
                                foregroundColor: const Color(0xFF15130C),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 17),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              child: const Text(
                                'Entrar en modo local',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                          const Spacer(),
                          const SizedBox(height: 28),
                          const Text(
                            'Universidad de Guadalajara · UDG Virtual\n'
                            'Diseño de aplicaciones móviles',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 11.5,
                              height: 1.6,
                              color: Color(0xFF6D7278),
                            ),
                          ),
                          if (!disponible) ...<Widget>[
                            const SizedBox(height: 10),
                            const Text(
                              'Modo sin conexión con Firebase',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 11,
                                color: Paleta.acentoOscuro,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _Marca extends StatelessWidget {
  const _Marca();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: <Color>[Paleta.acento, Paleta.acentoOscuro],
            ),
            borderRadius: BorderRadius.circular(13),
          ),
          child: const Icon(
            Icons.movie_filter_rounded,
            color: Colors.white,
            size: 24,
          ),
        ),
        const SizedBox(width: 11),
        const Text(
          'CineCatálogo',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.3,
            color: Paleta.texto,
          ),
        ),
      ],
    );
  }
}
