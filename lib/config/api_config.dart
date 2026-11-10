class ApiConfig {
  const ApiConfig._();

  static const String claveApi = String.fromEnvironment(
    'TMDB_API_KEY',
    defaultValue: '8265bd1679663a7ea12ac168da84d2e8',
  );

  static const String host = 'api.themoviedb.org';

  static const String version = '3';

  static const String idioma = 'es-MX';

  static const String baseImagenes = 'https://image.tmdb.org/t/p/w500';

  static const Duration tiempoLimite = Duration(seconds: 12);

  static const Duration esperaBusqueda = Duration(milliseconds: 450);

  static const int porPagina = 20;

  static const String rutaPopulares = 'movie/popular';

  static const String rutaBusqueda = 'search/movie';

  static const String rutaFicha = 'movie/';

  static Uri urlPopulares({int pagina = 1}) {
    return _url(rutaPopulares, <String, String>{'page': '$pagina'});
  }

  /// Ficha ampliada: duración, géneros completos y equipo técnico en una sola
  /// petición gracias a append_to_response.
  static Uri urlFicha(int id) {
    return _url('$rutaFicha$id', <String, String>{
      'append_to_response': 'credits',
    });
  }


  static Uri urlBusqueda(String consulta, {int pagina = 1}) {
    return _url(rutaBusqueda, <String, String>{
      'query': consulta,
      'page': '$pagina',
    });
  }

  static Uri _url(String ruta, Map<String, String> parametros) {
    return Uri.https(host, '/$version/$ruta', <String, String>{
      'api_key': claveApi,
      'language': idioma,
      ...parametros,
    });
  }

  static String? urlPoster(String? ruta) {
    if (ruta == null || ruta.isEmpty) return null;
    if (ruta.startsWith('http')) return ruta;
    return '$baseImagenes$ruta';
  }

  static const String fondoLocal = 'assets/images/fondo_home.png';
}
