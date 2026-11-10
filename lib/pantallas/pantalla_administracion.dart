import 'package:flutter/material.dart';

import '../estado/controlador_mi_lista.dart';
import '../modelos/pelicula.dart';
import '../servicios/error_base_datos.dart';
import '../servicios/iniciar_base_de_datos.dart';
import '../servicios/sesion.dart';
import '../tema/app_theme.dart';
import '../widgets/barra_superior.dart';
import '../widgets/campo_cine.dart';
import '../widgets/menu_superior.dart';
import '../widgets/poster_pelicula.dart';

/// Alta y baja de películas del catálogo. Cada movimiento se escribe en la
/// colección `catalogo` de Cloud Firestore y se refleja al instante en el
/// catálogo de la base de datos y en el catálogo principal.
class PantallaAdministracion extends StatefulWidget {
  const PantallaAdministracion({
    super.key,
    required this.conexion,
    required this.controlador,
    this.sesion,
    this.usuario,
  });

  final ConexionBase conexion;

  final ControladorMiLista controlador;

  final ServicioSesion? sesion;

  final UsuarioSesion? usuario;

  @override
  State<PantallaAdministracion> createState() => _PantallaAdministracionState();
}

class _PantallaAdministracionState extends State<PantallaAdministracion> {
  bool _guardando = false;

  void _avisar(String mensaje) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(mensaje)));
  }

  Future<void> _agregar() async {
    final Pelicula? nueva = await showModalBottomSheet<Pelicula>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) => const _FormularioAlta(),
    );
    if (nueva == null || !mounted) return;

    setState(() => _guardando = true);
    try {
      await widget.conexion.repositorio.altaPelicula(nueva);
      if (!mounted) return;
      _avisar('«${nueva.titulo}» se guardó en el catálogo de la base.');
    } catch (error) {
      if (!mounted) return;
      setState(() => _guardando = false);
      _avisar(ErrorBaseDatos.desde(error, accion: 'guardar la película').mensaje);
      return;
    }
    if (mounted) setState(() => _guardando = false);
  }

  Future<void> _borrar(Pelicula pelicula) async {
    final bool? confirmar = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        backgroundColor: Paleta.superficieAlta,
        title: const Text('Dar de baja', style: TextStyle(fontSize: 17)),
        content: Text(
          '«${pelicula.titulo}» se borra del catálogo de la base de datos. '
          'Esta acción no se puede deshacer.',
          style: const TextStyle(fontSize: 13.5, height: 1.5),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF8C3B36),
              foregroundColor: Colors.white,
            ),
            child: const Text('Dar de baja'),
          ),
        ],
      ),
    );
    if (confirmar != true || !mounted) return;

    setState(() => _guardando = true);
    try {
      await widget.conexion.repositorio.bajaPelicula(pelicula.id);
      if (!mounted) return;
      _avisar('«${pelicula.titulo}» salió del catálogo.');
    } catch (error) {
      if (!mounted) return;
      _avisar(ErrorBaseDatos.desde(error, accion: 'dar de baja').mensaje);
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Paleta.fondo,
      body: SafeArea(
        bottom: false,
        child: StreamBuilder<List<Pelicula>>(
          stream: widget.conexion.repositorio.catalogo(),
          builder: (
            BuildContext context,
            AsyncSnapshot<List<Pelicula>> instantanea,
          ) {
            final List<Pelicula> peliculas =
                instantanea.data ?? const <Pelicula>[];

            return CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: <Widget>[
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
                  sliver: SliverToBoxAdapter(
                    child: BarraSuperior(
                      volver: true,
                      acciones: MenuSuperior(
                        conexion: widget.conexion,
                        controlador: widget.controlador,
                        sesion: widget.sesion,
                        usuario: widget.usuario,
                      ),
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
                  sliver: SliverToBoxAdapter(child: _encabezado(peliculas)),
                ),
                if (peliculas.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: _vacio(),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 96),
                    sliver: SliverList.separated(
                      itemCount: peliculas.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 10),
                      itemBuilder: (BuildContext context, int i) =>
                          _fila(peliculas[i]),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _guardando ? null : _agregar,
        backgroundColor: Paleta.acento,
        foregroundColor: const Color(0xFF15130C),
        icon: _guardando
            ? const SizedBox(
                width: 17,
                height: 17,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Color(0xFF15130C),
                ),
              )
            : const Icon(Icons.add_rounded, size: 21),
        label: const Text(
          'Agregar película',
          style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }

  Widget _encabezado(List<Pelicula> peliculas) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Text(
          'Administración del catálogo',
          style: TextStyle(
            fontSize: 23,
            height: 1.15,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
            color: Paleta.texto,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Da de alta una película con título, año, dirección, género, '
          'sinopsis y la URL del póster, o retira una del catálogo. Cada '
          'cambio se escribe en Cloud Firestore.',
          style: TextStyle(
            fontSize: 13,
            height: 1.55,
            color: Paleta.textoSuave,
          ),
        ),
        const SizedBox(height: 14),
        Row(
          children: <Widget>[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Paleta.superficieAlta,
                borderRadius: BorderRadius.circular(Radios.chip),
                border: Border.all(color: Paleta.borde),
              ),
              child: Text(
                '${peliculas.length} en catalogo/',
                style: const TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  color: Paleta.textoSuave,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                widget.conexion.mensaje,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 11.5,
                  color: Paleta.textoSuave,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _fila(Pelicula pelicula) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Paleta.superficie,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Paleta.borde),
      ),
      child: Row(
        children: <Widget>[
          SizedBox(
            width: 48,
            height: 72,
            child: PosterPelicula(pelicula: pelicula, radio: 9),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  pelicula.titulo,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    height: 1.25,
                    color: Paleta.texto,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  '${pelicula.anioTexto} · ${pelicula.genero}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11.5,
                    color: Paleta.textoSuave,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  pelicula.directorTexto,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11.5,
                    color: Paleta.textoSuave,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: _guardando ? null : () => _borrar(pelicula),
            tooltip: 'Dar de baja',
            icon: const Icon(
              Icons.delete_outline_rounded,
              size: 21,
              color: Color(0xFFE0736B),
            ),
          ),
        ],
      ),
    );
  }

  Widget _vacio() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 26, 28, 90),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          const Icon(
            Icons.movie_creation_outlined,
            size: 44,
            color: Paleta.textoSuave,
          ),
          const SizedBox(height: 14),
          const Text(
            'El catálogo de la base está vacío',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Paleta.texto,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Toca «Agregar película» para dar de alta la primera.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: Paleta.textoSuave),
          ),
        ],
      ),
    );
  }
}

class _FormularioAlta extends StatefulWidget {
  const _FormularioAlta();

  @override
  State<_FormularioAlta> createState() => _FormularioAltaState();
}

class _FormularioAltaState extends State<_FormularioAlta> {
  final GlobalKey<FormState> _formulario = GlobalKey<FormState>();
  final TextEditingController _titulo = TextEditingController();
  final TextEditingController _anio = TextEditingController();
  final TextEditingController _director = TextEditingController();
  final TextEditingController _genero = TextEditingController();
  final TextEditingController _sinopsis = TextEditingController();
  final TextEditingController _poster = TextEditingController();

  String _vistaPrevia = '';

  @override
  void initState() {
    super.initState();
    _poster.addListener(_actualizarVista);
  }

  void _actualizarVista() {
    final String url = _poster.text.trim();
    if (url == _vistaPrevia) return;
    setState(() => _vistaPrevia = url);
  }

  @override
  void dispose() {
    _poster.removeListener(_actualizarVista);
    _titulo.dispose();
    _anio.dispose();
    _director.dispose();
    _genero.dispose();
    _sinopsis.dispose();
    _poster.dispose();
    super.dispose();
  }

  void _guardar() {
    if (!(_formulario.currentState?.validate() ?? false)) return;
    final int id = DateTime.now().millisecondsSinceEpoch;
    Navigator.of(context).pop(
      Pelicula(
        id: id,
        titulo: _titulo.text.trim(),
        anio: int.tryParse(_anio.text.trim()),
        director: _director.text.trim(),
        genero: _genero.text.trim(),
        calificacion: 0,
        sinopsis: _sinopsis.text.trim(),
        poster: _poster.text.trim(),
        esDeLaBase: true,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double alturaTeclado = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      margin: const EdgeInsets.all(10),
      padding: EdgeInsets.fromLTRB(20, 10, 20, 20 + alturaTeclado),
      decoration: BoxDecoration(
        color: Paleta.superficie,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Paleta.borde),
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Form(
            key: _formulario,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Paleta.borde,
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                ),
                const Text(
                  'Alta de película',
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.4,
                    color: Paleta.texto,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Los seis datos que pide la actividad. El póster se toma de '
                  'una URL pública.',
                  style: TextStyle(
                    fontSize: 12,
                    height: 1.5,
                    color: Paleta.textoSuave,
                  ),
                ),
                const SizedBox(height: 16),
                CampoCine(
                  etiqueta: 'Título',
                  controlador: _titulo,
                  icono: Icons.movie_outlined,
                  validador: (String? v) =>
                      (v ?? '').trim().length < 2 ? 'Escribe el título.' : null,
                ),
                const SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Expanded(
                      child: CampoCine(
                        etiqueta: 'Año',
                        controlador: _anio,
                        icono: Icons.calendar_today_rounded,
                        tipoTeclado: TextInputType.number,
                        validador: (String? v) {
                          final int? anio = int.tryParse((v ?? '').trim());
                          if (anio == null) return 'Año de cuatro dígitos.';
                          if (anio < 1888 || anio > 2100) {
                            return 'Entre 1888 y 2100.';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: CampoCine(
                        etiqueta: 'Género',
                        controlador: _genero,
                        icono: Icons.category_outlined,
                        validador: (String? v) => (v ?? '').trim().isEmpty
                            ? 'Escribe el género.'
                            : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                CampoCine(
                  etiqueta: 'Dirección',
                  pista: 'Quién dirige la película',
                  controlador: _director,
                  icono: Icons.person_pin_circle_outlined,
                  validador: (String? v) => (v ?? '').trim().length < 3
                      ? 'Escribe el nombre de quien dirige.'
                      : null,
                ),
                const SizedBox(height: 12),
                CampoCine(
                  etiqueta: 'Sinopsis',
                  pista: 'De qué trata, en dos o tres líneas',
                  controlador: _sinopsis,
                  icono: Icons.notes_rounded,
                  validador: (String? v) => (v ?? '').trim().length < 20
                      ? 'La sinopsis necesita al menos 20 caracteres.'
                      : null,
                ),
                const SizedBox(height: 12),
                CampoCine(
                  etiqueta: 'URL de la imagen',
                  pista: 'https://…',
                  controlador: _poster,
                  icono: Icons.image_outlined,
                  tipoTeclado: TextInputType.url,
                  validador: (String? v) {
                    final String url = (v ?? '').trim();
                    if (url.isEmpty) return 'Pega la URL del póster.';
                    if (!url.startsWith('http')) return 'Debe empezar con http.';
                    return null;
                  },
                ),
                if (_vistaPrevia.startsWith('http')) ...<Widget>[
                  const SizedBox(height: 14),
                  Row(
                    children: <Widget>[
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          _vistaPrevia,
                          width: 54,
                          height: 80,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => Container(
                            width: 54,
                            height: 80,
                            color: Paleta.superficieAlta,
                            child: const Icon(
                              Icons.broken_image_outlined,
                              size: 18,
                              color: Paleta.textoSuave,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Vista previa del póster',
                          style: TextStyle(
                            fontSize: 12,
                            color: Paleta.textoSuave,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 20),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Paleta.textoSuave,
                          side: const BorderSide(color: Paleta.borde),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Cancelar'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      flex: 2,
                      child: FilledButton(
                        onPressed: _guardar,
                        style: FilledButton.styleFrom(
                          backgroundColor: Paleta.acento,
                          foregroundColor: const Color(0xFF15130C),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Guardar en la base',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
