import 'package:firebase_auth/firebase_auth.dart';

/// Identificador de la persona que tiene la sesión abierta.
class UsuarioSesion {
  const UsuarioSesion({
    required this.uid,
    this.correo,
    this.nombre,
    this.anonimo = false,
  });

  factory UsuarioSesion.desdeFirebase(User usuario) => UsuarioSesion(
        uid: usuario.uid,
        correo: usuario.email,
        nombre: usuario.displayName,
        anonimo: usuario.isAnonymous,
      );

  /// Sesión de reserva cuando Firebase no responde: la app sigue funcionando
  /// con los datos en memoria y lo dice en la pantalla de perfil.
  factory UsuarioSesion.local() => const UsuarioSesion(
        uid: 'sesion-local',
        correo: null,
        nombre: 'Invitado',
        anonimo: true,
      );

  final String uid;
  final String? correo;
  final String? nombre;
  final bool anonimo;

  String get correoTexto => correo ?? 'sin correo';

  /// Nombre para mostrar. Firebase devuelve displayName vacío cuando la
  /// cuenta se crea y la pantalla se arma antes de que llegue el cambio de
  /// perfil; en ese caso se usa la parte del correo anterior a la arroba.
  String get nombreTexto {
    final String? completo = nombre;
    if (completo != null && completo.trim().isNotEmpty) return completo.trim();
    final String? cuenta = correo;
    if (cuenta != null && cuenta.contains('@')) return cuenta.split('@').first;
    return 'Invitado';
  }
}

/// Error de autenticación ya traducido a un mensaje que se le puede mostrar
/// a la persona. El detalle técnico va aparte, para la bitácora.
class ErrorSesion implements Exception {
  const ErrorSesion({required this.mensaje, this.detalle = ''});

  final String mensaje;
  final String detalle;

  @override
  String toString() => mensaje;
}

/// Envoltorio delgado sobre FirebaseAuth. Deja las pantallas sin conocer los
/// códigos de error del SDK y concentra aquí el alta, el acceso y el cierre.
class ServicioSesion {
  ServicioSesion({FirebaseAuth? auth}) : _auth = auth ?? FirebaseAuth.instance;

  final FirebaseAuth _auth;

  Stream<UsuarioSesion?> get cambios => _auth.userChanges().map(
        (User? usuario) =>
            usuario == null ? null : UsuarioSesion.desdeFirebase(usuario),
      );

  UsuarioSesion? get actual {
    final User? usuario = _auth.currentUser;
    return usuario == null ? null : UsuarioSesion.desdeFirebase(usuario);
  }

  Future<UsuarioSesion> crearCuenta({
    required String nombre,
    required String correo,
    required String clave,
  }) async {
    try {
      final UserCredential credencial =
          await _auth.createUserWithEmailAndPassword(
        email: correo.trim(),
        password: clave,
      );
      final User? usuario = credencial.user;
      if (usuario == null) {
        throw const ErrorSesion(
          mensaje: 'Firebase no devolvió la cuenta recién creada.',
        );
      }
      await usuario.updateDisplayName(nombre.trim());
      await usuario.reload();
      return UsuarioSesion.desdeFirebase(_auth.currentUser ?? usuario);
    } catch (error) {
      throw traducir(error, accion: 'crear la cuenta');
    }
  }

  Future<UsuarioSesion> iniciarSesion({
    required String correo,
    required String clave,
  }) async {
    try {
      final UserCredential credencial = await _auth.signInWithEmailAndPassword(
        email: correo.trim(),
        password: clave,
      );
      final User? usuario = credencial.user;
      if (usuario == null) {
        throw const ErrorSesion(
          mensaje: 'Firebase no devolvió la sesión iniciada.',
        );
      }
      return UsuarioSesion.desdeFirebase(usuario);
    } catch (error) {
      throw traducir(error, accion: 'iniciar sesión');
    }
  }

  Future<void> cerrarSesion() => _auth.signOut();

  static ErrorSesion traducir(Object error, {required String accion}) {
    if (error is ErrorSesion) return error;
    if (error is FirebaseAuthException) {
      return ErrorSesion(
        mensaje: _mensajeDe(error.code),
        detalle: '${error.code} · ${error.message ?? ''}',
      );
    }
    return ErrorSesion(
      mensaje: 'No se pudo $accion. Revisa la conexión e inténtalo de nuevo.',
      detalle: error.toString(),
    );
  }

  static String _mensajeDe(String codigo) {
    switch (codigo) {
      case 'invalid-email':
        return 'El correo no tiene un formato válido.';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'El correo o la contraseña no coinciden con ninguna cuenta.';
      case 'email-already-in-use':
        return 'Ya existe una cuenta registrada con ese correo.';
      case 'weak-password':
        return 'La contraseña necesita al menos seis caracteres.';
      case 'missing-password':
        return 'Escribe una contraseña.';
      case 'user-disabled':
        return 'Esa cuenta está deshabilitada.';
      case 'too-many-requests':
        return 'Demasiados intentos seguidos. Espera un momento.';
      case 'network-request-failed':
        return 'No hay conexión con el servicio de autenticación.';
      case 'operation-not-allowed':
        return 'El registro con correo y contraseña está deshabilitado en el '
            'proyecto de Firebase.';
      default:
        return 'No se pudo completar la operación ($codigo).';
    }
  }
}
