import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Tests contra el backend real. Se omiten en la suite normal y se habilitan con
/// ECOMMERCE_BACKEND_INTEGRATION=true y las variables ECOMMERCE_* de acceso.
void main() {
  final enabled =
      Platform.environment['ECOMMERCE_BACKEND_INTEGRATION'] == 'true';
  final baseUrl =
      Platform.environment['ECOMMERCE_API_BASE_URL'] ??
      'http://192.168.1.66:8080';
  final clientEmail = Platform.environment['ECOMMERCE_CLIENT_EMAIL'];
  final clientPassword = Platform.environment['ECOMMERCE_CLIENT_PASSWORD'];
  final staffEmail = Platform.environment['ECOMMERCE_STAFF_EMAIL'];
  final staffPassword = Platform.environment['ECOMMERCE_STAFF_PASSWORD'];

  group('Integración con backend real', () {
    test('autentica cliente/personal y aplica permisos de lectura', () async {
      final http = HttpClient();
      try {
        final clientToken = await _login(
          http,
          baseUrl,
          _required(clientEmail, 'ECOMMERCE_CLIENT_EMAIL'),
          _required(clientPassword, 'ECOMMERCE_CLIENT_PASSWORD'),
          'CLIENTE',
        );
        final staffToken = await _login(
          http,
          baseUrl,
          _required(staffEmail, 'ECOMMERCE_STAFF_EMAIL'),
          _required(staffPassword, 'ECOMMERCE_STAFF_PASSWORD'),
          'EMPLEADO',
        );

        final publicProducts = await _request(
          http,
          baseUrl,
          'GET',
          '/api/v1/productos/public',
        );
        expect(publicProducts.statusCode, 200);
        expect(publicProducts.body['success'], isTrue);
        expect(publicProducts.body['data'], isA<List>());

        final ownOrders = await _request(
          http,
          baseUrl,
          'GET',
          '/api/v1/pedidos/cliente',
          token: clientToken,
        );
        final incomingOrders = await _request(
          http,
          baseUrl,
          'GET',
          '/api/v1/pedidos/personal',
          token: staffToken,
        );
        expect(ownOrders.statusCode, 200);
        expect(ownOrders.body['success'], isTrue);
        expect(ownOrders.body['data'], isA<List>());
        expect(incomingOrders.statusCode, 200);
        expect(incomingOrders.body['success'], isTrue);
        expect(incomingOrders.body['data'], isA<List>());

        final forbiddenForClient = await _request(
          http,
          baseUrl,
          'GET',
          '/api/v1/pedidos/personal',
          token: clientToken,
        );
        final forbiddenForStaff = await _request(
          http,
          baseUrl,
          'GET',
          '/api/v1/pedidos/cliente',
          token: staffToken,
        );
        expect(forbiddenForClient.statusCode, 403);
        expect(forbiddenForStaff.statusCode, 403);
      } finally {
        http.close(force: true);
      }
    }, skip: !enabled);

    test('crea/cancela pedido y notifica ambos cambios por SSE', () async {
      final http = HttpClient();
      StreamIterator<String>? sseLines;
      String? clientToken;
      int? pedidoId;
      try {
        clientToken = await _login(
          http,
          baseUrl,
          _required(clientEmail, 'ECOMMERCE_CLIENT_EMAIL'),
          _required(clientPassword, 'ECOMMERCE_CLIENT_PASSWORD'),
          'CLIENTE',
        );
        final staffToken = await _login(
          http,
          baseUrl,
          _required(staffEmail, 'ECOMMERCE_STAFF_EMAIL'),
          _required(staffPassword, 'ECOMMERCE_STAFF_PASSWORD'),
          'EMPLEADO',
        );

        final streamRequest = await http.getUrl(
          Uri.parse('$baseUrl/api/v1/pedidos/personal/stream'),
        );
        streamRequest.headers.set(
          HttpHeaders.authorizationHeader,
          'Bearer $staffToken',
        );
        final streamResponse = await streamRequest.close();
        expect(streamResponse.statusCode, 200);
        sseLines = StreamIterator<String>(
          streamResponse
              .transform(utf8.decoder)
              .transform(const LineSplitter()),
        );
        expect(await _nextEvent(sseLines), 'connected');

        final productsResult = await _request(
          http,
          baseUrl,
          'GET',
          '/api/v1/productos/public',
        );
        final products = (productsResult.body['data'] as List)
            .cast<Map<String, dynamic>>();
        final product = products.firstWhere(
          (item) =>
              (item['stock'] as num? ?? 0) > 0 &&
              item['estado'] == 'PROD_ACTIVO',
        );

        final created = await _request(
          http,
          baseUrl,
          'POST',
          '/api/v1/pedidos',
          token: clientToken,
          body: {
            'carrito': {
              'cantidad': 1,
              'items': [
                {
                  'cantidad': 1,
                  'producto': {
                    'id': product['id'],
                    'precioVenta': product['precio'],
                    'stockActual': product['stock'],
                    'stockMinimo': 0,
                    'stockReservado': 0,
                  },
                },
              ],
            },
          },
        );
        expect(created.statusCode, 201, reason: created.body.toString());
        expect(created.body['success'], isTrue);
        final createdOrder = created.body['data'] as Map<String, dynamic>;
        pedidoId = (createdOrder['id'] as num).toInt();
        expect(createdOrder['estado'], 'PED_PENDIENTE');
        expect(await _nextEvent(sseLines), 'pedido-creado');

        final cancelled = await _request(
          http,
          baseUrl,
          'PATCH',
          '/api/v1/pedidos/cancelar/$pedidoId',
          token: clientToken,
        );
        expect(cancelled.statusCode, 200);
        expect(cancelled.body['success'], isTrue);
        expect(await _nextEvent(sseLines), 'pedido-cancelado');

        final clientOrders = await _request(
          http,
          baseUrl,
          'GET',
          '/api/v1/pedidos/cliente',
          token: clientToken,
        );
        final staffOrders = await _request(
          http,
          baseUrl,
          'GET',
          '/api/v1/pedidos/personal',
          token: staffToken,
        );
        expect(
          _findOrder(clientOrders.body, pedidoId!)['estado'],
          'PED_CANCELADO',
        );
        expect(
          _findOrder(staffOrders.body, pedidoId!)['estado'],
          'PED_CANCELADO',
        );
      } finally {
        // Limpia el estado operativo aunque una aserción intermedia falle.
        if (pedidoId != null && clientToken != null) {
          try {
            await _request(
              http,
              baseUrl,
              'PATCH',
              '/api/v1/pedidos/cancelar/$pedidoId',
              token: clientToken,
            );
          } catch (_) {
            // Se conserva el error original del test; el pedido ya puede estar cancelado.
          }
        }
        await sseLines?.cancel();
        http.close(force: true);
      }
    }, skip: !enabled);
  });
}

String _required(String? value, String name) {
  if (value == null || value.isEmpty) {
    throw StateError('Falta configurar la variable $name');
  }
  return value;
}

Future<String> _login(
  HttpClient http,
  String baseUrl,
  String email,
  String password,
  String expectedRole,
) async {
  final response = await _request(
    http,
    baseUrl,
    'POST',
    '/api/v1/auth/login',
    body: {'correo': email, 'contrasena': password},
  );
  expect(response.statusCode, 200);
  expect(response.body['success'], isTrue);
  final data = response.body['data'] as Map<String, dynamic>;
  final user = data['usuario'] as Map<String, dynamic>;
  expect(user['rol'], expectedRole);
  return data['token'] as String;
}

Future<_ApiResult> _request(
  HttpClient http,
  String baseUrl,
  String method,
  String path, {
  String? token,
  Map<String, Object?>? body,
}) async {
  final request = await http.openUrl(method, Uri.parse('$baseUrl$path'));
  request.headers.set(HttpHeaders.acceptHeader, 'application/json');
  if (token != null) {
    request.headers.set(HttpHeaders.authorizationHeader, 'Bearer $token');
  }
  if (body != null) {
    request.headers.contentType = ContentType.json;
    request.write(jsonEncode(body));
  }
  final response = await request.close();
  final text = await response.transform(utf8.decoder).join();
  return _ApiResult(
    statusCode: response.statusCode,
    body: text.isEmpty
        ? <String, dynamic>{}
        : jsonDecode(text) as Map<String, dynamic>,
  );
}

Future<String> _nextEvent(StreamIterator<String> lines) async {
  while (await lines.moveNext()) {
    final line = lines.current;
    if (line.startsWith('event:'))
      return line.substring('event:'.length).trim();
  }
  throw StateError('El stream SSE terminó antes de emitir el evento esperado');
}

Map<String, dynamic> _findOrder(Map<String, dynamic> response, int id) {
  expect(response['success'], isTrue);
  final orders = (response['data'] as List).cast<Map<String, dynamic>>();
  return orders.firstWhere((order) => order['id'] == id);
}

class _ApiResult {
  const _ApiResult({required this.statusCode, required this.body});
  final int statusCode;
  final Map<String, dynamic> body;
}
