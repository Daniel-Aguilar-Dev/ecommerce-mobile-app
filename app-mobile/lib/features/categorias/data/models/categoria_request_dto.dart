class CategoriaRequestDto {
  const CategoriaRequestDto({ required this.nombre, required this.descripcion });

  final String nombre;
  final String descripcion;

  Map<String, dynamic> toJson() {
    return {'nombre': nombre, 'descripcion': descripcion};
  }
}