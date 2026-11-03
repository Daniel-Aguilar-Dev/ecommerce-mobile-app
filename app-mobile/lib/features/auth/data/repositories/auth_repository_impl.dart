import 'package:ecommerce_app/core/network/api_exception.dart';
import 'package:ecommerce_app/features/auth/data/auth_remote_data_source.dart';
import 'package:ecommerce_app/features/auth/data/models/login_request_dto.dart';
import 'package:ecommerce_app/features/auth/data/models/login_response_dto.dart';
import 'package:ecommerce_app/features/auth/data/models/register_request_dto.dart';
import 'package:ecommerce_app/features/auth/domain/auth_repository.dart';
import 'package:ecommerce_app/features/auth/domain/auth_session.dart';
import 'package:ecommerce_app/features/auth/domain/auth_token_storage.dart';
import 'package:ecommerce_app/features/auth/domain/auth_user.dart';

// Los nombres públicos de inyección son claros; los campos internos son privados.
// ignore_for_file: prefer_initializing_formals

/// Coordina la API remota, el almacenamiento de tokens y los modelos de dominio.
class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({
    required AuthRemoteDataSource remoteDataSource,
    required AuthTokenStorage tokenStorage,
  }) : _remoteDataSource = remoteDataSource,
       _tokenStorage = tokenStorage;

  final AuthRemoteDataSource _remoteDataSource;
  final AuthTokenStorage _tokenStorage;

  @override
  Future<AuthSession?> restaurarSesion() async {
    final refreshToken = await _tokenStorage.leerRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) return null;
    return renovarSesion();
  }

  @override
  Future<AuthSession> iniciarSesion({
    required String correo,
    required String contrasena,
  }) async {
    final respuesta = await _remoteDataSource.iniciarSesion(
      LoginRequestDto(correo: correo, contrasena: contrasena),
    );

    await _guardarTokens(respuesta);
    return _crearSesion(respuesta);
  }

  @override
  Future<AuthUser> registrar({
    required String nombre,
    required String apellidos,
    required String correo,
    required String telefono,
    required String contrasena,
  }) async {
    final respuesta = await _remoteDataSource.registrar(
      RegisterRequestDto(
        nombre: nombre,
        apellidos: apellidos,
        correo: correo,
        telefono: telefono,
        contrasena: contrasena,
      ),
    );

    return AuthUser(
      id: respuesta.id,
      nombre: respuesta.nombre,
      correo: respuesta.correo,
      rol: respuesta.rol,
    );
  }

  @override
  Future<AuthSession> renovarSesion() async {
    final refreshToken = await _tokenStorage.leerRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) {
      throw const ApiException(
        message: 'No hay refresh token guardado; inicia sesión nuevamente',
        statusCode: 401,
      );
    }

    try {
      final respuesta = await _remoteDataSource.renovar(refreshToken);
      await _guardarTokens(respuesta);
      return _crearSesion(respuesta);
    } on ApiException catch (error) {
      // Si el refresh token venció o fue revocado, ya no hay sesión renovable.
      if (error.statusCode == 401) {
        await _tokenStorage.borrarTokens();
      }
      rethrow;
    }
  }

  @override
  Future<void> cerrarSesion() async {
    final refreshToken = await _tokenStorage.leerRefreshToken();
    try {
      if (refreshToken != null && refreshToken.isNotEmpty) {
        await _remoteDataSource.cerrarSesion(refreshToken);
      }
    } finally {
      // Limpia el dispositivo incluso si el servidor no está disponible.
      await _tokenStorage.borrarTokens();
    }
  }

  Future<void> _guardarTokens(LoginResponseDto respuesta) {
    return _tokenStorage.guardarTokens(
      accessToken: respuesta.token,
      refreshToken: respuesta.refreshToken,
    );
  }

  AuthSession _crearSesion(LoginResponseDto respuesta) {
    return AuthSession(
      tokenType: respuesta.tipo,
      token: respuesta.token,
      refreshToken: respuesta.refreshToken,
      usuario: AuthUser(
        id: respuesta.user.id,
        nombre: null,
        correo: respuesta.user.correo,
        rol: respuesta.user.rol,
      ),
    );
  }
}
