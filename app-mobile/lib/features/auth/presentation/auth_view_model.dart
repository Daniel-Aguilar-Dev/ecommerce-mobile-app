import 'package:flutter/foundation.dart';

import 'package:ecommerce_app/core/network/api_exception.dart';
import 'package:ecommerce_app/features/auth/domain/auth_repository.dart';
import 'package:ecommerce_app/features/auth/domain/auth_session.dart';

// La API del constructor conserva nombres públicos descriptivos.
// ignore_for_file: prefer_initializing_formals

enum AuthStatus { checking, unauthenticated, authenticated }

/// Estado de presentación y acciones del flujo de autenticación.
/// La vista solo invoca métodos y observa propiedades; no conoce HTTP ni DTOs.
class AuthViewModel extends ChangeNotifier {
  AuthViewModel({required AuthRepository authRepository})
    : _authRepository = authRepository;

  final AuthRepository _authRepository;

  AuthStatus _status = AuthStatus.checking;
  AuthSession? _session;
  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;

  AuthStatus get status => _status;
  AuthSession? get session => _session;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;

  /// En el arranque intenta renovar la sesión almacenada. El backend valida
  /// el refresh token y entrega un nuevo par; si no existe, muestra login.
  Future<void> inicializar() async {
    _status = AuthStatus.checking;
    notifyListeners();
    try {
      _session = await _authRepository.restaurarSesion();
      _status = _session == null
          ? AuthStatus.unauthenticated
          : AuthStatus.authenticated;
    } catch (error) {
      _session = null;
      _status = AuthStatus.unauthenticated;
      _errorMessage = _mensaje(error);
    }
    notifyListeners();
  }

  Future<bool> iniciarSesion({
    required String correo,
    required String contrasena,
  }) async {
    _comenzarOperacion();
    try {
      _session = await _authRepository.iniciarSesion(
        correo: correo.trim(),
        contrasena: contrasena,
      );
      _status = AuthStatus.authenticated;
      return true;
    } catch (error) {
      _errorMessage = _mensaje(error);
      return false;
    } finally {
      _terminarOperacion();
    }
  }

  Future<bool> registrar({
    required String nombre,
    required String apellidos,
    required String correo,
    required String telefono,
    required String contrasena,
  }) async {
    _comenzarOperacion();
    try {
      await _authRepository.registrar(
        nombre: nombre.trim(),
        apellidos: apellidos.trim(),
        correo: correo.trim(),
        telefono: telefono.trim(),
        contrasena: contrasena,
      );
      _successMessage = 'Cuenta creada. Inicia sesión para continuar.';
      return true;
    } catch (error) {
      _errorMessage = _mensaje(error);
      return false;
    } finally {
      _terminarOperacion();
    }
  }

  Future<void> cerrarSesion() async {
    _comenzarOperacion();
    try {
      await _authRepository.cerrarSesion();
    } catch (error) {
      // El repositorio elimina las credenciales locales incluso si falla la red.
      _errorMessage = _mensaje(error);
    } finally {
      _session = null;
      _status = AuthStatus.unauthenticated;
      _terminarOperacion();
    }
  }

  /// Llamado por el cliente HTTP cuando el refresh falla y borra credenciales.
  void expirarSesion() {
    _session = null;
    _status = AuthStatus.unauthenticated;
    _errorMessage = null;
    notifyListeners();
  }

  void limpiarMensajes() {
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }

  void _comenzarOperacion() {
    _isLoading = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }

  void _terminarOperacion() {
    _isLoading = false;
    notifyListeners();
  }

  String _mensaje(Object error) {
    if (error is ApiException) return error.message;
    return 'Ocurrió un error inesperado. Intenta de nuevo.';
  }
}
