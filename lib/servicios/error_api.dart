enum TipoErrorApi {
  sinConexion,

  tiempoAgotado,

  credenciales,

  noEncontrado,

  servidor,

  respuestaInvalida,

  desconocido,
}

class ErrorApi implements Exception {
  const ErrorApi({
    required this.tipo,
    required this.mensaje,
    required this.detalle,
    this.codigoStatus,
  });

  final TipoErrorApi tipo;

  final String mensaje;

  final String detalle;

  final int? codigoStatus;

  factory ErrorApi.deStatus(int status, {String? cuerpo}) {
    final String extra = (cuerpo == null || cuerpo.isEmpty)
        ? 'HTTP $status'
        : 'HTTP $status · ${_recortar(cuerpo)}';
    return switch (status) {
      401 || 403 => ErrorApi(
          tipo: TipoErrorApi.credenciales,
          mensaje: 'La clave de la API no es válida o fue rechazada.',
          detalle: extra,
          codigoStatus: status,
        ),
      404 => ErrorApi(
          tipo: TipoErrorApi.noEncontrado,
          mensaje: 'El recurso solicitado no existe en la API.',
          detalle: extra,
          codigoStatus: status,
        ),
      >= 500 => ErrorApi(
          tipo: TipoErrorApi.servidor,
          mensaje: 'El servidor de la API no está disponible por el momento.',
          detalle: extra,
          codigoStatus: status,
        ),
      _ => ErrorApi(
          tipo: TipoErrorApi.servidor,
          mensaje: 'La API respondió con un código inesperado.',
          detalle: extra,
          codigoStatus: status,
        ),
    };
  }

  String get titulo => switch (tipo) {
        TipoErrorApi.sinConexion => 'Sin conexión a internet',
        TipoErrorApi.tiempoAgotado => 'La API tardó demasiado',
        TipoErrorApi.credenciales => 'Acceso rechazado',
        TipoErrorApi.noEncontrado => 'Contenido no encontrado',
        TipoErrorApi.servidor => 'Falla del servidor',
        TipoErrorApi.respuestaInvalida => 'Respuesta inesperada',
        TipoErrorApi.desconocido => 'Algo salió mal',
      };

  String get icono => switch (tipo) {
        TipoErrorApi.sinConexion => 'wifi_off',
        TipoErrorApi.tiempoAgotado => 'hourglass_empty',
        TipoErrorApi.credenciales => 'key_off',
        TipoErrorApi.noEncontrado => 'search_off',
        TipoErrorApi.servidor => 'cloud_off',
        TipoErrorApi.respuestaInvalida => 'data_object',
        TipoErrorApi.desconocido => 'error_outline',
      };

  String get sugerencia => switch (tipo) {
        TipoErrorApi.sinConexion =>
          'Revisa que el dispositivo tenga datos móviles o Wi-Fi y vuelve a '
              'intentarlo.',
        TipoErrorApi.tiempoAgotado =>
          'La red está lenta. Puedes reintentar para lanzar la petición otra vez.',
        TipoErrorApi.credenciales =>
          'Verifica la clave configurada en ApiConfig.claveApi.',
        TipoErrorApi.noEncontrado =>
          'Comprueba la ruta solicitada o busca otro título.',
        TipoErrorApi.servidor =>
          'Es una falla del proveedor. Reintenta en unos minutos.',
        TipoErrorApi.respuestaInvalida =>
          'El formato del JSON cambió. Revisa el parseo en Pelicula.desdeTmdb.',
        TipoErrorApi.desconocido => 'Vuelve a intentarlo.',
      };

  static String _recortar(String texto) {
    final String limpio = texto.replaceAll(RegExp(r'\s+'), ' ').trim();
    return limpio.length <= 120 ? limpio : '${limpio.substring(0, 120)}…';
  }

  @override
  String toString() => 'ErrorApi(${tipo.name}): $mensaje — $detalle';
}
