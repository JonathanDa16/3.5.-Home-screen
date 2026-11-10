const Map<int, String> generosTmdb = <int, String>{
  28: 'Acción',
  12: 'Aventura',
  16: 'Animación',
  35: 'Comedia',
  80: 'Crimen',
  99: 'Documental',
  18: 'Drama',
  10751: 'Familia',
  14: 'Fantasía',
  36: 'Historia',
  27: 'Terror',
  10402: 'Música',
  9648: 'Misterio',
  10749: 'Romance',
  878: 'Ciencia ficción',
  10770: 'Película de TV',
  53: 'Suspenso',
  10752: 'Bélica',
  37: 'Western',
};

String nombreDelGenero(List<int> ids, {String porDefecto = 'Sin género'}) {
  for (final int id in ids) {
    final String? nombre = generosTmdb[id];
    if (nombre != null) return nombre;
  }
  return porDefecto;
}
