
import 'package:catalogo_peliculas/estado/controlador_mi_lista.dart';
import 'package:catalogo_peliculas/modelos/calificacion.dart';
import 'package:catalogo_peliculas/modelos/favorito.dart';
import 'package:catalogo_peliculas/modelos/pelicula.dart';
import 'package:catalogo_peliculas/servicios/catalogo_en_memoria.dart';
import 'package:catalogo_peliculas/servicios/error_base_datos.dart';
import 'package:catalogo_peliculas/servicios/repositorio_catalogo.dart';
import 'package:flutter_test/flutter_test.dart';

const Pelicula batman = Pelicula(
  id: 155,
  titulo: 'Batman: El caballero de la noche',
  anio: 2008,
  genero: 'Acción',
  calificacion: 8.5,
  sinopsis: 'El Joker causa estragos en Ciudad Gótica.',
  poster: '',
);

const Pelicula origen = Pelicula(
  id: 27205,
  titulo: 'El origen',
  anio: 2010,
  genero: 'Ciencia ficción',
  calificacion: 8.4,
  sinopsis: 'Un ladrón roba secretos dentro de los sueños.',
  poster: '',
);

class RepositorioQueFalla implements RepositorioCatalogo {
  @override
  String get usuarioId => 'falla';

  @override
  bool get enLinea => true;

  @override
  Stream<List<Favorito>> favoritos() =>
      Stream<List<Favorito>>.value(const <Favorito>[]);

  @override
  Stream<List<Calificacion>> calificaciones() =>
      Stream<List<Calificacion>>.value(const <Calificacion>[]);

  @override
  Stream<List<Pelicula>> catalogo() =>
      Stream<List<Pelicula>>.value(const <Pelicula>[]);

  @override
  Future<void> altaPelicula(Pelicula pelicula) =>
      Future<void>.error(Exception('permission-denied'));

  @override
  Future<void> bajaPelicula(int peliculaId) =>
      Future<void>.error(Exception('permission-denied'));

  @override
  Future<void> agregarFavorito(Pelicula pelicula) =>
      Future<void>.error(Exception('permission-denied'));

  @override
  Future<void> quitarFavorito(int peliculaId) =>
      Future<void>.error(Exception('unavailable'));

  @override
  Future<void> calificar(Pelicula pelicula, int estrellas) =>
      Future<void>.error(Exception('unavailable'));

  @override
  Future<void> quitarCalificacion(int peliculaId) =>
      Future<void>.error(Exception('unavailable'));

  @override
  Future<void> cerrar() async {}
}

void main() {
  test('arranca vacío y sin favoritos marcados', () async {
    final ControladorMiLista controlador =
        ControladorMiLista(repositorio: CatalogoEnMemoria());

    await Future<void>.delayed(Duration.zero);

    expect(controlador.cargando, isFalse);
    expect(controlador.total, 0);
    expect(controlador.esFavorito(batman.id), isFalse);

    controlador.dispose();
  });

  test('alternarFavorito agrega, avisa y quita en la segunda llamada', () async {
    final ControladorMiLista controlador =
        ControladorMiLista(repositorio: CatalogoEnMemoria());
    int avisos = 0;
    controlador.addListener(() => avisos++);

    final bool agregado = await controlador.alternarFavorito(batman);
    await Future<void>.delayed(Duration.zero);

    expect(agregado, isTrue);
    expect(controlador.esFavorito(batman.id), isTrue);
    expect(controlador.total, 1);
    expect(controlador.favoritos.single.titulo, batman.titulo);
    expect(avisos, greaterThan(0));

    final bool agregadoOtraVez = await controlador.alternarFavorito(batman);
    await Future<void>.delayed(Duration.zero);

    expect(agregadoOtraVez, isFalse);
    expect(controlador.esFavorito(batman.id), isFalse);
    expect(controlador.total, 0);

    controlador.dispose();
  });

  test('dos películas quedan ordenadas de la más reciente a la más antigua',
      () async {
    final ControladorMiLista controlador =
        ControladorMiLista(repositorio: CatalogoEnMemoria());

    await controlador.alternarFavorito(batman);
    await Future<void>.delayed(const Duration(milliseconds: 5));
    await controlador.alternarFavorito(origen);
    await Future<void>.delayed(Duration.zero);

    expect(controlador.total, 2);
    expect(controlador.favoritos.first.titulo, origen.titulo);

    controlador.dispose();
  });

  test('calificar guarda la nota y se puede consultar por id', () async {
    final ControladorMiLista controlador =
        ControladorMiLista(repositorio: CatalogoEnMemoria());

    await controlador.calificar(origen, 4);
    await Future<void>.delayed(Duration.zero);

    final Calificacion? guardada = controlador.calificacionDe(origen.id);
    expect(guardada, isNotNull);
    expect(guardada!.estrellas, 4);

    await controlador.quitarCalificacion(origen.id);
    await Future<void>.delayed(Duration.zero);

    expect(controlador.calificacionDe(origen.id), isNull);

    controlador.dispose();
  });

  test('un fallo del servicio se reporta como ErrorBaseDatos legible',
      () async {
    final ControladorMiLista controlador =
        ControladorMiLista(repositorio: RepositorioQueFalla());
    await Future<void>.delayed(Duration.zero);

    await expectLater(
      controlador.alternarFavorito(batman),
      throwsA(isA<ErrorBaseDatos>()),
    );
    expect(controlador.esFavorito(batman.id), isFalse);
    expect(controlador.ultimoError, isNotNull);

    controlador.limpiarError();
    expect(controlador.ultimoError, isNull);

    controlador.dispose();
  });

  test('ErrorBaseDatos traduce los códigos de Firestore', () {
    expect(
      ErrorBaseDatos.desde(Exception('PERMISSION_DENIED')).mensaje,
      contains('reglas'),
    );
    expect(
      ErrorBaseDatos.desde(Exception('UNAVAILABLE: io error')).mensaje,
      contains('Sin conexión'),
    );
    expect(
      ErrorBaseDatos.desde(Exception('algo raro')).mensaje,
      contains('No se pudo'),
    );
  });
}
