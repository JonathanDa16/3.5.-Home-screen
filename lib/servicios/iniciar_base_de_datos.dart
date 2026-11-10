import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

import '../config/firebase_config.dart';
import 'catalogo_en_memoria.dart';
import 'catalogo_firestore.dart';
import 'repositorio_catalogo.dart';
import 'sesion.dart';

class ConexionBase {
  const ConexionBase({
    required this.repositorio,
    required this.enLinea,
    required this.mensaje,
    this.usuarioId,
  });

  final RepositorioCatalogo repositorio;

  final bool enLinea;

  final String mensaje;

  final String? usuarioId;

  factory ConexionBase.sinConexion(String mensaje) => ConexionBase(
        repositorio: CatalogoEnMemoria(),
        enLinea: false,
        mensaje: mensaje,
      );
}

/// Enciende Firebase y, cuando el modo local está activo, apunta Firestore y
/// Authentication a los emuladores. Devuelve false si el SDK no arranca: en
/// ese caso la app sigue con los datos en memoria.
Future<bool> iniciarFirebase({
  Duration limite = const Duration(seconds: 90),
}) async {
  try {
    await _encender().timeout(limite);
    return true;
  } on TimeoutException {
    debugPrint('[Firebase] sin respuesta en ${limite.inSeconds} s');
    return false;
  } catch (error) {
    debugPrint('Firebase no inicializó: $error');
    return false;
  }
}

Future<void> _encender() async {
  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp(options: FirebaseConfig.actuales);
  }

  if (FirebaseConfig.usarEmulador) {
    final String host = FirebaseConfig.hostEmulador;
    FirebaseFirestore.instance.useFirestoreEmulator(
      host,
      FirebaseConfig.puertoFirestore,
    );
    await FirebaseAuth.instance.useAuthEmulator(
      host,
      FirebaseConfig.puertoAuth,
    );
    debugPrint('[Firebase] Firestore y Auth apuntando a $host '
        '(${FirebaseConfig.puertoFirestore}/${FirebaseConfig.puertoAuth})');
  }
}

/// Arma la conexión de datos de la persona que acaba de entrar: crea el
/// repositorio con su uid y deja escrito el documento de usuario.
Future<ConexionBase> conectarUsuario(UsuarioSesion usuario) async {
  try {
    final CatalogoFirestore repositorio =
        CatalogoFirestore(usuarioId: usuario.uid);
    await repositorio
        .preparar(plataforma: _plataforma())
        .timeout(const Duration(seconds: 20));
    return ConexionBase(
      repositorio: repositorio,
      enLinea: true,
      mensaje: FirebaseConfig.usarEmulador
          ? 'Cloud Firestore (emulador ${FirebaseConfig.hostEmulador})'
          : 'Cloud Firestore (${FirebaseConfig.proyecto})',
      usuarioId: usuario.uid,
    );
  } catch (error) {
    debugPrint('No se pudo preparar la base: $error');
    return ConexionBase.sinConexion(
      'La base de datos no respondió (${_resumen(error)}). '
      'Se muestran los datos en memoria.',
    );
  }
}

String _plataforma() {
  if (kIsWeb) return 'web';
  return defaultTargetPlatform.name;
}

String _resumen(Object error) {
  final String texto = error.toString().replaceAll('\n', ' ');
  return texto.length > 120 ? '${texto.substring(0, 120)}…' : texto;
}
