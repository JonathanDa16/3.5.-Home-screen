import 'dart:async';

import 'package:flutter/material.dart';

import '../config/api_config.dart';
import '../estado/controlador_mi_lista.dart';
import '../modelos/pelicula.dart';
import '../servicios/error_api.dart';
import '../servicios/peliculas_api.dart';
import '../tema/app_theme.dart';
import '../widgets/aviso_fuente.dart';
import '../widgets/barra_superior.dart';
import '../widgets/bloque_bienvenida.dart';
import '../widgets/buscador.dart';
import '../widgets/estado_carga.dart';
import '../widgets/estado_error.dart';
import '../widgets/estado_vacio.dart';
import '../widgets/hoja_detalle.dart';
import '../widgets/tarjeta_pelicula.dart';
import '../widgets/titulo_seccion.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, this.api, this.controlador, this.acciones});

  final PeliculasApi? api;

  final ControladorMiLista? controlador;

  /// Menú de la parte superior (el que elige el catálogo).
  final Widget? acciones;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const double margen = 20;

  late final PeliculasApi _api = widget.api ?? PeliculasApi();
  final TextEditingController _controlador = TextEditingController();

  Timer? _espera;

  int _turno = 0;

  List<Pelicula> _populares = const <Pelicula>[];

  List<Pelicula> _peliculas = const <Pelicula>[];

  bool _cargando = true;
  ErrorApi? _error;
  String _consulta = '';

  @override
  void initState() {
    super.initState();
    _cargarPopulares();
  }

  @override
  void dispose() {
    _espera?.cancel();
    _controlador.dispose();
    if (widget.api == null) _api.cerrar();
    super.dispose();
  }

  Future<void> _cargarPopulares({bool conservarDatos = false}) async {
    final int turno = ++_turno;
    setState(() {
      _cargando = true;
      _error = null;
    });

    try {
      final List<Pelicula> lista = await _api.populares();
      if (!mounted || turno != _turno) return;
      final List<Pelicula> marcadas = _marcarDestacadas(lista);
      setState(() {
        _populares = marcadas;
        _peliculas = marcadas;
        _cargando = false;
        _error = null;
      });
    } on ErrorApi catch (e) {
      if (!mounted || turno != _turno) return;
      setState(() {
        _error = e;
        _cargando = false;
        if (!conservarDatos) _peliculas = const <Pelicula>[];
      });
    }
  }

  Future<void> _buscar(String consulta) async {
    final int turno = ++_turno;
    setState(() {
      _cargando = true;
      _error = null;
    });

    try {
      final List<Pelicula> lista = await _api.buscar(consulta);
      if (!mounted || turno != _turno) return;
      setState(() {
        _peliculas = _marcarDestacadas(lista);
        _cargando = false;
        _error = null;
      });
    } on ErrorApi catch (e) {
      if (!mounted || turno != _turno) return;
      setState(() {
        _error = e;
        _cargando = false;
        _peliculas = const <Pelicula>[];
      });
    }
  }

  Future<void> _refrescar() async {
    final String limpia = _consulta.trim();
    if (limpia.isEmpty) {
      await _cargarPopulares(conservarDatos: true);
    } else {
      await _buscar(limpia);
    }
  }

  List<Pelicula> _marcarDestacadas(List<Pelicula> lista) {
    return <Pelicula>[
      for (int i = 0; i < lista.length; i++)
        i < 5 ? lista[i].comoDestacada(true) : lista[i],
    ];
  }

  bool get _buscando => _consulta.trim().isNotEmpty;

  List<Pelicula> get _destacadas =>
      _peliculas.where((Pelicula p) => p.destacada).toList();

  void _alEscribir(String valor) {
    _espera?.cancel();
    setState(() => _consulta = valor);

    final String limpia = valor.trim();
    if (limpia.isEmpty) {
      ++_turno;
      setState(() {
        _peliculas = _populares;
        _cargando = false;
        _error = null;
      });
      return;
    }

    _espera = Timer(ApiConfig.esperaBusqueda, () => _buscar(limpia));
  }

  void _limpiarBusqueda() {
    _espera?.cancel();
    _controlador.clear();
    ++_turno;
    setState(() {
      _consulta = '';
      _peliculas = _populares;
      _cargando = false;
      _error = null;
    });
  }

  void _reintentar() {
    final String limpia = _consulta.trim();
    if (limpia.isEmpty) {
      _cargarPopulares();
    } else {
      _buscar(limpia);
    }
  }

  void _avisar(String mensaje) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(mensaje)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Paleta.fondo,
      body: Stack(
        children: <Widget>[
          Positioned.fill(
            child: Image.asset(
              ApiConfig.fondoLocal,
              fit: BoxFit.cover,
              semanticLabel: 'Imagen de fondo: sala de cine a oscuras',
            ),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: <Color>[
                    Paleta.fondo.withValues(alpha: 0.82),
                    Paleta.fondo.withValues(alpha: 0.62),
                    Paleta.fondo.withValues(alpha: 0.97),
                    Paleta.fondo,
                  ],
                  stops: const <double>[0.0, 0.16, 0.48, 1.0],
                ),
              ),
            ),
          ),
          SafeArea(
            bottom: false,
            child: RefreshIndicator(
              onRefresh: _refrescar,
              color: Paleta.acento,
              backgroundColor: Paleta.superficieAlta,
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics(),
                ),
                slivers: <Widget>[
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(margen, 14, margen, 0),
                    sliver: SliverToBoxAdapter(
                      child: BarraSuperior(acciones: widget.acciones),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(margen, 22, margen, 0),
                    sliver: SliverToBoxAdapter(
                      child: BloqueBienvenida(total: _peliculas.isEmpty ? null : _peliculas.length),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(margen, 20, margen, 0),
                    sliver: SliverToBoxAdapter(
                      child: Buscador(
                        controlador: _controlador,
                        alCambiar: _alEscribir,
                        alLimpiar: _limpiarBusqueda,
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(margen, 10, margen, 0),
                    sliver: SliverToBoxAdapter(
                      child: AvisoFuente(peticion: _api.ultimaPeticion),
                    ),
                  ),
                  if (_cargando && _peliculas.isNotEmpty)
                    const SliverToBoxAdapter(child: _BarraProgreso()),
                  ..._contenido(),
                  const SliverToBoxAdapter(child: SizedBox(height: 28)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _contenido() {
    if (_error != null) {
      return <Widget>[
        SliverToBoxAdapter(
          child: EstadoError(error: _error!, alReintentar: _reintentar),
        ),
      ];
    }

    if (_cargando && _peliculas.isEmpty) {
      return <Widget>[
        SliverToBoxAdapter(
          child: EstadoCarga(
            mensaje: _buscando
                ? 'Buscando «${_consulta.trim()}»…'
                : 'Consultando ${ApiConfig.host}…',
          ),
        ),
      ];
    }

    final List<Pelicula> visibles = _peliculas;

    if (visibles.isEmpty) {
      return <Widget>[
        SliverToBoxAdapter(
          child: EstadoVacio(
            consulta: _consulta.trim(),
            alLimpiar: _limpiarBusqueda,
          ),
        ),
      ];
    }

    return <Widget>[
      if (!_buscando) ...<Widget>[
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(margen, 22, margen, 0),
          sliver: SliverToBoxAdapter(
            child: TituloSeccion(
              titulo: 'En tendencia',
              accion: 'Ver todo',
              alTocarAccion: () => _avisar(
                'El catálogo completo está en la cuadrícula de abajo.',
              ),
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 14)),
        SliverToBoxAdapter(
          child: SizedBox(
            height: 268,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: margen),
              itemCount: _destacadas.length,
              separatorBuilder: (_, _) => const SizedBox(width: 14),
              itemBuilder: (BuildContext context, int i) {
                final Pelicula p = _destacadas[i];
                return TarjetaPelicula(
                  pelicula: p,
                  anchoFijo: 152,
                  alTocar: () => mostrarDetallePelicula(
                    context,
                    p,
                    controlador: widget.controlador,
                  ),
                );
              },
            ),
          ),
        ),
      ],
      SliverPadding(
        padding: EdgeInsets.fromLTRB(margen, _buscando ? 26 : 30, margen, 14),
        sliver: SliverToBoxAdapter(
          child: TituloSeccion(
            titulo: _buscando ? 'Resultados' : 'Todo el catálogo',
          ),
        ),
      ),
      SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: margen),
        sliver: SliverGrid(
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 210,
            mainAxisSpacing: 20,
            crossAxisSpacing: 16,
            mainAxisExtent: 310,
          ),
          delegate: SliverChildBuilderDelegate(
            (BuildContext context, int i) {
              final Pelicula p = visibles[i];
              return TarjetaPelicula(
                pelicula: p,
                alTocar: () => mostrarDetallePelicula(
                  context,
                  p,
                  controlador: widget.controlador,
                ),
              );
            },
            childCount: visibles.length,
          ),
        ),
      ),
    ];
  }
}

class _BarraProgreso extends StatelessWidget {
  const _BarraProgreso();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: ClipRRect(
        borderRadius: BorderRadius.all(Radius.circular(99)),
        child: LinearProgressIndicator(
          minHeight: 2.5,
          backgroundColor: Paleta.superficieAlta,
          color: Paleta.acento,
        ),
      ),
    );
  }
}
