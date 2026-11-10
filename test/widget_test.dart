
import 'dart:async';

import 'package:catalogo_peliculas/main.dart';
import 'package:catalogo_peliculas/modelos/pelicula.dart';
import 'package:catalogo_peliculas/servicios/catalogo_en_memoria.dart';
import 'package:catalogo_peliculas/servicios/error_api.dart';
import 'package:catalogo_peliculas/servicios/iniciar_base_de_datos.dart';
import 'package:catalogo_peliculas/servicios/peliculas_api.dart';
import 'package:catalogo_peliculas/widgets/estado_carga.dart';
import 'package:catalogo_peliculas/widgets/estado_error.dart';
import 'package:catalogo_peliculas/widgets/estado_vacio.dart';
import 'package:catalogo_peliculas/widgets/tarjeta_pelicula.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const List<Pelicula> catalogoBase = <Pelicula>[
  Pelicula(
    id: 155,
    titulo: 'Batman: El caballero de la noche',
    anio: 2008,
    genero: 'Acción',
    calificacion: 8.5,
    sinopsis: 'El Joker causa estragos en Ciudad Gótica.',
    poster: '',
  ),
  Pelicula(
    id: 27205,
    titulo: 'El origen',
    anio: 2010,
    genero: 'Ciencia ficción',
    calificacion: 8.4,
    sinopsis: 'Un ladrón roba secretos dentro de los sueños.',
    poster: '',
  ),
  Pelicula(
    id: 12,
    titulo: 'Buscando a Nemo',
    anio: 2003,
    genero: 'Animación',
    calificacion: 7.8,
    sinopsis: 'Un pez payaso cruza el océano para encontrar a su hijo.',
    poster: '',
  ),
];

class ApiFalsa extends PeliculasApi {
  ApiFalsa({this.error, this.espera});

  ErrorApi? error;

  final Completer<List<Pelicula>>? espera;

  int llamadasPopulares = 0;
  int llamadasBuscar = 0;
  String? ultimaConsulta;

  @override
  Future<List<Pelicula>> populares({int pagina = 1}) {
    llamadasPopulares++;
    final Completer<List<Pelicula>>? pendiente = espera;
    if (pendiente != null) return pendiente.future;
    final ErrorApi? falla = error;
    if (falla != null) return Future<List<Pelicula>>.error(falla);
    ultimaPeticion = PeticionRegistrada(
      url: 'https://api.themoviedb.org/3/movie/popular?language=es-MX',
      status: 200,
      milisegundos: 412,
      bytes: 13868,
      resultados: catalogoBase.length,
    );
    return Future<List<Pelicula>>.value(catalogoBase);
  }

  @override
  Future<List<Pelicula>> buscar(String consulta, {int pagina = 1}) {
    llamadasBuscar++;
    ultimaConsulta = consulta.trim();
    final ErrorApi? falla = error;
    if (falla != null) return Future<List<Pelicula>>.error(falla);
    final String q = consulta.trim().toLowerCase();
    return Future<List<Pelicula>>.value(
      catalogoBase.where((Pelicula p) => p.textoBusqueda.contains(q)).toList(),
    );
  }
}

void main() {
  Future<void> abrirApp(WidgetTester tester, {PeliculasApi? api}) async {
    tester.view.physicalSize = const Size(1080, 2340);
    tester.view.devicePixelRatio = 2.625;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      CineCatalogoApp(
        api: api,
        conexion: ConexionBase(
          repositorio: CatalogoEnMemoria(),
          enLinea: false,
          mensaje: 'Base en memoria (prueba)',
        ),
      ),
    );
  }

  testWidgets('muestra el encabezado del catálogo y la marca',
      (WidgetTester tester) async {
    await abrirApp(tester, api: ApiFalsa());
    await tester.pump();

    expect(find.text('Qué ver hoy'), findsOneWidget);
    expect(find.text('CATÁLOGO'), findsOneWidget);
    expect(find.text('CineCatálogo'), findsOneWidget);
    expect(find.byIcon(CupertinoIcons.film), findsOneWidget);

    final Iterable<Image> imagenes =
        tester.widgetList<Image>(find.byType(Image));
    expect(
      imagenes.any((Image i) =>
          i.image is AssetImage &&
          (i.image as AssetImage).assetName == 'assets/images/fondo_home.png'),
      isTrue,
    );
  });

  testWidgets('muestra el esqueleto de carga mientras la petición está en curso',
      (WidgetTester tester) async {
    final Completer<List<Pelicula>> espera = Completer<List<Pelicula>>();
    final ApiFalsa api = ApiFalsa(espera: espera);

    await abrirApp(tester, api: api);
    await tester.pump();

    expect(find.byType(EstadoCarga), findsOneWidget);
    expect(find.textContaining('Consultando'), findsOneWidget);

    espera.complete(catalogoBase);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.byType(EstadoCarga), findsNothing);
    expect(find.text('Batman: El caballero de la noche'), findsWidgets);
    expect(api.llamadasPopulares, 1);
  });

  testWidgets('pinta las películas que llegan de la API',
      (WidgetTester tester) async {
    final ApiFalsa api = ApiFalsa();
    await abrirApp(tester, api: api);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('En tendencia'), findsOneWidget);
    expect(find.text('Todo el catálogo'), findsOneWidget);
    expect(find.text('El origen'), findsWidgets);
    expect(find.text('Acción · 2008'), findsWidgets);

    expect(find.textContaining('resultados'), findsOneWidget);
  });

  testWidgets('muestra el error de red y permite reintentar',
      (WidgetTester tester) async {
    final ApiFalsa api = ApiFalsa(
      error: const ErrorApi(
        tipo: TipoErrorApi.sinConexion,
        mensaje: 'No se pudo abrir la conexión con api.themoviedb.org.',
        detalle: 'SocketException · Network is unreachable',
      ),
    );

    await abrirApp(tester, api: api);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.byType(EstadoError), findsOneWidget);
    expect(find.text('Sin conexión a internet'), findsOneWidget);
    expect(find.textContaining('SocketException'), findsOneWidget);

    api.error = null;
    await tester.tap(find.text('Reintentar'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.byType(EstadoError), findsNothing);
    expect(find.text('El origen'), findsWidgets);
    expect(api.llamadasPopulares, 2);
  });

  testWidgets('el buscador consulta la API y muestra los resultados',
      (WidgetTester tester) async {
    final ApiFalsa api = ApiFalsa();
    await abrirApp(tester, api: api);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    await tester.enterText(find.byType(TextField), 'origen');
    expect(api.llamadasBuscar, 0);

    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump(const Duration(milliseconds: 300));

    expect(api.llamadasBuscar, 1);
    expect(api.ultimaConsulta, 'origen');
    expect(find.text('Resultados'), findsOneWidget);
    expect(find.text('En tendencia'), findsNothing);
  });

  testWidgets('sin coincidencias muestra el estado vacío',
      (WidgetTester tester) async {
    final ApiFalsa api = ApiFalsa();
    await abrirApp(tester, api: api);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    await tester.enterText(find.byType(TextField), 'zzzz');
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.byType(EstadoVacio), findsOneWidget);
    expect(find.text('Sin resultados'), findsOneWidget);
  });

  testWidgets('al limpiar el buscador vuelve al catálogo sin otra petición',
      (WidgetTester tester) async {
    final ApiFalsa api = ApiFalsa();
    await abrirApp(tester, api: api);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    await tester.enterText(find.byType(TextField), 'nemo');
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Buscando a Nemo'), findsOneWidget);

    await tester.tap(find.byTooltip('Limpiar búsqueda'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Todo el catálogo'), findsOneWidget);
    expect(api.llamadasPopulares, 1, reason: 'el catálogo ya estaba en caché');
  });

  testWidgets('guardar desde el detalle llena «Mi lista» (actividad 3.7)',
      (WidgetTester tester) async {
    await abrirApp(tester, api: ApiFalsa());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    await tester.tap(find.byType(TarjetaPelicula).first);
    await tester.pumpAndSettle();

    expect(find.text('Sinopsis'), findsOneWidget);
    expect(find.text('Tu calificación'), findsOneWidget);
    expect(find.text('Mi lista'), findsWidgets);

    await tester.tap(find.widgetWithText(FilledButton, 'Mi lista'));
    await tester.pumpAndSettle();

    expect(find.widgetWithText(FilledButton, 'En mi lista'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.star_outline_rounded).at(3));
    await tester.pumpAndSettle();

    expect(find.text('4 de 5'), findsOneWidget);

    await tester.tapAt(const Offset(8, 8));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Mi lista').last);
    await tester.pumpAndSettle();

    expect(find.text('Batman: El caballero de la noche'), findsOneWidget);
    expect(find.text('1 película guardada en tu cuenta'), findsOneWidget);
  });
}
