import 'package:ecommerce_app/features/categorias/domain/categoria.dart';
import 'package:ecommerce_app/features/productos/domain/producto_estado.dart';

class ProductoResponsePublicDto {
  const ProductoResponsePublicDto({
    required this.id,
    required this.nombre,
    required this.descripcion,
    this.sku,
    required this.marca,
    required this.stock,
    required this.precio,
    required this.unidadMedia,
    required this.estado,
    required this.categoria,
    required this.imagen,
    required this.estadoStock,
  });

  final int id;
  final String nombre;
  final String descripcion;
  final String? sku;
  final String marca;
  final int stock;
  final double precio;
  final String unidadMedia;
  final ProductoEstado estado;
  final Categoria categoria;
  final String imagen;
  final String estadoStock;

  factory ProductoResponsePublicDto.fromJson(Map<String, dynamic> json) {
    return ProductoResponsePublicDto(
      id: json['id'] as int,
      nombre: json['nombre'] as String,
      descripcion: json['descripcion'] as String,
      marca: json['marca'] as String,
      sku: json['sku'] as String?,
      stock: json['stock'] as int,
      precio: json['precio'] as double,
      unidadMedia: json['unidadMedida'] as String,
      estado: json['estado'] as ProductoEstado,
      imagen: json['imagen'] as String,
      categoria: json['categoria'] as Categoria,
      estadoStock: json['estadoStock'] as String,
    );
  }
}