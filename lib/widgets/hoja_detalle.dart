import 'package:flutter/material.dart';

import '../estado/controlador_mi_lista.dart';
import '../modelos/calificacion.dart';
import '../modelos/ficha_pelicula.dart';
import '../modelos/pelicula.dart';
import '../servicios/error_base_datos.dart';
import '../servicios/peliculas_api.dart';
import '../tema/app_theme.dart';
import 'poster_pelicula.dart';
import 'selector_estrellas.dart';

Future<void> mostrarDetallePelicula(
  BuildContext context,
  Pelicula p, {
  ControladorMiLista? controlador,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (BuildContext context) => _HojaDetalle(
      pelicula: p,
      controlador: controlador,
    ),
  );
}

class _HojaDetalle extends StatefulWidget {
  const _HojaDetalle({required this.pelicula, this.controlador});

  final Pelicula pelicula;
  final ControladorMiLista? controlador;

  @override
  State<_HojaDetalle> createState() => _HojaDetalleState();
}

class _HojaDetalleState extends State<_HojaDetalle> {
  bool _guardando = false;

  FichaPelicula? _ficha;
  bool _cargandoFicha = false;
  PeliculasApi? _api;

  Pelicula get _pelicula => widget.pelicula;

  @override
  void initState() {
    super.initState();
    // La ficha ampliada (dirección, duración, géneros completos) solo se pide
    // para las películas que vienen de TMDB: las de la base ya la traen.
    if (_pelicula.posterRemoto && _pelicula.id > 0) {
      _api = PeliculasApi();
      _cargarFicha();
    }
  }

  @override
  void dispose() {
    _api?.cerrar();
    super.dispose();
  }

  Future<void> _cargarFicha() async {
    setState(() => _cargandoFicha = true);
    try {
      final FichaPelicula ficha = await _api!.ficha(_pelicula.id);
      if (!mounted) return;
      setState(() {
        _ficha = ficha;
        _cargandoFicha = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _cargandoFicha = false);
    }
  }

  String get _genero => _ficha?.genero ?? _pelicula.genero;

  String get _anio => _ficha?.anioTexto ?? _pelicula.anioTexto;

  String? get _duracion {
    final int? minutos = _ficha?.duracionMin;
    if (minutos != null && minutos > 0) return _textoDuracion(minutos);
    return _pelicula.duracionTexto;
  }

  String get _director {
    final String? deLaFicha = _ficha?.director;
    if (deLaFicha != null && deLaFicha.trim().isNotEmpty) return deLaFicha;
    final String? delDocumento = _pelicula.director;
    if (delDocumento != null && delDocumento.trim().isNotEmpty) {
      return delDocumento;
    }
    if (_cargandoFicha) return 'consultando la API…';
    return 'sin dato';
  }

  static String _textoDuracion(int minutos) {
    final int horas = minutos ~/ 60;
    final int resto = minutos % 60;
    if (horas == 0) return '$resto min';
    if (resto == 0) return '$horas h';
    return '$horas h $resto min';
  }

  @override
  Widget build(BuildContext context) {
    final ControladorMiLista? controlador = widget.controlador;

    final Widget contenido = Container(
      margin: const EdgeInsets.all(10),
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
      decoration: BoxDecoration(
        color: Paleta.superficie,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Paleta.borde),
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 18),
                  decoration: BoxDecoration(
                    color: Paleta.borde,
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  SizedBox(
                    width: 96,
                    height: 144,
                    child: PosterPelicula(
                      pelicula: _pelicula,
                      radio: 14,
                      semantica: 'Póster de ${_pelicula.titulo}',
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          _pelicula.titulo,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            height: 1.15,
                            letterSpacing: -0.4,
                            color: Paleta.texto,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: <Widget>[
                            const Icon(
                              Icons.star_rounded,
                              color: Paleta.ambar,
                              size: 17,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${_pelicula.calificacion.toStringAsFixed(1)} / 10',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: Paleta.texto,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: <Widget>[
                            _Etiqueta(texto: _genero),
                            _Etiqueta(texto: _anio),
                            if (_duracion != null)
                              _Etiqueta(texto: _duracion!),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            const Icon(
                              Icons.person_outline_rounded,
                              size: 15,
                              color: Paleta.textoSuave,
                            ),
                            const SizedBox(width: 5),
                            Expanded(
                              child: Text(
                                'Dirección · $_director',
                                style: const TextStyle(
                                  fontSize: 12.5,
                                  height: 1.35,
                                  color: Paleta.textoSuave,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Text(
                'Sinopsis',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.4,
                  color: Paleta.textoSuave,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _pelicula.sinopsis,
                style: const TextStyle(
                  fontSize: 14,
                  height: 1.55,
                  color: Paleta.texto,
                ),
              ),
              if (controlador != null) ...<Widget>[
                const SizedBox(height: 22),
                _bloqueCalificacion(controlador),
              ],
              const SizedBox(height: 22),
              Row(
                children: <Widget>[
                  Expanded(
                    child: controlador == null
                        ? FilledButton.icon(
                            onPressed: () => _avisar(
                              '«${_pelicula.titulo}» se agregó a Mi lista.',
                            ),
                            icon: const Icon(Icons.add_rounded, size: 19),
                            label: const Text('Mi lista'),
                            style: _estiloPrincipal(),
                          )
                        : FilledButton.icon(
                            onPressed: _guardando
                                ? null
                                : () => _alternarFavorito(controlador),
                            icon: Icon(
                              controlador.esFavorito(_pelicula.id)
                                  ? Icons.bookmark_added_rounded
                                  : Icons.add_rounded,
                              size: 19,
                            ),
                            label: Text(
                              controlador.esFavorito(_pelicula.id)
                                  ? 'En mi lista'
                                  : 'Mi lista',
                            ),
                            style: _estiloPrincipal(),
                          ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _avisar(
                        'El tráiler estará disponible en la siguiente entrega.',
                      ),
                      icon: const Icon(Icons.play_arrow_rounded, size: 20),
                      label: const Text('Tráiler'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Paleta.texto,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: const BorderSide(color: Paleta.borde),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (controlador == null) return contenido;

    return AnimatedBuilder(
      animation: controlador,
      builder: (BuildContext context, Widget? _) => contenido,
    );
  }

  Widget _bloqueCalificacion(ControladorMiLista controlador) {
    final Calificacion? mia = controlador.calificacionDe(_pelicula.id);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
            children: <Widget>[
              const Expanded(
                child: Text(
                  'Tu calificación',
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.3,
                    color: Paleta.textoSuave,
                  ),
                ),
              ),
              if (mia != null)
                TextButton(
                  onPressed: () => _quitarCalificacion(controlador),
                  style: TextButton.styleFrom(
                    foregroundColor: Paleta.textoSuave,
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    minimumSize: const Size(0, 28),
                  ),
                  child: const Text(
                    'Borrar',
                    style: TextStyle(fontSize: 11.5),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 2),
          SelectorEstrellas(
            valor: mia?.estrellas ?? 0,
            tamano: 30,
            mostrarEtiqueta: true,
            alElegir: _guardando
                ? null
                : (int estrellas) => _calificar(controlador, estrellas),
          ),
          const SizedBox(height: 4),
          Text(
            mia == null
                ? 'Se guarda en Cloud Firestore al tocar una estrella.'
                : 'Guardada en Firestore · ${_fecha(mia.actualizadoEn)}',
            style: const TextStyle(fontSize: 11, color: Paleta.textoSuave),
          ),
      ],
    );
  }

  ButtonStyle _estiloPrincipal() => FilledButton.styleFrom(
        backgroundColor: Paleta.acento,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      );

  Future<void> _alternarFavorito(ControladorMiLista controlador) async {
    final ScaffoldMessengerState mensajes = ScaffoldMessenger.of(context);
    setState(() => _guardando = true);
    try {
      final bool guardada = await controlador.alternarFavorito(_pelicula);
      mensajes
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              guardada
                  ? '«${_pelicula.titulo}» se guardó en tu lista.'
                  : '«${_pelicula.titulo}» salió de tu lista.',
            ),
          ),
        );
    } on ErrorBaseDatos catch (error) {
      mensajes
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(error.mensaje)));
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }

  Future<void> _calificar(ControladorMiLista controlador, int estrellas) async {
    final ScaffoldMessengerState mensajes = ScaffoldMessenger.of(context);
    setState(() => _guardando = true);
    try {
      await controlador.calificar(_pelicula, estrellas);
      mensajes
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              'Guardaste $estrellas '
              '${estrellas == 1 ? 'estrella' : 'estrellas'} para '
              '«${_pelicula.titulo}».',
            ),
          ),
        );
    } on ErrorBaseDatos catch (error) {
      mensajes
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(error.mensaje)));
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }

  Future<void> _quitarCalificacion(ControladorMiLista controlador) async {
    try {
      await controlador.quitarCalificacion(_pelicula.id);
    } on ErrorBaseDatos catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(error.mensaje)));
    }
  }

  void _avisar(String mensaje) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(mensaje)));
  }

  static String _fecha(DateTime fecha) {
    const List<String> meses = <String>[
      'ene', 'feb', 'mar', 'abr', 'may', 'jun',
      'jul', 'ago', 'sep', 'oct', 'nov', 'dic',
    ];
    final String hora = fecha.hour.toString().padLeft(2, '0');
    final String minuto = fecha.minute.toString().padLeft(2, '0');
    return '${fecha.day} ${meses[fecha.month - 1]} ${fecha.year}, $hora:$minuto';
  }
}

class _Etiqueta extends StatelessWidget {
  const _Etiqueta({required this.texto});

  final String texto;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Paleta.superficieAlta,
        borderRadius: BorderRadius.circular(Radios.chip),
        border: Border.all(color: Paleta.borde),
      ),
      child: Text(
        texto,
        style: const TextStyle(
          fontSize: 11.5,
          fontWeight: FontWeight.w600,
          color: Paleta.textoSuave,
        ),
      ),
    );
  }
}
