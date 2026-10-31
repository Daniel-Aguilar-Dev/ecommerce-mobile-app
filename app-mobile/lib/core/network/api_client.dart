import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import 'api_exception.dart';

/// Adaptador entre las llamadas HTTP y los tipos que maneja el código Dart.
///
/// No conoce operaciones de autenticación ni DTOs: recibe rutas y mapas,
/// envía JSON y devuelve la respuesta JSON decodificada.
class ApiClient {
  /// [baseUrl] se configura desde la app; [httpClient] se puede inyectar
  /// para reutilizarlo o sustituirlo en pruebas.
  ///
  /// La lista de inicialización (después de `:`) prepara los campos `final`
  /// antes de ejecutar el cuerpo del constructor.
  ApiClient({required String baseUrl, http.Client? httpClient})
    : _baseUrl = Uri.parse(baseUrl),
      _httpClient = httpClient ?? http.Client(),
      _ownsHttpClient = httpClient == null;

  /// URL base convertida a Uri, que permite resolver rutas de forma segura.
  final Uri _baseUrl;

  /// Cliente HTTP reutilizable que realiza las solicitudes de red.
  final http.Client _httpClient;

  /// Indica si esta clase creó el cliente y, por tanto, debe cerrarlo.
  final bool _ownsHttpClient;

  /// Atajo para solicitudes POST; no agrega credenciales de autenticación.
  Future<Map<String, dynamic>> postJson(
    String path, {
    required Map<String, Object?> body,
    Map<String, String> headers = const {},
  }) => requestJson('POST', path, body: body, headers: headers);

  /// Atajo para solicitudes GET; no agrega credenciales de autenticación.
  Future<Map<String, dynamic>> getJson(
    String path, {
    Map<String, String> headers = const {},
  }) => requestJson('GET', path, headers: headers);

  /// Envía una solicitud JSON sin conocer el recurso ni su DTO.
  /// La autenticación vive en [AuthenticatedApiClient], no en este adaptador.
  Future<Map<String, dynamic>> requestJson(
    String method,
    String path, {
    Map<String, Object?>? body,
    Map<String, String> headers = const {},
  }) async {
    // `late` permite declarar la respuesta antes del try y asignarla una vez
    // cuando la solicitud termina correctamente.
    late final http.Response response;

    try {
      final request = http.Request(method, _baseUrl.resolve(path))
        ..headers.addAll({'Accept': 'application/json', ...headers});
      if (body != null) {
        request.headers['Content-Type'] = 'application/json';
        request.body = jsonEncode(body);
      }
      response = await http.Response.fromStream(
        await _httpClient.send(request).timeout(const Duration(seconds: 20)),
      ).timeout(const Duration(seconds: 20));
    } on http.ClientException {
      // Traducimos el error de la biblioteca HTTP a un error propio de la app.
      throw const ApiException(message: 'No se pudo conectar con el servidor');
    } on TimeoutException {
      // Un timeout significa que no hubo respuesta dentro del tiempo límite.
      throw const ApiException(
        message: 'La solicitud tardó demasiado. Intenta de nuevo',
      );
    }

    // La respuesta todavía no se ha validado; se asignará tras decodificarla.
    late final Map<String, dynamic> json;

    if(response.statusCode == 204) return {};

    try {
      // Se decodifican los bytes respetando UTF-8 y luego se interpreta JSON.
      final decoded = jsonDecode(utf8.decode(response.bodyBytes));

      // La API debe devolver un objeto JSON en la raíz, no una lista o texto.
      if (decoded is! Map<String, dynamic>) {
        throw const FormatException('La respuesta no es un objeto JSON');
      }

      json = decoded;
    } on FormatException {
      // Un cuerpo vacío o mal formado tampoco es una respuesta utilizable.
      throw ApiException(
        message: 'El servidor devolvió una respuesta inválida',
        statusCode: response.statusCode,
      );
    }

    // Cualquier estado fuera de 200–299 representa un fallo HTTP.
    if (response.statusCode < 200 || response.statusCode >= 300) {
      // El backend puede enviar errores específicos de campos en su envoltura.
      final rawErrors = json['errors'];
      final fieldErrors = rawErrors is Map
          ? rawErrors.map(
              // Convertimos claves y valores a String para cumplir el contrato
              // Map<String, String> de ApiException.
              (key, value) => MapEntry(key.toString(), value.toString()),
            )
          : const <String, String>{};

      // El mensaje y código vienen del backend; usamos un mensaje de respaldo
      // si la respuesta no tiene el formato esperado.
      throw ApiException(
        message: json['message'] is String
            ? json['message'] as String
            : 'Ocurrió un error al comunicarse con el servidor',
        code: json['error'] is String ? json['error'] as String : null,
        statusCode: response.statusCode,
        fieldErrors: fieldErrors,
      );
    }

    // Devuelve la envoltura JSON completa. La fuente remota extraerá `data`
    // y lo convertirá al DTO específico de login o registro.
    return json;
  }

  /// Libera el cliente solo si esta instancia lo creó.
  /// Si se inyectó desde fuera, su propietario externo debe cerrarlo.
  void close() {
    if (_ownsHttpClient) {
      _httpClient.close();
    }
  }
}
