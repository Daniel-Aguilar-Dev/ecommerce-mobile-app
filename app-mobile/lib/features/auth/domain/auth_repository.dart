import 'package:ecommerce_app/features/auth/domain/auth_session.dart';
import 'package:ecommerce_app/features/auth/domain/auth_user.dart';

abstract class AuthRepository {
  /// Intenta restaurar la sesión local usando el refresh token guardado.
  /// Devuelve null cuando el dispositivo todavía no tiene una sesión.
  Future<AuthSession?> restaurarSesion();

  Future<AuthSession> iniciarSesion({
    required String correo,
    required String contrasena,
  });

  Future<AuthUser> registrar({
    required String nombre,
    required String apellidos,
    required String correo,
    required String telefono,
    required String contrasena,
  });

  /// Renueva ambos tokens usando el refresh token guardado localmente.
  Future<AuthSession> renovarSesion();

  /// Revoca la sesión en el backend y elimina los tokens locales.
  Future<void> cerrarSesion();
}
