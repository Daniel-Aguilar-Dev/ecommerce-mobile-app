import 'package:ecommerce_app/features/categorias/domain/categoria.dart';
import 'package:ecommerce_app/features/categorias/domain/categoria_public.dart';

abstract class CategoriaRepository {
  Future<List<CategoriaPublic>> listaPublica();

  Future<List<Categoria>> listaPersonal(String? query);

  Future<CategoriaPublic> unaPublicaPorId(int id);

  Future<Categoria> unaPorId(int id);

  Future<Categoria> crear({
    required String nombre,
    required String descripcion
  });

  Future<Categoria> modificar({
    required int id,
    required String nombre,
    required String descripcion
  });

  Future<void> eliminar(int id);
}