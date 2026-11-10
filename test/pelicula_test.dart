
import 'package:catalogo_peliculas/modelos/pelicula.dart';
import 'package:flutter_test/flutter_test.dart';

const Map<String, dynamic> elementoPopulares = <String, dynamic>{
  'adult': false,
  'backdrop_path': '/9FE5eD92WfVCiivM9Pq9GVSrlWk.jpg',
  'genre_ids': <int>[28, 53, 80],
  'id': 155,
  'title': 'Batman: El caballero de la noche',
  'original_title': 'The Dark Knight',
  'overview': 'Cuando la amenaza conocida como el Joker causa estragos.',
  'popularity': 3247.0038,
  'poster_path': '/vLFCrzI3V4kbze877tP1H7TqppL.jpg',
  'release_date': '2008-07-16',
  'vote_average': 8.5,
};

void main() {
  group('Pelicula.desdeTmdb', () {
    test('mapea las llaves de TMDB a los campos del modelo', () {
      final Pelicula p = Pelicula.desdeTmdb(elementoPopulares);

      expect(p.id, 155);
      expect(p.titulo, 'Batman: El caballero de la noche');
      expect(p.anio, 2008);
      expect(p.genero, 'Acción');
      expect(p.calificacion, 8.5);
      expect(
        p.poster,
        'https://image.tmdb.org/t/p/w500/vLFCrzI3V4kbze877tP1H7TqppL.jpg',
      );
      expect(p.posterRemoto, isTrue);
      expect(p.destacada, isFalse);
      expect(p.duracionMin, isNull);
      expect(p.duracionTexto, isNull);
    });

    test('tolera un póster ausente y un estreno sin fecha', () {
      final Pelicula p = Pelicula.desdeTmdb(<String, dynamic>{
        'id': 7,
        'title': 'Sin estrenar',
        'poster_path': null,
        'release_date': '',
        'vote_average': 0,
        'genre_ids': <int>[],
      });

      expect(p.poster, isEmpty);
      expect(p.posterRemoto, isFalse);
      expect(p.anio, isNull);
      expect(p.anioTexto, 'Próximamente');
      expect(p.genero, 'Sin género');
      expect(p.sinopsis, contains('sinopsis'));
    });

    test('usa el título original cuando no hay título traducido', () {
      final Pelicula p = Pelicula.desdeTmdb(<String, dynamic>{
        'id': 9,
        'title': '   ',
        'original_title': 'Original Title',
      });

      expect(p.titulo, 'Original Title');
    });

    test('acota la calificación al rango de 0 a 10', () {
      final Pelicula alta =
          Pelicula.desdeTmdb(<String, dynamic>{'id': 1, 'vote_average': 42.3});
      final Pelicula nula =
          Pelicula.desdeTmdb(<String, dynamic>{'id': 2, 'vote_average': null});

      expect(alta.calificacion, 10);
      expect(nula.calificacion, 0);
    });

    test('el género cae al primero conocido de la lista', () {
      final Pelicula p = Pelicula.desdeTmdb(<String, dynamic>{
        'id': 3,
        'genre_ids': <int>[10759, 878],
      });

      expect(p.genero, 'Ciencia ficción');
    });
  });

  group('formato interno (para la 3.7)', () {
    test('fromJson reconstruye lo que guarda toJson', () {
      final Pelicula original = Pelicula.desdeTmdb(elementoPopulares);
      final Pelicula copia = Pelicula.fromJson(original.toJson());

      expect(copia.id, original.id);
      expect(copia.titulo, original.titulo);
      expect(copia.anio, original.anio);
      expect(copia.genero, original.genero);
      expect(copia.calificacion, original.calificacion);
      expect(copia.poster, original.poster);
    });
  });

  test('duracionTexto se arma solo cuando hay minutos', () {
    const Pelicula p = Pelicula(
      id: 1,
      titulo: 'Prueba',
      genero: 'Drama',
      calificacion: 5,
      sinopsis: 'x',
      poster: '',
      duracionMin: 118,
    );

    expect(p.duracionTexto, '1 h 58 min');
    expect(p.comoDestacada(true).destacada, isTrue);
  });
}
