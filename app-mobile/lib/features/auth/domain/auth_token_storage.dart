/// Contrato para persistir el token de autenticación en el dispositivo.
///
/// El dominio define qué operaciones necesita la app, sin depender del plugin
/// concreto ni de la plataforma donde se almacene el token.
abstract class AuthTokenStorage {
  /// Guarda juntos el access token y el refresh token recibidos del backend.
  Future<void> guardarTokens({
    required String accessToken,
    required String refreshToken,
  });

  /// Lee el access token guardado; devuelve null si no hay una sesión local.
  Future<String?> leerAccessToken();

  /// Lee el refresh token guardado; devuelve null si no hay una sesión local.
  Future<String?> leerRefreshToken();

  /// Elimina ambos tokens locales, por ejemplo al cerrar sesión.
  Future<void> borrarTokens();
}
