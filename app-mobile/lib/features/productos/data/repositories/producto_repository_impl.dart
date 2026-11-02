import 'dart:io';

import 'package:ecommerce_app/features/carrito/domain/carrito.dart';
import 'package:ecommerce_app/features/categorias/domain/categoria.dart';
import 'package:ecommerce_app/features/categorias/domain/categoria_public.dart';
import 'package:ecommerce_app/features/productos/data/models/producto_params.dart';
import 'package:ecommerce_app/features/productos/data/models/producto_params_public.dart';
import 'package:ecommerce_app/features/productos/data/models/producto_request_dto.dart';
import 'package:ecommerce_app/features/productos/data/models/producto_response_dto.dart';
import 'package:ecommerce_app/features/productos/data/models/producto_response_public_dto.dart';
import 'package:ecommerce_app/features/productos/data/models/stock_linea_response_dto.dart';
import 'package:ecommerce_app/features/productos/data/producto_data_source.dart';
import 'package:ecommerce_app/features/productos/domain/producto.dart';
import 'package:ecommerce_app/features/productos/domain/producto_public.dart';
import 'package:ecommerce_app/features/productos/domain/producto_repository.dart';

class ProductoRepositoryImpl implements ProductoRepository {
  const ProductoRepositoryImpl({
    required ProductoDataSource datasource
  }) : _productoDataSource = datasource;

  final ProductoDataSource _productoDataSource;

  @override
  Future<void> cambiarEstado(int id) async{
    return _productoDataSource.cambiarEstado(id);
  }

  @override
  Future<Producto> crear(ProductoRequestDto dto, File file) async{
    final response = await _productoDataSource.crear(dto, file);
    return _mapearProducto(response);
  }

  @override
  Future<void> eliminar(int id) async{
    return _productoDataSource.eliminar(id);
  }

  @override
  Future<List<String>> listaMarcas() async{
    return _productoDataSource.marcas();
  }

  @override
  Future<List<Producto>> listaPersonal(ProductoParams? params) async{
    final response = await _productoDataSource.todos(params);
    late final List<Producto> list = [];
    for (final c in response){
      list.add(_mapearProducto(c));
    }
    return  list;
  }

  @override
  Future<List<ProductoPublic>> listaPublica([ProductoParamsPublic? params]) async{
    final response = await _productoDataSource.todosPublic(params);
    late final List<ProductoPublic> list = [];
    for (final c in response){
      list.add(_mapearProductoPublic(c));
    }
    return  list;
  }

  @override
  Future<Producto> modificar(ProductoRequestDto dto, File file, int id) async{
    final response = await _productoDataSource.modificar(dto, file, id);
    return _mapearProducto(response);
  }

  @override
  Future<Producto> unoPorId(int id) async{
    final response = await _productoDataSource.unoPorId(id);
    return _mapearProducto(response);
  }

  @override
  Future<Producto> unoPorNombre(String nombre) async{
    final response = await _productoDataSource.unoPorNombre(nombre);
    return _mapearProducto(response);
  }

  @override
  Future<Producto> unoPorSku(String sku) async{
    final response = await _productoDataSource.unoPorSKU(sku);
    return _mapearProducto(response);
  }

  @override
  Future<ProductoPublic> unoPublicoPorId(int id) async{
    final response = await _productoDataSource.unoPublicoPorId(id);
    return _mapearProductoPublic(response);
  }

  @override
  Future<List<StockLineaResponseDto>> validarCarrito(Carrito carrito) async{
    final response = await _productoDataSource.validarStockCarrito(carrito);
    late final List<StockLineaResponseDto> list = [];
    for (final c in response){
      list.add(StockLineaResponseDto(
        nombre: c.nombre,
        disponible: c.disponible,
        productoId: c.productoId,
        motivo: c.motivo,
        solicitado: c.solicitado,
        suficiente: c.suficiente
      ));
    }
    return  list;
  }

  @override
  Future<int> validarStock(int id, int cantidad) async{
    return _productoDataSource.validarStockProducto(id);
  }

  Producto _mapearProducto(ProductoResponseDto response){
    return Producto(
        id: response.id,
        nombre: response.nombre,
        descripcion: response.descripcion,
        marca: response.marca,
        sku: response.sku,
        stockActual: response.stockActual,
        stockMinimo: response.stockMinimo,
        stockReservado: response.stockReservado,
        precioVenta: response.precioVenta,
        precioCompra: response.precioCompra,
        unidadMedia: response.unidadMedia,
        estado: response.estado,
        costoPromedio: response.costoPromedio,
        categoria:Categoria(id: response.categoria.id, nombre: response.categoria.nombre, descripcion: response.categoria.descripcion, tieneProductos: response.categoria.tieneProductos),
        imagenPublicId: response.imagenPublicId,
        imagenVersion: response.imagenVersion,
        imagenUrl: response.imagenUrl
    );
  }

  ProductoPublic _mapearProductoPublic(ProductoResponsePublicDto response){
    return ProductoPublic(
        id: response.id,
        nombre: response.nombre,
        descripcion: response.descripcion,
        marca: response.marca,
        sku: response.sku,
        stock: response.stock,
        precio: response.precio,
        unidadMedia: response.unidadMedia,
        estado: response.estado,
        categoria: CategoriaPublic(id: response.categoria.id, nombre: response.categoria.nombre, descripcion: response.categoria.descripcion),
        imagen: response.imagen,
        estadoStock: response.estadoStock
    );
  }
}