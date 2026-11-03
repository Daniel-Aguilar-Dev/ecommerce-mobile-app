import 'package:ecommerce_app/features/productos/domain/producto_public.dart';

class Carrito {
  const Carrito({
    required this.items,
    required this.cantidad
  });

  final List<CarritoItem> items;
  final int cantidad;

  Map<String, dynamic> toJson() {
    return {
      'items': items,
      'cantidad': cantidad,
    };
  }
}

class CarritoItem{
  const CarritoItem({
    required this.producto,
    required this.cantidad
  });

  final ProductoPublic producto;
  final int cantidad;
}