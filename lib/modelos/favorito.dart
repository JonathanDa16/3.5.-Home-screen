import 'pelicula.dart';

class Favorito {
  const Favorito({
    required this.peliculaId,
    required this.titulo,
    required this.poster,
    this.anio,
    required this.genero,
    required this.calificacion,
    required this.agregadoEn,
  });

  final int peliculaId;

  final String titulo;

  final String poster;

  final int? anio;

  final String genero;

  final double calificacion;

  final DateTime agregadoEn;

  factory Favorito.desdePelicula(Pelicula pelicula, {DateTime? agregadoEn}) {
    return Favorito(
      peliculaId: pelicula.id,
      titulo: pelicula.titulo,
      poster: pelicula.poster,
      anio: pelicula.anio,
      genero: pelicula.genero,
      calificacion: pelicula.calificacion,
      agregadoEn: agregadoEn ?? DateTime.now(),
    );
  }

  factory Favorito.fromMap(Map<String, dynamic> datos, {required int peliculaId}) {
    final String? titulo = (datos['titulo'] as String?)?.trim();
    return Favorito(
      peliculaId: peliculaId,
      titulo: (titulo == null || titulo.isEmpty) ? 'Título sin nombre' : titulo,
      poster: (datos['poster'] as String?) ?? '',
      anio: datos['anio'] is int ? datos['anio'] as int : null,
      genero: (datos['genero'] as String?) ?? 'Sin género',
      calificacion: datos['calificacion'] is num
          ? (datos['calificacion'] as num).toDouble()
          : 0,
      agregadoEn: _fecha(datos['agregadoEn']) ?? DateTime.now(),
    );
  }

  Map<String, dynamic> aMapa() => <String, dynamic>{
        'peliculaId': peliculaId,
        'titulo': titulo,
        'poster': poster,
        'anio': anio,
        'genero': genero,
        'calificacion': calificacion,
      };

  Pelicula comoPelicula() => Pelicula(
        id: peliculaId,
        titulo: titulo,
        anio: anio,
        genero: genero,
        calificacion: calificacion,
        sinopsis: '',
        poster: poster,
      );

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
  String toString() => 'Favorito($peliculaId, $titulo)';
}
