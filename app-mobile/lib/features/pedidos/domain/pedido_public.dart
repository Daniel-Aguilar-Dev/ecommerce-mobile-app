import 'package:ecommerce_app/features/pedidos/domain/pedido_estado.dart';

class PedidoPublic {
  const PedidoPublic({
    required this.id,
    required this.estado,
    required this.costo,
    required this.fecha,
    required this.carrito,
    required this.numPedido,
    required this.textPedido,
    this.clienteId,
    this.clienteNombre,
    this.codigoQr,
    this.motivoRechazo,
    this.fechaEntrega,
    this.createdAt,
    this.entregable = false,
  });

  final int id;
  final PedidoEstado estado;
  final double costo;
  final DateTime? fecha;
  final List<PedidoItem> carrito;
  final int numPedido;
  final String textPedido;
  final int? clienteId;
  final String? clienteNombre;
  final String? codigoQr;
  final String? motivoRechazo;
  final DateTime? fechaEntrega;
  final DateTime? createdAt;
  final bool entregable;
}

class PedidoItem {
  const PedidoItem({
    required this.productoId,
    required this.nombre,
    required this.cantidad,
    required this.precioUnitario,
    this.imagen,
  });

  final int productoId;
  final String nombre;
  final int cantidad;
  final double precioUnitario;
  final String? imagen;

  double get subtotal => cantidad * precioUnitario;
}
