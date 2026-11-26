import 'package:ecommerce_app/features/carrito/domain/carrito.dart';
import 'package:ecommerce_app/features/pedidos/data/models/pedido_request_dto.dart';
import 'package:ecommerce_app/features/pedidos/data/pedido_data_source.dart';
import 'package:ecommerce_app/features/pedidos/domain/pedido_estado.dart';
import 'package:ecommerce_app/features/pedidos/domain/pedido_public.dart';
import 'package:ecommerce_app/features/pedidos/domain/pedido_repository.dart';

class PedidoRepositoryImpl implements PedidoRepository {
  PedidoRepositoryImpl({required PedidoDataSource dataSource}) : _dataSource = dataSource;
  final PedidoDataSource _dataSource;

  @override
  Future<List<PedidoPublic>> misPedidos(PedidoEstado? estado) async =>
      (await _dataSource.misPedidos(estado)).map((dto) => dto.pedido).toList();
  @override
  Future<List<PedidoPublic>> listaPersonal(PedidoEstado? estado) async =>
      (await _dataSource.listaPersonal(estado)).map((dto) => dto.pedido).toList();
  @override
  Stream<String> escucharCambiosPersonal() =>
      _dataSource.escucharCambiosPersonal();
  @override
  Future<PedidoPublic> getMiPedido(int pedidoId) async => (await _dataSource.getMiPedido(pedidoId)).pedido;
  @override
  Future<PedidoPublic> getUnPedido(int pedidoId) async => (await _dataSource.getUnPedido(pedidoId)).pedido;
  @override
  Future<PedidoPublic> getPedidoByQR(String codigoQr) async => (await _dataSource.getPedidoByQR(codigoQr)).pedido;
  @override
  Future<PedidoPublic> crear({required Carrito carrito}) async =>
      (await _dataSource.crear(PedidoRequestDto(carrito: carrito))).pedido;
  @override
  Future<void> cancelar(int pedidoId) => _dataSource.cancelar(pedidoId);
  @override
  Future<PedidoPublic> confirmar(int pedidoId) async => (await _dataSource.confirmar(pedidoId)).pedido;
  @override
  Future<PedidoPublic> rechazar(int pedidoId, String motivo) async => (await _dataSource.rechazar(pedidoId, motivo)).pedido;
  @override
  Future<PedidoPublic> listo(int pedidoId) async => (await _dataSource.listo(pedidoId)).pedido;
  @override
  Future<PedidoPublic> entregarPorQr(String codigoQr, String metodoPago) async =>
      (await _dataSource.entregarPorQr(codigoQr, metodoPago)).pedido;
}
