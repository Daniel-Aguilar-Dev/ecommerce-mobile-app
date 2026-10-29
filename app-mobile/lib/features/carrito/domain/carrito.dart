import 'package:ecommerce_app/features/productos/domain/producto.dart';

class Carrito {
  const Carrito({
    required this.items
  });

  final List<CarritoItem> items;
}

class CarritoItem{
  const CarritoItem({
    required this.producto,
    required this.cantidad
  });

  final Producto producto;
  final int cantidad;
}