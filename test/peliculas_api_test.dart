
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:catalogo_peliculas/config/api_config.dart';
import 'package:catalogo_peliculas/modelos/pelicula.dart';
import 'package:catalogo_peliculas/servicios/error_api.dart';
import 'package:catalogo_peliculas/servicios/peliculas_api.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

Map<String, dynamic> cuerpoPopulares() => <String, dynamic>{
      'page': 1,
      'results': <Map<String, dynamic>>[
        <String, dynamic>{
          'id': 155,
          'title': 'Batman: El caballero de la noche',
          'genre_ids': <int>[28, 80],
          'overview': 'El Joker causa estragos en Ciudad Gótica.',
          'poster_path': '/poster1.jpg',
          'release_date': '2008-07-16',
          'vote_average': 8.5,
        },
        <String, dynamic>{
          'id': 27205,
          'title': 'El origen',
          'genre_ids': <int>[878],
          'overview': 'Un ladrón roba secretos dentro de los sueños.',
          'poster_path': '/poster2.jpg',
          'release_date': '2010-07-15',
          'vote_average': 8.4,
        },
      ],
      'total_pages': 1,
    };

http.Response respuestaJson(Map<String, dynamic> cuerpo) =>
    http.Response.bytes(
      utf8.encode(jsonEncode(cuerpo)),
      200,
      headers: <String, String>{
        'content-type': 'application/json; charset=utf-8',
      },
    );

class _ClienteQueFalla extends http.BaseClient {
  _ClienteQueFalla(this.error);

  final Object error;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    throw error;
  }
}

void main() {
  test('una respuesta 200 se convierte en una lista de películas', () async {
    late Uri urlPedida;
    final PeliculasApi api = PeliculasApi(
      cliente: MockClient((http.Request r) async {
        urlPedida = r.url;
        return respuestaJson(cuerpoPopulares());
      }),
    );

    final List<Pelicula> peliculas = await api.populares();

    expect(peliculas, hasLength(2));
    expect(peliculas.first.titulo, 'Batman: El caballero de la noche');
    expect(peliculas.first.genero, 'Acción');
    expect(peliculas.last.anio, 2010);

    expect(urlPedida.host, 'api.themoviedb.org');
    expect(urlPedida.path, '/3/movie/popular');
    expect(urlPedida.queryParameters['language'], 'es-MX');
    expect(urlPedida.queryParameters['api_key'], ApiConfig.claveApi);

    expect(api.ultimaPeticion, isNotNull);
    expect(api.ultimaPeticion!.status, 200);
    expect(api.ultimaPeticion!.resultados, 2);
    expect(api.ultimaPeticion!.url, isNot(contains(ApiConfig.claveApi)));
  });

  test('los acentos llegan bien aunque el charset no esté declarado', () async {
    final PeliculasApi api = PeliculasApi(
      cliente: MockClient((http.Request r) async {
        return http.Response.bytes(
          utf8.encode(jsonEncode(cuerpoPopulares())),
          200,
          headers: <String, String>{'content-type': 'application/json'},
        );
      }),
    );

    final List<Pelicula> peliculas = await api.populares();

    expect(peliculas.first.sinopsis, contains('Gótica'));
  });

  test('la búsqueda manda el texto como parámetro query codificado', () async {
    late Uri urlPedida;
    final PeliculasApi api = PeliculasApi(
      cliente: MockClient((http.Request r) async {
        urlPedida = r.url;
        return respuestaJson(cuerpoPopulares());
      }),
    );

    await api.buscar('  el origen  ');

    expect(urlPedida.path, '/3/search/movie');
    expect(urlPedida.queryParameters['query'], 'el origen');
  });

  test('una búsqueda vacía no gasta una petición', () async {
    int llamadas = 0;
    final PeliculasApi api = PeliculasApi(
      cliente: MockClient((http.Request r) async {
        llamadas++;
        return respuestaJson(cuerpoPopulares());
      }),
    );

    final List<Pelicula> resultado = await api.buscar('   ');

    expect(resultado, isEmpty);
    expect(llamadas, 0);
  });

  test('401 se traduce a un error de credenciales', () async {
    final PeliculasApi api = PeliculasApi(
      cliente: MockClient((http.Request r) async {
        return http.Response('{"status_message":"Invalid API key"}', 401);
      }),
    );

    await expectLater(
      api.populares(),
      throwsA(
        isA<ErrorApi>()
            .having((ErrorApi e) => e.tipo, 'tipo', TipoErrorApi.credenciales)
            .having((ErrorApi e) => e.codigoStatus, 'codigoStatus', 401),
      ),
    );
  });

  test('500 se traduce a un error de servidor', () async {
    final PeliculasApi api = PeliculasApi(
      cliente: MockClient((http.Request r) async {
        return http.Response('Internal Server Error', 500);
      }),
    );

    await expectLater(
      api.populares(),
      throwsA(
        isA<ErrorApi>()
            .having((ErrorApi e) => e.tipo, 'tipo', TipoErrorApi.servidor),
      ),
    );
  });

  test('un cuerpo que no es JSON se reporta como respuesta inválida',
      () async {
    final PeliculasApi api = PeliculasApi(
      cliente: MockClient((http.Request r) async {
        return http.Response('<html>Error</html>', 200);
      }),
    );

    await expectLater(
      api.populares(),
      throwsA(
        isA<ErrorApi>().having(
          (ErrorApi e) => e.tipo,
          'tipo',
          TipoErrorApi.respuestaInvalida,
        ),
      ),
    );
  });

  test('un JSON sin el arreglo results se reporta como respuesta inválida',
      () async {
    final PeliculasApi api = PeliculasApi(
      cliente: MockClient((http.Request r) async {
        return http.Response('{"status_code":7,"success":false}', 200);
      }),
    );

    await expectLater(
      api.populares(),
      throwsA(
        isA<ErrorApi>().having(
          (ErrorApi e) => e.tipo,
          'tipo',
          TipoErrorApi.respuestaInvalida,
        ),
      ),
    );
  });

  test('un SocketException se reporta como falta de conexión', () async {
    final PeliculasApi api = PeliculasApi(
      cliente: _ClienteQueFalla(const SocketException('Network unreachable')),
    );

    await expectLater(
      api.populares(),
      throwsA(
        isA<ErrorApi>()
            .having((ErrorApi e) => e.tipo, 'tipo', TipoErrorApi.sinConexion),
      ),
    );
  });

  test('un TimeoutException se reporta como tiempo agotado', () async {
    final PeliculasApi api = PeliculasApi(
      cliente: _ClienteQueFalla(TimeoutException('sin respuesta')),
    );

    await expectLater(
      api.populares(),
      throwsA(
        isA<ErrorApi>()
            .having((ErrorApi e) => e.tipo, 'tipo', TipoErrorApi.tiempoAgotado),
      ),
    );
  });
}
