import 'dart:async';

import 'package:flutter/foundation.dart';

import '../modelos/calificacion.dart';
import '../modelos/favorito.dart';
import '../modelos/pelicula.dart';
import '../servicios/error_base_datos.dart';
import '../servicios/repositorio_catalogo.dart';

class ControladorMiLista extends ChangeNotifier {
  ControladorMiLista({required this.repositorio}) {
    _suscripcionFavoritos = repositorio.favoritos().listen(
      _alCambiarFavoritos,
      onError: _alFallarStream,
    );
    _suscripcionCalificaciones = repositorio.calificaciones().listen(
      _alCambiarCalificaciones,
      onError: _alFallarStream,
    );
  }

  final RepositorioCatalogo repositorio;

  StreamSubscription<List<Favorito>>? _suscripcionFavoritos;
  StreamSubscription<List<Calificacion>>? _suscripcionCalificaciones;

  List<Favorito> _favoritos = const <Favorito>[];
  Map<int, Favorito> _indiceFavoritos = const <int, Favorito>{};
  Map<int, Calificacion> _indiceCalificaciones = const <int, Calificacion>{};

  bool _cargando = true;
  String? _ultimoError;

  List<Favorito> get favoritos => _favoritos;

  Map<int, Calificacion> get calificaciones => _indiceCalificaciones;

  int get total => _favoritos.length;

  bool get cargando => _cargando;

  String? get ultimoError => _ultimoError;

  bool esFavorito(int peliculaId) => _indiceFavoritos.containsKey(peliculaId);

  Calificacion? calificacionDe(int peliculaId) =>
      _indiceCalificaciones[peliculaId];

  Future<bool> alternarFavorito(Pelicula pelicula) async {
    final bool yaEstaba = esFavorito(pelicula.id);
    try {
      if (yaEstaba) {
        await repositorio.quitarFavorito(pelicula.id);
      } else {
        await repositorio.agregarFavorito(pelicula);
      }
      _ultimoError = null;
      return !yaEstaba;
    } catch (error) {
      debugPrint('Error al cambiar favorito: $error');
      _ultimoError = ErrorBaseDatos.desde(
        error,
        accion: yaEstaba ? 'quitar de la lista' : 'guardar en la lista',
      ).mensaje;
      notifyListeners();
      throw ErrorBaseDatos.desde(error);
    }
  }

  Future<void> calificar(Pelicula pelicula, int estrellas) async {
    try {
      await repositorio.calificar(pelicula, estrellas);
      _ultimoError = null;
    } catch (error) {
      debugPrint('Error al calificar: $error');
      _ultimoError = ErrorBaseDatos.desde(error, accion: 'calificar').mensaje;
      notifyListeners();
      throw ErrorBaseDatos.desde(error, accion: 'calificar');
    }
  }

  Future<void> quitarCalificacion(int peliculaId) async {
    try {
      await repositorio.quitarCalificacion(peliculaId);
    } catch (error) {
      throw ErrorBaseDatos.desde(error, accion: 'borrar la calificación');
    }
  }

  void limpiarError() {
    if (_ultimoError == null) return;
    _ultimoError = null;
    notifyListeners();
  }

  void _alCambiarFavoritos(List<Favorito> lista) {
    _favoritos = lista;
    _indiceFavoritos = <int, Favorito>{
      for (final Favorito f in lista) f.peliculaId: f,
    };
    _cargando = false;
    notifyListeners();
  }

  void _alCambiarCalificaciones(List<Calificacion> lista) {
    _indiceCalificaciones = <int, Calificacion>{
      for (final Calificacion c in lista) c.peliculaId: c,
    };
    notifyListeners();
  }

  void _alFallarStream(Object error) {
    debugPrint('Error en el stream de la base: $error');
    _ultimoError = ErrorBaseDatos.desde(error, accion: 'leer').mensaje;
    _cargando = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _suscripcionFavoritos?.cancel();
    _suscripcionCalificaciones?.cancel();
    repositorio.cerrar();
    super.dispose();
  }
}
