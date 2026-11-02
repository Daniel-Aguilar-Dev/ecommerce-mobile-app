import 'dart:io';

import 'package:ecommerce_app/core/network/api_exception.dart';
import 'package:ecommerce_app/core/network/authenticated_api_client.dart';
import 'package:ecommerce_app/core/network/public_api_client.dart';
import 'package:ecommerce_app/features/carrito/domain/carrito.dart';
import 'package:ecommerce_app/features/productos/data/models/producto_params.dart';
import 'package:ecommerce_app/features/productos/data/models/producto_params_public.dart';
import 'package:ecommerce_app/features/productos/data/models/producto_response_public_dto.dart';
import 'package:ecommerce_app/features/productos/data/models/producto_response_dto.dart';
import 'package:ecommerce_app/features/productos/data/models/producto_request_dto.dart';
import 'package:ecommerce_app/features/productos/data/models/stock_linea_response_dto.dart';
import 'package:flutter/cupertino.dart';

class ProductoDataSource {
  ProductoDataSource({
    required AuthenticatedApiClient apiClientAuth,
    required PublicApiClient apiClientPublic
  }) : _apiClientAuth = apiClientAuth, _apiClientPublic = apiClientPublic;

  final PublicApiClient _apiClientPublic;
  final AuthenticatedApiClient _apiClientAuth;

  static final _publicPath = "/api/v1/productos/public";
  static final _privatePath = "/api/v1/Productos";

  Future<List<ProductoResponsePublicDto>> todosPublic([ProductoParamsPublic? params]) async {
    late final Map<String, dynamic> responseJson;

    if(params != null){
      responseJson = await _apiClientPublic.getJson(
          "$_publicPath${params.getUrlParams()}"
      );
    } else {
      responseJson = await _apiClientPublic.getJson(
          _publicPath
      );
    }

    if (responseJson['success'] != true) {
      final message = responseJson['message'];
      throw ApiException(
        message: message is String
            ? message
            : 'No fue posible obtener los productos',
      );
    }

    final data = responseJson['data'];
    if (data is! List) {
      throw const ApiException(
        message: 'La respuesta tiene un formato inválido',
      );
    }

    return data.map((e) => ProductoResponsePublicDto.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<ProductoResponseDto>> todos([ProductoParams? params]) async{
    late final Map<String, dynamic> responseJson;
    if(params != null){
      responseJson = await _apiClientAuth.getJson(
          "$_privatePath${params.getUrlParams()}"
      );
    } else {
      responseJson = await _apiClientAuth.getJson(
          _privatePath
      );
    }

    if (responseJson['success'] != true) {
      final message = responseJson['message'];
      throw ApiException(
        message: message is String
            ? message
            : 'No fue posible obtener los productos',
      );
    }

    final data = responseJson['data'];
    if (data is! List) {
      throw const ApiException(
        message: 'La respuesta tiene un formato inválido',
      );
    }

    return data.map((e) => ProductoResponseDto.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<String>> marcas() async {
    final responseJson = await _apiClientPublic.getJson(
        "$_publicPath/marcas"
    );

    if (responseJson['success'] != true) {
      final message = responseJson['message'];
      throw ApiException(
        message: message is String
            ? message
            : 'No fue posible obtener los productos',
      );
    }

    final data = responseJson['data'];
    if (data is! List) {
      throw const ApiException(
        message: 'La respuesta tiene un formato inválido',
      );
    }

    return data.map((e) => e as String).toList();
  }

  Future<ProductoResponsePublicDto> unoPublicoPorId(int id) async{
    final responseJson = await _apiClientPublic.getJson(
        "$_publicPath/$id"
    );

    if (responseJson['success'] != true) {
      final message = responseJson['message'];
      throw ApiException(
        message: message is String
            ? message
            : 'No fue posible obtener el producto',
      );
    }

    final data = responseJson['data'];
    if (data is! Map<String, dynamic>) {
      throw const ApiException(
        message: 'La respuesta tiene un formato inválido',
      );
    }

    return data as ProductoResponsePublicDto;
  }

  Future<ProductoResponseDto> unoPorId(int id) async{
    final responseJson = await _apiClientAuth.getJson(
        "$_privatePath/$id"
    );

    if (responseJson['success'] != true) {
      final message = responseJson['message'];
      throw ApiException(
        message: message is String
            ? message
            : 'No fue posible obtener el producto',
      );
    }

    final data = responseJson['data'];
    if (data is! Map<String, dynamic>) {
      throw const ApiException(
        message: 'La respuesta tiene un formato inválido',
      );
    }

    return data as ProductoResponseDto;
  }

  Future<ProductoResponseDto> unoPorNombre(String nombre) async{
    final responseJson = await _apiClientAuth.getJson(
        "$_privatePath/name/$nombre"
    );

    if (responseJson['success'] != true) {
      final message = responseJson['message'];
      throw ApiException(
        message: message is String
            ? message
            : 'No fue posible obtener el producto',
      );
    }

    final data = responseJson['data'];
    if (data is! Map<String, dynamic>) {
      throw const ApiException(
        message: 'La respuesta tiene un formato inválido',
      );
    }

    return data as ProductoResponseDto;
  }

  Future<ProductoResponseDto> unoPorSKU(String sku) async{
    final responseJson = await _apiClientAuth.getJson(
        "$_privatePath/sku/$sku"
    );

    if (responseJson['success'] != true) {
      final message = responseJson['message'];
      throw ApiException(
        message: message is String
            ? message
            : 'No fue posible obtener el producto',
      );
    }

    final data = responseJson['data'];
    if (data is! Map<String, dynamic>) {
      throw const ApiException(
        message: 'La respuesta tiene un formato inválido',
      );
    }

    return data as ProductoResponseDto;
  }

  Future<int> validarStockProducto(int id) async{
    final responseJson = await _apiClientPublic.requestJson(
        "POST",
        "$_publicPath/validar/producto/$id"
    );

    if (responseJson['success'] != true) {
      final message = responseJson['message'];
      throw ApiException(
        message: message is String
            ? message
            : 'No fue posible obtener el stock del producto',
      );
    }

    final data = responseJson['data'];
    if (data is! int) {
      throw const ApiException(
        message: 'La respuesta tiene un formato inválido',
      );
    }

    return data;
  }

  Future<List<StockLineaResponseDto>> validarStockCarrito(Carrito carrito) async{
    final responseJson = await _apiClientPublic.requestJson(
      "POST",
      "$_publicPath/validar/carrito",
      body: carrito.toJson()
    );

    if (responseJson['success'] != true) {
      final message = responseJson['message'];
      throw ApiException(
        message: message is String
            ? message
            : 'No fue posible validar el carrito',
      );
    }

    final data = responseJson['data'];
    if (data is! List) {
      throw const ApiException(
        message: 'La respuesta tiene un formato inválido',
      );
    }

    return data.map((e) => StockLineaResponseDto.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<ProductoResponseDto> crear(ProductoRequestDto request, File file) async {
    final requestBody = request.toJson();

    final responseJson = await _apiClientAuth.requestMultipart(
      "POST",
      _privatePath,
      body: requestBody,
      file: file
    );

    if (responseJson['success'] != true) {
      final message = responseJson['message'];
      throw ApiException(
        message: message is String
            ? message
            : 'No fue posible registrar el producto',
      );
    }

    final data = responseJson['data'];
    if (data is! Map<String, dynamic>) {
      throw const ApiException(
        message: 'La respuesta tiene un formato inválido',
      );
    }

    return ProductoResponseDto.fromJson(data);
  }

  Future<ProductoResponseDto> modificar(ProductoRequestDto request, File file, int id) async{
    final requestBody = request.toJson();

    final responseJson = await _apiClientAuth.requestMultipart(
      "PUT",
      "$_privatePath/$id",
      body: requestBody,
      file: file
    );

    if (responseJson['success'] != true) {
      final message = responseJson['message'];
      throw ApiException(
        message: message is String
            ? message
            : 'No fue posible modificar el producto',
      );
    }

    final data = responseJson['data'];
    if (data is! Map<String, dynamic>) {
      throw const ApiException(
        message: 'La respuesta tiene un formato inválido',
      );
    }

    return ProductoResponseDto.fromJson(data);
  }

  Future<void> cambiarEstado(int id) async{
    final res = await _apiClientAuth.requestJson(
      "PATCH",
      "$_privatePath/$id",
    );
    //TODO quitar este print cuando vea que devuelve
    debugPrint("[DELETE]: Devuelve: ${res.toString()}");
  }

  Future<void> eliminar(int id) async{
    final res = await _apiClientAuth.requestJson(
      "DELETE",
      "$_privatePath/$id",
    );
    //TODO quitar este print cuando vea que devuelve
    debugPrint("[DELETE]: Devuelve: ${res.toString()}");
  }
}