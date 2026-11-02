import 'package:ecommerce_app/features/categorias/data/models/categoria_response_dto.dart';
import 'package:ecommerce_app/features/productos/domain/producto_estado.dart';

class ProductoResponseDto {
  const ProductoResponseDto({
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
  final double costoPromedio;
  final CategoriaResponseDto categoria;
  final String imagenPublicId;
  final int imagenVersion;
  final String imagenUrl;

  factory ProductoResponseDto.fromJson(Map<String, dynamic> json) {
    return ProductoResponseDto(
      id: json['id'] as int,
      nombre: json['nombre'] as String,
      descripcion: json['descripcion'] as String,
      marca: json['marca'] as String,
      sku: json['sku'] as String?,
      stockActual: json['stockActual'] as int,
      stockMinimo: json['stockMinimo'] as int,
      stockReservado: json['stockReservado'] as int,
      precioCompra: json['precioCompra'] as double,
      precioVenta: json['precioVenta'] as double,
      unidadMedia: json['unidadMedida'] as String,
      estado: ProductoEstado.fromJson(json['estado'] as String),
      imagenPublicId: json['imagenPublicId'] as String,
      imagenVersion: json['imagenVersion'] as int,
      imagenUrl: json['imagenUrl'] as String,
      costoPromedio: json['costoPromedio'] as double,
      categoria: CategoriaResponseDto.fromJson(json["categoria"] as Map<String, dynamic>)
    );
  }
}