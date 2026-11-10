
import 'package:catalogo_peliculas/modelos/favorito.dart';
import 'package:catalogo_peliculas/modelos/pelicula.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const Pelicula pelicula = Pelicula(
    id: 155,
    titulo: 'Batman: El caballero de la noche',
    anio: 2008,
    genero: 'Acción',
    calificacion: 8.5,
    sinopsis: 'El Joker causa estragos en Ciudad Gótica.',
    poster: 'https://image.tmdb.org/t/p/w500/poster.jpg',
  );

  test('desdePelicula copia los campos que se pintan en la lista', () {
    final Favorito favorito = Favorito.desdePelicula(
      pelicula,
      agregadoEn: DateTime(2026, 11, 2, 13, 5),
    );

    expect(favorito.peliculaId, 155);
    expect(favorito.titulo, 'Batman: El caballero de la noche');
    expect(favorito.anio, 2008);
    expect(favorito.genero, 'Acción');
    expect(favorito.calificacion, 8.5);
    expect(favorito.poster, contains('image.tmdb.org'));
    expect(favorito.agregadoEn, DateTime(2026, 11, 2, 13, 5));
  });

  test('aMapa no incluye agregadoEn: la fecha la pone el servidor', () {
    final Map<String, dynamic> mapa = Favorito.desdePelicula(pelicula).aMapa();

    expect(mapa['peliculaId'], 155);
    expect(mapa['titulo'], 'Batman: El caballero de la noche');
    expect(mapa.containsKey('agregadoEn'), isFalse);
  });

  test('fromMap lee un documento completo del emulador', () {
    final Favorito favorito = Favorito.fromMap(
      <String, dynamic>{
        'peliculaId': 155,
        'titulo': 'Batman: El caballero de la noche',
        'poster': 'https://image.tmdb.org/t/p/w500/poster.jpg',
        'anio': 2008,
        'genero': 'Acción',
        'calificacion': 8.5,
        'agregadoEn': '2026-11-02T19:05:00.000Z',
      },
      peliculaId: 155,
    );

    expect(favorito.titulo, 'Batman: El caballero de la noche');
    expect(favorito.agregadoEn.isUtc, isTrue);
    expect(favorito.agregadoEn.year, 2026);
  });

  test('fromMap tolera campos ausentes sin lanzar excepción', () {
    final Favorito favorito = Favorito.fromMap(
      <String, dynamic>{},
      peliculaId: 42,
    );

    expect(favorito.peliculaId, 42);
    expect(favorito.titulo, 'Título sin nombre');
    expect(favorito.genero, 'Sin género');
    expect(favorito.calificacion, 0);
    expect(favorito.anio, isNull);
    expect(favorito.poster, '');
  });

  test('fromMap acepta un Timestamp con toDate()', () {
    final _TimestampFalso marca = _TimestampFalso(DateTime(2026, 10, 30));
    final Favorito favorito = Favorito.fromMap(
      <String, dynamic>{'titulo': 'El origen', 'agregadoEn': marca},
      peliculaId: 27205,
    );

    expect(favorito.agregadoEn, DateTime(2026, 10, 30));
  });

  test('comoPelicula devuelve la forma que usan las tarjetas', () {
    final Pelicula devuelta = Favorito.desdePelicula(pelicula).comoPelicula();

    expect(devuelta.id, pelicula.id);
    expect(devuelta.titulo, pelicula.titulo);
    expect(devuelta.poster, pelicula.poster);
    expect(devuelta.posterRemoto, isTrue);
    expect(devuelta.sinopsis, isEmpty);
  });
}

class _TimestampFalso {
  _TimestampFalso(this._fecha);

  final DateTime _fecha;

  DateTime toDate() => _fecha;
}
