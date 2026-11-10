import 'pelicula.dart';

class Calificacion {
  const Calificacion({
    required this.peliculaId,
    required this.titulo,
    required this.estrellas,
    this.comentario,
    required this.actualizadoEn,
  });

  final int peliculaId;

  final String titulo;

  final int estrellas;

  final String? comentario;

  final DateTime actualizadoEn;

  static const int minimo = 1;
  static const int maximo = 5;

  factory Calificacion.para(
    Pelicula pelicula,
    int estrellas, {
    String? comentario,
    DateTime? actualizadoEn,
  }) {
    return Calificacion(
      peliculaId: pelicula.id,
      titulo: pelicula.titulo,
      estrellas: estrellas.clamp(minimo, maximo),
      comentario: _limpiar(comentario),
      actualizadoEn: actualizadoEn ?? DateTime.now(),
    );
  }

  factory Calificacion.fromMap(
    Map<String, dynamic> datos, {
    required int peliculaId,
  }) {
    final String? titulo = (datos['titulo'] as String?)?.trim();
    final Object? valor = datos['estrellas'];
    return Calificacion(
      peliculaId: peliculaId,
      titulo: (titulo == null || titulo.isEmpty) ? 'Título sin nombre' : titulo,
      estrellas: (valor is num ? valor.round() : 0).clamp(minimo, maximo),
      comentario: _limpiar(datos['comentario'] as String?),
      actualizadoEn: _fecha(datos['actualizadoEn']) ?? DateTime.now(),
    );
  }

  Map<String, dynamic> aMapa() => <String, dynamic>{
        'peliculaId': peliculaId,
        'titulo': titulo,
        'estrellas': estrellas,
        if (comentario != null) 'comentario': comentario,
      };

  Calificacion conEstrellas(int valor) => Calificacion(
        peliculaId: peliculaId,
        titulo: titulo,
        estrellas: valor.clamp(minimo, maximo),
        comentario: comentario,
        actualizadoEn: actualizadoEn,
      );

  String get resumen => '$estrellas de $maximo estrellas';

  static String? _limpiar(String? texto) {
    final String limpio = (texto ?? '').trim();
    return limpio.isEmpty ? null : limpio;
  }

  static DateTime? _fecha(Object? valor) {
    if (valor == null) return null;
    if (valor is DateTime) return valor;
    if (valor is String) return DateTime.tryParse(valor);
    try {
      final dynamic marca = valor;
      return (marca.toDate() as DateTime);
    } catch (_) {
      return null;
    }
  }

  @override
  String toString() => 'Calificacion($peliculaId, $estrellas★)';
}
