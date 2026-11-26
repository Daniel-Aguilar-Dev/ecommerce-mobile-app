import 'package:ecommerce_app/features/categorias/data/models/categoria_public_response_dto.dart';
import 'package:ecommerce_app/features/categorias/domain/categoria_public.dart';
import 'package:ecommerce_app/features/productos/domain/producto_estado.dart';
import 'package:ecommerce_app/features/productos/domain/producto_public.dart';

class Carrito {
  const Carrito({
    required this.items,
    required this.cantidad,
  });

  const Carrito.vacio() : items = const [], cantidad = 0;

  final List<CarritoItem> items;
  final int cantidad;

  double get total =>
      items.fold<double>(0, (suma, i) => suma + i.subtotal);

  bool get estaVacio => items.isEmpty;

  Map<String, dynamic> toJson() => {
    'items': items.map((i) => i.toJson()).toList(),
    'cantidad': cantidad,
  };

  factory Carrito.fromJson(Map<String, dynamic> json) {
    return Carrito(
      items: (json['items'] as List)
          .map((i) => CarritoItem.fromJson(Map<String, dynamic>.from(i as Map)))
          .toList(),
      cantidad: json['cantidad'] as int,
    );
  }
}

class CarritoItem {
  const CarritoItem({
    required this.producto,
    required this.cantidad,
  });

  final ProductoPublic producto;
  final int cantidad;

  double get subtotal => producto.precio * cantidad;

  CarritoItem copyWith({int? cantidad}) =>
      CarritoItem(producto: producto, cantidad: cantidad ?? this.cantidad);

  Map<String, dynamic> toJson() => {
    'producto': _productoToJson(producto),
    'cantidad': cantidad,
  };

  factory CarritoItem.fromJson(Map<String, dynamic> json) {
    return CarritoItem(
      producto: _productoFromJson(
          Map<String, dynamic>.from(json['producto'] as Map)),
      cantidad: json['cantidad'] as int,
    );
  }

  static ProductoPublic _productoFromJson(Map<String, dynamic> json) {
    CategoriaPublicResponseDto cat = CategoriaPublicResponseDto.fromJson(json["categoria"]);
    return ProductoPublic(
      id: json['id'] as int,
      nombre: json['nombre'] as String,
      descripcion: json['descripcion'] as String,
      marca: json['marca'] as String,
      sku: json['sku'] as String?,
      stock: json['stock'] as int,
      precio: json['precio'] as double,
      unidadMedia: json['unidadMedida'] as String,
      estado: ProductoEstado.fromJson(json["estado"] as String),
      imagen: json['imagen'] as String,
      categoria: CategoriaPublic(
          id: cat.id, nombre: cat.nombre, descripcion: cat.descripcion),
      estadoStock: json['estadoStock'] as String,
    );
  }

  Map<String, dynamic> _productoToJson(ProductoPublic prod) {
    return {
      "id" : prod.id,
      "nombre" : prod.nombre,
      "descripcion" : prod.descripcion,
      "marca" : prod.marca,
      "sku" : prod.sku,
      "stock" : prod.stock,
      "precio" : prod.precio,
      "unidadMedida" : prod.unidadMedia,
      "estado" : prod.estado.name,
      "imagen" : prod.imagen,
      "categoria" : { "id" : prod.categoria.id, "nombre" : prod.categoria.nombre, "descripcion" : prod.categoria.descripcion},
      "estadoStock" : prod.estadoStock,
    };
  }
}