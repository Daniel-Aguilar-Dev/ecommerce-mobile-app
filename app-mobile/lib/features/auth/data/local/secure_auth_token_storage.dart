import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../domain/auth_token_storage.dart';

/// Implementación de AuthTokenStorage que usa el almacenamiento seguro
/// disponible en la plataforma, en lugar de guardar el token como texto plano.
class SecureAuthTokenStorage implements AuthTokenStorage {
  SecureAuthTokenStorage({FlutterSecureStorage? storage})
    : _storage = storage ?? FlutterSecureStorage();

  /// La instancia del plugin se inyecta para separar el contrato del mecanismo
  /// concreto y permitir sustituirlo cuando sea necesario.
  final FlutterSecureStorage _storage;

  /// Se usan claves diferentes para leer y renovar la sesión de forma explícita.
  static const _accessTokenKey = 'auth_access_token';
  static const _refreshTokenKey = 'auth_refresh_token';

  @override
  Future<void> guardarTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await _storage.write(key: _accessTokenKey, value: accessToken);
    await _storage.write(key: _refreshTokenKey, value: refreshToken);
  }

  @override
  Future<String?> leerAccessToken() {
    return _storage.read(key: _accessTokenKey);
  }

  @override
  Future<String?> leerRefreshToken() {
    return _storage.read(key: _refreshTokenKey);
  }

  @override
  Future<void> borrarTokens() async {
    await _storage.delete(key: _accessTokenKey);
    await _storage.delete(key: _refreshTokenKey);
  }
}
