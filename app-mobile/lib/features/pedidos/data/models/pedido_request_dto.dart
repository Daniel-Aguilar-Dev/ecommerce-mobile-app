import 'package:ecommerce_app/features/carrito/domain/carrito.dart';

/// El backend deserializa CarritoItem.Producto como la entidad Producto.
/// Aunque PedidoService solo confía en el id y precioVenta consultados en BD,
/// Jackson requiere los campos enteros primitivos para poder construirla.
class PedidoRequestDto {
  const PedidoRequestDto({required this.carrito});

  final Carrito carrito;

  Map<String, Object?> toJson() => {
    'carrito': {
      'cantidad': carrito.cantidad,
      'items': carrito.items
          .map(
            (item) => {
              'cantidad': item.cantidad,
              'producto': {
                'id': item.producto.id,
                'precioVenta': item.producto.precio,
                'stockActual': item.producto.stock,
                // Estos datos son solo para deserialización; el servidor vuelve a leer
                // el producto real antes de validar y guardar el pedido.
                'stockMinimo': 0,
                'stockReservado': 0,
              },
            },
          )
          .toList(),
    },
  };
}
