import 'package:ecommerce_app/features/auth/domain/auth_user.dart';

class AuthSession {
  const AuthSession({
    required this.tokenType,
    required this.token,
    required this.refreshToken,
    required this.usuario,
  });

  final String tokenType;

  /// Access token Bearer que se envía al acceder a rutas protegidas.
  final String token;

  /// Credencial de larga duración que permite obtener un nuevo par de tokens.
  final String refreshToken;
  final AuthUser usuario;
}
