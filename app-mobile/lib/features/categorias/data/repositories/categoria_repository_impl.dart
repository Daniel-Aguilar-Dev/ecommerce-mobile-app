import 'package:ecommerce_app/features/categorias/data/categoria_data_source.dart';
import 'package:ecommerce_app/features/categorias/data/models/categoria_request_dto.dart';
import 'package:ecommerce_app/features/categorias/domain/categoria.dart';
import 'package:ecommerce_app/features/categorias/domain/categoria_public.dart';
import 'package:ecommerce_app/features/categorias/domain/categoria_repository.dart';

class CategoriaRepositoryImpl implements CategoriaRepository {
  const CategoriaRepositoryImpl({
    required CategoriaDataSource datasource
  }) : _categoriaDataSource = datasource;

  final CategoriaDataSource _categoriaDataSource;

  @override
  Future<Categoria> crear({required String nombre, required String descripcion}) async{
    final dto = CategoriaRequestDto(nombre: nombre, descripcion: descripcion);
    final response = await  _categoriaDataSource.crear(dto);
    return Categoria(
        id: response.id,
        nombre: response.nombre,
        descripcion:
        response.descripcion,
        tieneProductos: response.tieneProductos
    );
  }

  @override
  Future<void> eliminar(int id) async {
    return _categoriaDataSource.eliminar(id);
  }

  @override
  Future<List<Categoria>> listaPersonal(String? query) async{
    final response = await _categoriaDataSource.todos(query);
    late final List<Categoria> list = [];
    for (final c in response){
      list.add(Categoria(id: c.id, nombre: c.nombre, descripcion: c.descripcion, tieneProductos: c.tieneProductos));
    }
    return  list;
  }

  @override
  Future<List<CategoriaPublic>> listaPublica() async{
    final response = await _categoriaDataSource.todosPublic();
    late final List<CategoriaPublic> list = [];
    for (final c in response){
      list.add(CategoriaPublic(id: c.id, nombre: c.nombre, descripcion: c.descripcion));
    }
    return  list;
  }

  @override
  Future<Categoria> modificar({required int id, required String nombre, required String descripcion}) async{
    final dto = CategoriaRequestDto(nombre: nombre, descripcion: descripcion);
    final response = await _categoriaDataSource.modificar(dto, id);
    return Categoria(
        id: response.id,
        nombre: response.nombre,
        descripcion:
        response.descripcion,
        tieneProductos: response.tieneProductos
    );
  }

  @override
  Future<Categoria> unaPorId(int id) async{
    final response = await  _categoriaDataSource.unaPorId(id);
    return Categoria(
        id: response.id,
        nombre: response.nombre,
        descripcion:
        response.descripcion,
        tieneProductos: response.tieneProductos
    );
  }

  @override
  Future<CategoriaPublic> unaPublicaPorId(int id) async{
    final response = await  _categoriaDataSource.unaPublicaPorId(id);
    return CategoriaPublic(
        id: response.id,
        nombre: response.nombre,
        descripcion:
        response.descripcion,
    );
  }
}