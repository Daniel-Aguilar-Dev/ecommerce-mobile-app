import 'package:ecommerce_app/features/categorias/domain/categoria_public.dart';
import 'package:ecommerce_app/features/productos/domain/producto_estado.dart';

class ProductoPublic {
  const ProductoPublic({
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
  final CategoriaPublic categoria;
  final String imagen;
  final String estadoStock;
}