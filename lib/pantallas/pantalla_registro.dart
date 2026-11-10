import 'package:flutter/material.dart';

import '../servicios/sesion.dart';
import '../tema/app_theme.dart';
import '../widgets/campo_cine.dart';
import '../widgets/marco_acceso.dart';
import 'pantalla_acceso.dart';

/// Registro de una cuenta nueva con correo y contraseña. Firebase guarda la
/// cuenta y devuelve la sesión abierta, así que al terminar se entra directo
/// al catálogo.
class PantallaRegistro extends StatefulWidget {
  const PantallaRegistro({super.key, required this.servicio});

  final ServicioSesion servicio;

  @override
  State<PantallaRegistro> createState() => _PantallaRegistroState();
}

class _PantallaRegistroState extends State<PantallaRegistro> {
  final GlobalKey<FormState> _formulario = GlobalKey<FormState>();
  final TextEditingController _nombre = TextEditingController();
  final TextEditingController _correo = TextEditingController();
  final TextEditingController _clave = TextEditingController();
  final TextEditingController _repetir = TextEditingController();

  bool _enviando = false;
  String? _error;

  @override
  void dispose() {
    _nombre.dispose();
    _correo.dispose();
    _clave.dispose();
    _repetir.dispose();
    super.dispose();
  }

  Future<void> _registrar() async {
    if (!(_formulario.currentState?.validate() ?? false)) return;
    setState(() {
      _enviando = true;
      _error = null;
    });
    try {
      await widget.servicio.crearCuenta(
        nombre: _nombre.text,
        correo: _correo.text,
        clave: _clave.text,
      );
      if (!mounted) return;
      Navigator.of(context).popUntil((Route<dynamic> r) => r.isFirst);
    } on ErrorSesion catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error.mensaje;
        _enviando = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final String? error = _error;

    return MarcoAcceso(
      titulo: 'Crear una cuenta',
      subtitulo: 'Con esta cuenta se guardan tu lista, tus calificaciones y '
          'el catálogo que administres.',
      hijos: <Widget>[
        Form(
          key: _formulario,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              CampoCine(
                etiqueta: 'Nombre completo',
                pista: 'Como quieres que aparezca',
                controlador: _nombre,
                icono: Icons.person_outline_rounded,
                tipoTeclado: TextInputType.name,
                accionTeclado: TextInputAction.next,
                validador: (String? valor) =>
                    (valor ?? '').trim().length < 3
                        ? 'Escribe tu nombre.'
                        : null,
              ),
              const SizedBox(height: 14),
              CampoCine(
                etiqueta: 'Correo electrónico',
                pista: 'nombre@correo.com',
                controlador: _correo,
                icono: Icons.alternate_email_rounded,
                tipoTeclado: TextInputType.emailAddress,
                accionTeclado: TextInputAction.next,
                validador: (String? valor) {
                  final String texto = (valor ?? '').trim();
                  if (texto.isEmpty) return 'Escribe un correo.';
                  if (!texto.contains('@') || !texto.contains('.')) {
                    return 'El correo no tiene un formato válido.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),
              CampoCine(
                etiqueta: 'Contraseña',
                pista: 'Al menos seis caracteres',
                controlador: _clave,
                icono: Icons.lock_outline_rounded,
                oculto: true,
                accionTeclado: TextInputAction.next,
                validador: (String? valor) => (valor ?? '').length < 6
                    ? 'La contraseña tiene al menos seis caracteres.'
                    : null,
              ),
              const SizedBox(height: 14),
              CampoCine(
                etiqueta: 'Repetir contraseña',
                controlador: _repetir,
                icono: Icons.lock_reset_rounded,
                oculto: true,
                accionTeclado: TextInputAction.done,
                alEnviar: _enviando ? null : _registrar,
                validador: (String? valor) =>
                    valor != _clave.text ? 'Las contraseñas no coinciden.' : null,
              ),
              if (error != null) ...<Widget>[
                const SizedBox(height: 14),
                AvisoError(mensaje: error),
              ],
              const SizedBox(height: 22),
              FilledButton(
                onPressed: _enviando ? null : _registrar,
                style: FilledButton.styleFrom(
                  backgroundColor: Paleta.acento,
                  foregroundColor: const Color(0xFF15130C),
                  disabledBackgroundColor: Paleta.acentoOscuro,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(13),
                  ),
                ),
                child: _enviando
                    ? const SizedBox(
                        width: 19,
                        height: 19,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.2,
                          color: Color(0xFF15130C),
                        ),
                      )
                    : const Text(
                        'Registrarme',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: _enviando
                    ? null
                    : () => Navigator.of(context).pushReplacement(
                          MaterialPageRoute<void>(
                            builder: (_) =>
                                PantallaAcceso(servicio: widget.servicio),
                          ),
                        ),
                style: TextButton.styleFrom(
                  foregroundColor: Paleta.textoSuave,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text(
                  'Ya tengo cuenta · Iniciar sesión',
                  style: TextStyle(fontSize: 13),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
