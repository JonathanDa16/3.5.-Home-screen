import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../modelos/ficha_pelicula.dart';
import '../modelos/pelicula.dart';
import 'error_api.dart';

class PeticionRegistrada {
  const PeticionRegistrada({
    required this.url,
    required this.status,
    required this.milisegundos,
    required this.bytes,
    required this.resultados,
  });

  final String url;
  final int status;
  final int milisegundos;
  final int bytes;
  final int resultados;
}

class PeliculasApi {
  PeliculasApi({http.Client? cliente})
      : _cliente = cliente ?? http.Client(),
        _clientePropio = cliente == null;

  final http.Client _cliente;
  final bool _clientePropio;

  PeticionRegistrada? ultimaPeticion;

  Future<List<Pelicula>> populares({int pagina = 1}) {
    return _listar(ApiConfig.urlPopulares(pagina: pagina));
  }

  Future<List<Pelicula>> buscar(String consulta, {int pagina = 1}) {
    final String limpia = consulta.trim();
    if (limpia.isEmpty) return Future<List<Pelicula>>.value(<Pelicula>[]);
    return _listar(ApiConfig.urlBusqueda(limpia, pagina: pagina));
  }

  /// Pide la ficha ampliada de una película: duración, géneros completos y
  /// equipo técnico. De credits.crew sale el nombre de quien dirige.
  Future<FichaPelicula> ficha(int id) async {
    final Uri uri = ApiConfig.urlFicha(id);
    final Stopwatch reloj = Stopwatch()..start();
    final String urlVisible = _urlVisible(uri);

    final http.Response respuesta;
    try {
      respuesta = await _cliente.get(
        uri,
        headers: const <String, String>{'Accept': 'application/json'},
      ).timeout(ApiConfig.tiempoLimite);
    } on TimeoutException {
      reloj.stop();
      throw ErrorApi(
        tipo: TipoErrorApi.tiempoAgotado,
        mensaje: 'La ficha de la película no llegó en '
            '${ApiConfig.tiempoLimite.inSeconds} segundos.',
        detalle: 'TimeoutException · GET $urlVisible',
      );
    } on SocketException catch (e) {
      reloj.stop();
      throw ErrorApi(
        tipo: TipoErrorApi.sinConexion,
        mensaje: 'No se pudo abrir la conexión con api.themoviedb.org.',
        detalle: 'SocketException · ${e.osError?.message ?? e.message}',
      );
    } on http.ClientException catch (e) {
      reloj.stop();
      throw ErrorApi(
        tipo: TipoErrorApi.sinConexion,
        mensaje: 'La conexión con la API se interrumpió.',
        detalle: 'ClientException · ${e.message}',
      );
    }

    reloj.stop();

    if (respuesta.statusCode != 200) {
      throw ErrorApi.deStatus(respuesta.statusCode, cuerpo: respuesta.body);
    }

    final dynamic cuerpo;
    try {
      cuerpo = jsonDecode(utf8.decode(respuesta.bodyBytes));
    } on FormatException catch (e) {
      throw ErrorApi(
        tipo: TipoErrorApi.respuestaInvalida,
        mensaje: 'La ficha de la película no es un JSON válido.',
        detalle: 'FormatException · ${e.message} · GET $urlVisible',
      );
    }

    if (cuerpo is! Map<String, dynamic>) {
      throw ErrorApi(
        tipo: TipoErrorApi.respuestaInvalida,
        mensaje: 'La API respondió con una estructura distinta a la esperada.',
        detalle: 'Se esperaba un objeto · GET $urlVisible',
      );
    }

    ultimaPeticion = PeticionRegistrada(
      url: urlVisible,
      status: respuesta.statusCode,
      milisegundos: reloj.elapsedMilliseconds,
      bytes: respuesta.bodyBytes.length,
      resultados: 1,
    );
    _bitacora('GET $urlVisible → 200 en ${reloj.elapsedMilliseconds} ms · '
        '${respuesta.bodyBytes.length} bytes · ficha');
    return FichaPelicula.desdeTmdb(cuerpo);
  }


  Future<List<Pelicula>> _listar(Uri uri) async {
    final Stopwatch reloj = Stopwatch()..start();
    final http.Response respuesta;

    ultimaPeticion = null;

    try {
      respuesta = await _cliente.get(
        uri,
        headers: const <String, String>{'Accept': 'application/json'},
      ).timeout(ApiConfig.tiempoLimite);
    } on TimeoutException {
      reloj.stop();
      _bitacora('GET ${_urlVisible(uri)} → tiempo agotado '
          '(${ApiConfig.tiempoLimite.inSeconds} s)');
      throw ErrorApi(
        tipo: TipoErrorApi.tiempoAgotado,
        mensaje: 'La API no respondió en ${ApiConfig.tiempoLimite.inSeconds} '
            'segundos.',
        detalle: 'TimeoutException · GET ${_urlVisible(uri)}',
      );
    } on SocketException catch (e) {
      reloj.stop();
      _bitacora('GET ${_urlVisible(uri)} → sin conexión (${e.osError?.message})');
      throw ErrorApi(
        tipo: TipoErrorApi.sinConexion,
        mensaje: 'No se pudo abrir la conexión con api.themoviedb.org.',
        detalle: 'SocketException · ${e.osError?.message ?? e.message}',
      );
    } on http.ClientException catch (e) {
      reloj.stop();
      _bitacora('GET ${_urlVisible(uri)} → ClientException (${e.message})');
      throw ErrorApi(
        tipo: TipoErrorApi.sinConexion,
        mensaje: 'La conexión con la API se interrumpió.',
        detalle: 'ClientException · ${e.message}',
      );
    }

    reloj.stop();
    final String urlVisible = _urlVisible(uri);

    if (respuesta.statusCode != 200) {
      _bitacora('GET $urlVisible → ${respuesta.statusCode} '
          '(${reloj.elapsedMilliseconds} ms)');
      throw ErrorApi.deStatus(respuesta.statusCode, cuerpo: respuesta.body);
    }

    final List<Pelicula> peliculas = _modelosDe(respuesta, urlVisible);

    ultimaPeticion = PeticionRegistrada(
      url: urlVisible,
      status: respuesta.statusCode,
      milisegundos: reloj.elapsedMilliseconds,
      bytes: respuesta.bodyBytes.length,
      resultados: peliculas.length,
    );
    _bitacora('GET $urlVisible → 200 en ${reloj.elapsedMilliseconds} ms · '
        '${respuesta.bodyBytes.length} bytes · ${peliculas.length} películas');
    return peliculas;
  }

  List<Pelicula> _modelosDe(http.Response respuesta, String urlVisible) {
    final dynamic cuerpo;
    try {
      cuerpo = jsonDecode(utf8.decode(respuesta.bodyBytes));
    } on FormatException catch (e) {
      throw ErrorApi(
        tipo: TipoErrorApi.respuestaInvalida,
        mensaje: 'La respuesta de la API no es un JSON válido.',
        detalle: 'FormatException · ${e.message} · GET $urlVisible',
      );
    }

    if (cuerpo is! Map<String, dynamic> || cuerpo['results'] is! List) {
      throw ErrorApi(
        tipo: TipoErrorApi.respuestaInvalida,
        mensaje: 'La API respondió con una estructura distinta a la esperada.',
        detalle: 'Falta el arreglo "results" · GET $urlVisible',
      );
    }

    final List<dynamic> resultados = cuerpo['results'] as List<dynamic>;
    return <Pelicula>[
      for (final dynamic item in resultados)
        if (item is Map<String, dynamic>) Pelicula.desdeTmdb(item),
    ];
  }

  String _urlVisible(Uri uri) {
    final Map<String, String> parametros = Map<String, String>.from(
      uri.queryParameters,
    )..['api_key'] = '••••';
    return uri.replace(queryParameters: parametros).toString();
  }

  void _bitacora(String mensaje) {
    if (kDebugMode) debugPrint('[API] $mensaje');
  }

  void cerrar() {
    if (_clientePropio) _cliente.close();
  }
}
