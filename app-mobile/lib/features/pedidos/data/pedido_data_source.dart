import 'dart:convert';

import 'package:ecommerce_app/core/network/api_exception.dart';
import 'package:ecommerce_app/core/network/authenticated_api_client.dart';
import 'package:ecommerce_app/features/pedidos/data/models/pedido_request_dto.dart';
import 'package:ecommerce_app/features/pedidos/data/models/pedido_response_dto.dart';
import 'package:ecommerce_app/features/pedidos/domain/pedido_estado.dart';

class PedidoDataSource {
  PedidoDataSource({required AuthenticatedApiClient apiClient})
      : _apiClient = apiClient;

  final AuthenticatedApiClient _apiClient;
  static const _path = '/api/v1/pedidos';

  Future<List<PedidoResponseDto>> misPedidos(PedidoEstado? estado) =>
      _getList('/cliente', estado);

  Future<List<PedidoResponseDto>> listaPersonal(PedidoEstado? estado) =>
      _getList('/personal', estado);

  Stream<String> escucharCambiosPersonal() async* {
    var nombreEvento = 'message';
    await for (final linea in _apiClient
        .getEventStream('$_path/personal/stream')
        .transform(const LineSplitter())) {
      if (linea.isEmpty) {
        if (nombreEvento != 'message') yield nombreEvento;
        nombreEvento = 'message';
      } else if (linea.startsWith('event:')) {
        nombreEvento = linea.substring(6).trim();
      }
    }
  }

  Future<PedidoResponseDto> getMiPedido(int id) => _getOne('/one/cliente/$id');
  Future<PedidoResponseDto> getUnPedido(int id) => _getOne('/one/personal/$id');
  Future<PedidoResponseDto> getPedidoByQR(String qr) =>
      _getOne('/qr/${Uri.encodeComponent(qr)}');

  Future<PedidoResponseDto> crear(PedidoRequestDto request) async =>
      _parse(await _apiClient.postJson(_path, body: request.toJson()));

  Future<void> cancelar(int id) async =>
      _parseMessage(await _apiClient.requestJson('PATCH', '$_path/cancelar/$id'));

  Future<PedidoResponseDto> confirmar(int id) =>
      _patchPedido('/confirmar/$id');

  Future<PedidoResponseDto> rechazar(int id, String motivo) =>
      _patchPedido('/rechazar/$id', body: {'motivo': motivo});

  Future<PedidoResponseDto> listo(int id) => _patchPedido('/listo/$id');

  Future<PedidoResponseDto> entregarPorQr(String codigoQr, String metodoPago) =>
      _patchPedido('/entregar/qr/${Uri.encodeComponent(codigoQr)}', body: {'metodo': metodoPago});

  Future<List<PedidoResponseDto>> _getList(String suffix, PedidoEstado? estado) async {
    final query = estado == null ? '' : '?estado=${estado.name}';
    final response = await _apiClient.getJson('$_path$suffix$query');
    _validar(response);
    final data = response['data'];
    if (data is! List) {
      throw const RespuestaInvalida(message: 'La respuesta de pedidos tiene un formato inválido');
    }
    return data
        .map((e) => _parse({'success': true, 'data': e}))
        .toList();
  }

  Future<PedidoResponseDto> _getOne(String suffix) async =>
      _parse(await _apiClient.getJson('$_path$suffix'));

  Future<PedidoResponseDto> _patchPedido(String suffix, {Map<String, Object?>? body}) async =>
      _parse(await _apiClient.requestJson('PATCH', '$_path$suffix', body: body));

  PedidoResponseDto _parse(Map<String, dynamic> response) {
    _validar(response);
    final data = response['data'];
    if (data is! Map) {
      throw const RespuestaInvalida(message: 'La respuesta de pedidos tiene un formato inválido');
    }
    return PedidoResponseDto.fromJson(Map<String, dynamic>.from(data));
  }

  void _parseMessage(Map<String, dynamic> response) => _validar(response);

  void _validar(Map<String, dynamic> response) {
    if (response['success'] != true) {
      final message = response['message'];
      throw RespuestaInvalida(
        message: message is String ? message : 'No fue posible completar la operación del pedido',
      );
    }
  }
}
