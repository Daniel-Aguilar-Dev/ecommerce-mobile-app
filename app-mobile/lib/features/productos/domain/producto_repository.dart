import 'dart:io';

import 'package:ecommerce_app/features/carrito/domain/carrito.dart';
import 'package:ecommerce_app/features/productos/data/models/producto_params.dart';
import 'package:ecommerce_app/features/productos/data/models/producto_params_public.dart';
import 'package:ecommerce_app/features/productos/data/models/producto_request_dto.dart';
import 'package:ecommerce_app/features/productos/data/models/stock_linea_response_dto.dart';
import 'package:ecommerce_app/features/productos/domain/producto.dart';
import 'package:ecommerce_app/features/productos/domain/producto_public.dart';

abstract class ProductoRepository {
  Future<List<ProductoPublic>> listaPublica(ProductoParamsPublic? params);

  Future<List<Producto>> listaPersonal(ProductoParams? params);

  Future<ProductoPublic> unoPublicoPorId(int id);

  Future<Producto> unoPorId(int id);

  Future<Producto> unoPorNombre(String nombre);

  Future<Producto> unoPorSku(String sku);

  Future<List<String>> listaMarcas();

  Future<int> validarStock(int id, int cantidad);

  Future<List<StockLineaResponseDto>> validarCarrito(Carrito carrito);

  Future<Producto> crear(ProductoRequestDto dto, File file);

  Future<Producto> modificar(ProductoRequestDto dto, File file, int id);

  Future<void> cambiarEstado(int id);

  Future<void> eliminar(int id);
}