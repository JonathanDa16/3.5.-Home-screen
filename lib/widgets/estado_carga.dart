import 'package:flutter/material.dart';

import '../config/api_config.dart';
import '../tema/app_theme.dart';

class EstadoCarga extends StatefulWidget {
  const EstadoCarga({super.key, this.mensaje});

  final String? mensaje;

  @override
  State<EstadoCarga> createState() => _EstadoCargaState();
}

class _EstadoCargaState extends State<EstadoCarga>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulso = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _pulso.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulso,
      builder: (BuildContext context, Widget? _) {
        final double opacidad = 0.30 + (_pulso.value * 0.35);
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _bloque(alto: 13, ancho: 150, opacidad: opacidad),
              const SizedBox(height: 18),
              Row(
                children: <Widget>[
                  for (int i = 0; i < 2; i++) ...<Widget>[
                    if (i > 0) const SizedBox(width: 14),
                    Expanded(
                      child: _bloque(alto: 210, opacidad: opacidad),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 26),
              _bloque(alto: 13, ancho: 120, opacidad: opacidad),
              const SizedBox(height: 16),
              Row(
                children: <Widget>[
                  for (int i = 0; i < 2; i++) ...<Widget>[
                    if (i > 0) const SizedBox(width: 16),
                    Expanded(
                      child: _bloque(alto: 150, opacidad: opacidad),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 22),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  SizedBox(
                    width: 15,
                    height: 15,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Paleta.acento.withValues(alpha: 0.8),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Flexible(
                    child: Text(
                      widget.mensaje ?? 'Consultando ${ApiConfig.host}…',
                      maxLines: 2,
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12.5,
                        color: Paleta.textoSuave,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _bloque({required double alto, double? ancho, double? opacidad}) {
    return Container(
      height: alto,
      width: ancho,
      decoration: BoxDecoration(
        color: Paleta.superficieAlta.withValues(alpha: opacidad ?? 0.5),
        borderRadius: BorderRadius.circular(14),
      ),
    );
  }
}
