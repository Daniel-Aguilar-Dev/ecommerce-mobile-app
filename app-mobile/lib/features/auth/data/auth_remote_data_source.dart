import 'package:ecommerce_app/core/network/api_client.dart';
import 'package:ecommerce_app/core/network/api_exception.dart';
import 'package:ecommerce_app/features/auth/data/models/login_request_dto.dart';
import 'package:ecommerce_app/features/auth/data/models/login_response_dto.dart';
import 'package:ecommerce_app/features/auth/data/models/register_request_dto.dart';
import 'package:ecommerce_app/features/auth/data/models/register_response_dto.dart';

// El parámetro público mantiene un nombre claro y el colaborador queda privado.
// ignore_for_file: prefer_initializing_formals

class AuthRemoteDataSource {
  AuthRemoteDataSource({required ApiClient apiClient}) : _apiClient = apiClient;

  final ApiClient _apiClient;

  static const _loginPath = '/api/v1/auth/login';
  static const _registerPath = '/api/v1/auth/registro';
  static const _refreshPath = '/api/v1/auth/refresh';
  static const _logoutPath = '/api/v1/auth/logout';

  Future<LoginResponseDto> iniciarSesion(LoginRequestDto request) async {
    // Convierte el DTO de Dart al mapa que representa el cuerpo JSON del login.
    final requestBody = request.toJson();

    // ApiClient se encarga del HTTP y devuelve el JSON completo de la respuesta.
    final responseJson = await _apiClient.postJson(
      _loginPath,
      body: requestBody,
    );

    return _leerRespuestaTokens(
      responseJson,
      mensajeFallback: 'No fue posible iniciar sesión',
    );
  }

  /// Usa el refresh token actual para pedir un nuevo par de tokens al backend.
  Future<LoginResponseDto> renovar(String refreshToken) async {
    final responseJson = await _apiClient.postJson(
      _refreshPath,
      body: {'refreshToken': refreshToken},
    );

    return _leerRespuestaTokens(
      responseJson,
      mensajeFallback: 'No fue posible renovar la sesión',
    );
  }

  /// Revoca la sesión remota usando su refresh token vigente.
  Future<void> cerrarSesion(String refreshToken) async {
    final responseJson = await _apiClient.postJson(
      _logoutPath,
      body: {'refreshToken': refreshToken},
    );

    if (responseJson['success'] != true) {
      final message = responseJson['message'];
      throw ApiException(
        message: message is String
            ? message
            : 'No fue posible cerrar la sesión en el servidor',
      );
    }
  }

  Future<RegisterResponseDto> registrar(RegisterRequestDto request) async {
    final requestBody = request.toJson();

    final responseJson = await _apiClient.postJson(
      _registerPath,
      body: requestBody,
    );

    if (responseJson['success'] != true) {
      final message = responseJson['message'];
      throw ApiException(
        message: message is String
            ? message
            : 'No fue posible realizar el registro',
      );
    }

    final data = responseJson['data'];
    if (data is! Map<String, dynamic>) {
      throw const ApiException(
        message: 'La respuesta tiene un formato inválido',
      );
    }

    return RegisterResponseDto.fromJson(data);
  }

  LoginResponseDto _leerRespuestaTokens(
    Map<String, dynamic> responseJson, {
    required String mensajeFallback,
  }) {
    // La API devuelve el resultado dentro de success/message/data.
    if (responseJson['success'] != true) {
      final message = responseJson['message'];
      throw ApiException(
        message: message is String ? message : mensajeFallback,
      );
    }

    // El DTO modela solo `data`, que contiene ambos tokens y el usuario.
    final data = responseJson['data'];
    if (data is! Map<String, dynamic>) {
      throw const ApiException(
        message: 'La respuesta de autenticación tiene un formato inválido',
      );
    }

    return LoginResponseDto.fromJson(data);
  }
}
