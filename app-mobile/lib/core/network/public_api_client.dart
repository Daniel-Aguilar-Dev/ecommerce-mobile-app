import 'package:ecommerce_app/core/network/api_client.dart';

class PublicApiClient {
  PublicApiClient({
    required ApiClient apiClient,
  }) : _apiClient = apiClient;

  final ApiClient _apiClient;

  static final rutasPublicas = [
    "/api/v1/categorias/public",
    "/api/v1/productos/public"
  ];

  Future<Map<String, dynamic>> getJson(String path) {
    return requestJson('GET', path);
  }

  Future<Map<String, dynamic>> requestJson(
      String method,
      String path, {
        Map<String, Object?>? body,
      }) async {
    assert(
    rutasPublicas.any((r) => path.startsWith(r)),
    'La ruta deseada no es un recurso público',
    );
    return await _apiClient.requestJson(
      method,
      path,
      body: body,
    );
  }
}
