import 'package:ecommerce_app/features/carrito/domain/carrito.dart';
import 'package:ecommerce_app/features/pedidos/domain/pedido_estado.dart';
import 'package:ecommerce_app/features/pedidos/domain/pedido_public.dart';

abstract class PedidoRepository {
  Future<List<PedidoPublic>> misPedidos(PedidoEstado? estado);
  Future<List<PedidoPublic>> listaPersonal(PedidoEstado? estado);
  Stream<String> escucharCambiosPersonal();
  Future<PedidoPublic> getMiPedido(int pedidoId);
  Future<PedidoPublic> getUnPedido(int pedidoId);
  Future<PedidoPublic> getPedidoByQR(String codigoQr);
  Future<PedidoPublic> crear({required Carrito carrito});
  Future<void> cancelar(int pedidoId);
  Future<PedidoPublic> confirmar(int pedidoId);
  Future<PedidoPublic> rechazar(int pedidoId, String motivo);
  Future<PedidoPublic> listo(int pedidoId);
  Future<PedidoPublic> entregarPorQr(String codigoQr, String metodoPago);
}
