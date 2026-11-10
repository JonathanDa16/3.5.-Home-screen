import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../modelos/calificacion.dart';
import '../modelos/favorito.dart';
import '../modelos/pelicula.dart';
import 'repositorio_catalogo.dart';

class CatalogoFirestore implements RepositorioCatalogo {
  CatalogoFirestore({required this.usuarioId, FirebaseFirestore? base})
      : _db = base ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  @override
  final String usuarioId;

  @override
  bool get enLinea => true;

  DocumentReference<Map<String, dynamic>> get _usuario =>
      _db.collection('usuarios').doc(usuarioId);

  CollectionReference<Map<String, dynamic>> get _favoritos =>
      _usuario.collection('favoritos');

  CollectionReference<Map<String, dynamic>> get _calificaciones =>
      _usuario.collection('calificaciones');

  /// Colección raíz compartida: el catálogo que se administra desde la app.
  CollectionReference<Map<String, dynamic>> get _catalogo =>
      _db.collection('catalogo');

  @override
  Stream<List<Favorito>> favoritos() {
    return _favoritos.orderBy('agregadoEn', descending: true).snapshots().map(
          (QuerySnapshot<Map<String, dynamic>> snapshot) => <Favorito>[
            for (final QueryDocumentSnapshot<Map<String, dynamic>> doc
                in snapshot.docs)
              Favorito.fromMap(
                doc.data(),
                peliculaId: _idDeDocumento(doc),
              ),
          ],
        );
  }

  @override
  Stream<List<Calificacion>> calificaciones() {
    return _calificaciones
        .orderBy('actualizadoEn', descending: true)
        .snapshots()
        .map(
          (QuerySnapshot<Map<String, dynamic>> snapshot) => <Calificacion>[
            for (final QueryDocumentSnapshot<Map<String, dynamic>> doc
                in snapshot.docs)
              Calificacion.fromMap(
                doc.data(),
                peliculaId: _idDeDocumento(doc),
              ),
          ],
        );
  }

  Future<void> preparar({String plataforma = 'android'}) {
    return _usuario.set(<String, dynamic>{
      'plataforma': plataforma,
      'creadoEn': FieldValue.serverTimestamp(),
      'ultimaConexion': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  @override
  Future<void> agregarFavorito(Pelicula pelicula) {
    debugPrint('[Firestore] set favoritos/${pelicula.id}');
    return _favoritos.doc('${pelicula.id}').set(<String, dynamic>{
      ...Favorito.desdePelicula(pelicula).aMapa(),
      'agregadoEn': FieldValue.serverTimestamp(),
    }).then((_) => debugPrint('[Firestore] ok favoritos/${pelicula.id}'))
        .catchError((Object e) {
      debugPrint('[Firestore] error favoritos/${pelicula.id}: $e');
      throw e;
    });
  }

  @override
  Future<void> quitarFavorito(int peliculaId) {
    return _favoritos.doc('$peliculaId').delete();
  }

  @override
  Future<void> calificar(Pelicula pelicula, int estrellas) {
    final Calificacion calificacion = Calificacion.para(pelicula, estrellas);
    debugPrint('[Firestore] set calificaciones/${pelicula.id} ($estrellas★)');
    return _calificaciones.doc('${pelicula.id}').set(<String, dynamic>{
      ...calificacion.aMapa(),
      'actualizadoEn': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true)).then(
      (_) => debugPrint('[Firestore] ok calificaciones/${pelicula.id}'),
    ).catchError((Object e) {
      debugPrint('[Firestore] error calificaciones/${pelicula.id}: $e');
      throw e;
    });
  }

  @override
  Stream<List<Pelicula>> catalogo() {
    return _catalogo
        .orderBy('titulo')
        .snapshots()
        .map((QuerySnapshot<Map<String, dynamic>> snapshot) => <Pelicula>[
              for (final QueryDocumentSnapshot<Map<String, dynamic>> doc
                  in snapshot.docs)
                _peliculaDeDocumento(doc),
            ]);
  }

  @override
  Future<void> altaPelicula(Pelicula pelicula) {
    debugPrint('[Firestore] set catalogo/${pelicula.id}');
    return _catalogo.doc('${pelicula.id}').set(<String, dynamic>{
      ...pelicula.aMapaCatalogo(),
      'altaEn': FieldValue.serverTimestamp(),
      'altaPor': usuarioId,
    }).then((_) => debugPrint('[Firestore] ok catalogo/${pelicula.id}'))
        .catchError((Object e) {
      debugPrint('[Firestore] error catalogo/${pelicula.id}: $e');
      throw e;
    });
  }

  @override
  Future<void> bajaPelicula(int peliculaId) {
    debugPrint('[Firestore] delete catalogo/$peliculaId');
    return _catalogo.doc('$peliculaId').delete();
  }

  Pelicula _peliculaDeDocumento(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final Map<String, dynamic> datos = doc.data();
    final int? delNombre = int.tryParse(doc.id);
    final Object? delCampo = datos['anio'];
    return Pelicula(
      id: delNombre ?? 0,
      titulo: (datos['titulo'] as String?)?.trim() ?? 'Título sin nombre',
      anio: delCampo is num ? delCampo.toInt() : null,
      director: datos['director'] is String ? datos['director'] as String : null,
      genero: (datos['genero'] as String?)?.trim() ?? 'Sin género',
      calificacion: datos['calificacion'] is num
          ? (datos['calificacion'] as num).toDouble()
          : 0,
      duracionMin: datos['duracionMin'] is num
          ? (datos['duracionMin'] as num).toInt()
          : null,
      sinopsis: (datos['sinopsis'] as String?)?.trim() ?? '',
      poster: (datos['poster'] as String?)?.trim() ?? '',
      esDeLaBase: true,
    );
  }


  @override
  Future<void> quitarCalificacion(int peliculaId) {
    return _calificaciones.doc('$peliculaId').delete();
  }

  @override
  Future<void> cerrar() async {
  }

  int _idDeDocumento(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final int? delNombre = int.tryParse(doc.id);
    if (delNombre != null) return delNombre;
    final Object? delCampo = doc.data()['peliculaId'];
    return delCampo is num ? delCampo.toInt() : 0;
  }
}
