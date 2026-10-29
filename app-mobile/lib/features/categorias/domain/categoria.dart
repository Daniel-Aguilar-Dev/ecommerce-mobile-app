import 'package:ecommerce_app/core/audit/auditable_entity.dart';

class Categoria extends AuditableEntity{
  const Categoria({
    required super.createdAt, required super.updatedAt, required super.createdBy, required super.updatedBy,
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.tieneProductos
  });

  final int id;
  final String nombre;
  final String descripcion;
  final bool tieneProductos;
}