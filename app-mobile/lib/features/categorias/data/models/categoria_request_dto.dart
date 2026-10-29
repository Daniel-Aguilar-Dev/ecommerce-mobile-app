class CategoriaRequestDto {
  const CategoriaRequestDto({ required this.nombre, required this.descripcion });

  final String nombre;
  final String descripcion;

  Map<String, dynamic> toJsonCreate() {
    return {'nombre': nombre, 'descripcion': descripcion};
  }
}