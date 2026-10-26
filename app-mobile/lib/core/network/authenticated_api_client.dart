import 'package:ecommerce_app/core/network/api_client.dart';
import 'package:ecommerce_app/core/network/api_exception.dart';
import 'package:ecommerce_app/features/auth/domain/auth_repository.dart';
import 'package:ecommerce_app/features/auth/domain/auth_token_storage.dart';

// Se conservan nombres públicos descriptivos y campos de implementación privados.
// ignore_for_file: prefer_initializing_formals

/// Cliente para endpoints protegidos. El ApiClient base sigue siendo anónimo,
/// por lo que login, registro, refresh y logout nunca provocan una renovación.
class AuthenticatedApiClient {
  AuthenticatedApiClient({
    required ApiClient apiClient,
    required AuthTokenStorage tokenStorage,
    required AuthRepository authRepository,
    required void Function() onSessionExpired,
  }) : _apiClient = apiClient,
       _tokenStorage = tokenStorage,
       _authRepository = authRepository,
       _onSessionExpired = onSessionExpired;

  final ApiClient _apiClient;
  final AuthTokenStorage _tokenStorage;
  final AuthRepository _authRepository;
  final void Function() _onSessionExpired;

  /// Future compartido: varios 401 simultáneos esperan la misma renovación.
  Future<void>? _refreshInFlight;

  Future<Map<String, dynamic>> getJson(String path) {
    return requestJson('GET', path);
  }

  Future<Map<String, dynamic>> postJson(
    String path, {
    required Map<String, Object?> body,
  }) {
    return requestJson('POST', path, body: body);
  }

  /// Permite usar también PUT, PATCH o DELETE en recursos protegidos.
  Future<Map<String, dynamic>> requestJson(
    String method,
    String path, {
    Map<String, Object?>? body,
  }) async {
    final tokenUsado = await _obtenerAccessToken();

    try {
      return await _enviar(method, path, tokenUsado, body);
    } on ApiException catch (error) {
      if (error.statusCode != 401) rethrow;

      // Si otra solicitud ya renovó mientras esta esperaba su respuesta,
      // reutiliza el token nuevo y evita rotar el refresh token otra vez.
      final tokenActual = await _tokenStorage.leerAccessToken();
      final tokenParaReintento =
          tokenActual != null &&
              tokenActual.isNotEmpty &&
              tokenActual != tokenUsado
          ? tokenActual
          : await _renovarOExpirar();

      // Se reintenta exactamente una vez. Un segundo 401 se entrega al caller.
      try {
        return await _enviar(method, path, tokenParaReintento, body);
      } on ApiException catch (retryError) {
        if (retryError.statusCode == 401) {
          await _tokenStorage.borrarTokens();
          _onSessionExpired();
        }
        rethrow;
      }
    }
  }

  Future<Map<String, dynamic>> _enviar(
    String method,
    String path,
    String accessToken,
    Map<String, Object?>? body,
  ) {
    return _apiClient.requestJson(
      method,
      path,
      body: body,
      headers: {'Authorization': 'Bearer $accessToken'},
    );
  }

  Future<String> _obtenerAccessToken() async {
    final token = await _tokenStorage.leerAccessToken();
    if (token != null && token.isNotEmpty) return token;
    return _renovarOExpirar();
  }

  Future<String> _renovarOExpirar() async {
    try {
      await _renovarUnaVezCompartida();
      final tokenNuevo = await _tokenStorage.leerAccessToken();
      if (tokenNuevo == null || tokenNuevo.isEmpty) {
        throw const ApiException(
          message: 'La API no devolvió un access token renovado',
          statusCode: 401,
        );
      }
      return tokenNuevo;
    } catch (_) {
      try {
        await _tokenStorage.borrarTokens();
      } catch (_) {
        // Aunque el dispositivo no permita limpiar el storage, la UI debe
        // abandonar la ruta autenticada y pedir credenciales nuevamente.
      }
      _onSessionExpired();
      throw const ApiException(
        message: 'La sesión expiró. Inicia sesión nuevamente',
        statusCode: 401,
      );
    }
  }

  Future<void> _renovarUnaVezCompartida() {
    final enCurso = _refreshInFlight;
    if (enCurso != null) return enCurso;

    late final Future<void> operacion;
    operacion =
        Future<void>.sync(() async {
          await _authRepository.renovarSesion();
        }).whenComplete(() {
          if (identical(_refreshInFlight, operacion)) {
            _refreshInFlight = null;
          }
        });
    _refreshInFlight = operacion;
    return operacion;
  }
}
