import 'package:ecommerce_app/features/pedidos/domain/pedido_estado.dart';
import 'package:ecommerce_app/features/pedidos/domain/pedido_public.dart';

class PedidoResponseDto {
  const PedidoResponseDto(this.pedido);

  final PedidoPublic pedido;

  factory PedidoResponseDto.fromJson(Map<String, dynamic> json) {
    final carrito = _asMap(json['carrito']);
    final rawItems = carrito['items'];
    final items = rawItems is List
        ? rawItems.map((e) => _parseItem(_asMap(e))).toList()
        : <PedidoItem>[];
    return PedidoResponseDto(PedidoPublic(
      id: _toInt(json['id']),
      estado: PedidoEstado.fromJson(json['estado'] as String),
      costo: _toDouble(json['costo']),
      fecha: _toDate(json['fecha']),
      carrito: items,
      numPedido: _toInt(json['numPedido']),
      textPedido: json['textPedido'] as String? ?? '',
      clienteId: _toNullableInt(json['clienteId']),
      clienteNombre: json['clienteNombre'] as String?,
      codigoQr: json['codigoQr'] as String?,
      motivoRechazo: json['motivoRechazo'] as String?,
      fechaEntrega: _toDate(json['fechaEntrega']),
      createdAt: _toDate(json['createdAt']),
      entregable: json['entregable'] as bool? ?? false,
    ));
  }

  static PedidoItem _parseItem(Map<String, dynamic> item) {
    final producto = _asMap(item['producto']);
    return PedidoItem(
      productoId: _toInt(producto['id']),
      nombre: producto['nombre'] as String? ?? 'Producto',
      cantidad: _toInt(item['cantidad']),
      precioUnitario: _toDouble(producto['precioVenta'] ?? producto['precio']),
      imagen: producto['imagen'] as String? ?? producto['imagenUrl'] as String?,
    );
  }

  static Map<String, dynamic> _asMap(dynamic value) =>
      value is Map ? Map<String, dynamic>.from(value) : <String, dynamic>{};

  static int _toInt(dynamic value) => value is num ? value.toInt() : 0;
  static int? _toNullableInt(dynamic value) => value is num ? value.toInt() : null;
  static double _toDouble(dynamic value) => value is num ? value.toDouble() : 0;

  static DateTime? _toDate(dynamic value) {
    if (value is num) return DateTime.fromMillisecondsSinceEpoch(value.toInt());
    if (value is String) return DateTime.tryParse(value);
    return null;
  }
}
