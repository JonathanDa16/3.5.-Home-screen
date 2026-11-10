class ErrorBaseDatos implements Exception {
  const ErrorBaseDatos(this.mensaje, {this.causa});

  final String mensaje;

  final Object? causa;

  factory ErrorBaseDatos.desde(Object error, {String accion = 'guardar'}) {
    final String texto = error
        .toString()
        .toLowerCase()
        .replaceAll('_', '-')
        .replaceAll('[', ' ')
        .replaceAll(']', ' ');
    final String mensaje;

    if (texto.contains('permission-denied') ||
        texto.contains('permission denied')) {
      mensaje = 'Las reglas de Firestore rechazaron la operación.';
    } else if (texto.contains('unavailable') ||
        texto.contains('network') ||
        texto.contains('socket')) {
      mensaje = 'Sin conexión con la base de datos; intenta de nuevo.';
    } else if (texto.contains('deadline') || texto.contains('timeout')) {
      mensaje = 'La base de datos tardó demasiado en responder.';
    } else if (texto.contains('not-found')) {
      mensaje = 'El documento ya no existe en la base de datos.';
    } else {
      mensaje = 'No se pudo $accion en la base de datos.';
    }

    return ErrorBaseDatos(mensaje, causa: error);
  }

  @override
  String toString() => mensaje;
}
