import '../config/api_config.dart';
import 'generos_tmdb.dart';

/// Ficha ampliada de una película. Se arma con la respuesta de
/// `movie/{id}?append_to_response=credits`, que en una sola petición trae la
/// duración, los géneros completos y el equipo técnico (de ahí sale la
/// dirección). La pantalla de descripción la pide al abrirse.
class FichaPelicula {
  const FichaPelicula({
    required this.id,
    required this.titulo,
    this.anio,
    this.director,
    required this.genero,
    required this.sinopsis,
    required this.poster,
    this.duracionMin,
    this.calificacion = 0,
  });

  final int id;
  final String titulo;
  final int? anio;
  final String? director;
  final String genero;
  final String sinopsis;
  final String poster;
  final int? duracionMin;
  final double calificacion;

  String get anioTexto => anio == null ? 'Sin año' : '$anio';

  String get directorTexto {
    final String? nombre = director;
    if (nombre == null || nombre.trim().isEmpty) return 'Sin dato de dirección';
    return nombre;
  }

  factory FichaPelicula.desdeTmdb(Map<String, dynamic> json) {
    final Map<String, dynamic> creditos = json['credits'] is Map
        ? Map<String, dynamic>.from(json['credits'] as Map)
        : <String, dynamic>{};

    String? director;
    final Object? equipo = creditos['crew'];
    if (equipo is List) {
      for (final dynamic persona in equipo) {
        if (persona is! Map) continue;
        if (persona['job'] == 'Director' && persona['name'] is String) {
          director = (persona['name'] as String).trim();
          break;
        }
      }
    }

    final List<String> generos = <String>[
      if (json['genres'] is List)
        for (final dynamic g in json['genres'] as List<dynamic>)
          if (g is Map && g['name'] is String) (g['name'] as String).trim(),
    ];

    final List<int> ids = <int>[
      if (json['genres'] is List)
        for (final dynamic g in json['genres'] as List<dynamic>)
          if (g is Map && g['id'] is int) g['id'] as int,
    ];

    final String? fecha = json['release_date'] is String
        ? json['release_date'] as String
        : null;

    final Object? runtime = json['runtime'];

    return FichaPelicula(
      id: json['id'] is int ? json['id'] as int : 0,
      titulo: (json['title'] as String?)?.trim() ?? 'Título sin nombre',
      anio: _anioDe(fecha),
      director: director,
      genero: generos.isEmpty ? nombreDelGenero(ids) : generos.join(', '),
      sinopsis: (json['overview'] as String?)?.trim().isNotEmpty ?? false
          ? (json['overview'] as String).trim()
          : 'TMDB todavía no tiene la sinopsis de esta película en español.',
      poster: ApiConfig.urlPoster(
            json['poster_path'] is String ? json['poster_path'] as String : null,
          ) ??
          '',
      duracionMin: runtime is int && runtime > 0 ? runtime : null,
      calificacion: json['vote_average'] is num
          ? (json['vote_average'] as num).toDouble()
          : 0,
    );
  }

  static int? _anioDe(String? fecha) {
    if (fecha == null || fecha.length < 4) return null;
    final int? anio = int.tryParse(fecha.substring(0, 4));
    if (anio == null || anio < 1900) return null;
    return anio;
  }
}
