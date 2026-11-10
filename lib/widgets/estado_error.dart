import 'package:flutter/material.dart';

import '../servicios/error_api.dart';
import '../tema/app_theme.dart';

class EstadoError extends StatelessWidget {
  const EstadoError({
    super.key,
    required this.error,
    required this.alReintentar,
  });

  final ErrorApi error;
  final VoidCallback alReintentar;

  IconData get _icono => switch (error.tipo) {
        TipoErrorApi.sinConexion => Icons.wifi_off_rounded,
        TipoErrorApi.tiempoAgotado => Icons.hourglass_empty_rounded,
        TipoErrorApi.credenciales => Icons.key_off_rounded,
        TipoErrorApi.noEncontrado => Icons.search_off_rounded,
        TipoErrorApi.servidor => Icons.cloud_off_rounded,
        TipoErrorApi.respuestaInvalida => Icons.data_object_rounded,
        TipoErrorApi.desconocido => Icons.error_outline_rounded,
      };

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 8, 20, 0),
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 22),
      decoration: BoxDecoration(
        color: Paleta.superficie,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Paleta.borde),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: Paleta.acento.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(_icono, color: Paleta.acento, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  error.titulo,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Paleta.texto,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            error.mensaje,
            style: const TextStyle(
              fontSize: 13.5,
              height: 1.5,
              color: Paleta.texto,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            error.sugerencia,
            style: const TextStyle(
              fontSize: 12.5,
              height: 1.5,
              color: Paleta.textoSuave,
            ),
          ),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: Paleta.fondo.withValues(alpha: 0.55),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Paleta.borde),
            ),
            child: Text(
              error.detalle,
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 10.5,
                height: 1.4,
                color: Paleta.textoSuave,
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: alReintentar,
              icon: const Icon(Icons.refresh_rounded, size: 19),
              label: const Text('Reintentar'),
              style: FilledButton.styleFrom(
                backgroundColor: Paleta.acento,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
