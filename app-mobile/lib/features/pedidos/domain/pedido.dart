import 'pedido_public.dart';

/// Pedido presentado a personal; comparte el payload público de la API.
class Pedido extends PedidoPublic {
  const Pedido({
    required super.id,
    required super.estado,
    required super.costo,
    required super.fecha,
    required super.carrito,
    required super.numPedido,
    required super.textPedido,
    super.clienteId,
    super.clienteNombre,
    super.motivoRechazo,
    super.fechaEntrega,
    super.createdAt,
    super.entregable,
  });
}
