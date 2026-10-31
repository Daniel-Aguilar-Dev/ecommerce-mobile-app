import 'package:ecommerce_app/features/categorias/domain/categoria.dart';
import 'package:ecommerce_app/features/productos/domain/producto_estado.dart';

class Producto {
  const Producto({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.marca,
    this.sku,
    required this.stockActual,
    required this.stockMinimo,
    required this.stockReservado,
    required this.precioVenta,
    required this.precioCompra,
    required this.unidadMedia,
    required this.estado,
    required this.costoPromedio,
    required this.categoria,
    required this.imagenPublicId,
    required this.imagenVersion,
    required this.imagenUrl,
  });

  final int id;
  final String nombre;
  final String descripcion;
  final String marca;
  final String? sku;
  final int stockActual;
  final int stockMinimo;
  final int stockReservado;
  final double precioVenta;
  final double precioCompra;
  final String unidadMedia;
  final ProductoEstado estado;
  final int costoPromedio;
  final Categoria categoria;
  final String imagenPublicId;
  final int imagenVersion;
  final String imagenUrl;
}