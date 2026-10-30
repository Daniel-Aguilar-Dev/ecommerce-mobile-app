import 'package:ecommerce_app/core/network/api_exception.dart';
import 'package:ecommerce_app/core/network/authenticated_api_client.dart';
import 'package:ecommerce_app/core/network/public_api_client.dart';
import 'package:ecommerce_app/features/categorias/data/models/categoria_public_response_dto.dart';
import 'package:ecommerce_app/features/categorias/data/models/categoria_request_dto.dart';
import 'package:ecommerce_app/features/categorias/data/models/categoria_response_dto.dart';
import 'package:ecommerce_app/features/categorias/domain/categoria.dart';

class CategoriaDataSource {
  CategoriaDataSource({
    required AuthenticatedApiClient apiClientAuth,
    required PublicApiClient apiClientPublic
  }) : _apiClientAuth = apiClientAuth, _apiClientPublic = apiClientPublic;

  final PublicApiClient _apiClientPublic;
  final AuthenticatedApiClient _apiClientAuth;

  static final _publicPath = "/api/v1/categorias/public";
  static final _privatePath = "/api/v1/categorias";

  Future<List<CategoriaPublicResponseDto>> todosPublic() async {
    final responseJson = await _apiClientPublic.getJson(
      _publicPath
    );

    if (responseJson['success'] != true) {
      final message = responseJson['message'];
      throw ApiException(
        message: message is String
            ? message
            : 'No fue posible obtener las categorías',
      );
    }

    final data = responseJson['data'];
    if (data is! List) {
      throw const ApiException(
        message: 'La respuesta tiene un formato inválido',
      );
    }

    return data.map((e) => CategoriaPublicResponseDto.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<CategoriaResponseDto>> todos(String? query) async{
    late final Map<String, dynamic> responseJson;
    if(query != null && query.isNotEmpty){
      responseJson = await _apiClientAuth.getJson(
          "$_privatePath/?nombre=$query"
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
            : 'No fue posible obtener las categorías',
      );
    }

    final data = responseJson['data'];
    if (data is! List) {
      throw const ApiException(
        message: 'La respuesta tiene un formato inválido',
      );
    }

    return data.map((e) => CategoriaResponseDto.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<Categoria> unaPublicaPorId(int id) async{
    final responseJson = await _apiClientPublic.getJson(
        "$_publicPath/$id"
    );

    if (responseJson['success'] != true) {
      final message = responseJson['message'];
      throw ApiException(
        message: message is String
            ? message
            : 'No fue posible obtener la categoría',
      );
    }

    final data = responseJson['data'];
    if (data is! Map<String, dynamic>) {
      throw const ApiException(
        message: 'La respuesta tiene un formato inválido',
      );
    }

    return data as Categoria;
  }

  Future<CategoriaResponseDto> unaPorId(int id) async{
    final responseJson = await _apiClientAuth.getJson(
        "$_privatePath/$id"
    );

    if (responseJson['success'] != true) {
      final message = responseJson['message'];
      throw ApiException(
        message: message is String
            ? message
            : 'No fue posible obtener la categoría',
      );
    }

    final data = responseJson['data'];
    if (data is! Map<String, dynamic>) {
      throw const ApiException(
        message: 'La respuesta tiene un formato inválido',
      );
    }

    return data as CategoriaResponseDto;
  }

  Future<CategoriaResponseDto> crear(CategoriaRequestDto request) async {
    final requestBody = request.toJson();

    final responseJson = await _apiClientAuth.postJson(
      _privatePath,
      body: requestBody,
    );

    if (responseJson['success'] != true) {
      final message = responseJson['message'];
      throw ApiException(
        message: message is String
            ? message
            : 'No fue posible registrar la categoría',
      );
    }

    final data = responseJson['data'];
    if (data is! Map<String, dynamic>) {
      throw const ApiException(
        message: 'La respuesta tiene un formato inválido',
      );
    }

    return CategoriaResponseDto.fromJson(data);
  }

  Future<CategoriaResponseDto> modificar(CategoriaRequestDto request, int id) async{
    final requestBody = request.toJson();

    final responseJson = await _apiClientAuth.requestJson(
      "PATCH",
      "$_privatePath/$id",
      body: requestBody,
    );

    if (responseJson['success'] != true) {
      final message = responseJson['message'];
      throw ApiException(
        message: message is String
            ? message
            : 'No fue posible modificar la categoría',
      );
    }

    final data = responseJson['data'];
    if (data is! Map<String, dynamic>) {
      throw const ApiException(
        message: 'La respuesta tiene un formato inválido',
      );
    }

    return CategoriaResponseDto.fromJson(data);
  }

  Future<void> eliminar(int id) async{
    await _apiClientAuth.requestJson(
      "DELETE",
      "$_privatePath/$id",
    );
  }
}