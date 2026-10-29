import 'package:ecommerce_app/core/network/api_client.dart';

class CategoriaDataSource {
  CategoriaDataSource({required ApiClient apiClient}) : _apiClient = apiClient;

  final ApiClient _apiClient;

  static const _loginPath = '/api/v1/auth/login';
  static const _registerPath = '/api/v1/auth/registro';
  static const _refreshPath = '/api/v1/auth/refresh';
  static const _logoutPath = '/api/v1/auth/logout';
}