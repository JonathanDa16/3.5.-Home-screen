
import 'package:catalogo_peliculas/modelos/calificacion.dart';
import 'package:catalogo_peliculas/modelos/pelicula.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const Pelicula pelicula = Pelicula(
    id: 27205,
    titulo: 'El origen',
    anio: 2010,
    genero: 'Ciencia ficción',
    calificacion: 8.4,
    sinopsis: 'Un ladrón roba secretos dentro de los sueños.',
    poster: '',
  );

  test('para() arma la calificación con el id de la película', () {
    final Calificacion calificacion = Calificacion.para(
      pelicula,
      4,
      actualizadoEn: DateTime(2026, 11, 2, 13, 20),
    );

    expect(calificacion.peliculaId, 27205);
    expect(calificacion.titulo, 'El origen');
    expect(calificacion.estrellas, 4);
    expect(calificacion.comentario, isNull);
    expect(calificacion.resumen, '4 de 5 estrellas');
  });

  test('para() acota los valores fuera de rango', () {
    expect(Calificacion.para(pelicula, 0).estrellas, Calificacion.minimo);
    expect(Calificacion.para(pelicula, 9).estrellas, Calificacion.maximo);
  });

  test('aMapa omite el comentario cuando viene vacío', () {
    final Calificacion sinNota = Calificacion.para(pelicula, 3);
    final Calificacion conNota = Calificacion.para(
      pelicula,
      3,
      comentario: '  Vale la pena  ',
    );

    expect(sinNota.aMapa().containsKey('comentario'), isFalse);
    expect(conNota.aMapa()['comentario'], 'Vale la pena');
  });

  test('aMapa no escribe la fecha: la pone el servidor', () {
    expect(
      Calificacion.para(pelicula, 5).aMapa().containsKey('actualizadoEn'),
      isFalse,
    );
  });

  test('fromMap lee un documento del emulador y acota los datos raros', () {
    final Calificacion normal = Calificacion.fromMap(
      <String, dynamic>{
        'peliculaId': 27205,
        'titulo': 'El origen',
        'estrellas': 4,
        'actualizadoEn': '2026-11-02T19:20:00.000Z',
      },
      peliculaId: 27205,
    );

    final Calificacion exagerada = Calificacion.fromMap(
      <String, dynamic>{'titulo': 'El origen', 'estrellas': 12},
      peliculaId: 27205,
    );

    expect(normal.estrellas, 4);
    expect(normal.actualizadoEn.year, 2026);
    expect(exagerada.estrellas, 5);
  });

  test('conEstrellas conserva el resto de los campos', () {
    final Calificacion original = Calificacion.para(
      pelicula,
      2,
      comentario: 'Regular',
    );
    final Calificacion cambiada = original.conEstrellas(5);

    expect(cambiada.estrellas, 5);
    expect(cambiada.comentario, 'Regular');
    expect(cambiada.titulo, original.titulo);
    expect(cambiada.peliculaId, original.peliculaId);
  });
}
