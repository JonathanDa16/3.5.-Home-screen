import 'dart:async';

import '../modelos/calificacion.dart';
import '../modelos/favorito.dart';
import '../modelos/pelicula.dart';
import 'repositorio_catalogo.dart';

class CatalogoEnMemoria implements RepositorioCatalogo {
  CatalogoEnMemoria({
    this.usuarioId = 'memoria-local',
    List<Favorito> iniciales = const <Favorito>[],
    List<Calificacion> calificacionesIniciales = const <Calificacion>[],
  })  : _favoritos = <int, Favorito>{
          for (final Favorito f in iniciales) f.peliculaId: f,
        },
        _calificaciones = <int, Calificacion>{
          for (final Calificacion c in calificacionesIniciales) c.peliculaId: c,
        } {
    _avisarFavoritos();
    _avisarCalificaciones();
  }

  @override
  final String usuarioId;

  @override
  bool get enLinea => false;

  final Map<int, Favorito> _favoritos;
  final Map<int, Calificacion> _calificaciones;
  final Map<int, Pelicula> _catalogoPeliculas = <int, Pelicula>{};

  final StreamController<List<Favorito>> _controlFavoritos =
      StreamController<List<Favorito>>.broadcast();
  final StreamController<List<Calificacion>> _controlCalificaciones =
      StreamController<List<Calificacion>>.broadcast();
  final StreamController<List<Pelicula>> _controlCatalogo =
      StreamController<List<Pelicula>>.broadcast();

  @override
  Stream<List<Favorito>> favoritos() async* {
    yield _listaFavoritos();
    yield* _controlFavoritos.stream;
  }

  @override
  Stream<List<Calificacion>> calificaciones() async* {
    yield _listaCalificaciones();
    yield* _controlCalificaciones.stream;
  }

  @override
  Future<void> agregarFavorito(Pelicula pelicula) async {
    _favoritos[pelicula.id] = Favorito.desdePelicula(pelicula);
    _avisarFavoritos();
  }

  @override
  Future<void> quitarFavorito(int peliculaId) async {
    _favoritos.remove(peliculaId);
    _avisarFavoritos();
  }

  @override
  Future<void> calificar(Pelicula pelicula, int estrellas) async {
    _calificaciones[pelicula.id] = Calificacion.para(pelicula, estrellas);
    _avisarCalificaciones();
  }

  @override
  Future<void> quitarCalificacion(int peliculaId) async {
    _calificaciones.remove(peliculaId);
    _avisarCalificaciones();
  }

  @override
  Future<void> cerrar() async {
    await _controlFavoritos.close();
    await _controlCalificaciones.close();
    await _controlCatalogo.close();
  }

  @override
  Stream<List<Pelicula>> catalogo() async* {
    yield _listaCatalogo();
    yield* _controlCatalogo.stream;
  }

  @override
  Future<void> altaPelicula(Pelicula pelicula) async {
    _catalogoPeliculas[pelicula.id] = Pelicula(
      id: pelicula.id,
      titulo: pelicula.titulo,
      anio: pelicula.anio,
      director: pelicula.director,
      genero: pelicula.genero,
      calificacion: pelicula.calificacion,
      duracionMin: pelicula.duracionMin,
      sinopsis: pelicula.sinopsis,
      poster: pelicula.poster,
      esDeLaBase: true,
    );
    _avisarCatalogo();
  }

  @override
  Future<void> bajaPelicula(int peliculaId) async {
    _catalogoPeliculas.remove(peliculaId);
    _avisarCatalogo();
  }

  List<Pelicula> _listaCatalogo() {
    final List<Pelicula> lista = _catalogoPeliculas.values.toList()
      ..sort((Pelicula a, Pelicula b) => a.titulo.compareTo(b.titulo));
    return lista;
  }

  void _avisarCatalogo() {
    if (!_controlCatalogo.isClosed) _controlCatalogo.add(_listaCatalogo());
  }

  List<Favorito> _listaFavoritos() {
    final List<Favorito> lista = _favoritos.values.toList()
      ..sort((Favorito a, Favorito b) => b.agregadoEn.compareTo(a.agregadoEn));
    return lista;
  }

  List<Calificacion> _listaCalificaciones() {
    final List<Calificacion> lista = _calificaciones.values.toList()
      ..sort(
        (Calificacion a, Calificacion b) =>
            b.actualizadoEn.compareTo(a.actualizadoEn),
      );
    return lista;
  }

  void _avisarFavoritos() {
    if (!_controlFavoritos.isClosed) _controlFavoritos.add(_listaFavoritos());
  }

  void _avisarCalificaciones() {
    if (!_controlCalificaciones.isClosed) {
      _controlCalificaciones.add(_listaCalificaciones());
    }
  }
}
