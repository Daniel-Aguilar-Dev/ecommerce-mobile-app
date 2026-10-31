import 'package:ecommerce_app/features/categorias/domain/categoria.dart';
import 'package:ecommerce_app/features/productos/domain/producto_estado.dart';

class ProductoRequestDto {
  const ProductoRequestDto({
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
    required this.categoria,
  });

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
  final Categoria categoria;

  Map<String, dynamic> toJson() {
    return {
      'nombre': nombre,
      'descripcion': descripcion,
      'marca' : marca,
      if(sku != null) 'sku' : sku,
      "stockActual" : stockActual,
      "stockMinimo" : stockMinimo,
      "stockReservado" : stockReservado,
      "precioVenta" : precioVenta,
      "precioCompra" : precioCompra,
      "unidadMedia" : unidadMedia,
      "estado" : estado,
      "categoria" : categoria,
    };
  }
}