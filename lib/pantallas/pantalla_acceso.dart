import 'package:flutter/material.dart';

import '../servicios/sesion.dart';
import '../tema/app_theme.dart';
import '../widgets/campo_cine.dart';
import '../widgets/marco_acceso.dart';
import 'pantalla_registro.dart';

/// Acceso con una cuenta ya registrada. Al terminar, la PuertaSesion escucha
/// el cambio de estado y arma la navegación con el catálogo.
class PantallaAcceso extends StatefulWidget {
  const PantallaAcceso({super.key, required this.servicio});

  final ServicioSesion servicio;

  @override
  State<PantallaAcceso> createState() => _PantallaAccesoState();
}

class _PantallaAccesoState extends State<PantallaAcceso> {
  final GlobalKey<FormState> _formulario = GlobalKey<FormState>();
  final TextEditingController _correo = TextEditingController();
  final TextEditingController _clave = TextEditingController();

  bool _enviando = false;
  String? _error;

  @override
  void dispose() {
    _correo.dispose();
    _clave.dispose();
    super.dispose();
  }

  Future<void> _entrar() async {
    if (!(_formulario.currentState?.validate() ?? false)) return;
    setState(() {
      _enviando = true;
      _error = null;
    });
    try {
      await widget.servicio.iniciarSesion(
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
      titulo: 'Iniciar sesión',
      subtitulo: 'Entra con el correo y la contraseña con los que te '
          'registraste.',
      hijos: <Widget>[
        Form(
          key: _formulario,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              CampoCine(
                etiqueta: 'Correo electrónico',
                pista: 'nombre@correo.com',
                controlador: _correo,
                icono: Icons.alternate_email_rounded,
                tipoTeclado: TextInputType.emailAddress,
                accionTeclado: TextInputAction.next,
                validador: (String? valor) {
                  final String texto = (valor ?? '').trim();
                  if (texto.isEmpty) return 'Escribe tu correo.';
                  if (!texto.contains('@') || !texto.contains('.')) {
                    return 'El correo no tiene un formato válido.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),
              CampoCine(
                etiqueta: 'Contraseña',
                controlador: _clave,
                icono: Icons.lock_outline_rounded,
                oculto: true,
                accionTeclado: TextInputAction.done,
                alEnviar: _enviando ? null : _entrar,
                validador: (String? valor) {
                  if ((valor ?? '').isEmpty) return 'Escribe tu contraseña.';
                  if ((valor ?? '').length < 6) {
                    return 'La contraseña tiene al menos seis caracteres.';
                  }
                  return null;
                },
              ),
              if (error != null) ...<Widget>[
                const SizedBox(height: 14),
                AvisoError(mensaje: error),
              ],
              const SizedBox(height: 22),
              FilledButton(
                onPressed: _enviando ? null : _entrar,
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
                        'Entrar',
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
                                PantallaRegistro(servicio: widget.servicio),
                          ),
                        ),
                style: TextButton.styleFrom(
                  foregroundColor: Paleta.textoSuave,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text(
                  'Todavía no tengo cuenta · Registrarme',
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
