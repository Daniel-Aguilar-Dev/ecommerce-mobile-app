class CategoriaResponseDto {
  const CategoriaResponseDto({
    required this.nombre,
    required this.descripcion,
    required this.tieneProductos,
    required this.id
  });

  final String nombre;
  final int id;
  final String descripcion;
  final bool tieneProductos;

  factory CategoriaResponseDto.fromJson(Map<String, dynamic> json) {
    return CategoriaResponseDto(
      nombre: json['nombre'] as String,
      descripcion: json['descripcion'] as String,
      id: json['id'] as int,
      tieneProductos: json['tieneProductos'] as bool
    );
  }
}